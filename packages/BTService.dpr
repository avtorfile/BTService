Library BTService;

{$R 'example_plugin_delphi7Resource.res' 'example_plugin_delphi7Resource.rc'}

uses
  Windows,
  SysUtils,
  Classes,
  ActiveX,
  Dialogs,
  AxCtrls,
  Forms,
  IniFiles,
  Registry,
  Contnrs,
  uTransferInfo in '..\src\uTransferInfo.pas',
  uFunctions in '..\src\uFunctions.pas',
  uSettings in '..\src\uSettings.pas',
  uStatus in '..\src\uStatus.pas',
  uSearchLink in '..\src\uSearchLink.pas',
  uPluginInfo in '..\src\uPluginInfo.pas',
  DllForm in '..\src\DllForm.pas' {fDllForm},
  AsyncExTypes in '..\src\AsyncExTypes.pas',
  BDecode in '..\src\BDecode.pas',
  bittorrentConst in '..\src\bittorrentConst.pas',
  BitTorrentDlDb in '..\src\BitTorrentDlDb.pas',
  BittorrentStringfunc in '..\src\BittorrentStringfunc.pas',
  BitTorrentUtils in '..\src\BitTorrentUtils.pas',
  btcore in '..\src\btcore.pas',
  dht_consts in '..\src\dht_consts.pas',
  dht_int160 in '..\src\dht_int160.pas',
  dht_routingbin in '..\src\dht_routingbin.pas',
  dht_search in '..\src\dht_search.pas',
  dht_searchManager in '..\src\dht_searchManager.pas',
  dht_socket in '..\src\dht_socket.pas',
  dht_zones in '..\src\dht_zones.pas',
  hashes in '..\src\hashes.pas',
  thread_bitTorrent in '..\src\thread_bitTorrent.pas',
  torrentparser in '..\src\torrentparser.pas',
  thread_download in '..\src\thread_download.pas',
  thread_share in '..\src\thread_share.pas',
  thread_supernode in '..\src\thread_supernode.pas',
  thread_terminator in '..\src\thread_terminator.pas',
  thread_upload in '..\src\thread_upload.pas',
  dhtconsts in '..\src\dht\dhtconsts.pas',
  dhtcontact in '..\src\dht\dhtcontact.pas',
  dhthashlist in '..\src\dht\dhthashlist.pas',
  dhtkeywords in '..\src\dht\dhtkeywords.pas',
  dhtroutingbin in '..\src\dht\dhtroutingbin.pas',
  dhtsearch in '..\src\dht\dhtsearch.pas',
  dhtsearchManager in '..\src\dht\dhtsearchManager.pas',
  dhtsocket in '..\src\dht\dhtsocket.pas',
  dhttypes in '..\src\dht\dhttypes.pas',
  dhtUtils in '..\src\dht\dhtUtils.pas',
  dhtzones in '..\src\dht\dhtzones.pas',
  int128 in '..\src\dht\int128.pas',
  thread_dht in '..\src\dht\thread_dht.pas',
  ares_objects in '..\src\ares_objects.pas',
  ares_types in '..\src\ares_types.pas',
  blcksock in '..\src\blcksock.pas',
  class_cmdlist in '..\src\class_cmdlist.pas',
  classes2 in '..\src\classes2.pas',
  const_ares in '..\src\const_ares.pas',
  const_client in '..\src\const_client.pas',
  const_commands in '..\src\const_commands.pas',
  const_commands_pfs in '..\src\const_commands_pfs.pas',
  const_commands_privatechat in '..\src\const_commands_privatechat.pas',
  const_privchat in '..\src\const_privchat.pas',
  const_supernode_commands in '..\src\const_supernode_commands.pas',
  const_timeouts in '..\src\const_timeouts.pas',
  const_udpTransfer in '..\src\const_udpTransfer.pas',
  const_win_messages in '..\src\const_win_messages.pas',
  hashlist in '..\src\hashlist.pas',
  helper_altsources in '..\src\helper_altsources.pas',
  helper_ares_nodes in '..\src\helper_ares_nodes.pas',
  helper_arescol in '..\src\helper_arescol.pas',
  helper_autoscan in '..\src\helper_autoscan.pas',
  helper_base64_32 in '..\src\helper_base64_32.pas',
  helper_bighints in '..\src\helper_bighints.pas',
  helper_combos in '..\src\helper_combos.pas',
  helper_crypt in '..\src\helper_crypt.pas',
  helper_datetime in '..\src\helper_datetime.pas',
  helper_diskio in '..\src\helper_diskio.pas',
  helper_download_disk in '..\src\helper_download_disk.pas',
  helper_download_misc in '..\src\helper_download_misc.pas',
  helper_filtering in '..\src\helper_filtering.pas',
  helper_graphs in '..\src\helper_graphs.pas',
  helper_gui_misc in '..\src\helper_gui_misc.pas',
  helper_hashlinks in '..\src\helper_hashlinks.pas',
  helper_http in '..\src\helper_http.pas',
  helper_ICH in '..\src\helper_ICH.pas',
  helpeR_ipfunc in '..\src\helpeR_ipfunc.pas',
  helper_library_db in '..\src\helper_library_db.pas',
  helper_mimetypes in '..\src\helper_mimetypes.pas',
  helper_params in '..\src\helper_params.pas',
  helper_preview in '..\src\helper_preview.pas',
  helper_private_chat in '..\src\helper_private_chat.pas',
  helper_registry in '..\src\helper_registry.pas',
  helper_search_gui in '..\src\helper_search_gui.pas',
  helper_share_misc in '..\src\helper_share_misc.pas',
  helper_share_settings in '..\src\helper_share_settings.pas',
  helper_sockets in '..\src\helper_sockets.pas',
  helper_sorting in '..\src\helper_sorting.pas',
  helper_stringfinal in '..\src\helper_stringfinal.pas',
  helper_strings in '..\src\helper_strings.pas',
  helper_supernode_crypt in '..\src\helper_supernode_crypt.pas',
  helper_unicode in '..\src\helper_unicode.pas',
  helper_urls in '..\src\helper_urls.pas',
  keywfunc in '..\src\keywfunc.pas',
  mysupernodes in '..\src\mysupernodes.pas',
  securehash in '..\src\securehash.pas',
  synsock in '..\src\synsock.pas',
  th_rbld in '..\src\th_rbld.pas',
  types_supernode in '..\src\types_supernode.pas',
  umediar in '..\src\umediar.pas',
  utility_ares in '..\src\utility_ares.pas',
  vars_global in '..\src\vars_global.pas',
  vars_localiz in '..\src\vars_localiz.pas',
  uExtraData in '..\src\uExtraData.pas',
  uThreads in '..\src\uThreads.pas',
  bttransfer in '..\src\bttransfer.pas',
  hashedstorage in '..\src\hashedstorage.pas',
  BTTrackerAnnounce in '..\src\BTTrackerAnnounce.pas',
  MessageDigests in '..\src\MessageDigests.pas',
  TorrentFile in '..\src\TorrentFile.pas',
  uHashingThreads in '..\src\uHashingThreads.pas',
  uFileManager in '..\src\uFileManager.pas',
  zlibex in '..\src\zlibex.pas',
  ZLibExApi in '..\src\ZLibExApi.pas',       
  PluginAPI in '..\PluginAPI\Headers\PluginAPI.pas',
  CRC16 in '..\PluginAPI\Headers\CRC16.pas',
  Helpers in '..\PluginAPI\Headers\Helpers.pas',
  PluginForm in '..\PluginAPI\Plugins\PluginForm.pas',
  PluginSupport in '..\PluginAPI\Plugins\PluginSupport.pas';

{$E pld}
{$R *.RES}

type

  TTracker = record
    Name, Announce, Webpage:String;
    Down:Boolean;
  end;

  TMakeTorrentBTTransfer = class(TBTTransfer)
    public
      constructor Create(Peerid:string);

      procedure Log(Level:Integer; Msg:String); override;
  end;

  TMakeTorrentBTHashedStorage = class(THashedStorage)
    public
      constructor Create(PieceSize:Int64; Files:TObjectList; Hash, Multifile:Boolean; LocalPath:String);

      procedure HashEvent(Event:String; Param:Integer); override;
      procedure HashChangeFile(Filename:string; Size:Int64); override;
      procedure HashDonePiece; override;
