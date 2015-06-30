unit TorrentFile;

interface

uses
  SysUtils, StrUtils, Contnrs, Hashes, Classes, BDecode, MessageDigests, Windows, TorrentParser;

type
  TBitfield = array of boolean;
  TTorrentPiece = class(TObject)
  private
    _Hash: String;
    _HashBin: String;
    _Valid: Boolean;
  public
    property Hash: String read _Hash;
    property HashBin: String read _HashBin;
    property Valid: Boolean read _Valid write _Valid;
    constructor Create(Hash: String; HashBin:String; Valid: Boolean);
  end;
  {TTorrentSubFile = class(TObject)
  private
    _Name: String;
    _Path: String;
    _Filename: String;
    _Length: Int64;
    _Offset: Int64;
    _Left: Int64;
  public
    property Name: String read _Name write _Name;
    property Path: String read _Path write _Path;
    property Length: Int64 read _Length;
    property Offset: Int64 read _Offset;
    property Left: Int64 read _Left write _Left;
    property Filename: String read _Filename write _Filename;
    constructor Create(Name: String; Path: String; Length: Int64; Offset: Int64);
  end;}
  TTorrentFile = class(TObject)
  published
  private
    _Announce : String;
    _Name : String;
    _Comment : String;
    _Length : Int64;
    _Date : TDateTime;
    _Count : Integer;
    _Err : TStringList;
    _Tree : TObjectHash;
    _SHA1Hash : String;
    _HashBin : String;
    _Multifile : Boolean;
    _PrivateTorrent: Boolean;
    _Advertisement : String;
    _Releaser : String;
    _SiteReleaser : String;
    _Files : TObjectList;
  public
    Pieces : array of TTorrentPiece;
    PieceLength : Integer;
    BackupTrackers : TStringList;

    property Announce: String read _Announce write _Announce;
    property Name: String read _Name write _Name;
    property Date: TDateTime read _Date write _Date;
    property Length: Int64 read _Length;
    property Count: Integer read _Count;
    property Tree: TObjectHash read _Tree;
    property Errors: TStringList read _Err;
    property Hash: String read _SHA1Hash;
    property Comment: String read _Comment write _Comment;
    property HashBin: String read _HashBin;
    property Multifile: Boolean read _Multifile;
    property PrivateTorrent: Boolean read _PrivateTorrent;
    property Advertisement: String read _Advertisement;
    property Releaser: String read _Releaser;
    property SiteReleaser: String read _SiteReleaser;
    property Files: TObjectList read _Files write _Files;
    procedure Clear();
    function Load(Stream: TStream): Boolean;
    procedure Save(Stream: TStream; Pieces : array of TTorrentPiece);
    procedure Init(Announce, Name, Comment, HashBin:String; Length:Int64;
      Multifile:Boolean; PrivateTorrent:Boolean; Advertisement:String; Releaser:String; SiteReleaser:String);
    constructor Create();
    destructor Destroy(); override;
  end;

function DateTimeToUnixTime(const DateTime: TDateTime): Integer;
function UnixTimeToDateTime(const UnixTime: Integer): TDateTime;

implementation

const
  hdrUTF8  : String = #$EF#$BB;
  hdrUTF8W : String = #$BF;
  hdrUTF16 : String = #$FF#$FE;
  hdrUTF32 : String = #$FE#$FF;

function DateTimeToUnixTime(const DateTime: TDateTime): Integer;

var
 FileTime: TFileTime;
 SystemTime: TSystemTime;
 I: Int64;

begin
 // first convert datetime to Win32 file time
 DateTimeToSystemTime(DateTime, SystemTime);
 SystemTimeToFileTime(SystemTime, FileTime);

 // simple maths to go from Win32 time to Unix time
 I := Int64(FileTime.dwHighDateTime) shl 32 + FileTime.dwLowDateTime;
 Result := (I - 116444736000000000) div Int64(10000000);
end;

function UnixTimeToDateTime(const UnixTime: Integer): TDateTime;

