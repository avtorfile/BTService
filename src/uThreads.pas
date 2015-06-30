unit uThreads;

interface

Uses
  Windows, Classes, SysUtils, uTransferInfo, btcore, thread_bittorrent, helper_datetime,
  vars_global, helper_strings, helper_unicode, dialogs, uExtraData;

Type
  TTrackersThread = class(TThread)
public
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean; P: Pointer);
private
    InfoTrackers: TInfoTrackers;
end;

Type
  TPiecesThread = class(TThread)
public
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean; P: Pointer);
private
    InfoPieces: TInfoPieces;
end;

Type
  TFilesThread = class(TThread)
public
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean; P: Pointer);
private
    InfoFiles: TInfoFiles;
end;

Type
  TPeersThread = class(TThread)
public
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean; P: Pointer);
private
    InfoPeers: TInfoPeers;
end;

implementation

////////////////////////////////////////////////////////////////////////////////

constructor TTrackersThread.Create(CreateSuspended: Boolean; P: Pointer);
begin
  InfoTrackers := P;
  inherited Create(CreateSuspended);
  InfoTrackers.Status := stStart;
  if Handle <> 0 then
  InfoTrackers.ThreadHandle := Handle;
end;

procedure TTrackersThread.Execute;
var i,k:Integer;
tran:TBitTorrentTransfer;
ftracker:TBitTorrentTracker;
DelimitedStr:string;
TorrentInfo:WideString;
DHTTick:Cardinal;
Next_Poll:Cardinal;
visualStr:string;
Now_Time:Cardinal;
begin
FreeOnTerminate := false;
InfoTrackers.Status := stProcess;

EnterCriticalSection(TrackerCriticalSection);
try
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(InfoTrackers.Hash) then
  begin
    Now_Time := time_now;
    if MIN2S(15)>(Now_Time-tran.m_lastudpsearch) then
    begin
      DHTTick := MIN2S(15)-(Now_Time-tran.m_lastudpsearch);
      Next_Poll := Now_Time+DHTTick;      
      visualStr := 'Working';
    end
    else
    begin
      DHTTick := 0;
      Next_Poll := Now_Time;
      visualStr := 'Connecting [DHT]';
    end;

    DelimitedStr:='|'+('')+
        '| |'+('[DHT]')+
        '| |'+('')+
        '| |'+('')+
        '| |'+('')+
        '| |'+('')+
        '| |'+('')+
        '| |'+(visualStr)+
        '| |'+inttostr(integer(0))+
        '| |'+''+
        '| |'+inttostr(tran.NumConnectedSeedersDHT)+
        '| |'+inttostr(tran.NumConnectedLeechersDHT)+
        '| |'+inttostr(DHTTick)+
        '| |'+inttostr(Next_Poll)+
        //'| |'+(ftracker.socket.)+
        '|';

      {if tran.trackers.count>0 then
      TorrentInfo:= TorrentInfo+'^'+(DelimitedStr)+'^ '
      else}
      TorrentInfo:= '^'+(DelimitedStr)+'^ ';

    for k:=0 to tran.trackers.count-1 do
    begin
      ftracker:=tran.trackers[k];
      DelimitedStr:='|'+(ftracker.host)+
        '| |'+(ftracker.URL)+
        '| |'+(ftracker.TrackerID)+
        '| |'+(ftracker.CurrTrackerEvent)+
        '| |'+(ftracker.BufferReceive)+
        '| |'+(ftracker.WarningMessage)+
        '| |'+(ftracker.FError)+
        '| |'+(ftracker.visualStr)+
        '| |'+inttostr(integer(tbittorrenttrackerStatus(ftracker.Status)))+
        '| |'+inttostr(ftracker.Interval)+
        '| |'+inttostr(ftracker.Seeders)+
        '| |'+inttostr(ftracker.Leechers)+
        '| |'+inttostr(ftracker.tick)+
        '| |'+inttostr(ftracker.Next_Poll)+
        //'| |'+(ftracker.socket.)+
        '|';
      {if k=0 then
      TorrentInfo:= '^'+(DelimitedStr)+'^ '
      else}
      TorrentInfo:= TorrentInfo+'^'+(DelimitedStr)+'^ '
    end;

    
      

    Break;
  end;
end;
finally
  LeaveCriticalSection(TrackerCriticalSection);
end;
CompleteTrackersInContainer(InfoTrackers.Hash,TorrentInfo);
end;

////////////////////////////////////////////////////////////////////////////////

constructor TPiecesThread.Create(CreateSuspended: Boolean; P: Pointer);
begin
  InfoPieces := P;
  inherited Create(CreateSuspended);
  InfoPieces.Status := spcStart;
  if Handle <> 0 then
  InfoPieces.ThreadHandle := Handle;
end;

procedure TPiecesThread.Execute;
var i,k:Integer;
tran:TBitTorrentTransfer;
//ffile:TBitTorrentFile;
fpiece:TBitTorrentChunk;
DelimitedStr:string;
PiecesInfo:WideString;
begin
FreeOnTerminate := false;
InfoPieces.Status := spcProcess;