//      function Cancel:Boolean; override;
  end;

  TPlugin = class(TCheckedInterfacedObject,
                  IPlugin,
                  IDestroyNotify,
                  IUnknown,
                  IServicePlugin,
                  IBTServicePlugin,
                  IBTServicePluginFilesInfo,
                  IAssociation,                   
                  IBTServiceAddSeeding,
                  IBTDeleteTorrent,
                  IBTServicePluginPeersInfo,
                  IBTServicePluginPiecesInfo,
                  IBTServicePluginProgressive,
                  IBTCreateTorrent,
                  IBTServicePluginTrackersInfo,
                  IBTServicePluginAddTrackers,
                  IBTServicePluginUpdateTracker,
                  IBTServicePluginBitSettings
                  )
  private
    FCore: ICore;
    FWnds: IApplicationWindows;
  protected
    property Core: ICore read FCore;
    property Wnds: IApplicationWindows read FWnds;
    function MessageBox(const AText, ACaption: String;
      const AFlags: DWORD): Integer;
    // IPlugin
    function GetID: TGUID; safecall;
    function GetName: WideString; safecall;
    function GetVersion: WideString; safecall;
    function GetAuthorName: WideString; safecall;
    function GetEmailAuthor: WideString; safecall;
    function GetSiteAuthor: WideString; safecall;
    function GetPluginType: Integer; safecall;
    // IDestroyNotify
    procedure Delete; safecall;
    // IAssociation
    procedure MagnetAssociation(ProgName:WideString;Assoc: Bool); safecall;
    procedure BittorrentAssociation(ProgName:WideString;Assoc: Bool); safecall;
    // IBTServicePluginBitSettings
    function GetBittorrentPort: Integer; safecall;
    function GetUpBandAllow: Integer; safecall;
    function GetDownBandAllow: Integer; safecall;
    function GetInconidleChecked: Bool; safecall;
    function GetLimiteUpload: Integer; safecall;
    function GetUlPerIp: Integer; safecall;
    function GetDlAllowed: Integer; safecall;
    procedure SetBittorrentPort(Port: Integer); safecall;
    procedure SetUpBandAllow(UpBandAllow: Integer); safecall;
    procedure SetDownBandAllow(DownBandAllow: Integer); safecall;
    procedure SetInconidleChecked(InconidleChecked: Bool); safecall;
    procedure SetLimiteUpload(LimiteUpload: Integer); safecall;
    procedure SetUlPerIp(UlPerIp: Integer); safecall;
    procedure SetDlAllowed(DlAllowed: Integer); safecall;
    // IBTServicePluginAddTrackers
    procedure AddTrackers(Hash: WideString;Trackers: WideString); safecall;
    // IBTServicePluginUpdateTracker
    procedure UpdateTracker(Hash: WideString; UrlTracker: WideString); safecall;
    // IBTServicePluginTrackersInfo
    function GetTrackersInfo(Hash: WideString):WideString; safecall;
    function CheckTrackersStatus(Hash: WideString): WideString; safecall;
    function GetDataTrackers(Hash: WideString): WideString; safecall;
    procedure StopTrackersThread(Hash: WideString); safecall;
    procedure ReleaseTrackersThread(Hash: WideString); safecall;   
    // IBTServicePluginPiecesInfo
    function GetPiecesInfo(Hash: WideString):WideString; safecall;
    function CheckPiecesStatus(Hash: WideString): WideString; safecall;
    function GetDataPieces(Hash: WideString): WideString; safecall;
    procedure StopPiecesThread(Hash: WideString); safecall;
    procedure ReleasePiecesThread(Hash: WideString); safecall;
    // IBTServicePluginFilesInfo
    function GetFilesInfo(Hash: WideString):WideString; safecall;
    function CheckFilesStatus(Hash: WideString): WideString; safecall;
    function GetDataFiles(Hash: WideString): WideString; safecall;
    procedure StopFilesThread(Hash: WideString); safecall;
    procedure ReleaseFilesThread(Hash: WideString); safecall;
    // IBTServicePluginPeersInfo
    function GetPeersInfo(Hash: WideString):WideString; safecall;
    function CheckPeersStatus(Hash: WideString): WideString; safecall;
    function GetDataPeers(Hash: WideString): WideString; safecall;
    procedure StopPeersThread(Hash: WideString); safecall;
    procedure ReleasePeersThread(Hash: WideString); safecall;
    // IBTServicePluginProgressive
    function SizeProgressiveDownloaded(Hash: WideString):WideString; safecall;
    procedure DoProgressiveDownload(Hash: WideString); safecall;
    procedure DoNotProgressiveDownload(Hash: WideString); safecall;
    procedure StartTorrentProgressive(WSData: WideString); safecall;
    procedure StartMagnetTorrentProgressive(WSData: WideString); safecall;
    // IBTServicePlugin
    function GetStatusTorrent(Hash: WideString):WideString; safecall;
    function GetInfoTorrentFile(TorrentFile: WideString):WideString; safecall;
    procedure AddSeeding(WSData: WideString); safecall;
    procedure StartTorrent(WSData: WideString); safecall;
    procedure StartMagnetTorrent(WSData: WideString); safecall;
    procedure ResumeTorrent({ID: WideString;}Hash: WideString;TorrentFolder: WideString); safecall;
    procedure StopTorrent({ID: WideString;}Hash: WideString); safecall;
    function FindTorrent({ID: WideString;}Hash: WideString): WideString; safecall;
    function GetInfoTorrent({ID: WideString;}Hash: WideString): WideString; safecall;
    procedure DeleteTorrent(Hash: WideString); safecall;
    // IBTCreateTorrent
    procedure SingleFileTorrent(ID: WideString; FileName: WideString;
    TorrentName: WideString; Comment: WideString; Trackers: WideString;
    WebSeeds: WideString; PrivateTorrent: Bool; SizePart: Integer;
    CreateEncrypted: Bool; ReserveFileOrder: Bool; Related: WideString;
    Advertisement: WideString; Releaser:WideString; SiteReleaser:WideString); safecall;
    procedure CreateFolderTorrent(ID: WideString; FileName: WideString;
    TorrentName: WideString; Comment: WideString; Trackers: WideString;
    WebSeeds: WideString; PrivateTorrent: Bool; SizePart: Integer;
    CreateEncrypted: Bool; ReserveFileOrder: Bool; Related: WideString;
    Advertisement: WideString; Releaser:WideString; SiteReleaser:WideString); safecall;
    function GetInfoTorrentCreating(IDC: WideString): WideString; safecall;
    procedure StopCreateTorrentThread(IDC: WideString); safecall;
    procedure ReleaseCreateTorrentThread(IDC: WideString); safecall;
    // IBTDeleteTorrent
    procedure DeleteTorrentWithFiles(Hash: WideString); safecall;
    // IServicePlugin
    function GetServiceName: WideString; safecall;
    function GetServices: WideString; safecall;
    procedure Run(WSData: WideString); safecall;
    procedure StopThread(ID: WideString); safecall;
    procedure ReleaseThread(ID: WideString); safecall;
    function GetRecognition(ID: WideString): WideString; safecall;
    procedure CompleteRecognition(WSData: WideString); safecall;
    procedure CompleteRequest(ID: WideString; PageHtml: WideString;
      ErrorText: WideString; Cookie: WideString; Header: WideString;
      Location: WideString; Status: WideString; StatusCode: WideString;
      ReasonPhrase: WideString; Referer: WideString); safecall;
    procedure CompleteLog(WSData: WideString); safecall;         
    function CheckAndGet(ID: WideString): WideString; safecall;
    function GetActive: Bool; safecall;
    procedure SetActive(Value: Bool); safecall;
    function GetCountThreads: Integer; safecall;
    procedure SetCountThreads(Value: Integer); safecall;
    function GetUsePlugCountThreads: Bool; safecall;
    procedure SetUsePlugCountThreads(Value: Bool); safecall;
    function GetPremiumContent: Bool; safecall;
    procedure SetPremiumContent(Value: Bool); safecall;
    function GetUsePremium: Bool; safecall;
    procedure SetUsePremium(Value: Bool); safecall;
    function GetLoginPremium: WideString; safecall;
    procedure SetLoginPremium(Value: WideString); safecall;
    function GetPasswordPremium: WideString; safecall;
    procedure SetPasswordPremium(Value: WideString); safecall;
    function GetUrlSalePremium: WideString; safecall;
    procedure SetUrlSalePremium(Value: WideString); safecall;
    function GetRefUrlPremium: WideString; safecall;
    procedure SetRefUrlPremium(Value: WideString); safecall;
    function GetNumUsualSect: Integer; safecall;
    procedure SetNumUsualSect(Value: Integer); safecall;
    function GetNumProxySect: Integer; safecall;
    procedure SetNumProxySect(Value: Integer); safecall;
    function GetSubstituteProxySection: Bool; safecall;
    procedure SetSubstituteProxySection(Value: Bool); safecall;
    procedure CreateServiceForm(SkinActive: Bool; SkinDirectory: WideString;
      SkinName: WideString; Saturation: Integer; Hue: Integer;
      LeftForm: Integer; WidthForm: Integer; TopForm: Integer;
      HeightForm: Integer; Lang: WideString); safecall;
  public
    storage: TMakeTorrentBTHashedStorage;
    constructor Create(const ACore: ICore);
    destructor Destroy; override;           
  end;

  { TPlugin }

constructor TMakeTorrentBTTransfer.Create(Peerid:String);
begin
  inherited Create(peerid);
end;

constructor TMakeTorrentBTHashedStorage.Create(PieceSize:Int64; Files:TObjectList; Hash, Multifile:Boolean; LocalPath:String);
begin
  inherited Create(PieceSize, Files, False, MultiFile, LocalPath);

  if Hash then
  begin
  LoadPieces;
  end;
end;

procedure TMakeTorrentBTHashedStorage.HashEvent(Event:String; Param:Integer);
begin
    if Event = 'start' then
    begin
//      frmProgress.btnFinished.Enabled := False;
//      frmProgress.btnAbort.Enabled := True;
    end;

    if Event = 'done' then
    begin
      //fCreateTorrent.ProgressBar1.Position := fCreateTorrent.ProgressBar1.Max;
    end;

    if Event = 'abort' then
    begin
//      frmProgress.btnFinished.Enabled := True;
    end;
end;

procedure TMakeTorrentBTHashedStorage.HashChangeFile(Filename:string; Size:Int64);
begin
    //fCreateTorrent.ProgressBar2.Max := (Size div ps) +1;
    //fCreateTorrent.ProgressBar2.Position := 0;
end;

procedure TMakeTorrentBTHashedStorage.HashDonePiece;
begin
    //fCreateTorrent.ProgressBar2.Position:=fCreateTorrent.ProgressBar2.Position+1;
    //fCreateTorrent.ProgressBar1.Position:=fCreateTorrent.ProgressBar1.Position+1;
end;

procedure TMakeTorrentBTTransfer.Log(Level:Integer; Msg:String);
begin
  if level=4 then
  begin
  end;
end;
 

constructor TPlugin.Create(const ACore: ICore);
begin
  inherited Create;
  FCore := ACore;
  Assert(FCore.Version >= 1);
  if not Supports(FCore, IApplicationWindows, FWnds) then
    raise EInvalidCoreVersion.Create('Этому плагину нужна поддержка окон');
  Application.Handle := FWnds.ApplicationWnd;
end;

procedure TPlugin.Delete;
begin
  Application.Handle := 0;
  FWnds := nil;
  FCore := nil;
end;

destructor TPlugin.Destroy;
begin
  Delete;
  inherited;
end;    

procedure TPlugin.BittorrentAssociation(ProgName:WideString;Assoc: Bool);
var
 reg: Tregistry;
 ini: TMemIniFile;
begin
vars_global.check_opt_torrent_assoc_checked:=Assoc;
if PortableApp then
begin
 ini:=TMemIniFile.Create(IniName);
 try 
   Ini.WriteInteger('General','HookBitTorrentExt', integer(vars_global.check_opt_torrent_assoc_checked))
 finally
   ini.UpdateFile;
   ini.Free;
 end;
end
else
Set_regInteger('General.HookBitTorrentExt',integer(vars_global.check_opt_torrent_assoc_checked));

 reg:=Tregistry.create;
 if not vars_global.check_opt_torrent_assoc_checked then helper_hashlinks.restorePreviousBittorrentApp(ProgName,reg)
  else helper_hashlinks.check_bittorrent_association(ProgName,reg);
 reg.destroy;
end;

procedure TPlugin.MagnetAssociation(ProgName:WideString;Assoc: Bool);
var
 reg:Tregistry;
begin
  reg:=Tregistry.create;
  helper_hashlinks.check_magnet_association(ProgName,reg);
  reg.destroy;
end;

procedure TPlugin.CreateServiceForm(SkinActive: Bool;
  SkinDirectory: WideString; SkinName: WideString; Saturation: Integer;
  Hue: Integer; LeftForm: Integer; WidthForm: Integer; TopForm: Integer;
  HeightForm: Integer; Lang: WideString);
var
  DllForm: TfDllForm;
begin
  Settings.SkinActive := SkinActive;
  Settings.SkinDirectory := SkinDirectory;
  Settings.SkinName := SkinName;
  Settings.Saturation := Saturation;
  Settings.Hue := Hue;

  DllForm := TfDllForm.Create(FCore);
  try
    DllForm.Left := LeftForm + (WidthForm div 2) - (DllForm.Width div 2);
    DllForm.Top := TopForm + (HeightForm div 2) - (DllForm.Height div 2);
    DllForm.Language := Lang;
    DllForm.ShowModal;
  finally
    FreeAndNil(DllForm);
  end;
end;

function TPlugin.MessageBox(const AText, ACaption: String;
  const AFlags: DWORD): Integer;
begin
  Wnds.ModalStarted;
  try
    Result := Windows.MessageBox(Wnds.MainWnd, PChar(AText), PChar(ACaption),
      (AFlags and (not MB_SYSTEMMODAL)) or MB_TASKMODAL);
  finally
    Wnds.ModalFinished;
  end;
end;

function TPlugin.GetID: TGUID;
begin
  Result := IDPlugin;
end;

function TPlugin.GetName: WideString;
begin
  Result := PluginName;
end;

function TPlugin.GetVersion: WideString;
begin
  Result := GetPluginVersion;
end;

function TPlugin.GetServiceName: WideString;
begin
  Result := ServiceName;
end;

function TPlugin.GetAuthorName: WideString;
begin
  Result := Author;
end;

function TPlugin.GetEmailAuthor: WideString;
begin
  Result := EmailAuthor;
end;

function TPlugin.GetSiteAuthor: WideString;
begin
  Result := SiteAuthor;
end;

function TPlugin.GetServices: WideString;
begin
  Result := Services;
end;

function TPlugin.GetPluginType: Integer;
begin
  Result := Integer(PluginType);
end;

procedure TPlugin.Run(WSData: WideString);
var
  i: Integer;
  ID: string;
  Info: TInfo;
  SLData: TStringList;
begin
  SLData := TStringList.Create;
  SLData.Text := WSData;
  ID := SLData[4];
  SetInfo(SLData);
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          ThreadList.Add(TSearchLinkThread.Create(False, Info));
          break;
        end;
      end;
    finally
      Container.UnlockList;
      SLData.Free;
    end;
end;

