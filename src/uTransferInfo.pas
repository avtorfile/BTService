unit uTransferInfo;

interface

Uses Windows, Classes, SysUtils, uStatus, hashedstorage;

procedure SetInfo(SLData: TStringList);
procedure CreateThreadInContainer(ID: string; ThreadHandle: THandle);     
procedure SeekingInContainer(ID: string);
procedure DTInContainer(ID: string; DTTime: String; DT: String);
procedure RecognitionInContainer(ID: string);
procedure CompleteInContainer(ID: string; Link: String; Referer: String;
  Cookie: String; ErrorPlug: String; DataPost: string);
procedure CompletePiecesInContainer(Hash: string; PiecesInfo: string);
procedure CompleteTrackersInContainer(Hash: string; TrackersInfo: string);
procedure CompleteFilesInContainer(Hash: string; FilesInfo: string);
procedure CompletePeersInContainer(Hash: string; PeersInfo: string);
procedure GetInContainer(ID: string);
procedure PostInContainer(ID: string);
procedure HeadInContainer(ID: string);
procedure LogInContainer(ID: string; LogText: string);
procedure SetTrackersInfo(Hash: String);
procedure SetPiecesInfo(Hash: String);
procedure SetFilesInfo(Hash: String);
procedure SetPeersInfo(Hash: String);

type
/////////////////////////// Class TStatusTrackers //////////////////////////////
TStatusTrackers = (stNotStart, stStart, stProcess, stCompleted);
////////////////////////////////////////////////////////////////////////////////

//////////////////////////// Class TStatusFiles ////////////////////////////////
TStatusFiles = (sfNotStart, sfStart, sfProcess, sfCompleted);
////////////////////////////////////////////////////////////////////////////////

//////////////////////////// Class TStatusPeers ////////////////////////////////
TStatusPeers = (spNotStart, spStart, spProcess, spCompleted);
////////////////////////////////////////////////////////////////////////////////

/////////////////////////// Class TStatusPieces ////////////////////////////////
TStatusPieces = (spcNotStart, spcStart, spcProcess, spcCompleted);
////////////////////////////////////////////////////////////////////////////////

Type

  TDataEnter = class(TObject)
  public
    Url: String;
    Referer: String;
    Accept: String;
    AgentName: String;
    GetNamePath: String;
    CaptchaPath: String;
    ProxyType: String;
    ProxyAddress: String;
    ProxyLogin: String;
    ProxyPassword: String;
    ProxyPort: Integer;
    ServerAuthType: String;
    Username: String;
    Password: String;
    Cookie: TStringList;
    DataPost: TStringList;
    LastError: String;
    DataType: Integer;
    ExtensionCaptcha: String;
    AcceptLanguage: String;
    RequestVer: Integer;
    CaptchaFile: String;
    ExtraHeader: TStringList;
    RecomPlugFileName: String;
    DRequestType: String;
    SectLinks: String;
  end;

  TDataExit = class(TObject)
  public
    Cookie: TStringList;
    Error: String;
    PageHtml: String;
    Status: String;
    Header: String;
    Location: String;
    ResultRecognition: String;
    StatusCode: String;
    ReasonPhrase: String;
    Referer: String;
  end;

  TInfoInProg = class(TObject)
  public
    Url: String;
    Referer: String;
    Cookie: String;
    Error: String;
    DTTime: String;
    DT: String;
    Status: TStatus;
    DataPost: String;
    Log: String;
    ExtraHeader: String;
    ExtraData: String;
  end;

  TInfo = class(TObject)
  public
    ID: String;
    ThreadHandle: THandle;
    InfoInProg: TInfoInProg;
    DataIn: TDataEnter;
    DataOut: TDataExit;
  end;

  TInfoCreating = class(TObject)
  public
    ThreadHandle: THandle;
    HashedData: THashedData;
    Multifile: Boolean;
    ID: String;
    FileName: String;
    TorrentName: String;
    Comment: String;
    Trackers: String;
    WebSeeds: String;
    PrivateTorrent: Boolean;
    SizePart: Int64;
    CreateEncrypted: Boolean;
    ReserveFileOrder: Boolean;
    Related: String;
    Advertisement: String;
    Releaser: String;
    SiteReleaser: String;
  end;

  TInfoTrackers = class(TObject)
  public
    Hash: String;
    ThreadHandle: THandle;
    TrackersInfo: String;
    Status: TStatusTrackers;
  end;

  TInfoFiles = class(TObject)
  public
    Hash: String;
    ThreadHandle: THandle;
    FilesInfo: String;
    Status: TStatusFiles;
  end;

  TInfoPieces = class(TObject)
  public
     Hash: String;
     ThreadHandle: THandle;
     OffSet:int64;
     Size:cardinal;
     Index:cardinal;
     Progress:cardinal;
     PiecesInfo: String;
     Status: TStatusPieces;
  end;

  TInfoPeers = class(TObject)
  public
    Hash: String;
    ThreadHandle: THandle;
    PeersInfo: String;
    Status: TStatusPeers;
  end;