var 
  FileTime: TFileTime; 
  SystemTime: TSystemTime; 
  I: Int64; 
   
begin 
  // first convert unix time to a Win32 file time 
  I := Int64(UnixTime) * Int64(10000000) + 116444736000000000; 
  FileTime.dwLowDateTime := DWORD(I); 
  FileTime.dwHighDateTime := I shr 32; 

  // now convert to system time 
  FileTimeToSystemTime(FileTime, SystemTime); 

  // and finally convert the system time to TDateTime 
  Result := SystemTimeToDateTime(SystemTime); 
end;

{ TTorrentSubFile }

{constructor TTorrentSubFile.Create(Name, Path: String; Length: Int64; Offset: Int64);
begin
  _Name := Name;
  _Path := Path;
  _Length := Length;
  _Offset := Offset;
  _Left := Length;
  
  inherited Create();
end;}

{ TTorrentFile }

procedure TTorrentFile.Clear();
var
  i : Integer;
begin
  _Announce := '';
  _Name := '';
  _SHA1Hash := '';
  _Length := 0;
  _Count := 0;
  _Files.Clear();
  _Tree.Clear();
  _Err.Clear();
  for i := Low(Pieces) to High(Pieces) do FreeAndNil(Pieces[i]);
  SetLength(Pieces,0);
  _Multifile := False;
end;

constructor TTorrentFile.Create();
begin
  _Files := TObjectList.Create();
  _Tree := TObjectHash.Create();
  _Err := TStringList.Create();
  BackupTrackers := TStringList.Create;
  inherited Create();
end;

destructor TTorrentFile.Destroy();
begin
  Clear();
  FreeAndNil(_Files);
  FreeAndNil(_Tree);
  FreeAndNil(_Err);
  FreeAndNil(BackupTrackers);
  inherited;
end;

procedure TTorrentFile.Init(Announce, Name, Comment, HashBin:String; Length:Int64;
 Multifile:Boolean; PrivateTorrent:Boolean; Advertisement:String; Releaser:String; SiteReleaser:String);
begin
  _Announce := Announce;
  _Name := Name;
  _Comment := Comment;
  _HashBin := HashBin;
  _Length := Length;
  _Multifile := Multifile;
  _PrivateTorrent := PrivateTorrent;
  _Advertisement := Advertisement;
  _Releaser := Releaser;
  _SiteReleaser := SiteReleaser;     
  _Date := Now;
end;

function TTorrentFile.Load(Stream: TStream): Boolean;
var
  info, thisfile: TObjectHash;
  files, path, backup, backup2: TObjectList;
  fp, fn: String;
  i, j, pcount: Integer;
  sz, fs, fo: Int64;
  sha: TSHA1;
  r: Boolean;
  o: TObject;
  p: pointer;
  s:string;
  