procedure TPlugin.StopThread(ID: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  Info: TInfo;
begin
  Find := False;

  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          ThreadHandle := Info.ThreadHandle;
          Find := true;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;

  if Find = true then
    with ThreadList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TSearchLinkThread(Items[i]).Handle then
          begin
            TSearchLinkThread(Items[i]).Terminate;
            TSearchLinkThread(Items[i]).WaitFor;
            TSearchLinkThread(Items[i]).Free;
            Delete(i);
            break;
          end;
        end;
      finally
        ThreadList.UnlockList;
      end;
end;

procedure TPlugin.ReleaseThread(ID: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  Info: TInfo;
begin
  Find := False;

  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          ThreadHandle := Info.ThreadHandle;
          if Info.InfoInProg.Status = sSearchCompleted then
          begin
            Info.DataIn.DataPost.Free;
            Info.DataIn.ExtraHeader.Free;
            if assigned(Info.DataIn.Cookie) then
              Info.DataIn.Cookie.Free;
            if assigned(Info.DataOut.Cookie) then
              Info.DataOut.Cookie.Free;
            Info.InfoInProg.Free;
            Info.DataIn.Free;
            Info.DataOut.Free;
            Info.Free;
            Delete(i);
          end;
          Find := true;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;

  if Find = true then
  begin
    with ThreadList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TSearchLinkThread(Items[i]).Handle then
          begin
            if CheckThreadIsAlive(TSearchLinkThread(Items[i])) = true then
            begin
              TSearchLinkThread(Items[i]).Terminate;
              TSearchLinkThread(Items[i]).WaitFor;
              TSearchLinkThread(Items[i]).Free;
              Delete(i);
            end;
            break;
          end;
        end;
      finally
        ThreadList.UnlockList;
      end;
  end;
end;

function TPlugin.GetRecognition(ID: WideString): WideString;
var
  i: Integer;
  Info: TInfo;
  SLData: TStringList;
begin
  SLData := TStringList.Create;
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          SLData.Text := IntToStr(Settings.TimeRecognition);
          SLData.Add(IntToStr(Settings.MethodRecognition));
          SLData.Add(BoolToStr(Settings.UseAntigateKey));
          SLData.Add(Settings.AntigateKey);
          SLData.Add(Settings.RecognitionProg);
          SLData.Add(Info.DataIn.CaptchaFile);
          SLData.Add(Settings.CapIniFile);
          SLData.Add(Settings.CatalogLetters);
          SLData.Add(BoolToStr(Settings.phrase));
          SLData.Add(BoolToStr(Settings.regsense));
          SLData.Add(IntToStr(Settings.numeric));
          SLData.Add(BoolToStr(Settings.calc));
          SLData.Add(IntToStr(Settings.min_len));
          SLData.Add(IntToStr(Settings.max_len));
          Result := SLData.Text;
          break;
        end;
      end;
    finally
      Container.UnlockList;
      SLData.Free;
    end;
end;

procedure TPlugin.CompleteRecognition(WSData: WideString);
var
  i: Integer;
  Info: TInfo;
  SLData: TStringList;
  ID: String;
begin
  SLData := TStringList.Create;
  SLData.Text := WSData;
  ID := SLData[0];
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.DataOut.ResultRecognition := SLData[1];
          Info.DataOut.Status := 'sCompleteRecognition';
          Info.InfoInProg.Status := sSeeking;
          break;
        end;
      end;
    finally
      Container.UnlockList;
      SLData.Free;
    end;
end;

procedure TPlugin.CompleteRequest(ID: WideString; PageHtml: WideString;
  ErrorText: WideString; Cookie: WideString; Header: WideString;
  Location: WideString; Status: WideString; StatusCode: WideString;
  ReasonPhrase: WideString; Referer: WideString);
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
          Info.DataOut.PageHtml := PageHtml;
          Info.DataOut.Error := ErrorText;
          Info.DataOut.Cookie.Text := Cookie;
          Info.DataOut.Header := Header;
          Info.DataOut.Location := Location;
          Info.DataOut.Status := Status;
          Info.DataOut.StatusCode := StatusCode;
          Info.DataOut.ReasonPhrase := ReasonPhrase;
          Info.DataOut.Referer := Referer;
          Info.InfoInProg.Status := sSeeking;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;
end;

procedure TPlugin.CompleteLog(WSData: WideString);
var
  ID: String;
  i: Integer;
  Info: TInfo;
  SLData: TStringList;
begin
  SLData := TStringList.Create;
  SLData.Text := WSData;
  ID := SLData[0];

  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          Info.DataOut.Status := SLData[1];
          Info.InfoInProg.Status := sSeeking;
          break;
        end;
      end;
    finally
      Container.UnlockList;
      SLData.Free;
    end;
end;

function TPlugin.GetBittorrentPort: Integer; safecall;
begin
  Result:=vars_global.myport;
end;

function TPlugin.GetUpBandAllow: Integer; safecall;
begin
  Result:=vars_global.up_band_allow;
end;        

function TPlugin.GetDownBandAllow: Integer; safecall;
begin
  Result:=vars_global.down_band_allow;
end;

function TPlugin.GetInconidleChecked: Bool; safecall;
begin
  Result:=vars_global.check_opt_tran_inconidle_checked;
end;

function TPlugin.GetLimiteUpload:Integer; safecall;
begin
  Result:=vars_global.limite_upload;
end;

function TPlugin.GetUlPerIp: Integer; safecall;
begin
  Result:=vars_global.max_ul_per_ip;
end;

function TPlugin.GetDlAllowed: Integer; safecall;
begin
  Result:=vars_global.max_dl_allowed;
end; 

procedure TPlugin.SetBittorrentPort(Port: Integer); safecall;
var ini:TMemIniFile;
begin
  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.myport:=Port;
     if ((vars_global.myport<1) or (vars_global.myport>65535)) then vars_global.myport:=80;
     Ini.WriteInteger('Transfer','ServerPort', vars_global.myport);
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
    vars_global.myport:=Port;
    if ((vars_global.myport<1) or (vars_global.myport>65535)) then vars_global.myport:=80;
    set_reginteger('Transfer.ServerPort',vars_global.myport);
  end;
end;

procedure TPlugin.SetUpBandAllow(UpBandAllow: Integer); safecall;
var ini:TMemIniFile;
begin
  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.up_band_allow:=UpBandAllow;//strtointdef(Edit_opt_tran_upband.text,0);
     Ini.WriteInteger('Transfer','AllowedUpBand', vars_global.up_band_allow);
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
    vars_global.up_band_allow:=UpBandAllow;//strtointdef(Edit_opt_tran_upband.text,0);
    set_reginteger('Transfer.AllowedUpBand',vars_global.up_band_allow);
  end;
end;

procedure TPlugin.SetDownBandAllow(DownBandAllow: Integer); safecall;
var ini:TMemIniFile;
begin
  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.down_band_allow:=DownBandAllow;//strtointdef(Edit_opt_tran_dnband.text,0);
     Ini.WriteInteger('Transfer','AllowedDownBand', vars_global.down_band_allow);
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
    vars_global.down_band_allow:=DownBandAllow;//strtointdef(Edit_opt_tran_dnband.text,0);
    set_reginteger('Transfer.AllowedDownBand',vars_global.down_band_allow);
  end;
end;

procedure TPlugin.SetInconidleChecked(InconidleChecked: Bool); safecall;
var ini:TMemIniFile;
begin
  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.check_opt_tran_inconidle_checked:=InconidleChecked;
     Ini.WriteInteger('Transfer','MaximizeUpBandOnIdle', integer(vars_global.check_opt_tran_inconidle_checked));
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
    vars_global.check_opt_tran_inconidle_checked:=InconidleChecked;
    set_reginteger('Transfer.MaximizeUpBandOnIdle',integer(vars_global.check_opt_tran_inconidle_checked));
  end;
end;

procedure TPlugin.SetLimiteUpload(LimiteUpload: Integer); safecall;
var ini:TMemIniFile;
begin
  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.limite_upload:=LimiteUpload;//strtointdef(Edit_opt_tran_limup.text,4);
     Ini.WriteInteger('Transfer','MaxUpCount', vars_global.limite_upload);
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
    vars_global.limite_upload:=LimiteUpload;//strtointdef(Edit_opt_tran_limup.text,4);
    set_reginteger('Transfer.MaxUpCount',vars_global.limite_upload);
  end;
end;

procedure TPlugin.SetUlPerIp(UlPerIp: Integer); safecall;
var ini:TMemIniFile;
begin
  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.max_ul_per_ip:=UlPerIp;//strtointdef(Edit_opt_tran_upip.text,3);
     Ini.WriteInteger('Transfer','MaxUpPerUser', vars_global.max_ul_per_ip);
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
  vars_global.max_ul_per_ip:=UlPerIp;//strtointdef(Edit_opt_tran_upip.text,3);
  set_reginteger('Transfer.MaxUpPerUser',vars_global.max_ul_per_ip);
  end;
end;

procedure TPlugin.SetDlAllowed(DlAllowed: Integer); safecall;
var ini:TMemIniFile;
begin
  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.max_dl_allowed:=DlAllowed;//strtointdef(Edit_opt_tran_limdn.text,MAXNUM_ACTIVE_DOWNLOADS);
     Ini.WriteInteger('Transfer','MaxDlCount', vars_global.max_dl_allowed);
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
    vars_global.max_dl_allowed:=DlAllowed;//strtointdef(Edit_opt_tran_limdn.text,MAXNUM_ACTIVE_DOWNLOADS);
    set_reginteger('Transfer.MaxDlCount',vars_global.max_dl_allowed);
  end;
end;

procedure TPlugin.AddTrackers(Hash: WideString; Trackers: WideString);
var i,x:Integer;
tran:TBitTorrentTransfer;
TrackersList:TStringList;
begin
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];

  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    TrackersList:=TStringList.Create;
    //ShowMessage('Trackers: '+Trackers);
    TrackersList.Delimiter := ' ';
    TrackersList.QuoteChar := '*';
    TrackersList.DelimitedText:=Trackers;
    //TrackersList.Text:={widestrtoutf8str}(Trackers);
    for x:=0 to TrackersList.Count-1 do
    begin
      //ShowMessage(TrackersList[x]);
      tran.addTracker(TrackersList[x]);
    end;
    TrackersList.Free;
  end;
end;
end;

procedure TPlugin.UpdateTracker(Hash: WideString; UrlTracker: WideString);
var i,x:Integer;
tran:TBitTorrentTransfer;
Tracker:TBitTorrentTracker;
begin
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin      
    if UrlTracker='[DHT]' then
    begin
      tran.m_lastudpsearch:=0;
    end
    else
    for x:=0 to tran.trackers.Count-1 do
    begin
      Tracker:=tran.trackers[x];
      if Tracker.URL=UrlTracker then
      begin
        tracker.next_poll:=gettickcount;
        tran.trackerIndex:=x;
        Break;
      end;
    end;
  end;
end;
end;

function TPlugin.GetTrackersInfo(Hash: WideString):WideString;
var
  i: Integer;
  InfoTrackers: TInfoTrackers;
begin
  SetTrackersInfo(Hash);
  with TrackersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoTrackers := Items[i];
        if Hash = InfoTrackers.Hash then
        begin
          ThreadTrackersList.Add(TTrackersThread.Create(False, InfoTrackers));
          break;
        end;
      end;
    finally
      TrackersContainer.UnlockList;
    end;
end;

function TPlugin.GetPiecesInfo(Hash: WideString):WideString;
var
  i: Integer;
  InfoPieces: TInfoPieces;
begin
  SetPiecesInfo(Hash);
  with PiecesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPieces := Items[i];
        if Hash = InfoPieces.Hash then
        begin
          ThreadPiecesList.Add(TPiecesThread.Create(False, InfoPieces));
          break;
        end;
      end;
    finally
      PiecesContainer.UnlockList;
    end;
end;

function TPlugin.GetFilesInfo(Hash: WideString):WideString;
var
  i: Integer;
  InfoFiles: TInfoFiles;
begin
  SetFilesInfo(Hash);
  with FilesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoFiles := Items[i];
        if Hash = InfoFiles.Hash then
        begin
          ThreadFilesList.Add(TFilesThread.Create(False, InfoFiles));
          break;
        end;
      end;
    finally
      FilesContainer.UnlockList;
    end;
end;

function TPlugin.GetPeersInfo(Hash: WideString):WideString;
var
  i: Integer;
  InfoPeers: TInfoPeers;
begin
  SetPeersInfo(Hash);
  with PeersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPeers := Items[i];
        if Hash = InfoPeers.Hash then
        begin
          ThreadPeersList.Add(TPeersThread.Create(False, InfoPeers));
          break;
        end;
      end;
    finally
      PeersContainer.UnlockList;
    end;
end;

function TPlugin.CheckTrackersStatus(Hash: WideString): WideString;
var
  i: Integer;
  StatusInProg: string;
  InfoTrackers: TInfoTrackers;
begin
  with TrackersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoTrackers := Items[i];
        if Hash = InfoTrackers.Hash then
        begin
          StatusInProg := IntToStr(Integer(InfoTrackers.Status));
          break;
        end;
      end;
    finally
      TrackersContainer.UnlockList;
    end;       
   Result := StatusInProg;
end;

function TPlugin.CheckPiecesStatus(Hash: WideString): WideString;
var
  i: Integer;
  StatusInProg: string;
  InfoPieces: TInfoPieces;
begin
  with PiecesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPieces := Items[i];
        if Hash = InfoPieces.Hash then
        begin
          StatusInProg := IntToStr(Integer(InfoPieces.Status));
          break;
        end;
      end;
    finally
      PiecesContainer.UnlockList;
    end;
   Result := StatusInProg;
end;

function TPlugin.CheckFilesStatus(Hash: WideString): WideString;
var
  i: Integer;
  StatusInProg: string;
  InfoFiles: TInfoFiles;
begin
  with FilesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoFiles := Items[i];
        if Hash = InfoFiles.Hash then
        begin
          StatusInProg := IntToStr(Integer(InfoFiles.Status));
          break;
        end;
      end;
    finally
      FilesContainer.UnlockList;
    end;       
   Result := StatusInProg;
end;

function TPlugin.CheckPeersStatus(Hash: WideString): WideString;
var
  i: Integer;
  StatusInProg: string;
  InfoPeers: TInfoPeers;
begin
  with PeersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPeers := Items[i];
        if Hash = InfoPeers.Hash then
        begin
          StatusInProg := IntToStr(Integer(InfoPeers.Status));             
          break;
        end;
      end;
    finally
      PeersContainer.UnlockList;
    end;
  Result := StatusInProg;
end;

function TPlugin.GetDataTrackers(Hash: WideString): WideString;
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
          Result := InfoTrackers.TrackersInfo;
          break;
        end;
      end;
    finally
      TrackersContainer.UnlockList;
    end;
end;

function TPlugin.GetDataPieces(Hash: WideString): WideString;
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
          Result := InfoPieces.PiecesInfo;
          break;
        end;
      end;
    finally
      PiecesContainer.UnlockList;
    end;
end;

function TPlugin.GetDataFiles(Hash: WideString): WideString;
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
          Result := InfoFiles.FilesInfo;
          break;
        end;
      end;
    finally
      FilesContainer.UnlockList;
    end;
end;

procedure TPlugin.StopTrackersThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoTrackers: TInfoTrackers;
begin
  Find := False;
  with TrackersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoTrackers := Items[i];
        if Hash = InfoTrackers.Hash then
        begin
          ThreadHandle := InfoTrackers.ThreadHandle;
          Find := true;
          break;
        end;
      end;
    finally
      TrackersContainer.UnlockList;
    end;

  if Find = true then
    with ThreadTrackersList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TTrackersThread(Items[i]).Handle then
          begin
            TTrackersThread(Items[i]).Terminate;
            TTrackersThread(Items[i]).WaitFor;
            TTrackersThread(Items[i]).Free;
            Delete(i);
            break;
          end;
        end;
      finally
        ThreadTrackersList.UnlockList;
      end;
end;

function TPlugin.GetDataPeers(Hash: WideString): WideString;
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
          break;
        end;
      end;
    finally
      PeersContainer.UnlockList;
    end;
  Result := InfoPeers.PeersInfo;
end;

procedure TPlugin.StopPiecesThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoPieces: TInfoPieces;
begin
  Find := False;
  with PiecesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPieces := Items[i];
        if Hash = InfoPieces.Hash then
        begin
          ThreadHandle := InfoPieces.ThreadHandle;
          Find := true;
          break;
        end;
      end;
    finally
      PiecesContainer.UnlockList;
    end;

  if Find = true then
    with ThreadPiecesList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TPiecesThread(Items[i]).Handle then
          begin
            TPiecesThread(Items[i]).Terminate;
            TPiecesThread(Items[i]).WaitFor;
            TPiecesThread(Items[i]).Free;
            Delete(i);
            break;
          end;
        end;
      finally
        ThreadPiecesList.UnlockList;
      end;
end;

procedure TPlugin.StopFilesThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoFiles: TInfoFiles;
begin
  Find := False;
  with FilesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoFiles := Items[i];
        if Hash = InfoFiles.Hash then
        begin
          ThreadHandle := InfoFiles.ThreadHandle;
          Find := true;
          break;
        end;
      end;
    finally
      FilesContainer.UnlockList;
    end;

  if Find = true then
    with ThreadFilesList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TFilesThread(Items[i]).Handle then
          begin
            TFilesThread(Items[i]).Terminate;
            TFilesThread(Items[i]).WaitFor;
            TFilesThread(Items[i]).Free;
            Delete(i);
            break;
          end;
        end;
      finally
        ThreadFilesList.UnlockList;
      end;
end;

procedure TPlugin.StopPeersThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoPeers: TInfoPeers;
begin
  Find := False;

  with PeersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPeers := Items[i];
        if Hash = InfoPeers.Hash then
        begin
          ThreadHandle := InfoPeers.ThreadHandle;
          Find := true;
          break;
        end;
      end;
    finally
      PeersContainer.UnlockList;
    end;

  if Find = true then
    with ThreadPeersList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TPeersThread(Items[i]).Handle then
          begin
            TPeersThread(Items[i]).Terminate;
            TPeersThread(Items[i]).WaitFor;
            TPeersThread(Items[i]).Free;
            Delete(i);
            break;
          end;
        end;
      finally
        ThreadPeersList.UnlockList;
      end;
end;

procedure TPlugin.ReleaseTrackersThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoTrackers: TInfoTrackers;
begin
  Find := False;

  with TrackersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoTrackers := Items[i];
        if Hash = InfoTrackers.Hash then
        begin
          ThreadHandle := InfoTrackers.ThreadHandle;
          if InfoTrackers.Status = stCompleted then
          begin
            InfoTrackers.Free;
            Delete(i);
          end;
          Find := true;
          break;
        end;
      end;
    finally
      TrackersContainer.UnlockList;
    end;

  if Find = true then
  begin
    with ThreadTrackersList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TTrackersThread(Items[i]).Handle then
          begin
            if CheckThreadIsAlive(TTrackersThread(Items[i])) = true then
            begin
              TTrackersThread(Items[i]).Terminate;
              TTrackersThread(Items[i]).WaitFor;
              TTrackersThread(Items[i]).Free;
              Delete(i);
            end;
            break;
          end;
        end;
      finally
        ThreadTrackersList.UnlockList;
      end;
  end;
end;    

procedure TPlugin.ReleasePiecesThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoPieces: TInfoPieces;
begin
  Find := False;

  with PiecesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPieces := Items[i];
        if Hash = InfoPieces.Hash then
        begin
          ThreadHandle := InfoPieces.ThreadHandle;
          if InfoPieces.Status = spcCompleted then
          begin
            InfoPieces.Free;
            Delete(i);
          end;
          Find := true;
          break;
        end;
      end;
    finally
      PiecesContainer.UnlockList;
    end;

  if Find = true then
  begin
    with ThreadPiecesList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TPiecesThread(Items[i]).Handle then
          begin
            if CheckThreadIsAlive(TPiecesThread(Items[i])) = true then
            begin
              TPiecesThread(Items[i]).Terminate;
              TPiecesThread(Items[i]).WaitFor;
              TPiecesThread(Items[i]).Free;
              Delete(i);
            end;
            break;
          end;
        end;
      finally
        ThreadPiecesList.UnlockList;
      end;
  end;
end;

procedure TPlugin.ReleaseFilesThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoFiles: TInfoFiles;
begin
  Find := False;

  with FilesContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoFiles := Items[i];
        if Hash = InfoFiles.Hash then
        begin
          ThreadHandle := InfoFiles.ThreadHandle;
          if InfoFiles.Status = sfCompleted then
          begin
            InfoFiles.Free;
            Delete(i);
          end;
          Find := true;
          break;
        end;
      end;
    finally
      FilesContainer.UnlockList;
    end;

  if Find = true then
  begin
    with ThreadFilesList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TFilesThread(Items[i]).Handle then
          begin
            if CheckThreadIsAlive(TFilesThread(Items[i])) = true then
            begin
              TFilesThread(Items[i]).Terminate;
              TFilesThread(Items[i]).WaitFor;
              TFilesThread(Items[i]).Free;
              Delete(i);
            end;
            break;
          end;
        end;
      finally
        ThreadFilesList.UnlockList;
      end;
  end;
end;

procedure TPlugin.ReleasePeersThread(Hash: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoPeers: TInfoPeers;
begin
  Find := False;

  with PeersContainer.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoPeers := Items[i];
        if Hash = InfoPeers.Hash then
        begin
          ThreadHandle := InfoPeers.ThreadHandle;
          if InfoPeers.Status = spCompleted then
          begin
            InfoPeers.Free;
            Delete(i);
          end;
          Find := true;
          break;
        end;
      end;
    finally
      PeersContainer.UnlockList;
    end;

  if Find = true then
  begin
    with ThreadPeersList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TPeersThread(Items[i]).Handle then
          begin
            if CheckThreadIsAlive(TPeersThread(Items[i])) = true then
            begin
              TPeersThread(Items[i]).Terminate;
              TPeersThread(Items[i]).WaitFor;
              TPeersThread(Items[i]).Free;
              Delete(i);
            end;
            break;
          end;
        end;
      finally
        ThreadPeersList.UnlockList;
      end;
  end;
end;      

function TPlugin.GetStatusTorrent(Hash: WideString):WideString;
var i:Integer;
tran:TBitTorrentTransfer;
begin
Result:='';
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];

  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    //ShowMessage(ansilowercase(bytestr_to_hexstr(tran.fHashValue))+' || '+ansilowercase(Hash));
    Result:= IntToStr(Integer(tran.fstate));
  end;
end;
end;

function TPlugin.GetInfoTorrentFile(TorrentFile: WideString):WideString;
var
stream:thandlestream;
Parser:TTorrentParser;
InfoSL:TStringList;
TorrentInfo:WideString;
thisfile:TTorrentSubFile;    
FilesList:string;
TrackersList:string;
DelimitedFile:string;
i:Integer;
begin 
stream:=MyFileOpen(TorrentFile,ARES_READONLY_BUT_SEQUENTIAL);
if stream=nil then
begin
//ShowMessage('TorrentFile: '+TorrentFile);
//ShowMessage('stream = nil');
exit;
end;
//showmessage('TTorrentParser.Create');
Parser:=TTorrentParser.Create;
 if Parser.Load(stream) then
 begin
   InfoSL:=TStringList.Create;
   try
    try
     InfoSL.Insert(0,parser.name);
     InfoSL.Insert(1,parser.Comment);
     InfoSL.Insert(2,IntToStr(parser.Size));
     InfoSL.Insert(3,DateTimeToStr(parser.Date));

      if parser.Files.count=1 then
      begin
       thisfile:=(parser.Files[0] as TTorrentSubFile);
       thisfile.Name:=extractfilename(parser.name);
       if length(thisfile.Name)>200 then thisfile.name:=copy(thisfile.name,1,200);
       DelimitedFile:='|'+thisfile.Name+
                        '| |'+thisfile.Path+
                        '| |'+IntToStr(thisfile.Offset)+
                        '| |'+IntToStr(thisfile.Length)+'|';
       InfoSL.Insert(4,'^'+DelimitedFile+'^');
      end else
      begin
       for i:=0 to parser.Files.count-1 do
       begin
        thisfile:=(parser.Files[i] as TTorrentSubFile);
        thisfile.Name:=StripIllegalFileChars(thisfile.Name);
        if length(thisfile.Name)>200 then thisfile.name:=copy(thisfile.name,1,200);
        DelimitedFile:='|'+thisfile.Name+
                        '| |'+thisfile.Path+
                        '| |'+IntToStr(thisfile.Offset)+
                        '| |'+IntToStr(thisfile.Length)+'|';
        if i=0 then
        FilesList:='^'+DelimitedFile else
        if i=parser.Files.count-1 then
        FilesList:=FilesList+'^ ^'+DelimitedFile+'^' else
        FilesList:=FilesList+'^ ^'+DelimitedFile;
       end;
        InfoSL.Insert(4,FilesList);
      end;

     InfoSL.Insert(5,helper_strings.bytestr_to_hexstr(parser.HashValue));  
     InfoSL.Insert(6,Parser.Advt);
     InfoSL.Insert(7,Parser.Releaser);
     InfoSL.Insert(8,Parser.SiteReleaser);       

     TrackersList:='';
     TrackersList:='*'+Parser._Announce+'* ';

     for i:=0 to Parser._Announces.Count-1 do
     begin
        if i=0 then
        TrackersList:='*'+Parser._Announces[i]+'*' else
        if i=Parser._Announces.count-1 then
        TrackersList:=TrackersList+' *'+Parser._Announces[i]+'*' else
        TrackersList:=TrackersList+' *'+Parser._Announces[i]+'*';
     end;      

     InfoSL.Insert(9,TrackersList);

     //InfoSL.Insert(10,Parser.Errors.Text);
     //ShowMessage(Parser.Errors.Text);
     TorrentInfo:=InfoSL.Text;
     Result:=TorrentInfo;
    except
    end;
   finally
     InfoSL.Free;
   end;
 end; //else
  //begin ShowMessage('Bad Parser.Load');
    //ShowMessage(Parser.Errors.Text);
  //end
end;

procedure TPlugin.AddSeeding(WSData: WideString);
var
  ID: WideString;
  TorrentFileName: WideString;
  TorrentFolder: WideString;
  SLData: TStringList;
  //HashValue: string;
begin
  SLData := TStringList.Create;
  try
  SLData.Text := widestrtoutf8str(WSData);
  ID := utf8strtowidestr(SLData[0]);
  TorrentFileName := utf8strtowidestr(SLData[1]);
  TorrentFolder := utf8strtowidestr(SLData[2]);
  //HashValue := SLData[3];
  //ShowMessage(HashValue);

  myshared_folder:={utf8strtowidestr}(TorrentFolder);
  my_torrentFolder:={utf8strtowidestr}(TorrentFolder);
  //ShowMessage(myshared_folder);
  //SetInfo(SLData);
  //ShowMessage('RunService');
  //ShowMessage(WSData);
  //ShowMessage('ID='+ID);
  finally
    SLData.Free;
  end;

  {if thread_down=nil then
  begin
  thread_down:=tthread_download.create(true);
  thread_down.Resume;
  end;}
  //ShowMessage(widestrtoutf8str(TorrentFileName));
  bittorrentUtils.StartSeeding({utf8strtowidestr}(TorrentFileName),{LoadingFileName,}ID);
end;

function TPlugin.SizeProgressiveDownloaded(Hash: WideString):WideString;
var i,k:Integer;
tran:TBitTorrentTransfer;
fpiece:TBitTorrentChunk;
SizeProgressive:int64;
SizeProgressiveWideString: WideString;
begin
Result:= '';
SizeProgressive:=0;
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin  
    //for k := low(tran.fpieces) downto 0 do
    for k:=0 to high(tran.fpieces) do
    begin
      fpiece:=tran.fpieces[k];
      if fpiece.fprogress=fpiece.fsize then
      //if fpiece.downloadable then
      SizeProgressive:=SizeProgressive+fpiece.fsize
      else
      begin
        try
         SizeProgressiveWideString := inttostr(SizeProgressive);
         Result := SizeProgressiveWideString;
        except    
        end;
        Break;
      end;
    end;
  end;
end;
end;

procedure TPlugin.DoProgressiveDownload(Hash: WideString);
var i,k:Integer;
tran:TBitTorrentTransfer;
fpiece:TBitTorrentChunk;
begin
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    for k:=0 to high(tran.fpieces) do
    begin
      fpiece:=tran.fpieces[k];
      fpiece.priority:=(high(tran.fpieces)-k);
    end;
  end;
end;
end;

procedure TPlugin.DoNotProgressiveDownload(Hash: WideString);
var i,k:Integer;
tran:TBitTorrentTransfer;
fpiece:TBitTorrentChunk;
begin
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    for k:=0 to high(tran.fpieces) do
    begin
      fpiece:=tran.fpieces[k];
      fpiece.priority:=0;
    end;
  end;
end;
end;

procedure TPlugin.StartTorrentProgressive(WSData: WideString);
var
  ID: string;
  TorrentFileName: string;
  TorrentFolder: string;
  SLData: TStringList;
begin
  SLData := TStringList.Create;
  try
  SLData.Text := WSData;
  ID := SLData[0];
  TorrentFileName := SLData[1];
  TorrentFolder := SLData[2];

  myshared_folder:={utf8strtowidestr}(TorrentFolder);
  my_torrentFolder:={utf8strtowidestr}(TorrentFolder);
  finally
    SLData.Free;
  end;   

  bittorrentUtils.loadTorrent({utf8strtowidestr}(TorrentFileName),ID,true);
end;

procedure TPlugin.StartTorrent(WSData: WideString);
var
  ID: string;
  TorrentFileName: string;
  TorrentFolder: string;
  SLData: TStringList;
  //HashValue: string;
begin
  SLData := TStringList.Create;
  try
  SLData.Text := WSData;
  ID := SLData[0];
  TorrentFileName := SLData[1];
  TorrentFolder := SLData[2];
  //HashValue := SLData[3];
  //ShowMessage(HashValue);

  myshared_folder:={utf8strtowidestr}(TorrentFolder);
  my_torrentFolder:={utf8strtowidestr}(TorrentFolder);
  //ShowMessage(myshared_folder);
  //SetInfo(SLData);
  //ShowMessage('RunService');
  //ShowMessage(WSData);
  //ShowMessage('ID='+ID);
  finally
    SLData.Free;
  end;

  {if thread_down=nil then
  begin
  thread_down:=tthread_download.create(true);
  thread_down.Resume;
  end;}

  bittorrentUtils.loadTorrent({utf8strtowidestr}(TorrentFileName),ID,false);
end;

procedure TPlugin.StartMagnetTorrentProgressive(WSData: WideString);
var
  ID: string;
  TorrentLink: string;
  TorrentFolder: string;
  SLData: TStringList;
  url:string;
  posi:integer;
begin
  SLData := TStringList.Create;
  try
  SLData.Text := WSData;
  ID := SLData[0];
  TorrentLink := SLData[1];
  TorrentFolder := SLData[2];
  myshared_folder:={utf8strtowidestr}(TorrentFolder);
  my_torrentFolder:={utf8strtowidestr}(TorrentFolder);
  finally
   SLData.Free;
  end;

url:=TorrentLink;

posi:=pos('magnet:?',lowercase(url));
if posi>0 then begin
 add_magnet_link(copy(url,posi,length(url)),ID,true);
 exit;
end;
end;

procedure TPlugin.StartMagnetTorrent(WSData: WideString);
var
  ID: string;
  TorrentLink: string;
  TorrentFolder: string;
  SLData: TStringList;
  url:string;
  posi:integer;
  //HashValue:string;
begin
  SLData := TStringList.Create;
  try
  SLData.Text := WSData;
  ID := SLData[0];
  TorrentLink := SLData[1];
  TorrentFolder := SLData[2];
  //HashValue := SLData[3];
  myshared_folder:={utf8strtowidestr}(TorrentFolder);
  my_torrentFolder:={utf8strtowidestr}(TorrentFolder);
  finally
   SLData.Free;
  end;

url:=TorrentLink;//trim(widestrtoutf8str(TorrentLink));
//set_regstring('General.LastHashLink',url);

{posi:=pos('arlnk://',lowercase(url));
if posi>0 then begin
 add_weblink(copy(url,posi+8,length(url)));
 exit;
end;}

//ShowMessage('id: '+id);
//ShowMessage('id1: '+id);
posi:=pos('magnet:?',lowercase(url));
if posi>0 then begin
 add_magnet_link(copy(url,posi,length(url)),ID,false);
 exit;
end;
end;

procedure TPlugin.ResumeTorrent(Hash: WideString;TorrentFolder: WideString);
var i:integer;
tran:TBitTorrentTransfer;
Find:boolean;
BitTorrentTransfer:tBitTorrentTransfer;
//DelimitedData: WideString;
begin
Find:=false; 

  myshared_folder:={utf8strtowidestr}(TorrentFolder);
  my_torrentFolder:={utf8strtowidestr}(TorrentFolder);

if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  //if tran.fid=ID then
  //ShowMessage(HashValue+' = '+tran.fHashValue);
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    tran.fstate:=dlProcessing;
    BitTorrentDlDb.BitTorrentDb_updateDbOnDisk(GlobTransfer);
    Find:=True;
    //BitTorrentPauseTransfer(tran);
    //vars_global.thread_bittorrent.Terminate;
  end;
end;

//ShowMessage(vars_global.data_Path+'\Data\TempDl\PBTHash_'+Hash+'.dat');

if (Find=false) and
   (FileExists(vars_global.data_Path+'\Data\TempDl\PBTHash_'+Hash+'.dat'))
then
begin
//ShowMessage('Exists');
BitTorrentTransfer:=tBitTorrentTransfer.create;
BitTorrentTransfer.fhashvalue:=helper_strings.hexstr_to_bytestr(Hash);
BitTorrentDlDb.BitTorrentDb_load(BitTorrentTransfer);

if vars_global.bittorrent_Accepted_sockets=nil then vars_global.bittorrent_Accepted_sockets:=tmylist.create;
if vars_global.thread_bittorrent=nil then begin
  vars_global.thread_bittorrent:=tthread_bitTorrent.create(true);
  vars_global.thread_bittorrent.BittorrentTransfers:=tmylist.create;
  vars_global.thread_bittorrent.TrackersThreadList:=TList.create;
  vars_global.thread_bittorrent.TransfersThreadList:=TList.create;
end;
vars_global.thread_bittorrent.BittorrentTransfers.add(BitTorrentTransfer);
//BitTorrentUtils.start_thread_bittorrent;
vars_global.thread_bittorrent.resume;
end;

{if vars_global.BitTorrentTempList=nil then vars_global.BitTorrentTempList:=tmylist.create;
if vars_global.bittorrent_Accepted_sockets=nil then vars_global.bittorrent_Accepted_sockets:=tmylist.create;

  if vars_global.thread_bittorrent=nil then begin
    vars_global.thread_bittorrent:=tthread_bitTorrent.create(true);
     vars_global.thread_bittorrent.BittorrentTransfers:=tmylist.create;
 //    vars_global.thread_bittorrent.BittorrentTransfers.add(bittorrentTransfer);
     vars_global.thread_bittorrent.resume;
  end;
  vars_global.BitTorrentTempList.add(bittorrentTransfer);}

if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  //if tran.fid=ID then
  //ShowMessage(HashValue+' = '+tran.fHashValue);
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    tran.fstate:=dlProcessing;
    BitTorrentDlDb.BitTorrentDb_updateDbOnDisk(Tran);
  end;
end;



//Sleep(3000);

{if (vars_global.thread_bittorrent<>nil)
  and assigned(vars_global.thread_bittorrent) then
  begin
    vars_global.thread_bittorrent.resume;
  end;}

try
//BitTorrentUtils.check_bittorrentTransfers;
except
end;

//showmessage('Stoped');
end;

procedure TPlugin.StopTorrent({ID: WideString;}Hash: WideString);
var i:integer;
tran:TBitTorrentTransfer;
begin
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  //if tran.fid=ID then
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    tran.fstate:=dlPaused;
    //vars_global.thread_bittorrent.BitTorrentPauseTransfer(tran);
    tran.CalculateLeechsSeeds;
    BitTorrentDlDb.BitTorrentDb_updateDbOnDisk(Tran);
    //vars_global.thread_bittorrent.Terminate;
  end;
end;
end;

procedure TPlugin.DeleteTorrent(Hash: WideString);
var i,x,k,index:integer;
tran:TBitTorrentTransfer;
Tracker:TBitTorrentTracker;
begin
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
   index:=vars_global.thread_bittorrent.BittorrentTransfers.indexof(tran);
   if index<>-1 then
   begin
      for x:=0 to tran.Trackers.Count-1 do
      begin
        Tracker:=tran.Trackers[x];
        for k := vars_global.thread_bittorrent.TrackersThreadList.Count - 1 downto 0 do
        begin
          if Tracker.ThreadHandle = TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).Handle then
          begin
            TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).Terminate;
            TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).WaitFor;
            TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).Free;
            vars_global.thread_bittorrent.TrackersThreadList.Delete(k);
            break;
          end;
        end;
      end;

      for k := vars_global.thread_bittorrent.TransfersThreadList.Count - 1 downto 0 do
      begin
          if tran.ThreadHandle = TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).Handle then
          begin
            TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).Terminate;
            TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).WaitFor;
            TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).Free;
            vars_global.thread_bittorrent.TransfersThreadList.Delete(k);
            break;
          end;
      end;

      //vars_global.thread_bittorrent.BittorrentTransfers.delete(index);
      if tran.fstate=dlSeeding then
      tran.Uploadtreeview:=True else
      tran.Uploadtreeview:=False;
      tran.want_cancelled:=True;
      {tran.fstate:=dlCancelled;
      tran.FDlSpeed:=0;
      tran.FUlSpeed:=0;
        try
         if tran.dbstream<>nil then tran.dbstream.size:=0;
         bitTorrentDb_CheckErase(tran);
        except
        end;
     Sleep(100);}
     try
     //vars_global.thread_bittorrent.BittorrentTransfers.Remove(tran);
     //tran.wipeout;
     except
     end;

     //tran.free;
     //tran:=nil;
   end;

  end;