Var
  ContainerCreateTorrent: TThreadList;
  Container: TThreadList;
  TrackersContainer: TThreadList;
  PiecesContainer: TThreadList;
  FilesContainer: TThreadList;
  PeersContainer: TThreadList;
  CreateTorrentThreadList: TThreadList;
  ThreadList: TThreadList;
  ThreadTrackersList: TThreadList;
  ThreadPiecesList: TThreadList;
  ThreadFilesList: TThreadList;
  ThreadPeersList: TThreadList;

implementation

procedure SetTrackersInfo(Hash: String);
var
  InfoTrackers: TInfoTrackers;
begin
  InfoTrackers := TInfoTrackers.Create;
  InfoTrackers.Hash := Hash;
  TrackersContainer.Add(InfoTrackers);
end;

procedure SetPiecesInfo(Hash: String);
var
  InfoPieces: TInfoPieces;
begin
  InfoPieces := TInfoPieces.Create;
  InfoPieces.Hash := Hash;
  PiecesContainer.Add(InfoPieces);
end;

procedure SetFilesInfo(Hash: String);
var
  InfoFiles: TInfoFiles;
begin
  InfoFiles := TInfoFiles.Create;
  InfoFiles.Hash := Hash;
  FilesContainer.Add(InfoFiles);
end;

procedure SetPeersInfo(Hash: String);
var
  InfoPeers: TInfoPeers;
begin
  InfoPeers := TInfoPeers.Create;
  InfoPeers.Hash := Hash;
  PeersContainer.Add(InfoPeers);
end;

procedure SetInfo(SLData: TStringList);
var
  Info: TInfo;
begin
  Info := TInfo.Create;
  Info.DataIn := TDataEnter.Create;
  Info.DataOut := TDataExit.Create;
  Info.DataIn.DataPost := TStringList.Create;
  Info.DataIn.Cookie := TStringList.Create;
  Info.DataOut.Cookie := TStringList.Create;
  Info.DataIn.ExtraHeader := TStringList.Create;
  Info.InfoInProg := TInfoInProg.Create;
  Info.DataIn.Url := SLData[0];
  Info.DataIn.Referer := SLData[1];
  Info.DataIn.AgentName := SLData[2];
  Info.DataIn.GetNamePath := SLData[3];
  Info.ID := SLData[4];
  Info.DataIn.CaptchaPath := SLData[5];
  Info.DataIn.LastError := SLData[6];
  Info.DataIn.ProxyAddress := SLData[7];
  if Trim(SLData[8]) = '' then
    Info.DataIn.ProxyPort := 80
  else
    Info.DataIn.ProxyPort := StrToInt(SLData[8]);
  Info.DataIn.ProxyLogin := SLData[9];
  Info.DataIn.ProxyPassword := SLData[10];
  Info.DataIn.ProxyType := SLData[11];
  Info.DataIn.ServerAuthType := SLData[12];
  Info.DataIn.Username := SLData[13];
  Info.DataIn.Password := SLData[14];
  Info.DataIn.Cookie.Text := SLData[15];
  Info.DataIn.DataPost.Text := SLData[16];
  Container.Add(Info);
end;

procedure CreateThreadInContainer(ID: string; ThreadHandle: THandle);
var
  Info: TInfo;
  i: Integer;
begin
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sCreatedThread;
          if ThreadHandle <> 0 then
            Info.ThreadHandle := ThreadHandle;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;
end;

procedure SeekingInContainer(ID: string);
var
  i: Integer;
  Info: TInfo;
begin
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sSeeking;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;
end;

procedure DTInContainer(ID: string; DTTime: String; DT: String);
var
  i: Integer;
  Info: TInfo;
begin
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sDownloadTicket;
          Info.InfoInProg.DTTime := DTTime;
          Info.InfoInProg.DT := DT;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;
end;

procedure RecognitionInContainer(ID: string);
var
  i: Integer;
  Info: TInfo;
begin
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sRecognition;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;
end;

procedure GetInContainer(ID: string);
var
  i: Integer;
  Info: TInfo;
  ExtraDataList: TStringList;
