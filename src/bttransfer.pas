unit bttransfer;

interface
uses BTTrackerAnnounce, TorrentFile, OverByteIcsWSocket, hashedstorage;

const
  aWsState: array[TSocketState] of string = (
        'invalid',   'opened',    'bound',     'connecting',
        'socks connected', 'connected', 'accepting', 'listening', 'closed');

type
  TBTPeer = class(TObject)
  private
    _Peerid:String;
    _IP:String;
    _Port:Word;
    _ID:Integer;
    _BitField:TBitfield;

    WrPtr: integer;
    RdPtr: integer;
    Buffer: PChar;
    BufferSize: integer;
  public
    Socket: TWSocket;
    Active: Boolean;
    Handshake:Boolean;
    NumHave:Integer;
    LastMsg:String;

    Transfer: TObject;

    constructor Create(Parent:TObject; IP, Peerid:string; Port:Word; ID:Integer);
    destructor Destroy;

    procedure SessionConnected(Sender: TObject; Error: Word);
    procedure DataAvailable(Sender: TObject; Error: Word);
    procedure ChangeState(Sender: TObject; OldState, NewState: TSocketState);

    procedure Log(Msg:String);
    procedure AbortError(Msg:string);

  end;
  PBTPeer = ^TBTPeer;

  TBTTransfer = class(TObject)
  private
    _Peerid:string;
  public
    torrentfile: TTorrentFile;
    announce: TTrackerAnnounce;
    storage: THashedStorage;
    Peers:array of TBTPeer;
    NumPeers:Integer;
    LocalName:String;

    property Peerid: String read _Peerid;

    constructor Create(Peerid:string);
    destructor Destroy;

    procedure Log(Level:Integer; Msg:String); virtual; abstract;
    procedure StatusChange(ID:Integer); virtual; abstract;

    procedure LaunchPeerThread(Peer:TTrackerPeer);
    function LoadTorrent(FileName:String):Boolean;
    //TODO: function QueryTracker(event:string):Boolean;
  end;

implementation
uses Classes, SysUtils, BDecode, Math;

function FillField(s:string; var f:TBitField):Integer;
var i,k:integer;
    tmp:TBitField;
begin
k:=0;
setlength(tmp,length(s)*8);

for i:=0 to length(s)-1 do
begin
  tmp[8*i+7]:=(ord(s[i+1]) and 1)=1;
  tmp[8*i+6]:=(ord(s[i+1]) and 2)=2;
  tmp[8*i+5]:=(ord(s[i+1]) and 4)=4;
  tmp[8*i+4]:=(ord(s[i+1]) and 8)=8;
  tmp[8*i+3]:=(ord(s[i+1]) and 16)=16;
  tmp[8*i+2]:=(ord(s[i+1]) and 32)=32;
  tmp[8*i+1]:=(ord(s[i+1]) and 64)=64;
  tmp[8*i]:=(ord(s[i+1]) and 128)=128;
end;

SetLength(tmp,length(f));
f:=tmp;

for i:=0 to length(f) do if f[i] then inc(k);
FillField:=k;
end;

function FieldToBin(f:TBitfield; num:integer):string;
var s:string;
    c:byte;
    i:integer;

begin
  c:=0;
  if (num mod 8) > 1 then setlength(s,(num div 8)+1) else setlength(s, num div 8);

  for i:=0 to num-1 do
  begin
    if (i<>0) and ((i mod 8)=0) then
    begin
     s[i div 8]:=chr(c);
     c:=0;
    end;
    if f[i] then inc(c,1 shl (7-(i mod 8)) );
  end;

  if ((num-1) mod 8)<>0 then s[((num-1) div 8)+1]:=chr(c);

  FieldToBin:=s;
end;

constructor TBTPeer.Create(Parent:TObject; IP, Peerid:string; Port:Word; ID:Integer);
begin
  inherited Create();

  Transfer:=Parent;

  _Peerid:=Peerid;
  _IP:=IP;
  _Port:=Port;
  _ID:=ID;
  NumHave:=0;
  SetLength(_BitField,high((Transfer as TBTTransfer).torrentfile.pieces)+1);
  
  Log('Peer Created: '+IP+':'+IntToStr(Port));
  Active:= True;

  Socket:=TWSocket.Create(nil);
  Socket.Port := IntToStr(_Port);
  Socket.Addr := _IP;
  Socket.Proto := 'tcp';
  Socket.MultiThreaded := False;
  Socket.OnSessionConnected := SessionConnected;
  Socket.OnDataAvailable := DataAvailable;
  Socket.OnChangeState := ChangeState;
  Socket.LineMode := False;
  Socket.Connect;
end;

destructor TBTPeer.Destroy;
begin
  Socket.Destroy;

  inherited Destroy();
end;

procedure TBTPeer.Log(Msg:String);
begin
   LastMsg:=Msg;
  (Transfer as TBTTransfer).Log(2,IntToStr(_ID)+': '+Msg);
end;

procedure TBTPeer.AbortError(Msg:String);
begin
  Log('ABORTING: ' + Msg);
  Socket.CloseDelayed;
  (Transfer as TBTTransfer).StatusChange(_ID);  
end;

procedure TBTPeer.SessionConnected(Sender: TObject; Error: Word);
var s:string;
begin
  if Error <> 0 then begin
      AbortError('Winsock error: ' + IntToStr(Error));
      Exit;
  end;


  s:=#19'BitTorrent protocol'#0#0#0#0#0#0#0#0+(Transfer as TBTTransfer).torrentfile.HashBin+(Transfer as TBTTransfer).PeerId;

  (Sender as TWSocket).SendStr(s);
  (Sender as TWSocket).Flush;
  Log('Session Connected, Sending Handshake.' + IntToStr(Length(s)));

  RdPtr := 0;
  WrPtr := 0;
  if BufferSize = 0 then begin
     BufferSize := 16384;
     ReAllocMem(Buffer, BufferSize);
  end;