end;
end;

procedure TPlugin.SingleFileTorrent(ID: WideString; FileName: WideString;
    TorrentName: WideString; Comment: WideString; Trackers: WideString;
    WebSeeds: WideString; PrivateTorrent: Bool; SizePart: Integer;
    CreateEncrypted: Bool; ReserveFileOrder: Bool; Related: WideString;
    Advertisement: WideString; Releaser:WideString; SiteReleaser:WideString);
var
  i:Integer;
  InfoCreating:TInfoCreating;
begin   
  InfoCreating := TInfoCreating.Create;
  InfoCreating.HashedData := THashedData.Create;
  
  {InfoCreating.ID := widestrtoutf8str(ID);
  InfoCreating.FileName := widestrtoutf8str(FileName);
  InfoCreating.TorrentName := widestrtoutf8str(TorrentName);
  InfoCreating.Comment := widestrtoutf8str(Comment);
  InfoCreating.Trackers := widestrtoutf8str(Trackers);
  InfoCreating.WebSeeds := widestrtoutf8str(WebSeeds);
  InfoCreating.Related := widestrtoutf8str(Related);
  InfoCreating.Advertisement := widestrtoutf8str(Advertisement);
  InfoCreating.Releaser := widestrtoutf8str(Releaser);
  InfoCreating.SiteReleaser := widestrtoutf8str(SiteReleaser);}

  InfoCreating.ID := (ID);
  InfoCreating.FileName := (FileName);
  InfoCreating.TorrentName := (TorrentName);
  InfoCreating.Comment := (Comment);
  InfoCreating.Trackers := (Trackers);
  InfoCreating.WebSeeds := (WebSeeds);
  InfoCreating.Related := (Related);
  InfoCreating.Advertisement := (Advertisement);
  InfoCreating.Releaser := (Releaser);
  InfoCreating.SiteReleaser := (SiteReleaser);

  
  InfoCreating.Multifile := false;
  InfoCreating.PrivateTorrent := PrivateTorrent;
  InfoCreating.CreateEncrypted := CreateEncrypted;
  InfoCreating.ReserveFileOrder := ReserveFileOrder;

  if SizePart <= 0 then
  InfoCreating.SizePart := 0;
  if SizePart = 1 then
  InfoCreating.SizePart := 16384;
  if SizePart = 2 then
  InfoCreating.SizePart := 32768;
  if SizePart = 3 then
  InfoCreating.SizePart := 65536;
  if SizePart = 4 then
  InfoCreating.SizePart := 131072;
  if SizePart = 5 then
  InfoCreating.SizePart := 262144;
  if SizePart = 6 then
  InfoCreating.SizePart := 524288;
  if SizePart = 7 then
  InfoCreating.SizePart := 1048576;
  if SizePart = 8 then
  InfoCreating.SizePart := 2097152;
  if SizePart = 9 then
  InfoCreating.SizePart := 4194304;
  if SizePart = 10 then
  InfoCreating.SizePart := 8388608;
  if SizePart = 11 then
  InfoCreating.SizePart := 16777216;

  ContainerCreateTorrent.Add(InfoCreating);

  with ContainerCreateTorrent.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoCreating := Items[i];
        if ID = InfoCreating.ID then
        begin
          CreateTorrentThreadList.Add(TCreateTorrentThread.Create(False, InfoCreating));
          break;
        end;
      end;
    finally
      ContainerCreateTorrent.UnlockList;
    end;
