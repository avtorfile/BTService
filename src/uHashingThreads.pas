unit uHashingThreads;
Interface

Uses
   Windows, Classes, SysUtils, forms, Contnrs, uTransferInfo, uFunctions,
   TorrentParser, torrentfile, hashedstorage, bttransfer, BTTrackerAnnounce,
   MessageDigests, uFileManager, dialogs;

Type

  TTracker = record
    Name, Announce, Webpage:String;
    Down:Boolean;
  end;

  TMakeTorrentBTTransfer = class(TBTTransfer)
    public
      constructor Create(Peerid:string);  
      procedure Log(Level:Integer; Msg:String); override;
  end;

  {TMakeTorrentBTHashedStorage = class(THashedStorage)
    public
      constructor Create(PieceSize:Int64; Files:TObjectList; Hash, Multifile:Boolean; LocalPath:String);

      procedure HashEvent(Event:String; Param:Integer); override;
      procedure HashChangeFile(Filename:string; Size:Int64); override;
      procedure HashDonePiece; override;
//      function Cancel:Boolean; override;
  end;}

TCreateTorrentThread = class(TThread)
  private
    InfoCreating: TInfoCreating;
    procedure Hashing;
  public
    procedure Execute; override;
    constructor Create(CreateSuspended : Boolean; P : Pointer);
end;

Implementation

{TSearchLinkThread}

constructor TMakeTorrentBTTransfer.Create(Peerid:String);
begin
  inherited Create(peerid);
end;

procedure TMakeTorrentBTTransfer.Log(Level:Integer; Msg:String);
begin
  if level=4 then
  begin
  end;
end;

constructor TCreateTorrentThread.Create(CreateSuspended : Boolean; P : Pointer);
begin
 InfoCreating:=P;
 inherited Create(CreateSuspended);
 InfoCreating.ThreadHandle := Handle;
 //CreateTorrentThreadInContainer(ThreadData.ID,Handle);
 InfoCreating.HashedData.status:='start';
end;

procedure TCreateTorrentThread.Execute;
var
  torrent: TTorrentFile;
  files: TObjectList;
  totalsize: int64;     

function GetFileSize(name:String):Int64;
var strm:TFileStream;
begin
  strm:=TFileStream.Create(name,fmOpenRead);
  GetFileSize:=strm.Size;
  strm.Destroy;
end;  

function GetPieceLength:Integer;
var i:integer;
    j:int64;

begin
  //if radCustom.Checked then
  //  GetPieceLength:=Round(Power(2,cmbPieceSize.ItemIndex+17)) else
  begin
    j:=0;
    for i:=0 to files.Count-1 do inc(j,(files[i] as TTorrentSubFile).Length);

    if j>2000000000 then
      GetPieceLength:=4194304 //2097152
    else if j>1000000000 then
      GetPieceLength:=1048576
    else if j>450000000 then
      GetPieceLength:=524288
    else GetPieceLength:=262144;
   end; 
