unit hashedstorage;

interface
uses Contnrs, forms, TorrentParser,torrentfile, dialogs{, BTTrackerAnnounce, MessageDigests};

type

THashedData = class (TObject)
  private
    q : array of array of Int64;
  public
    lp : String;
    _Files : TObjectList;
    mf : boolean;
    Pieces : array of TTorrentPiece;
    NumPieces : int64;
    ps : int64;
    status : String;
    FileName : String;
    ProgressMax1: int64;
    ProgressMax2: int64;
    ProgressPosition1: int64;
    ProgressPosition2: int64;
end;

type THashedStorage = class (TObject)
  private
    q : array of array of Int64;
    lp : String;
    _Files : TObjectList;
    mf : boolean;
  public
    Pieces : array of TTorrentPiece;
    NumPieces : int64;
    ps : int64;


    constructor Create(PieceSize:Int64; Files:TObjectList; Hash, Multifile:Boolean; LocalPath:String);
    destructor Destroy(Flush:Boolean);
    procedure LoadPieces;
    function GetBitfield(t:TTorrentFile):TBitfield;
    // function CheckPiece(Num:Integer):boolean;

    procedure HashChangeFile(Filename:string; Size:Int64); virtual; abstract;
    procedure HashDonePiece; virtual; abstract;
    procedure HashEvent(Event:String; Param:Integer); virtual; abstract;
//    function Cancel:Boolean; virtual; abstract;
end;

implementation
uses classes, messagedigests, sysutils;

constructor THashedStorage.Create(PieceSize:Int64; Files:TObjectList; Hash, Multifile:Boolean; LocalPath:String);
begin
  inherited Create;

  ps:=PieceSize;
  _Files:=files;
  lp:=LocalPath;
  mf:=multifile;
  setLength(Pieces,0);
  NumPieces:=0;

  if Hash then LoadPieces;
end;

destructor THashedStorage.Destroy(Flush:Boolean);
begin
  //if Flush then flush;
  
  inherited Destroy;
end;

function THashedStorage.GetBitfield(t:TTorrentFile):TBitfield;
var b:TBitfield;
    i:integer;
begin
  setLength(b,0);

  if NumPieces<>0 then
    if NumPieces = Length(t.pieces) then
      begin
        setLength(b,NumPieces);
        for i:=0 to NumPieces-1 do b[i]:= (t.Pieces[i].Hash = Pieces[i].Hash);
      end;
      
  GetBitfield:=b;
end;

procedure THashedStorage.LoadPieces;
// TODO: Gracefully handle non-existant files
var buff:PChar;
    f: TFileStream;
    sha: TSHA1;
    i:integer;
    got, need, lastsize : integer;
    piece: TTorrentPiece;
    cfile: TTorrentSubfile;
    fname:string;
    p:pointer;
    hashbin:string;

begin
  f:=nil;
  sha:=TSha1.Create;
  need:=ps;
  numpieces:=0;
  getmem(buff,need);

  try
    try
      HashEvent('start',0);

      for i:=0 to _Files.Count-1 do
      //if not Cancel then
      begin
        cfile := _Files[i] as TTorrentSubFile;

        if cfile.Filename<>'' then
          fname := cfile.Filename
        else if mf then
          fname := lp+'\'+cfile.Path+cfile.Name
        else
          fname := lp;

        {showmessage('Name: '+cfile.Name);
        showmessage('Path: '+cfile.Path);
        showmessage('Filename: '+cfile.Filename);}

        //t.Log(3,'Opening: '+fname);
        f:=TFileStream.Create(fname,fmOpenRead or fmShareDenyNone);
        f.Seek(0,soFromBeginning);
        HashChangeFile(fname,f.Size);
        
        repeat
          application.ProcessMessages;
          got := f.Read(buff^,need);
          sha.Transform(buff^,got);

          if (got = need)or( (f.Position = f.Size)and(i=_Files.Count-1) ) then
          begin
            sha.Complete;
            p := sha.HashValueBytes;
            SetLength(HashBin,20);
            move(p^,HashBin[1],20);

            piece:=TTorrentPiece.Create(Lowercase(sha.HashValue), HashBin, True);
            inc(NumPieces);
            setlength(pieces,NumPieces);
            //t.Log(4,IntToStr(NumPieces) +' '+Lowercase(sha.HashValue));
            //if Lowercase(sha.HashValue) = t.torrentfile.Pieces[NumPieces-1].Hash then t.Log('GOOD!');
            Pieces[NumPieces-1] := piece;
            need:=ps;
            sha.Clear;
            HashDonePiece;
          end;
        until (f.Position = f.Size) {or Cancel};

        //if (not Cancel) then
        begin
          dec(need,got);
          //t.Log(4,'Closing file '+fname);
          FreeAndNil(f);
        end;
      end;

    finally
      HashEvent('done',0);
          
      FreeAndNil(sha);
      FreeAndNil(f);
    end;
  except
    // error handling
  end;

end;

end.