end;

procedure TPlugin.CreateFolderTorrent(ID: WideString; FileName: WideString;
    TorrentName: WideString; Comment: WideString; Trackers: WideString;
    WebSeeds: WideString; PrivateTorrent: Bool; SizePart: Integer;
    CreateEncrypted: Bool; ReserveFileOrder: Bool; Related: WideString;
    Advertisement: WideString; Releaser:WideString; SiteReleaser:WideString);
var
//  torrent: TTorrentFile;
//  files: TObjectList;
//  totalsize: int64;
  i:Integer;
  InfoCreating:TInfoCreating;
begin
  InfoCreating := TInfoCreating.Create;
  InfoCreating.HashedData := THashedData.Create;

  {InfoCreating.ID := widestrtoutf8str(ID);
  InfoCreating.FileName := widestrtoutf8str(FileName);
  InfoCreating.TorrentName := widestrtoutf8str(TorrentName);
  InfoCreating.Comment := widestrtoutf8str(Comment);
  InfoCreating.Trackers := widestrtoutf8str(Trackers);
  InfoCreating.WebSeeds := widestrtoutf8str(WebSeeds);
  InfoCreating.Related := widestrtoutf8str(Related);
  InfoCreating.Advertisement := widestrtoutf8str(Advertisement);
  InfoCreating.Releaser := widestrtoutf8str(Releaser);
  InfoCreating.SiteReleaser := widestrtoutf8str(SiteReleaser);}

  InfoCreating.ID := (ID);
  InfoCreating.FileName := (FileName);
  InfoCreating.TorrentName := (TorrentName);
  InfoCreating.Comment := (Comment);
  InfoCreating.Trackers := (Trackers);
  InfoCreating.WebSeeds := (WebSeeds);
  InfoCreating.Related := (Related);
  InfoCreating.Advertisement := (Advertisement);
  InfoCreating.Releaser := (Releaser);
  InfoCreating.SiteReleaser := (SiteReleaser);  

  InfoCreating.Multifile := true;
  InfoCreating.PrivateTorrent := PrivateTorrent;
  InfoCreating.CreateEncrypted := CreateEncrypted;
  InfoCreating.ReserveFileOrder := ReserveFileOrder;

  if SizePart <= 0 then
  InfoCreating.SizePart := 0;
  if SizePart = 1 then
  InfoCreating.SizePart := 16384;
  if SizePart = 2 then
  InfoCreating.SizePart := 32768;
  if SizePart = 3 then
  InfoCreating.SizePart := 65536;
  if SizePart = 4 then
  InfoCreating.SizePart := 131072;
  if SizePart = 5 then
  InfoCreating.SizePart := 262144;
  if SizePart = 6 then
  InfoCreating.SizePart := 524288;
  if SizePart = 7 then
  InfoCreating.SizePart := 1048576;
  if SizePart = 8 then
  InfoCreating.SizePart := 2097152;
  if SizePart = 9 then
  InfoCreating.SizePart := 4194304;
  if SizePart = 10 then
  InfoCreating.SizePart := 8388608;
  if SizePart = 11 then
  InfoCreating.SizePart := 16777216;

  ContainerCreateTorrent.Add(InfoCreating);

  with ContainerCreateTorrent.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoCreating := Items[i];
        if ID = InfoCreating.ID then
        begin
          CreateTorrentThreadList.Add(TCreateTorrentThread.Create(False, InfoCreating));
          break;
        end;
      end;
    finally
      ContainerCreateTorrent.UnlockList;
    end;