end;

  procedure CreateTorrent(torrent: TTorrentFile; files: TObjectList;
    LocalName, Output: String);
  var
    transfer: TMakeTorrentBTTransfer;
    outfile: TFileStream;
    I: Integer;
    TrackersList: TStringList;
    s:string;
    TextFileManager:TTextFileManager;
    TorrentString:string;

  begin
    torrent.files := files;

    if InfoCreating.SizePart<=0 then
    torrent.PieceLength := GetPieceLength
    else
    torrent.PieceLength := InfoCreating.SizePart;  

    TrackersList:= TStringList.Create;
    try
    TrackersList.Text:=InfoCreating.Trackers;
    for i:=0 to TrackersList.Count-1 do
    begin
      if trim(TrackersList[i])<>'' then
      begin
        s:=TrimLeft(TrackersList[i]);
        s:=TrimRight(TrackersList[i]);
        torrent.BackupTrackers.Add(s);
      end;
    end;
    finally
      TrackersList.Free;
    end;

    {s:=InfoCreating.Trackers;
    repeat
    LinkStr := SearchParam3(s, 'highres%2', 0, '%26quality%3D', 12);
    torrent.BackupTrackers.Add()
    until ;}

    // Init Fake Transfer
    transfer := TMakeTorrentBTTransfer.Create('');
    transfer.TorrentFile := torrent;  

    


   // if ({((totalsize div torrent.PieceLength) + 1)}totalsize >= 2147483647) then
   // begin
   //   InfoCreating.HashedData.ProgressMax1 := totalsize {div 1024}; //((totalsize div torrent.PieceLength) + 1) ;
   // end
   // else
    begin
      InfoCreating.HashedData.ProgressMax1 := totalsize; //(totalsize div torrent.PieceLength) + 1; 
    end;
    InfoCreating.HashedData.ProgressPosition1 := 0;

    // Hash the files
    //storage := TMakeTorrentBTHashedStorage.Create(torrent.PieceLength, files,
    //  True, torrent.Multifile, LocalName);

    InfoCreating.HashedData.ps:=torrent.PieceLength;
    InfoCreating.HashedData._Files:=files;
    InfoCreating.HashedData.lp:=LocalName;
    InfoCreating.HashedData.mf:=torrent.Multifile;
    setLength(InfoCreating.HashedData.Pieces,0);
    InfoCreating.HashedData.NumPieces:=0;
    //InfoCreating.HashedData.Hash:=true;
    {HashingThread:=THashingThread.Create(False, InfoCreating);
    HashingThread.WaitFor;
    HashingThread.Free;}

    Hashing;


    if terminated then
    begin
      //Application.MessageBox('Operation Aborted!', 'Abort', 0);
      //ButtonSave:=true;
      //Button3.Caption:='?????????';
    end
    else
    begin
      // Write the output file
      outfile := TFileStream.Create(Output, fmCreate);
      torrent.Save(outfile, InfoCreating.HashedData.Pieces);
      FreeAndNil(outfile);

      {TextFileManager:=TTextFileManager.Create();
      try
        TorrentString:=TextFileManager.Load(Output);
        TextFileManager.Save(Output, TorrentString, ffUTF8);
        if isUTF8FileBOM(Output) then
       begin
        //if showlog then
        //log('File Utf-8 with BOM');
        DeleteBOM(Output);
       end
      finally
        TextFileManager.Free;
      end;}

      
    end;

    // Free your mind..
    //FreeAndNil(InfoCreating.HashedData);
    FreeAndNil(transfer);
  end;

  function MyCompare(List: TStringList; Index1, Index2: Integer): Integer;
  begin
    // Pure string compares; very simple.
    if List[Index1] < List[Index2] then MyCompare:=-1;
    if List[Index1] = List[Index2] then MyCompare:=0;
    if List[Index1] > List[Index2] then MyCompare:=1;
  end;

  procedure AddFolder(Files:TObjectList; LocalPath,TorrentPath:String; Recurse:Boolean);
  var
    sr: TSearchRec;
    ftmp: TStringList;
    path:string;
    i:integer;
    comp:TStringListSortCompare;
    fs:Int64;
    fn:string;
  begin
    ftmp:=TStringList.Create;

    if FindFirst(LocalPath+'\*.*',faAnyFile,sr) = 0 then
    begin
      repeat
        if (sr.Name <> '.') and (sr.Name <> '..') then ftmp.Add(sr.Name);
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;

    comp:=@MyCompare;
    ftmp.CustomSort(comp);

    for i:=0 to ftmp.Count-1 do
    if DirectoryExists(LocalPath+'\'+ftmp[i]) and Recurse then
    begin
      if torrentpath = '' then path:=ftmp[i] else path:=TorrentPath+'\'+ftmp[i];
      AddFolder(Files,LocalPath+'\'+ftmp[i],path, Recurse); 
    end
    else
    if ({(not chkSkipThumbs.Checked) or} (lowercase(string(ftmp[i])) <> 'thumbs.db')) then
    begin
      try
        fn := LocalPath+'\'+ftmp[i];
        fs := FileSize(fn);//SizeFile(fn); //GetFileSize(fn);
      except
      end;
      files.Add(TTorrentSubFile.Create(ftmp[i],torrentpath,fs,0));
      (files[files.count-1] as TTorrentSubFile).Filename := LocalPath + '\' + ftmp[i];
      totalsize:= totalsize + (files[files.count-1] as TTorrentSubFile).Length;   
      //inc(totalsize,(files[files.count-1] as TTorrentSubFile).Length);
    end;

    FreeAndNil(ftmp);
  end;

  procedure SingleFileCreateTorrent(FileName, Output: String);
  var TrackersList: TStringList;
  i:Integer;
  s:string;
  begin
    torrent := TTorrentFile.Create;
    try
      totalsize :=  FileSize(FileName);// SizeFile(FileName); GetFileSize(FileName);
    except
    end;
    files := TObjectList.Create;
    files.Add(TTorrentSubFile.Create(ExtractFileName(FileName), '', totalsize,
        0));

    TrackersList:= TStringList.Create;
    try
    TrackersList.Text:=InfoCreating.Trackers;
    for i:=0 to TrackersList.Count-1 do
    begin
      if (i=0) and (trim(TrackersList[i])<>'') then
      begin
        s:=TrackersList[i];
        Break;
      end
      else
      begin
        if (trim(TrackersList[i])<>'') then
        s:=TrackersList[i];
        Break;
      end;
    end;
    finally
      TrackersList.Free;
    end;

    torrent.Init(s, ExtractFileName(FileName),
      InfoCreating.Comment, '', totalsize, False, InfoCreating.PrivateTorrent,
      InfoCreating.Advertisement, InfoCreating.Releaser, InfoCreating.SiteReleaser);
    CreateTorrent(torrent, files, FileName, Output);
    FreeAndNil(torrent);
  end;

  procedure MultiFileCreateTorrent(FileName, TorrentName: String);
  var TrackersList: TStringList;
  i:Integer;
  s:string;
  begin
    files := TObjectList.Create;
    torrent := TTorrentFile.Create;
    totalsize := 0;
    AddFolder(files, FileName, '', True);

    TrackersList:= TStringList.Create;
    try
    TrackersList.Text:=InfoCreating.Trackers;
    for i:=0 to TrackersList.Count-1 do
    begin
      if (i=0) and (trim(TrackersList[i])<>'') then
      begin
        s:=TrackersList[i];
        Break;
      end
      else
      begin
        if (trim(TrackersList[i])<>'') then
        s:=TrackersList[i];
        Break;
      end;
    end;
    finally
      TrackersList.Free;
    end;

    torrent.Init(s, ExtractFileName(FileName),
      InfoCreating.Comment, '', 0, True, InfoCreating.PrivateTorrent,
      InfoCreating.Advertisement, InfoCreating.Releaser, InfoCreating.SiteReleaser);

    CreateTorrent(torrent, files, FileName, TorrentName);

    FreeAndNil(torrent);
  end;

begin
  if InfoCreating.Multifile then
  begin
    MultiFileCreateTorrent(InfoCreating.FileName, InfoCreating.TorrentName);
  end
  else
  begin
    SingleFileCreateTorrent(InfoCreating.FileName, InfoCreating.TorrentName);
  end;
  if terminated then
  InfoCreating.HashedData.status:='stoped'
  else
  InfoCreating.HashedData.status:='completed';
end;

procedure TCreateTorrentThread.Hashing;
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
  need:=InfoCreating.HashedData.ps;
  InfoCreating.HashedData.Numpieces:=0;
  getmem(buff,need);

  try
    try
      //HashEvent('start',0);
      //if not (InfoCreating.HashedData.status='stoping') then
      if not terminated then
      begin
        InfoCreating.HashedData.status:='start';
      end;

      if not terminated then
      for i:=0 to InfoCreating.HashedData._Files.Count-1 do   
      begin     
        cfile := InfoCreating.HashedData._Files[i] as TTorrentSubFile;

        if cfile.Filename<>'' then
        begin         
          fname := cfile.Filename;
        end
        else
        if InfoCreating.HashedData.mf then
        begin
          fname := InfoCreating.HashedData.lp+'\'+cfile.Path+cfile.Name;
        end
        else
        begin
          fname := InfoCreating.HashedData.lp;
        end;  

        //t.Log(3,'Opening: '+fname);
        if not terminated then
        begin
          try
            f:=TFileStream.Create(fname,{fmOpenRead or fmshareCompator}fmOpenRead or fmShareDenyNone);
            f.Seek(0,soFromBeginning);
          except  
          end;
        end;

        //HashChangeFile(fname,f.Size);
        //if not (InfoCreating.HashedData.status='stoping') then
        if not terminated then
        begin
          InfoCreating.HashedData.status:='creating';
          InfoCreating.HashedData.Filename:=fname;
          InfoCreating.HashedData.ProgressMax2 := (f.Size div InfoCreating.HashedData.ps) +1;
          InfoCreating.HashedData.ProgressPosition2 := 0;
        end;

        if not terminated then
        repeat
          //application.ProcessMessages;
          got := f.Read(buff^,need);
          sha.Transform(buff^,got);
          if not terminated then
          if (got = need)or( (f.Position = f.Size)and(i=InfoCreating.HashedData._Files.Count-1) ) then
          begin
            sha.Complete;
            p := sha.HashValueBytes;
            SetLength(HashBin,20);
            move(p^,HashBin[1],20);

            piece:=TTorrentPiece.Create(Lowercase(sha.HashValue), HashBin, True);
            inc(InfoCreating.HashedData.NumPieces);
            setlength(InfoCreating.HashedData.pieces,InfoCreating.HashedData.NumPieces);
            //t.Log(4,IntToStr(NumPieces) +' '+Lowercase(sha.HashValue));
            //if Lowercase(sha.HashValue) = t.torrentfile.Pieces[NumPieces-1].Hash then t.Log('GOOD!');
            InfoCreating.HashedData.Pieces[InfoCreating.HashedData.NumPieces-1] := piece;
            need:=InfoCreating.HashedData.ps;
            sha.Clear;

            //HashDonePiece;
            InfoCreating.HashedData.ProgressPosition2:=InfoCreating.HashedData.ProgressPosition2+1;
            
            InfoCreating.HashedData.ProgressPosition1:=InfoCreating.HashedData.ProgressPosition1+
              InfoCreating.HashedData.ps;//InfoCreating.HashedData.ProgressPosition1+1;
          end;
        until (f.Position = f.Size) or (terminated){or Cancel};

        //if (not Cancel) then
        if not terminated then
        begin
          dec(need,got);
          //t.Log(4,'Closing file '+fname);
          FreeAndNil(f);
        end;
      end;

    finally
      //HashEvent('done',0);
      {if terminated then
      InfoCreating.HashedData.status:='stoped'
      else
      InfoCreating.HashedData.status:='done';}
          
      FreeAndNil(sha);
      FreeAndNil(f);
    end;
  except
    // error handling
  end;

end;



end.