begin
  Clear();
  r := False;
  sz := 0;
  try
    try
      sha := TSHA1.Create();

      o := bdecodeStream(Stream);
      if(Assigned(o)) then begin
        _Tree := o as TObjectHash;
        if(_Tree.Exists('announce')) then begin
          _Announce := (_Tree['announce'] as TIntString).StringPart;
        end else begin
          _Err.Add('Corrupt File: Missing "announce" segment');
        end;
        if(_Tree.Exists('announce-list')) then begin
           backup := _Tree['announce-list'] as TObjectList;
           for i := 0 to backup.Count - 1 do begin
                backup2 := (backup[i] as TObjectList);
                for j:=0 to backup2.Count -1 do BackupTrackers.Add((backup2[j] as TIntString).StringPart);
           end;
        end;
        if(_Tree.Exists('comment')) then begin
          _Comment := (_Tree['comment'] as TIntString).StringPart;
        end;
        if(_Tree.Exists('creation date')) then begin
          _Date := UnixTimeToDateTime((_Tree['creation date'] as TIntString).IntPart);
        end;
        if(_Tree.Exists('info')) then begin
          info := _Tree['info'] as TObjectHash;
          if(info.Exists('name')) then begin
            _Name := (info['name'] as TIntString).StringPart;
            if copy(_Name,system.length(_Name)-7,8)='.torrent' then
              _Name:=copy(_Name,0,system.length(_Name)-8);
          end else begin
            _Err.Add('Corrupt File: Missing "info.name" segment');
          end;
          if(info.Exists('piece length')) then begin
            PieceLength := (info['piece length'] as TIntString).IntPart;
          end else begin
            _Err.Add('Corrupt File: Missing "info.piece length" segment');
          end;
          if(info.Exists('pieces')) then begin
            fp := (info['pieces'] as TIntString).StringPart;
            pcount := System.Length(fp) div 20;
            SetLength(Pieces,pcount);
            for i := 0 to pcount - 1 do begin
              s:=copy(fp,(i * 20) + 1,20);
              Pieces[i] := TTorrentPiece.Create(bin2hex(s), s, False);
            end;
          end else begin
            _Err.Add('Corrupt File: Missing "info.pieces" segment');
          end;
          if(info.Exists('length')) then begin // single-file archive
            sz := (info['length'] as TIntString).IntPart;
            _Count := 1;
            _Files.Add(TTorrentSubFile.Create(_Name,'',sz,Int64(0)));
          end else begin
            if(info.Exists('files')) then begin
              _Multifile := True;
              files := info['files'] as TObjectList;
              for i := 0 to files.Count - 1 do begin
                thisfile := files[i] as TObjectHash;
                if(thisfile.Exists('length')) then begin
                  fs := (thisfile['length'] as TIntString).IntPart;
                end else begin
                  fs := Int64(0);
                  _Err.Add('Corrupt File: files[' + IntToStr(i) + '] is missing a "length" segment');
                end;
                fp := '';
                fn := '';
                if(thisfile.Exists('path')) then begin
                  path := thisfile['path'] as TObjectList;
                  for j := 0 to path.Count - 2 do
                    fp := fp + (path[j] as TIntString).StringPart + '\';
                  if(path.Count > 0) then fn := (path[path.Count - 1] as TIntString).StringPart;
                end else begin
                  _Err.Add('Corrupt File: files[' + IntToStr(i) + '] is missing a "path" segment');
                end;
                _Files.Add(TTorrentSubFile.Create(fn,fp,fs,sz));
                sz := sz + fs;
              end;
              _Count := _Files.Count;
            end else begin
              _Err.Add('Corrupt File: Missing both "info.length" and "info.files" segments (should have one or the other)');
            end;
          end;
          if(_Tree.Exists('_info_start') and _Tree.Exists('_info_length')) then begin
            fo := Stream.Position;
            Stream.Seek((_Tree['_info_start'] as TIntString).IntPart,soFromBeginning);
            fs := (_Tree['_info_length'] as TIntString).IntPart;
            SetLength(fp,fs);
            Stream.Read(PChar(fp)^,fs);
            sha.TransformString(fp);
            sha.Complete();
            _SHA1Hash := sha.hashvalue;
            p := sha.HashValueBytes;
            SetLength(_HashBin,20);
            move(p^,_HashBin[1],20);
            Stream.Seek(fo,soFromBeginning);
          end;
        end else begin
          _Err.Add('Corrupt File: Missing "info" segment');
        end;
        _Length := sz;
        r := True;
      end else begin
        _Err.Add('Error parsing file; does not appear to be valid bencoded metainfo');
      end;
    finally
      FreeAndNil(sha);
    end;
  except
    _Err.Add('Something bad happened while trying to load the file, probably corrupt metainfo');
  end;
  Result := r;
end;

procedure TTorrentFile.Save(Stream: TStream; Pieces : array of TTorrentPiece);
var i:integer;
    s,s2:string;