end;

function TPlugin.GetInfoTorrentCreating(IDC: WideString): WideString;
var
  i: Integer;
  InfoCreating: TInfoCreating;
  DelimitedData: WideString;
begin
  with ContainerCreateTorrent.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoCreating := Items[i];
        if widestrtoutf8str(IDC) = (InfoCreating.ID) then
        begin
          DelimitedData := '|' + InfoCreating.ID + '| |' + InfoCreating.HashedData.Status + '| |' +
            InfoCreating.HashedData.FileName + '| |' + IntToStr(InfoCreating.HashedData.ProgressMax1) + '| |' +
            IntToStr(InfoCreating.HashedData.ProgressMax2) + '| |' + IntToStr(InfoCreating.HashedData.ProgressPosition1) + '| |' +
            IntToStr(InfoCreating.HashedData.ProgressPosition2) + '|';
          Result := DelimitedData;
          break;
        end;
      end;
    finally
      ContainerCreateTorrent.UnlockList;
    end;
end;

procedure TPlugin.StopCreateTorrentThread(IDC: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoCreating: TInfoCreating;
begin
  Find := False;

  with ContainerCreateTorrent.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoCreating := Items[i];
        if IDC = InfoCreating.ID then
        begin
          ThreadHandle := InfoCreating.ThreadHandle;
          Find := true;
          break;
        end;
      end;
    finally
      ContainerCreateTorrent.UnlockList;
    end;

  if Find = true then
    with CreateTorrentThreadList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TCreateTorrentThread(Items[i]).Handle then
          begin
            TCreateTorrentThread(Items[i]).Terminate;
            TCreateTorrentThread(Items[i]).WaitFor;
            TCreateTorrentThread(Items[i]).Free;
            Delete(i);
            break;
          end;
        end;
      finally
        CreateTorrentThreadList.UnlockList;
      end;
end;

procedure TPlugin.ReleaseCreateTorrentThread(IDC: WideString);
var
  i: Integer;
  Find: boolean;
  ThreadHandle: THandle;
  InfoCreating: TInfoCreating;
begin
  Find := False;

  with ContainerCreateTorrent.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        InfoCreating := Items[i];
        if IDC = InfoCreating.ID then
        begin
          ThreadHandle := InfoCreating.ThreadHandle;
          if (InfoCreating.HashedData.Status = 'completed') or
          (InfoCreating.HashedData.Status = 'stoped') then
          begin
            InfoCreating.HashedData.Free;
            InfoCreating.Free;
            Delete(i);
          end;
          Find := true;
          break;
        end;
      end;
    finally
      ContainerCreateTorrent.UnlockList;
    end;

  if Find = true then
  begin
    with CreateTorrentThreadList.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          if ThreadHandle = TCreateTorrentThread(Items[i]).Handle then
          begin
            if CheckThreadIsAlive(TCreateTorrentThread(Items[i])) = true then
            begin
              TCreateTorrentThread(Items[i]).Terminate;
              TCreateTorrentThread(Items[i]).WaitFor;
              TCreateTorrentThread(Items[i]).Free;
              Delete(i);
            end;
            break;
          end;
        end;
      finally
        CreateTorrentThreadList.UnlockList;
      end;
  end;
end;

procedure TPlugin.DeleteTorrentWithFiles(Hash: WideString);
var i,x,k,index:integer;
tran:TBitTorrentTransfer;
Tracker:TBitTorrentTracker;
begin
try
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do
begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
   index:=vars_global.thread_bittorrent.BittorrentTransfers.indexof(tran);
   if index<>-1 then
   begin
      for x:=0 to tran.Trackers.Count-1 do
      begin
        Tracker:=tran.Trackers[x];
        for k := vars_global.thread_bittorrent.TrackersThreadList.Count - 1 downto 0 do
        begin
          if Tracker.ThreadHandle = TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).Handle then
          begin
            TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).Terminate;
            TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).WaitFor;
            TThreadTracker(vars_global.thread_bittorrent.TrackersThreadList.Items[k]).Free;
            vars_global.thread_bittorrent.TrackersThreadList.Delete(k);
            break;
          end;
        end;
      end;

      for k := vars_global.thread_bittorrent.TransfersThreadList.Count - 1 downto 0 do
      begin
          if tran.ThreadHandle = TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).Handle then
          begin
            TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).Terminate;
            TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).WaitFor;
            TThreadTransfer(vars_global.thread_bittorrent.TransfersThreadList.Items[k]).Free;
            vars_global.thread_bittorrent.TransfersThreadList.Delete(k);
            break;
          end;
      end;

      //vars_global.thread_bittorrent.BittorrentTransfers.delete(index);
      if tran.fstate=dlSeeding then
      begin
        tran.fstate:=dlPaused;
        tran.CalculateLeechsSeeds;
        BitTorrentDlDb.BitTorrentDb_updateDbOnDisk(Tran);
      end;
      //Sleep(10);
      //tran.Uploadtreeview:=True else
      tran.Uploadtreeview:=False;
      tran.want_cancelled:=True;
   end;
  end;