EnterCriticalSection(TrackerCriticalSection);
try
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(InfoPieces.Hash) then
  begin
    for k:=0 to high(tran.fpieces) do //for k:=0 to tran.fpieces.count-1 do           
    begin
      fpiece:=tran.fpieces[k];
      DelimitedStr:='|'+IntToStr(fpiece.foffSet)+
        '| |'+IntToStr(fpiece.fsize)+
        '| |'+IntToStr(fpiece.findex)+
        '| |'+IntToStr(fpiece.fprogress)+'|';
      if k=0 then
      PiecesInfo:= '^'+DelimitedStr+'^ '
      else PiecesInfo:= PiecesInfo+'^'+DelimitedStr+'^ ';
    end;
    Break;  
  end;
end;
finally
  LeaveCriticalSection(TrackerCriticalSection);
end;
CompletePiecesInContainer(InfoPieces.Hash,PiecesInfo);
end;

////////////////////////////////////////////////////////////////////////////////

constructor TFilesThread.Create(CreateSuspended: Boolean; P: Pointer);
begin
  InfoFiles := P;
  inherited Create(CreateSuspended);
  InfoFiles.Status := sfStart;
  if Handle <> 0 then
  InfoFiles.ThreadHandle := Handle;
end;

procedure TFilesThread.Execute;
var i,k:Integer;
tran:TBitTorrentTransfer;
ffile:TBitTorrentFile;
DelimitedStr:string;
TorrentInfo:WideString;
begin
FreeOnTerminate := false;
InfoFiles.Status := sfProcess;

EnterCriticalSection(TrackerCriticalSection);
try
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(InfoFiles.Hash) then
  begin
    for k:=0 to tran.ffiles.count-1 do
    begin
      ffile:=tran.ffiles[k];
      DelimitedStr:='|'+(ffile.ffilename)+
        '| |'+IntToStr(ffile.fsize)+
        '| |'+IntToStr(ffile.fprogress)+
        '| |'+IntToStr(ffile.foffset)+'|';
      //InfoSL.Insert(k,DelimitedFile);
      if k=0 then
      TorrentInfo:= '^'+(DelimitedStr)+'^ '
      else TorrentInfo:= TorrentInfo+'^'+(DelimitedStr)+'^ '
    end;
    Break;
  end;
end;
finally
  LeaveCriticalSection(TrackerCriticalSection);
end;
CompleteFilesInContainer(InfoFiles.Hash,TorrentInfo);
end;

////////////////////////////////////////////////////////////////////////////////

constructor TPeersThread.Create(CreateSuspended: Boolean; P: Pointer);
begin
  InfoPeers := P;
  inherited Create(CreateSuspended);
  InfoPeers.Status := spStart;
  if Handle <> 0 then
  InfoPeers.ThreadHandle := Handle;
end;

procedure TPeersThread.Execute;
var i,k:Integer;
tran:TBitTorrentTransfer;
//InfoSL:TStringList;
DelimitedStr:string;
PeersInfo:WideString;
source:TBitTorrentSource;
ID:string;
status:string;
Client:string;
begin
FreeOnTerminate := false;
InfoPeers.Status:=spProcess;

EnterCriticalSection(TrackerCriticalSection);
try
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(InfoPeers.Hash) then
  begin       
    for k:=0 to tran.fsources.count-1 do
    begin
      source:=tran.fsources[k];

      if source.status = btSourceIdle then
      status:='0' else
      if source.status = btSourceConnecting then
      status:='1' else
      if source.status = btSourceReceivingHandshake then
      status:='2' else
      if source.status = btSourceweMustSendHandshake then
      status:='3' else
      if source.status = btSourceShouldDisconnect then
      status:='4' else
      if source.status = btSourceShouldRemove then
      status:='5' else
      if source.status = btSourceConnected then
      status:='6';

      ID:=StringReplace(source.ID,'|', '',[rfReplaceAll, rfIgnoreCase]);
      ID:=StringReplace(ID,'^', '',[rfReplaceAll, rfIgnoreCase]);
      //DelimitedFile:='|'+ID+
      Client:=StringReplace(source.Client,'|', '',[rfReplaceAll, rfIgnoreCase]);
      Client:=StringReplace(Client,'^', '',[rfReplaceAll, rfIgnoreCase]);

      if trim(source.Client) <> '' then
      begin
       DelimitedStr:='|'+status+
        '| |'+(source.ipS)+
        '| |'+(Client)+
        '| |'+IntToStr(source.progress)+
        '| |'+IntToStr(source.recv)+
        '| |'+IntToStr(source.sent)+
        '| |'+IntToStr(source.speed_recv)+
        '| |'+IntToStr(source.speed_send)+
        '| |'+IntToStr(source.port)+
        '|';

       if k=0 then
       PeersInfo:= '^'+(DelimitedStr)+'^ '
       else PeersInfo:= PeersInfo+'^'+(DelimitedStr)+'^ '
      end;
    end;
    Break;
  end;
end;
finally
  LeaveCriticalSection(TrackerCriticalSection);//LeaveCriticalSection(ServiceSection);
end;
CompletePeersInContainer(InfoPeers.Hash,PeersInfo);
end;

end.