procedure WStrm(s:string);
//var buf:UTF8String;
begin
  //buf:=AnsiToUtf8(s);
  //buf:=UTF8Encode(s);
  //buf:=UTF8Decode(s);
  //buf:=s;
  //Stream.WriteBuffer(hdrUTF8[1],2);
  //Stream.WriteBuffer(hdrUTF8W[1],1);
  Stream.WriteBuffer(s[1],system.length(s));
end;

procedure WStrg(s:string);
var t:String;
//buf:UTF8String;
begin
  //buf:=AnsiToUtf8(s);
  //buf:=UTF8Encode(s);
  //buf:=UTF8Decode(s);
  //buf:=s;
  t:=inttostr(system.length(s))+':'+s;
  WStrm((t));
end;

procedure WInt(i:int64);
begin
  WStrm('i'); WStrm(IntToStr(i)); WStrm('e');
end;

begin
  WStrm('d');
  WStrg('announce'); WStrg(AnsiToUtf8(Announce));
  if BackupTrackers.Count > 0 then
  begin
    WStrg('announce-list');
    WStrm('l');
     // Primary Tracker
     WStrm('l');
      WStrg(AnsiToUtf8(Announce));
     WStrm('e');
     // Backup Tracker
     for i:=0 to BackupTrackers.Count-1 do
      if BackupTrackers[i] <> Announce then
      begin
      WStrm('l');
      WStrg(AnsiToUtf8(BackupTrackers[i]));
      WStrm('e');
      end;
    WStrm('e');
  end;

  WStrg('created by');
  WStrg(AnsiToUtf8('uTorrent/3.4.2'));

  if Comment <> '' then
  begin
    WStrg('comment');
    WStrg(AnsiToUtf8(comment));
  end;

  if Advertisement <> '' then
  begin
    WStrg('advt');
    WStrg(AnsiToUtf8(Advertisement));
  end;

  if Releaser <> '' then
  begin
    WStrg('releaser');
    WStrg(AnsiToUtf8(Releaser));
  end;

  if SiteReleaser <> '' then
  begin
    WStrg('sitereleaser');
    WStrg(AnsiToUtf8(SiteReleaser));
  end;

  if Date <> 0 then
  begin
    WStrg('creation date');
    WInt(DateTimeToUnixTime(Date));
  end;

  WStrg('encoding'); WStrm('');
  WStrg('UTF-8'); WStrm('');

  WStrg('info'); WStrm('d');

  if Multifile then
  begin
  WStrg('files'); WStrm('l');

  for i:=0 to Files.Count-1 do
   with (Files[i] as TTorrentSubFile) do
    begin
       WStrm('d');
         WStrg('length');
         WInt(Length);
         WStrg('path');
         WStrm('l');

         if Path <> '' then
         begin
           s:=path;
           repeat
            if pos('\',s) <> 0 then
            begin
              s2:=copy(s,1,pos('\',s)-1); WStrg(AnsiToUtf8(s2));
              Delete(s,1,pos('\',s));
            end;

            if (pos('\',s)=0) and (s <>'') then WStrg(AnsiToUtf8(s));
           until pos('\',s)=0;
         end;
         WStrg(AnsiToUtf8(Name));

         WStrm('e');
       WStrm('e');
    end;

  WStrm('e');
  end
  else
  begin
     WStrg('length');
     WInt(Length);
  end;

  WStrg('name');
  WStrg(AnsiToUtf8(Name));
  WStrg('piece length');
  WInt(PieceLength);

  WStrg('pieces');
  WStrm(IntToStr((high(pieces)+1)*20));
  WStrm(':');
  for i:=0 to high(pieces) do WStrm(pieces[i].HashBin);   

  if PrivateTorrent then
  begin
  WStrg('private');
  WInt(1);
  end;

  WStrm('e');
  WStrm('e');
end;

{ TTorrentPiece }

constructor TTorrentPiece.Create(Hash, HashBin: String; Valid: Boolean);
begin
  _Hash := Hash;
  _HashBin := HashBin;
  _Valid := Valid;
  inherited Create();
end;

end.