end;
except
end;
end;

function TPlugin.FindTorrent({ID: WideString;}Hash: WideString): WideString;
var i:integer;
tran:TBitTorrentTransfer;
begin
Result:=BoolToStr(False);
if assigned(vars_global.thread_bittorrent) then
begin
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];  
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
    Result:=BoolToStr(True);
    Break;
  end;
  end;
end else
begin
  if (FileExists(vars_global.data_Path+'\Data\TempDl\PBTHash_'+Hash+'.dat')) then
  begin
    Result:=BoolToStr(True);
  end;
end;
end;

function TPlugin.GetInfoTorrent({ID: WideString;}Hash: WideString): WideString;
var i:integer;
tran:TBitTorrentTransfer;
DelimitedData: WideString;
begin
if assigned(vars_global.thread_bittorrent) then
for i:=0 to vars_global.thread_bittorrent.BittorrentTransfers.count-1 do begin
  tran:=vars_global.thread_bittorrent.BittorrentTransfers[i];
  //if tran.fid=ID then
  //ShowMessage(Hash+' = '+bytestr_to_hexstr(tran.fHashValue));
  if ansilowercase(bytestr_to_hexstr(tran.fHashValue))=ansilowercase(Hash) then
  begin
   DelimitedData:='|'+tran.fname+'| |'+
   IntToStr(tran.fdownloaded)+'| |'+
   IntToStr(tran.fuploaded)+'| |'+
   IntToStr(tran.fsize)+'| |'+
   IntToStr(tran.numConnected)+'| |'+
   IntToStr(tran.NumConnectedSeeders)+'| |'+
   IntToStr(tran.NumConnectedLeechers)+'| |'+
   IntToStr(Integer(tran.fstate))+'| |'+
   IntToStr(tran.FDlSpeed)+'| |'+
   IntToStr(tran.FUlSpeed)+'| |'+
   tran.fid+'| |'+
   IntToStr(tran.ffiles.Count)+'| |'+
   IntToStr(tran.fsources.count)+'|';
   Result := DelimitedData;
   Break;
  end;
 end;

 {if assigned(vars_global.BitTorrentTempList) then
for i:=0 to vars_global.BitTorrentTempList.count-1 do begin
  tran:=vars_global.BitTorrentTempList[i];
  if tran.fid=ID then
  begin
   DelimitedData:='|'+tran.fname+'| |'+
   IntToStr(tran.fdownloaded)+'| |'+
   IntToStr(tran.fuploaded)+'| |'+
   IntToStr(tran.fsize)+'| |'+
   IntToStr(tran.numConnected)+'| |'+
   IntToStr(tran.NumConnectedSeeders)+'| |'+
   IntToStr(tran.NumConnectedLeechers)+'| |'+
   IntToStr(Integer(tran.fstate))+'| |'+
   IntToStr(tran.FDlSpeed)+'| |'+
   IntToStr(tran.FUlSpeed)+'|';
   Result := DelimitedData;
  end;
 end;}

end;

function TPlugin.CheckAndGet(ID: WideString): WideString;
var
  i: Integer;
  StatusInProg: string;
  Info: TInfo;
  DelimitedData: WideString;
begin
  with Container.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        Info := Items[i];
        if ID = Info.ID then
        begin
          StatusInProg := StatusInString(Info.InfoInProg.Status);
          DelimitedData := '|' + Info.ID + '| |' + StatusInProg + '| |' +
            Info.InfoInProg.Url + '| |' + Info.InfoInProg.Referer + '| |' +
            Info.InfoInProg.Cookie + '| |' + Info.InfoInProg.Error + '| |' +
            Info.InfoInProg.DTTime + '| |' + Info.InfoInProg.DT + '| |' +
            Info.InfoInProg.DataPost + '| |' + Info.InfoInProg.Log + '| |' +
            Info.InfoInProg.ExtraHeader + '| |' + Info.InfoInProg.ExtraData +
            '|';
          Result := DelimitedData;
          break;
        end;
      end;
    finally
      Container.UnlockList;
    end;
end;

function TPlugin.GetActive: Bool;
begin
  Result := Settings.Active;
end;

procedure TPlugin.SetActive(Value: Bool);
begin
  Settings.Active := Value;
end;

function TPlugin.GetCountThreads: Integer;
begin
  Result := Settings.CountThreads;
end;

procedure TPlugin.SetCountThreads(Value: Integer);
begin
  Settings.CountThreads := Value;
end;

function TPlugin.GetUsePlugCountThreads: Bool;
begin
  Result := Settings.UseNumThreadsPlug;
end;

procedure TPlugin.SetUsePlugCountThreads(Value: Bool);
begin
  Settings.UseNumThreadsPlug := Value;
end;

function TPlugin.GetPremiumContent: Bool;
begin
  Result := PremiumContent;
end;

procedure TPlugin.SetPremiumContent(Value: Bool);
begin
  PremiumContent := Value;
end;

function TPlugin.GetUsePremium: Bool;
begin
  Result := Settings.UsePremium;
end;

procedure TPlugin.SetUsePremium(Value: Bool);
begin
  Settings.UsePremium := Value;
end;

function TPlugin.GetLoginPremium: WideString;
begin
  Result := Settings.LoginPremium;
end;

procedure TPlugin.SetLoginPremium(Value: WideString);
begin
  Settings.LoginPremium := Value;
end;

function TPlugin.GetPasswordPremium: WideString;
begin
  Result := Settings.PasswordPremium;
end;

procedure TPlugin.SetPasswordPremium(Value: WideString);
begin
  Settings.PasswordPremium := Value;
end;

function TPlugin.GetUrlSalePremium: WideString;
begin
  Result := UrlSalePremium;
end;

procedure TPlugin.SetUrlSalePremium(Value: WideString);
begin
  UrlSalePremium := Value;
end;

function TPlugin.GetRefUrlPremium: WideString; 
begin
  Result := UrlRefPremium;
end;

procedure TPlugin.SetRefUrlPremium(Value: WideString);
begin
  UrlRefPremium := Value;
end;

function TPlugin.GetNumUsualSect: Integer;
begin
  Result := Settings.NumUsualSect;
end;

procedure TPlugin.SetNumUsualSect(Value: Integer);
begin
  Settings.NumUsualSect := Value;
end;

function TPlugin.GetNumProxySect: Integer;
begin
  Result := Settings.NumProxySect;
end;

procedure TPlugin.SetNumProxySect(Value: Integer);
begin
  Settings.NumProxySect := Value;
end;

function TPlugin.GetSubstituteProxySection: Bool;
begin
  Result := Settings.SubstituteProxySection;
end;

procedure TPlugin.SetSubstituteProxySection(Value: Bool);
begin
  Settings.SubstituteProxySection := Value;
end;

procedure prendi_prefs_reg2;
begin
socks_type:=SoctNone;
socks_username:='';
socks_password:='';
MAX_OUTCONNECTIONS:=4;
hash_throttle:=1;
queue_firstinfirstout:=false;

panel6sizedefault:=50;
default_width_chat:=100;

max_dl_allowed:=100;
up_band_allow:=0;
down_band_allow:=0;
max_ul_per_ip:=6;
limite_upload:=10;

myport:=random(60000)+5000;
my_mdht_port:=random(60000)+5000;

vars_global.user_sex:=0;
vars_global.user_country:=0;
vars_global.user_stateCity:='';
vars_global.user_age:=0;
vars_global.user_personalMessage:='';      
end;

procedure init_gui_second;
begin
 prendi_prefs_reg;
end;   

procedure init_core_first;
var tmp_str:string;
 desktopPath:widestring;
begin

try
LanIPC:=getlocalip;
LanIPS:=ipint_to_dotstring(LanIPC);
except
 LanIPC:=0;
 LanIPS:=cAnyHost;
end;

getcursorpos(prev_cursorpos);
vars_global.minutes_idle:=0;

desktopPath:=Get_Desktop_Path;

    try
//     myshared_folder:=prendi_reg_my_shared_folder(desktopPath);
//     myshared_folder:='e:\Downloads\Test\'{Edit1.Text};

    except
       //myshared_folder:='c:\';
    end;


     try
//     my_torrentFolder:=regGetMyTorrentFolder(desktopPath);
//     my_torrentFolder:='e:\Downloads\Test\'{Edit1.Text};

     except
//       my_torrentFolder:=myshared_folder;
     end;

    erase_dir_recursive(data_path+widestring('\Temp'));


   try

//      vars_global.versioneares:=get_program_version;
       tmp_str:=vars_global.versioneares;                 //1.8.1.2927
        delete(tmp_str,1,pos('.',tmp_str));   //8.1.2927
         delete(tmp_str,1,pos('.',tmp_str));  //1.2927
          delete(tmp_str,1,pos('.',tmp_str)); //2927
           vars_global.buildno:=strtointdef(tmp_str,DEFAULT_BUILD_NO);

   except
    vars_global.versioneares:=ARES_VERS;
    vars_global.buildno:=DEFAULT_BUILD_NO;
   end;

 if Win32Platform=VER_PLATFORM_WIN32_NT then begin // OS supports setfilepointerEX?
  helper_diskio.kern32handle:=SafeLoadLibrary('kernel32.dll');
  if helper_diskio.kern32handle<>0 then
   @helper_diskio.SetfilePointerEx:=GetProcAddress(helper_diskio.kern32handle,'SetFilePointerEx');
 end;

 try
 vars_global.InternetConnectionOK:=utility_ares.isInternetConnectionOk;
 except
 end;

 randseed:=gettickcount;

mysupernodes.mysupernodes_create;
 lista_shared:=tmylist.create;
 lista_socket_accept_down:=tmylist.create;
 lista_risorse_temp:=tthreadlist.create;
 lista_risorsepartial_temp:=tthreadlist.create;
 lista_socket_temp_proxy:=tmylist.create;
 lista_push_nostri:=tmylist.create;
 lista_pushed_chatrequest:=tmylist.create;
 relayed_direct_chats:=tthreadlist.create;
 DHT_hashFiles:=TThreadList.create;
 DHT_KeywordFiles:=TThreadList.create;
 ares_aval_nodes:=tthreadlist.create;

 if lista_down_temp=nil then lista_down_temp:=tmylist.create;

 scan_start_time:=gettickcount;

 if thread_down=nil then thread_down:=tthread_download.create(true);
 if share=nil then share:=tthread_share.create(true);
 if thread_up=nil then thread_up:=tthread_upload.create(true);
// if client=nil then client:=tthread_client.create(false);
 if threadDHT=nil then threadDHT:=tthread_dht.create(false);
  

 with share do begin
  paused:=false; // false
  juststarted:=true; //true
  resume;
 end;

 try
   vars_global.check_opt_gen_autostart_checked:=false;
   reg_toggle_autostart;
   mainGui_initprefpanel;
 except
 end;

 thread_down.Resume;
 thread_up.Resume;

should_show_prompt_nick:=true; //true

end;

procedure init_global_vars;
begin

 randomize;

 vars_global.myport:=strtointdef('26018',80);
 if ((vars_global.myport<1) or (vars_global.myport>65535)) then vars_global.myport:=80;