end;

procedure TBTPeer.ChangeState(Sender: TObject; OldState, NewState: TSocketState);
begin
  Log('New State: ' + aWsState[NewState]);

  if NewState = wsClosed then Active:=False;
end;

procedure TBTPeer.DataAvailable(Sender: TObject; Error: Word);
var Count:Integer;
    s,s2:string;
    p:PChar;
    li, li2:^longint;


function EndianLong(L : longint) : longint;
begin
  result := swap(L shr 16) or
           (longint(swap(L and $ffff)) shl 16);
end;

begin
  if Error <> 0 then begin
      AbortError('Winsock error: ' + IntToStr(Error));
      Exit;
  end;

  Log('Data available!');

   try
      if BufferSize - WrPtr <= 8192 then begin
         BufferSize := BufferSize * 2;
         ReAllocMem(Buffer, BufferSize);
      end;

      with Sender as TWSocket do
         Count := Receive(@Buffer[WrPtr], BufferSize - WrPtr);
      if Count <= 0 then
         Exit;

      Log('Read: '+IntToStr(Count));
      Inc(WrPtr, Count);

      // handshake handler
      if (not Handshake) then
        if WrPtr >= 20 then
        begin
          setlength(s,20);
          p:=@Buffer[0];
          move(p^,s[1],20);

          if s=#19'BitTorrent protocol' then
          begin
            RdPtr:=28; //skip 8 reserved bytes
            Log('Handshake Valid.');

            p:=@Buffer[RdPtr];
            move(p^,s[1],20);
            if s=(Transfer as TBTTransfer).torrentfile.HashBin then
              Log('Remote Filehash matches local!')
            else
            begin
              AbortError('Invalid remote filehash: '+bin2hex(s)); Exit;
            end;
            inc(RdPtr,20);

            p:=@Buffer[RdPtr];
            move(p^,s[1],20);
            if s=_peerid then
            begin
              Log('Remote Peer Id matches expected!');
              HandShake:=True;
              Log('Handshake completed!');
            end
            else
            begin
              AbortError('Invalid Peerid: '+bin2hex(s)); Exit;
            end;

            inc(RdPtr,20);

          end
          else
          begin
            AbortError('Handshake Malformed: '+s); Exit;
          end;
        end;

      if (HandShake) then
        while (RdPtr+4) <= WrPtr do
         begin
           li:=@Buffer[RdPtr];
           li^:=endianlong(li^);
           
           Log('Packet Length: '+inttostr(li^));
           
           if li^ = 0 then
           begin
             Log('Got Keep-Alive');
             (Transfer as TBTTransfer).StatusChange(_ID);
             Inc(RdPtr,4);
           end
           else
           if (RdPtr+4+li^) <= WrPtr then
           begin
             p:=@Buffer[RdPtr+4];
             setlength(s,1);
             move(p^,s[1],1);
             Log('Got Message Type: '+inttostr(ord(s[1])));
             
             case ord(s[1]) of
              4: // have
               begin
                 li2:=@Buffer[RdPtr+5];
                 li2^:=endianlong(li2^);
                 inc(numhave);
                 Log('Got have: '+IntToStr(li2^));

                 if (not _Bitfield[li2^]) then _Bitfield[li2^]:=true else Log('Already got? '+IntToStr(li2^));

                 (Transfer as TBTTransfer).StatusChange(_ID);
               end;
              5: // got bitfield
               begin
                 setlength(s,li^-1);
                 p:=@Buffer[RdPtr+5];
                 move(p^,s[1],li^-1);
                 numhave:=fillfield(s,_Bitfield);
                 Log('Got bitfield: '+IntToStr(numhave));

                 (Transfer as TBTTransfer).StatusChange(_ID);
                 //AbortError('Done!');
               end;
              else
              begin
                 Log('Unknown: '+IntToStr(ord(s[1])));
              end;
             end;
             Inc(RdPtr,4+li^);
           end;
         end;

      if RdPtr = WrPtr then begin
         RdPtr := 0;
         WrPtr := 0;
      end;

   except
      on E: Exception do
         (Transfer as TBTTransfer).Log(0,E.Message);
   end;
end;

constructor TBTTransfer.Create(Peerid:string);
begin
  _peerid:=peerid;
  LocalName:='';
  NumPeers:=0;
  torrentfile:=TTorrentFile.Create;
  announce:=TTrackerAnnounce.Create;

  SetLength(peers,0);
  inherited Create();
end;

destructor TBTTransfer.Destroy;
var i:integer;
begin
  FreeAndNil(torrentfile);
  FreeAndNil(announce);
  for i:=0 to high(peers) do freeandnil(peers[i]);
  
  inherited Destroy();
end;

function TBTTransfer.LoadTorrent(FileName:String):Boolean;
var f:TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead);
  
  try
    if torrentfile.Load(f) then
    begin
      LoadTorrent:=True;
      LocalName:=torrentfile.Name;
    end
    else
      LoadTorrent:=False;
  finally
    FreeAndNil(f);
  end;
end;

procedure TBTTransfer.LaunchPeerThread(Peer:TTrackerPeer);
begin
  inc(NumPeers);
  setlength(peers,numpeers);
  peers[numpeers-1]:=TBTPeer.Create(self,peer.IP,peer.Peerid, peer.Port, numpeers);
end;

end.
