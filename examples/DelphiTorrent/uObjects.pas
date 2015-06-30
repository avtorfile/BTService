unit uObjects;

interface

uses Windows, Classes, SysUtils, XMLDoc, XMLIntf;

type

  PVSTFiles = ^TVSTFiles;

  TVSTFiles = record
    index: integer;
    ffilepath: String;
    ffilename: String;
    fsize: Int64;
    fprogress: Int64;
    foffset: Int64;
  end;

type
  PVSTPeers = ^TVSTPeers;

  TVSTPeers = record
    index: integer;
    IpC: cardinal;
    port: integer;
    ID, ipS, Client: string;
    progress: Int64;
    recv: string;
    sent: string;
    speed_recv: string;
    speed_send: string;
  end;

type
  PVSTTrackers = ^TVSTTrackers;

  TVSTTrackers = record
    index: integer;
    fHost: String;
    fURL: String;
    fTrackerID: String;
    fCurrTrackerEvent: String;
    fBufferReceive: String;
    fWarningMessage: String;
    fFError: String;
    fvisualStr: String;
    fStatus: integer;
    fInterval: integer;
    fSeeders: integer;
    fLeechers: integer;
    ftick: integer;
    fNext_Poll: integer;
  end;

type
  PVSTRecord = ^TVSTRecord;

  TVSTRecord = record
    FileName: string;
    Link: string;
    Status: string;
    TimeLeft: string;
    DownloadTime: string;
    FileSize: Int64;
    LoadedData: Int64;
    Speed: string;
    Seeds: string;
    Leeches: string;
    UpSpeed: string;
    Uploaded: string;
    DirectLink: string;
    Directory: string;
    Category: string;
    Referer: string;
    Plugin: string;
    ID: string;
    Range: string;
    SortID: string;
    CountSections: string;
    ElementNumber: integer;
    ImageIndex: integer;
    ImageIndexLink: integer;
    ImageIndexStatus: integer;
  end;

  targuments = array of string;

  TTaskStatus = (tsReady, tsError, tsLoad, tsLoading, tsStoped, tsDelete,
    tsDeleted, tsGetURL, tsQueue, tsErroring, tsStoping,
    tsBittorrentMagnetDiscovery, tsSeeding, tsFileError, tsAllocating,
    tsFinishedAllocating, tsRebuilding, tsProcessing, tsJustCompleted,
    tsCompleted, tsDownloading, tsPaused, tsLeechPaused, tsLocalPaused,
    tsCancelled, tsQueuedSource, tsUploading, tsStartProcess);

  TPieces = class(TObject)
    foffset: Int64;
    fsize: Int64;
    findex: Int64;
    fprogress: Int64;
    AddedSegment: boolean;
    IndexSegment: integer;
  end;

  TOptions = class(TObject)
  private
  public
    Name: string;
    Version: string;
    Path: string;
    TasksListName: string;
    LastID: integer;
    MainFormHandle: THandle;
    AddTorrentHandle: THandle;
    StartSeeding: boolean;
    PrivateTorrent: boolean;
    Trackers: string;
    PartSize: integer;
    CreateTorrentHandle: THandle;
    AddTaskHandle: THandle;
    Directory: string;
    procedure Save;
    procedure Load;
  end;

  TTorrentSubFileClass = class(TObject)
    Name: String;
    Path: String;
    FileName: String;
    Length: Int64;
    Offset: Int64;
    Left: Int64;
  end;

  TDeletedTorrent = class(TObject)
    HashDeleted: String;
    FileName: String;
    Filename2: String;
    Path: boolean;
  end;

  TFiles = class(TObject)
    ffilename: String;
    fsize: Int64;
    fprogress: Int64;
    foffset: Int64;
    VisualData: PVSTFiles;
  end;

  TPeer = class(TObject)
    IpC: cardinal;
    port: integer;
    ID, ipS, Client: string;
    progress: Int64;
    recv: Int64;
    sent: Int64;
    speed_recv: integer;
    speed_send: integer;
    FindIP: boolean;
    VisualData: PVSTPeers;
  end;

  TTrackers = class(TObject)
    Host: String;
    URL: String;
    TrackerID: String;
    CurrTrackerEvent: String;
    BufferReceive: String;
    WarningMessage: String;
    FError: String;
    VisualData: PVSTTrackers;
    visualStr: String;
    Status: integer;
    Interval: integer;
    Seeders: integer;
    Leechers: integer;
    tick: integer;
    Next_Poll: integer;
  end;

var
  Options: TOptions;

implementation

procedure TOptions.Save;
var
  Xml: TXMLDocument;
  Parent: IXMLNode;
  Child: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  Xml.Active := True;
  if Xml.IsEmptyDoc then
    Xml.DocumentElement := Xml.CreateElement('XMLOptions', '');
  Xml.DocumentElement.Attributes['Name'] := 'Settings';
  Xml.DocumentElement.Attributes['Version'] := Version;
  Parent := Xml.DocumentElement.AddChild('Options');
  Child := Parent.AddChild('LastID');
  Child.Text := IntToStr(LastID);
  Child := Parent.AddChild('Directory');
  Child.Text := Directory;
  Xml.SaveToFile(Path + '\' + 'Settings' + '.xml');
  Xml.Free;
end;

procedure TOptions.Load;
var
  FS: TFileStream;
  XmlRun: IXMLDocument;
  ParentRun: IXMLNode;
  ChildRun: IXMLNode;
begin
  if not FileExists(Path + '\' + 'Settings' + '.xml') then
  begin
    try
      try
        FS := TFileStream.Create(Path + '\' + 'Settings' + '.xml',
          fmCreate or fmShareDenyNone);
      except
      end;
    finally
      FS.Free;
    end;
  end
  else
  begin
    XmlRun := TXMLDocument.Create(nil);
    XmlRun.Active := True;
    try
      XmlRun.LoadFromFile(Path + '\' + 'Settings' + '.xml');
    except
    end;
  end;

  try
    ParentRun := XmlRun.DocumentElement.ChildNodes['Options'];
  except
  end;

  try
    ChildRun := ParentRun.ChildNodes['LastID'];
    if ChildRun.Text <> '' then
      LastID := StrToInt(ChildRun.Text)
    else
      LastID := 0;
  except
    LastID := 0;
  end;

  try
    ChildRun := ParentRun.ChildNodes['Directory'];
    if ChildRun.Text <> '' then
      Directory := ChildRun.Text
    else
      Directory := 'c:\Downloads\';
  except
    Directory := 'c:\Downloads\';
  end;

  XmlRun := nil;
end;

end.