// set_reginteger('Transfer.ServerPort',vars_global.myport);

 blendPlaylistForm:=nil;
 vars_global.IDEIsRunning:=false;
 vars_global.InternetConnectionOK:=false;
 vars_global.StopAskingChatServers:=false;
 vars_global.trayinternetswitch:=false; 
 relayed_direct_chats:=nil;
 client_has_relayed_chats:=false;
 vars_global.need_chatroom_update_message:=false;
 vars_global.should_update_chatroom_avatar:=false;
 vars_global.isSortingPerAvatar:=false;

 DHT_availableContacts:=0; // need bootstrap?
 DHT_AliveContacts:=0;
 DHT_possibleBootstrapClientIP:=0;
 DHT_possibleBootstrapClientPort:=0;
 DHT_hashFiles:=nil;
 DHT_KeywordFiles:=nil;
 DHT_LastPublishKeyFiles:=0;
 DHT_LastPublishHashFiles:=0;  

 vars_global.versioneares:=ARES_VERS;

 lista_down_temp:=nil;

 BitTorrentTempList:=nil;
 bittorrent_Accepted_sockets:=nil;
 vars_global.thread_bittorrent:=nil;  

 app_minimized:=false;
 last_shown_SRCtab:=0;
 typed_lines_chat:=nil;
 ending_session:=false;
 chat_favorite_height:=0;
 vars_global.closing:=false;
 initialized:=false;
 cambiato_manual_folder_share:=false;
 isvideoplaying:=false;
 allow_regular_paths_browse:=true;  //true
 cambiato_setting_autoscan:=false;
 program_start_time:=gettickcount;
 changed_download_hashes:=false;
 ShareScans:=0;
 shufflying_playlist:=false;
 stopped_by_user:=false;
 logon_time:=0;
 vars_global.was_on_src_tab:=false;
 velocita_att_upload:=0;
 velocita_att_download:=0;
 hash_select_in_library:='';
 ever_pressed_chat_list:=false;
 hashing:=false;
 queue_firstinfirstout:=true;
 numero_pvt_open:=0;
 socks_type:=SoctNone;
 socks_password:='';
 socks_username:='';
 socks_ip:='';
 socks_port:=0;
 ip_user_granted:=0;
 port_user_granted:=0;
 ip_alt_granted:=0;
 image_less_top:=-1;
 image_more_top:=-1;
 image_back_top:=-1;
 MAX_SIZE_NO_QUEUE:=256*KBYTE;
 queue_length:=0;
 numero_upload:=0;
 numero_download:=0;
 numTorrentDownloads:=0;
 numTorrentUploads:=0;
 speedTorrentDownloads:=0;
 speedTorrentUploads:=0;
 downloadedBytes:=0;
 BitTorrentDownloadedBytes:=0;
 BitTorrentUploadedBytes:=0;
 numero_queued:=0;
 localip:=cAnyHost;
 graphIsDownload:=false;
 graphIsUpload:=false;
 handle_obj_graphhint:=INVALID_HANDLE_VALUE;
 panel6sizedefault:=175;
 default_width_chat:=170;
 num_seconds:=0;
 up_band_allow:=0;
 down_band_allow:=0;
 im_firewalled:=true;  //true
 update_my_nick:=false;
 last_chat_req:=0;
 last_mem_check:=0;
 need_rescan:=false;
 playlist_visible:=false;
 should_send_channel_list:=false;
 my_shared_count:=0;
 oldhintposy:=0;
 oldhintposx:=0;
 partialUploadSent:=0;
 speedUploadPartial:=0;

 helper_diskio.SetfilePointerEx:=nil;
 helper_diskio.kern32handle:=0;

end;

procedure init_threads_var;
begin
   search_dir:=nil;
   thread_down:=nil;
   thread_up:=nil;
   hash_server:=nil;   
   threadDHT:=nil;
   share:=nil;
//   client:=nil;
end;

procedure init_lists;
begin
 lista_shared:=nil;
 lista_socket_accept_down:=nil;
 lista_risorse_temp:=nil;
 lista_risorsepartial_temp:=nil;
 lista_socket_temp_proxy:=nil;
 list_chatchan_visual:=tmylist.create;
 src_panel_list:=tmylist.create;
 chat_chanlist_backup:=tmylist.create;
 fresh_downloaded_files:=nil;
end;

function Tnt_CreateDirectoryW(lpPathName: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL;
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
    Result := CreateDirectoryW{TNT-ALLOW CreateDirectoryW}(lpPathName, lpSecurityAttributes)
  else
    Result := CreateDirectoryA{TNT-ALLOW CreateDirectoryA}(PAnsiChar(AnsiString(lpPathName)), lpSecurityAttributes);
end;

procedure init_gui_first;  //1 second after oncreate?
begin

 init_global_vars;
 init_threads_var;
 init_lists;

  //font_chat:=tfont.create;

 if PortableApp then
 begin
   try
     app_path:=AnsiLowerCase(BTServicePath);
     data_path:=app_path;
     Tnt_createdirectoryW(pwidechar(data_path),nil);
   except
   end;   
 end
 else
 begin
  try
   app_path:=get_app_path;
   if Win32Platform=VER_PLATFORM_WIN32_NT then begin
    data_path:=Get_App_DataPath+'\'+appname;
    Tnt_createdirectoryW(pwidechar(data_path),nil);
   end else data_path:=app_path;

  except
  end;
 end;

end;      


procedure global_shutdown3(dummy:boolean);
begin
{try
 erase_dir_recursive(data_path+'\Temp');
 erase_emptydir(data_path+'\Data\TempDl');
 erase_directory(data_path+'\Data\TempUl');
except
end;}

{try
if Assigned(thread_down) then
if thread_down<>nil then begin
 thread_down.waitfor;
 thread_down.free;
 thread_down:=nil;
end;
except
end;}

{try
if Assigned(threadDHT) then
if threadDHT<>nil then begin
 threadDHT.waitfor;
 threadDHT.free;
 threadDHT:=nil;
end;
except
end;}

{try
if Assigned(hash_server) then
if hash_server<>nil then begin
  hash_server.WaitFor;
  hash_server.free;
  hash_server:=nil;
end;
except
end;}

{try
if Assigned(thread_up) then
if thread_up<>nil then begin
 thread_up.waitfor;
 thread_up.free;
 thread_up:=nil;
end;
except
end;}

{try
if Assigned(vars_global.thread_bittorrent) then
if vars_global.thread_bittorrent<>nil then begin
 vars_global.thread_bittorrent.waitfor;
 vars_global.thread_bittorrent.free;
 vars_global.thread_bittorrent:=nil;
end;
except
end;}

{try
aresnodes_savetodisk(ares_aval_nodes);
aresnodes_freeList(ares_aval_nodes);
except
end;}

{if helper_diskio.kern32handle<>0 then
FreeLibrary(helper_diskio.kern32handle);}
//FreeAndNil(chatTabs);

//sleep(100);

 {terminator.terminate;
 terminator.waitfor;
 terminator.free;}

//sleep(100);
end;

procedure global_shutdown2;
begin
 {terminator:=tthread_terminator.create(false);
 try
 if share<>nil then begin
  need_rescan:=false;
   share.terminate;
   exit;
 end;
 except
 end;}
 global_shutdown3(true);
end;

procedure global_shutdown;
begin
if vars_global.closing then exit;
vars_global.closing:=true;

 try
 //if Assigned(thread_down) then
 if thread_down<>nil then
 begin
 thread_down.Terminate;
 thread_down.WaitFor;
 thread_down.Free;
 thread_down:=nil;
 end;
 except
 end;

 try
 //if Assigned(thread_up) then
 if thread_up<>nil then
 begin
 thread_up.Terminate;
 thread_up.WaitFor;
 thread_up.Free;
 thread_up:=nil;
 end;
 except
 end;

 try
 //if Assigned(hash_server) then
 if hash_server<>nil then
 begin
  hash_server.terminate;
  hash_server.WaitFor;
  hash_server.free;
  hash_server:=nil;
 end;
 //if Assigned(client_chat) then
 {if client_chat<>nil then
 begin
 client_chat.terminate;
 client_chat.WaitFor;
 client_chat.Free;
 client_chat:=nil;
 end;}
 //if Assigned(threadDHT) then
 if threadDHT<>nil then
 begin
 threadDHT.terminate;
 threadDHT.WaitFor;
 threadDHT.Free;
 threadDHT:=nil;
 end;
 //if Assigned(vars_global.thread_bittorrent) then
 if vars_global.thread_bittorrent<>nil then
 begin
 vars_global.thread_bittorrent.terminate;
 vars_global.thread_bittorrent.WaitFor;
 vars_global.thread_bittorrent.Free;
 vars_global.thread_bittorrent:=nil;
 end;
 except
 end;

 try
 mysupernodes.mysupernodes_free;
 except
 end;
 try
 list_chatchan_visual.Free;
 except
 end;
 try
 src_panel_list.Free;
 except
 end;
 try
 chat_chanlist_backup.Free;
 except
 end;



 try
 lista_shared.Free;
 lista_socket_accept_down.Free;
 lista_risorse_temp.Free;
 lista_risorsepartial_temp.Free;
 lista_socket_temp_proxy.Free;
 lista_push_nostri.Free;
 lista_pushed_chatrequest.Free;
 relayed_direct_chats.Free;
 DHT_hashFiles.Free;
 DHT_KeywordFiles.Free;
 ares_aval_nodes.Free;
 lista_down_temp.Free;
 except
 end;

 try
 //if Assigned(thread_down) then
 if share<>nil then
 begin
 share.Terminate;
 share.WaitFor;
 share.Free;
 share:=nil;
 end;
 except
 end;

try
set_NEWtrusted_metas;
except
end;

 try
 if program_start_time>0 then stats_uptime_write(program_start_time,program_totminuptime);
 stats_maxspeed_write;
 except
 end;   

global_shutdown2;
end;

function Init(const ACore: ICore): IPlugin; safecall;
var
  Buffer: array [0 .. MAX_PATH] of char;
  FNPlugin:string;
  IniFName:string;
begin
  Result := TPlugin.Create(ACore);
  PortableApp:=true;
  try
  GetModuleFileName(HInstance, Buffer, MAX_PATH);
  except
  end;
  PluginName := Buffer;
  PluginName := AnsiLowerCase(PluginName);
  FNPlugin := ExtractFileName(PluginName);
  BTServicePath := ChangeFileExt(PluginName,'');
  IniFName:=ChangeFileExt(FNPlugin,'.ini');
  IniName := BTServicePath + '\' + IniFName;
  ProgressiveDL:=False;
  CreateTorrentThreadList := TThreadList.Create;
  ThreadList := TThreadList.Create;
  ThreadTrackersList := TThreadList.Create;
  ThreadFilesList := TThreadList.Create;
  ThreadPeersList := TThreadList.Create;
  ThreadPiecesList := TThreadList.Create;
  Container := TThreadList.Create;
  ContainerCreateTorrent := TThreadList.Create;
  TrackersContainer := TThreadList.Create;
  FilesContainer := TThreadList.Create;
  PeersContainer := TThreadList.Create;
  PiecesContainer := TThreadList.Create;
  Settings := TSettings.Create;
  InitializeCriticalSection(ServiceSection);
  InitializeCriticalSection(TrackerCriticalSection);
  ReadIniParams;

  init_gui_first;
  init_gui_second;
  init_core_first;   
end;

procedure Done; safecall;
begin
  global_shutdown;
  Sleep(500);
  WriteIniParams;
  CreateTorrentThreadList.Free;
  ThreadList.Free;
  ThreadTrackersList.Free;
  ThreadFilesList.Free;
  ThreadPeersList.Free;
  ThreadPiecesList.Free;
  ContainerCreateTorrent.Free;
  Container.Free;
  TrackersContainer.Free;
  FilesContainer.Free;
  PeersContainer.Free;
  PiecesContainer.Free;
  Settings.Free;
  DeleteCriticalSection(ServiceSection);
  DeleteCriticalSection(TrackerCriticalSection);
end;

exports Init name SPluginInitFuncName, Done name SPluginDoneFuncName;

end.
