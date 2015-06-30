unit BTTrackerAnnounce;

interface

uses
  SysUtils, Contnrs, Hashes, Classes, BDecode, MessageDigests;

type
  TTrackerPeer = class(TObject)
  private
    _Peerid: String;
    _Ip: String;
    _Port: Word;
  public
    property Peerid: String read _Peerid;
    property Port: Word read _Port;
    property IP: String read _Ip;
    constructor Create(Peerid, IP: String; Port: Word);
  end;

  TTrackerAnnounce = class(TObject)
  private
    _Err: TStringList;
    _Peers: TObjectHash;
    _Tree: TObjectHash;
    _Interval: Integer;
  public
    property Errors: TStringList read _Err;
    property Peers: TObjectHash read _Peers;
    property Tree: TObjectHash read _Tree;
    property Interval: Integer read _Interval;
    constructor Create();
    destructor Destroy(); override;
    function Load(Stream: TStream): Boolean;
  end;

implementation

{ TTrackerPeer }

constructor TTrackerPeer.Create(Peerid, IP: String; Port: Word);
begin
  _Peerid := Peerid;
  _Port := Port;
  _IP := Ip;
  inherited Create();
end;

{ TTrackerAnnounce }

constructor TTrackerAnnounce.Create();
begin
  _Err := TStringList.Create();
  _Peers := TObjectHash.Create();
  inherited Create();
end;

destructor TTrackerAnnounce.Destroy();
begin
  FreeAndNil(_Err);
  FreeAndNil(_Peers);
  inherited Destroy();
end;

function TTrackerAnnounce.Load(Stream: TStream): Boolean;
var
  r: Boolean;
  o: TObject;
  info: TObjectHash;
  f: TObjectList;
  h, k, n: String;
  c, i, j: Integer;
begin
  r := False;
  _Peers.Clear();
  FreeAndNil(_Tree);
  try
    try
      o := bdecodeStream(Stream);
      if (o <> nil) then begin
        if(o is TObjectHash) then begin
          _Tree := o as TObjectHash;
          if(_Tree.Exists('peers')) then begin
            if(_Tree['peers'] is TObjectList) then begin
              f := _Tree['peers'] as TObjectList;
              _Interval := (_Tree['interval'] as TIntString).IntPart;

              for j:=0 to f.Count - 1 do
              begin
                if(f.Items[j] is TObjectHash) then begin
                  info := f.Items[j] as TObjectHash;
                  h := {bin2Hex(}(info['peer id'] as TIntString).StringPart{)};
                  i := (info['port'] as TIntString).IntPart;
                  n := (info['ip'] as TIntString).StringPart;
                  _Peers.Items[h] := TTrackerPeer.Create(h,n,i);
                end else begin
                  _Err.Add('Invalid Tracker Response; info for all peers should be a dictionary');
                end;
              end;
              r := True;
            end else begin
              _Err.Add('Invalid Tracker Response; "peers" segment is not a list?');
            end;
          end else begin
            if _Tree.Exists('failure reason') then
              _Err.Add('Tracker Error: '+(_Tree['failure reason'] as TIntString).StringPart)
            else
             _Err.Add('Invalid Tracker Response; missing "peers" segment');
          end;
        end else begin
          _Err.Add('Invalid Tracker Response; metainfo is malformed (not a dictionary)');
        end;
      end else begin
        _Err.Add('Invalid Tracker Response; not bencoded metainfo');
      end;
    finally
      if(not r) then FreeAndNil(o);
    end;
  except
    _Err.Add('Error while trying to parse the Tracker state');
  end;
  Result := r;
end;

end.