begin
  ExtraDataList := TStringList.Create;
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sGet;
          Info.InfoInProg.Url := Info.DataIn.Url;
          Info.InfoInProg.Referer := Info.DataIn.Referer;
          Info.InfoInProg.Cookie := Info.DataIn.Cookie.Text;
          Info.InfoInProg.Error := Info.DataIn.LastError;
          Info.InfoInProg.ExtraHeader := Info.DataIn.ExtraHeader.Text;
          ExtraDataList.Text := IntToStr(Info.DataIn.DataType);
          ExtraDataList.Add(Info.DataIn.CaptchaFile);
          ExtraDataList.Add(Info.DataIn.AcceptLanguage);
          ExtraDataList.Add(IntToStr(Info.DataIn.RequestVer));
          ExtraDataList.Add(Info.DataIn.ProxyType);
          ExtraDataList.Add(Info.DataIn.ProxyAddress);
          ExtraDataList.Add(IntToStr(Info.DataIn.ProxyPort));
          ExtraDataList.Add(Info.DataIn.ProxyLogin);
          ExtraDataList.Add(Info.DataIn.ProxyPassword);
          ExtraDataList.Add(Info.DataIn.ServerAuthType);
          ExtraDataList.Add(Info.DataIn.Username);
          ExtraDataList.Add(Info.DataIn.Password);
          ExtraDataList.Add(Info.DataIn.Accept);
          ExtraDataList.Add(Info.DataIn.AgentName);
          Info.InfoInProg.ExtraData := ExtraDataList.Text;
          break;
        end;
      end;
    finally
      Container.UnlockList;
      ExtraDataList.Free;
    end;
end;

procedure PostInContainer(ID: string);
var
  i: Integer;
  Info: TInfo;
  ExtraDataList: TStringList;
begin
  ExtraDataList := TStringList.Create;
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sPost;
          Info.InfoInProg.Url := Info.DataIn.Url;
          Info.InfoInProg.Referer := Info.DataIn.Referer;
          Info.InfoInProg.Cookie := Info.DataIn.Cookie.Text;
          Info.InfoInProg.Error := Info.DataIn.LastError;
          Info.InfoInProg.DataPost := Info.DataIn.DataPost.Text;
          Info.InfoInProg.ExtraHeader := Info.DataIn.ExtraHeader.Text;
          ExtraDataList.Text := IntToStr(Info.DataIn.DataType);
          ExtraDataList.Add(Info.DataIn.CaptchaFile);
          ExtraDataList.Add(Info.DataIn.AcceptLanguage);
          ExtraDataList.Add(IntToStr(Info.DataIn.RequestVer));
          ExtraDataList.Add(Info.DataIn.ProxyType);
          ExtraDataList.Add(Info.DataIn.ProxyAddress);
          ExtraDataList.Add(IntToStr(Info.DataIn.ProxyPort));
          ExtraDataList.Add(Info.DataIn.ProxyLogin);
          ExtraDataList.Add(Info.DataIn.ProxyPassword);
          ExtraDataList.Add(Info.DataIn.ServerAuthType);
          ExtraDataList.Add(Info.DataIn.Username);
          ExtraDataList.Add(Info.DataIn.Password);
          ExtraDataList.Add(Info.DataIn.Accept);
          ExtraDataList.Add(Info.DataIn.AgentName);
          Info.InfoInProg.ExtraData := ExtraDataList.Text;
          break;
        end;
      end;
    finally
      Container.UnlockList;
      ExtraDataList.Free;
    end;
end;

procedure HeadInContainer(ID: string);
var
  i: Integer;
  Info: TInfo;
  ExtraDataList: TStringList;
begin
  ExtraDataList := TStringList.Create;
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sHead;
          Info.InfoInProg.Url := Info.DataIn.Url;
          Info.InfoInProg.Referer := Info.DataIn.Referer;
          Info.InfoInProg.Cookie := Info.DataIn.Cookie.Text;
          Info.InfoInProg.Error := Info.DataIn.LastError;
          Info.InfoInProg.ExtraHeader := Info.DataIn.ExtraHeader.Text;
          ExtraDataList.Text := IntToStr(Info.DataIn.DataType);
          ExtraDataList.Add(Info.DataIn.CaptchaFile);
          ExtraDataList.Add(Info.DataIn.AcceptLanguage);
          ExtraDataList.Add(IntToStr(Info.DataIn.RequestVer));
          ExtraDataList.Add(Info.DataIn.ProxyType);
          ExtraDataList.Add(Info.DataIn.ProxyAddress);
          ExtraDataList.Add(IntToStr(Info.DataIn.ProxyPort));
          ExtraDataList.Add(Info.DataIn.ProxyLogin);
          ExtraDataList.Add(Info.DataIn.ProxyPassword);
          ExtraDataList.Add(Info.DataIn.ServerAuthType);
          ExtraDataList.Add(Info.DataIn.Username);
          ExtraDataList.Add(Info.DataIn.Password);
          ExtraDataList.Add(Info.DataIn.Accept);
          ExtraDataList.Add(Info.DataIn.AgentName);
          Info.InfoInProg.ExtraData := ExtraDataList.Text;
          break;
        end;
      end;
    finally
      Container.UnlockList;
      ExtraDataList.Free;
    end;
end;

procedure LogInContainer(ID: string; LogText: string);
var
  i: Integer;
  Info: TInfo;
begin
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sLog;
          Info.InfoInProg.Log := LogText;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;
end;

procedure CompleteInContainer(ID: string; Link: string; Referer: string;
  Cookie: string; ErrorPlug: string; DataPost: string);
var
  i: Integer;
  Info: TInfo;
  ExtraDataList: TStringList;
begin
  ExtraDataList := TStringList.Create;
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.InfoInProg.Status := sSearchCompleted;
          Info.InfoInProg.Url := Link;
          Info.InfoInProg.Referer := Referer;
          Info.InfoInProg.Cookie := Cookie;
          Info.InfoInProg.Error := ErrorPlug;
          Info.InfoInProg.DataPost := DataPost;
          Info.InfoInProg.ExtraHeader := Info.DataIn.ExtraHeader.Text;
          ExtraDataList.Text := IntToStr(Info.DataIn.DataType);
          ExtraDataList.Add(Info.DataIn.CaptchaFile);
          ExtraDataList.Add(Info.DataIn.AcceptLanguage);
          ExtraDataList.Add(IntToStr(Info.DataIn.RequestVer));
          ExtraDataList.Add(Info.DataIn.ProxyType);
          ExtraDataList.Add(Info.DataIn.ProxyAddress);
          ExtraDataList.Add(IntToStr(Info.DataIn.ProxyPort));
          ExtraDataList.Add(Info.DataIn.ProxyLogin);
          ExtraDataList.Add(Info.DataIn.ProxyPassword);
          ExtraDataList.Add(Info.DataIn.ServerAuthType);
          ExtraDataList.Add(Info.DataIn.Username);
          ExtraDataList.Add(Info.DataIn.Password);
          ExtraDataList.Add(Info.DataIn.Accept);
          ExtraDataList.Add(Info.DataIn.AgentName);
          ExtraDataList.Add(Info.DataIn.RecomPlugFileName);
          ExtraDataList.Add(Info.DataIn.DRequestType);
          ExtraDataList.Add(Info.DataIn.SectLinks);
          Info.InfoInProg.ExtraData := ExtraDataList.Text;
          break;
        end;
      end;
    finally
      Container.UnlockList;
      ExtraDataList.Free;
    end;
end;

procedure CompletePiecesInContainer(Hash: string; PiecesInfo: string);
var
  i: Integer;
  InfoPieces: TInfoPieces;
begin
  with PiecesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPieces := Items[i];
        if Hash = InfoPieces.Hash then
        begin
          InfoPieces.Status := spcCompleted;
          InfoPieces.PiecesInfo := PiecesInfo;
          break;
        end;
      end;
    finally
      PiecesContainer.UnlockList;
    end;
end;

procedure CompleteTrackersInContainer(Hash: string; TrackersInfo: string);
var
  i: Integer;
  InfoTrackers: TInfoTrackers;
begin
  with TrackersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoTrackers := Items[i];
        if Hash = InfoTrackers.Hash then
        begin
          InfoTrackers.Status := stCompleted;
          InfoTrackers.TrackersInfo := TrackersInfo;
          break;
        end;
      end;
    finally
      TrackersContainer.UnlockList;
    end;
end;

procedure CompleteFilesInContainer(Hash: string; FilesInfo: string);
var
  i: Integer;
  InfoFiles: TInfoFiles;
begin
  with FilesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoFiles := Items[i];
        if Hash = InfoFiles.Hash then
        begin
          InfoFiles.Status := sfCompleted;
          InfoFiles.FilesInfo := FilesInfo;
          break;
        end;
      end;
    finally
      FilesContainer.UnlockList;
    end;
end;

procedure CompletePeersInContainer(Hash: string; PeersInfo: string);
var
  i: Integer;
  InfoPeers: TInfoPeers;
begin
  with PeersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPeers := Items[i];
        if Hash = InfoPeers.Hash then
        begin
          InfoPeers.Status := spCompleted;
          InfoPeers.PeersInfo := PeersInfo;
          break;
        end;
      end;
    finally
      PeersContainer.UnlockList;
    end;
end;

end.
