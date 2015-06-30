unit PluginAPI;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

interface

uses
  //{$IFDEF DELPHI7_LVL}
  {$IFDEF DELPHIXE3_LVL}
  Winapi.Windows,
  Winapi.ActiveX;
  {$ELSE}
  Windows,
  ActiveX;
  {$ENDIF }

  {$IFDEF VER150}
  {$ELSE}

  {$ENDIF } //{$IFEND}
//  Windows,
//  ActiveX;
  

type
{$IFDEF UNICODE}
  PtrUInt = NativeUInt;
  PtrInt = NativeInt;
{$ELSE}
  PtrUInt = Cardinal;
  PtrInt = Integer;
{$ENDIF}

  IDestroyNotify = interface
    ['{B50C8ABE-A10A-4BD9-AA17-0311326FE1A6}']
    procedure Delete; safecall;
  end;

  ILoadNotify = interface
    ['{16A8B203-DED1-479E-AEB9-7ACAB1734F37}']
    procedure Loaded; safecall;
  end;

  ICore = interface
    ['{602AFD4B-D766-4352-BA77-91AACCB8981D}']
    // private
    function GetVersion: Integer; safecall;
    // public
    property Version: Integer read GetVersion;
  end;

  IPlugin = interface
    ['{631B96BB-1E7E-407D-83F1-5C673D2B5A15}']
    // private
    function GetID: TGUID; safecall;
    function GetName: WideString; safecall;
    function GetVersion: WideString; safecall;
    function GetAuthorName: WideString; safecall;
    function GetEmailAuthor: WideString; safecall;
    function GetSiteAuthor: WideString; safecall;
    function GetPluginType: Integer; safecall;
    // public
    property ID: TGUID read GetID;
    property Name: WideString read GetName;
    property Version: WideString read GetVersion;
    property AuthorName: WideString read GetAuthorName;
    property EmailAuthor: WideString read GetEmailAuthor;
    property SiteAuthor: WideString read GetSiteAuthor;
    property PluginType: Integer read GetPluginType;
  end;

  IPlugins = interface
    ['{AB739898-6A48-4876-A9FF-FFE89B409A56}']
    // private
    function GetCount: Integer; safecall;
    function GetPlugin(const AIndex: Integer): IPlugin; safecall;
    // public
    property Count: Integer read GetCount;
    property Plugins[const AIndex: Integer]: IPlugin read GetPlugin; default;
  end;

  IAssociation = interface
    ['{DBAC2E21-6A16-4FB2-82AB-2F6E9383263D}']
    // private
    procedure MagnetAssociation(ProgName:WideString;Assoc: Bool); safecall;
    procedure BittorrentAssociation(ProgName:WideString;Assoc: Bool); safecall;
  end;

  IBTServicePluginBitSettings = interface
    ['{93C0691B-2F55-454F-B897-7C47AC82B759}']
    // private
    function GetBittorrentPort:Integer; safecall;
    function GetUpBandAllow:Integer; safecall;
    function GetDownBandAllow:Integer; safecall;
    function GetInconidleChecked:Bool; safecall;
    function GetLimiteUpload:Integer; safecall;
    function GetUlPerIp:Integer; safecall;
    function GetDlAllowed:Integer; safecall;
    procedure SetBittorrentPort(Port: Integer); safecall;
    procedure SetUpBandAllow(UpBandAllow: Integer); safecall;
    procedure SetDownBandAllow(DownBandAllow: Integer); safecall;
    procedure SetInconidleChecked(InconidleChecked: Bool); safecall;
    procedure SetLimiteUpload(LimiteUpload: Integer); safecall;
    procedure SetUlPerIp(UlPerIp: Integer); safecall;
    procedure SetDlAllowed(DlAllowed: Integer); safecall;
  end;

  IBTServicePluginAddTrackers = interface
    ['{1A223065-A71E-40B0-B5F9-2B0BEA0957CB}']
    // private
    procedure AddTrackers(Hash: WideString; Trackers: WideString); safecall;
  end;

  IBTServicePluginUpdateTracker = interface
    ['{3F50268D-8F9F-4F00-9FC2-DDE1CCB9F46D}']
    // private
    procedure UpdateTracker(Hash: WideString; UrlTracker: WideString); safecall;
  end;

  IBTServicePluginTrackersInfo = interface
    ['{6C52BF06-B548-484D-9CB9-E82B9256368D}']
    // private
    function GetTrackersInfo(Hash: WideString): WideString; safecall;
    function CheckTrackersStatus(Hash: WideString): WideString; safecall;
    function GetDataTrackers(Hash: WideString): WideString; safecall;
    procedure StopTrackersThread(Hash: WideString); safecall;
    procedure ReleaseTrackersThread(Hash: WideString); safecall;
  end;

  IBTServicePluginPiecesInfo = interface
    ['{DBA99578-A074-4160-93BD-2389718AFB82}']
    // private
    function GetPiecesInfo(Hash: WideString): WideString; safecall;
    function CheckPiecesStatus(Hash: WideString): WideString; safecall;
    function GetDataPieces(Hash: WideString): WideString; safecall;
    procedure StopPiecesThread(Hash: WideString); safecall;
    procedure ReleasePiecesThread(Hash: WideString); safecall;
  end;

  IBTServicePluginFilesInfo = interface
    ['{A3737F1E-D88A-4AC0-8BF8-D7C2D23999ED}']
    // private
    function GetFilesInfo(Hash: WideString): WideString; safecall;
    function CheckFilesStatus(Hash: WideString): WideString; safecall;
    function GetDataFiles(Hash: WideString): WideString; safecall;
    procedure StopFilesThread(Hash: WideString); safecall;
    procedure ReleaseFilesThread(Hash: WideString); safecall;
  end;

  IBTServicePluginPeersInfo = interface
    ['{3FC3A677-24F7-4FFB-99A7-6A6BDD6EFD96}']
    // private
    function GetPeersInfo(Hash: WideString): WideString; safecall;
    function CheckPeersStatus(Hash: WideString): WideString; safecall;
    function GetDataPeers(Hash: WideString): WideString; safecall;
    procedure StopPeersThread(Hash: WideString); safecall;
    procedure ReleasePeersThread(Hash: WideString); safecall;
  end;

  IBTCreateTorrent = interface
    ['{1E5160B2-7EAF-4904-9DFE-8979685DFCDD}']
    // private
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
  end;

  IBTDeleteTorrent = interface
    ['{EB07B30E-CB4D-4EE7-9262-DC35E8DE44A4}']
    // private
    procedure DeleteTorrentWithFiles(Hash: WideString); safecall;
  end;

  IBTServiceAddSeeding = interface
    ['{C2C97DDD-02EC-46B3-AFBA-FEB34E24D89B}']
    // private
    procedure AddSeeding(WSData: WideString); safecall;
  end;

  IAdsence = interface
    ['{4E07FE4C-6474-4AAB-9E33-3B50EA0BB472}']
    // private
    function GetAdsenceLinks: WideString; safecall;
    function GetAdsenceShow: Bool; safecall;
    function GetIntervalUpdateAdsence: Integer; safecall;
    function GetPreventClosingAdsence: Bool; safecall;
  end;

  IBTServicePluginProgressive = interface
    ['{E8F609D0-5478-4470-8724-1DCAD81B6768}']
    // private
    function SizeProgressiveDownloaded(Hash: WideString):WideString; safecall;
    procedure DoProgressiveDownload(Hash: WideString); safecall;
    procedure DoNotProgressiveDownload(Hash: WideString); safecall;
    procedure StartTorrentProgressive(WSData: WideString); safecall;
    procedure StartMagnetTorrentProgressive(WSData: WideString); safecall;
  end;

  IBTServicePlugin = interface
    ['{A1AB40D2-B5F8-4EE8-A6AE-3C5E7519409B}']
    // private
    function GetStatusTorrent(Hash: WideString): WideString; safecall;
    function GetInfoTorrentFile(TorrentFile: WideString):WideString; safecall;
    procedure StartTorrent(WSData: WideString); safecall;
    procedure StartMagnetTorrent(WSData: WideString); safecall;
    procedure ResumeTorrent({ID: WideString;}Hash: WideString;TorrentFolder: WideString); safecall;
    procedure StopTorrent({ID: WideString;}Hash: WideString); safecall;
    function FindTorrent({ID: WideString;}Hash: WideString): WideString; safecall;
    function GetInfoTorrent({ID: WideString;}Hash: WideString): WideString; safecall;
    procedure DeleteTorrent(Hash: WideString); safecall;
  end;

  IServicePlugin = interface
    ['{ACDC5A55-1BC3-497B-AD19-2C6D3E9132C8}']
    // private
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
    // procedure CheckAndGet(ID:WideString;out OutID:WideString;
    // out Status:WideString;out Url:WideString;out Referer:WideString;
    // out Cookie:WideString;out Error:WideString;out DTTime:WideString;
    // out DT:WideString;out DataPost:WideString;out Log:WideString;
    // out ExtraHeader:WideString;out ExtraData:WideString); safecall;
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
      HeightForm: Integer; Lang: WideString { ;
        const AlphaSkin: IStream } ); safecall;
  end;

  IAddDownload = interface
    ['{80283BC6-98B7-487A-B56C-7634903E358D}']
    function AddDownload(ID: WideString): WideString; safecall;
    procedure CompleteAddDownload(WSData: WideString); safecall;
  end;

  ITrackerSupport = interface
    ['{23CB7D6D-1E2F-463E-B632-353216B7C793}']
    function GetTrackerSupport: Bool; safecall;
  end;

  ISelf = interface
    ['{656DE702-7433-4F2A-B3A8-0F6BBB32F2C2}']
    // private
    function GetIndex: Integer; safecall;
    // public
    property Index: Integer read GetIndex;
  end;

  IExportImportPluginInfo = interface
    ['{D6B90C88-647D-4265-9052-2EE1BD274979}']
    // private
    function GetMask: WideString; safecall;
    function GetDescription: WideString; safecall;
    // public
    property Mask: WideString read GetMask;
    property Description: WideString read GetDescription;
  end;

  IExportPlugin = interface(IExportImportPluginInfo)
    ['{09428378-34BA-4326-8550-BF1CA72FDF53}']
    procedure ExportRTF(const ARTF: IStream; const AFileName: WideString);
      safecall;
  end;

  IImportPlugin = interface(IExportImportPluginInfo)
    ['{6C85B093-7AAF-4EF0-B98E-D9DBDE950718}']
    procedure ImportRTF(const AFileName: WideString; const ARTF: IStream);
      safecall;
    function ExportPlugin: TGUID; safecall;
  end;

  INotifyEvent = interface
    ['{80B8A93C-B69B-49BA-BD7C-749629C9D97B}']
    procedure Execute(Sender: IInterface); safecall;
  end;

  IMenuItem = interface
    ['{B1A0A830-532B-4573-AE19-33EAA4D76096}']
    // private
    function GetCaption: WideString; safecall;
    function GetChecked: Bool; safecall;
    function GetEnabled: Bool; safecall;
    function GetHint: WideString; safecall;
    procedure SetCaption(const AValue: WideString); safecall;
    procedure SetChecked(const AValue: Bool); safecall;
    procedure SetEnabled(const AValue: Bool); safecall;
    procedure SetHint(const AValue: WideString); safecall;
    // public
    property Caption: WideString read GetCaption write SetCaption;
    property Checked: Bool read GetChecked write SetChecked;
    property Enabled: Bool read GetEnabled write SetEnabled;
    property Hint: WideString read GetHint write SetHint;
    procedure RegisterExecuteHandler(const AEventHandler: INotifyEvent);
      safecall;
  end;

  IMenuManager = interface
    ['{216082F8-8FE8-4B51-83E5-C8324452AD18}']
    function CreateMenuItem: IMenuItem; safecall;
    procedure DeleteMenuItem(var AItem: IMenuItem); safecall;
  end;

  TEditorSearchTypes = DWORD;

const
  esfWholeWord = 0;
  esfMatchCase = 1;

type
  IEditor = interface
    ['{F82E46C3-A744-4137-B9A0-242E50CC0041}']
    // private
    // function GetText: WideString; safecall;
    // procedure SetText(const AValue: WideString); safecall;
    // function GetSelText: WideString; safecall;
    // procedure SetSelText(const AValue: WideString); safecall;
    // function GetSelStart: Integer; safecall;
    // procedure SetSelStart(const AValue: Integer); safecall;
    // function GetSelLength: Integer; safecall;
    // procedure SetSelLength(const AValue: Integer); safecall;
    // function GetModified: BOOL; safecall;
    // function GetCanUndo: BOOL; safecall;
    // function GetCaretPos: TPoint; safecall;
    // procedure SetCaretPos(const AValue: TPoint); safecall;

    // public
    // property Text: WideString read GetText write SetText;
    // property SelText: WideString read GetSelText write SetSelText;
    // property SelStart: Integer read GetSelStart write SetSelStart;
    // property SelLength: Integer read GetSelLength write SetSelLength;
    // procedure SelectAll; safecall;
    // property Modified: BOOL read GetModified;
    // property CanUndo: BOOL read GetCanUndo;
    // procedure Undo; safecall;
    // procedure ClearUndo; safecall;
    // procedure Clear; safecall;
    // procedure ClearSelection; safecall;
    // procedure CopyToClipboard; safecall;
    // procedure CutToClipboard; safecall;
    // procedure PasteFromClipboard; safecall;
    // property CaretPos: TPoint read GetCaretPos write SetCaretPos;
    // function FindText(const SearchStr: WideString; const StartPos, Length: Integer; Options: TEditorSearchTypes): Integer; safecall;
  end;

  IApplicationWindows = interface
    ['{2E3A7D92-4E59-4C63-B0CB-4752C089C970}']
    // private
    function GetApplicationWnd: HWND; safecall;
    function GetMainWnd: HWND; safecall;
    function GetActiveWnd: HWND; safecall;
    function GetClientWnd: HWND; safecall;
    function GetPopupCtrlWnd: HWND; safecall;
    // public
    property ApplicationWnd: HWND read GetApplicationWnd;
    property MainWnd: HWND read GetMainWnd;
    property ActiveWnd: HWND read GetActiveWnd;
    property ClientWnd: HWND read GetClientWnd;
    property PopupCtrlWnd: HWND read GetPopupCtrlWnd;

    procedure ModalStarted; safecall;
    procedure ModalFinished; safecall;

    procedure ProcessMessages; safecall;
    procedure HandleMessage; safecall;
  end;

  IAppIcon = interface
    ['{ADBA8082-9BFF-481C-939E-6C1DCB2D9D85}']
    // private
    function GetSmall: HICON; safecall;
    function GetLarge: HICON; safecall;
    // public
    property Small: HICON read GetSmall;
    property Large: HICON read GetLarge;
  end;

type
  TInitPluginFunc = function(const ACore: ICore): IPlugin; safecall;
  TDonePluginFunc = procedure; safecall;

const
  SPluginInitFuncName = '927AAB81591D41B896E8A0A8E68BF5DE';
  SPluginDoneFuncName = SPluginInitFuncName + '_done';
  SPluginExt = '.pld';

  E_ArgumentException = HRESULT($8004BAB3);
  E_ArgumentOutOfRangeException = HRESULT($80040F15);
  E_PathTooLongException = HRESULT($8004CC22);
  E_NotSupportedException = HRESULT($8004B97A);
  E_DirectoryNotFoundException = HRESULT($80042E5D);
  E_FileNotFoundException = HRESULT($8004B072);
  E_NoConstructException = HRESULT($8004AB91);
  E_Abort = HRESULT($8004C1E0);
  E_HeapException = HRESULT($80045F11);
  E_OutOfMemory = HRESULT($800443BC);
  E_InOutError = HRESULT($8004EEFF);
  E_InvalidPointer = HRESULT($80046E30);
  E_InvalidCast = HRESULT($8004F87B);
  E_ConvertError = HRESULT($800428DF);
  E_VariantError = HRESULT($8004906B);
  E_PropReadOnly = HRESULT($8004C2AE);
  E_PropWriteOnly = HRESULT($800421FF);
  E_AssertionFailed = HRESULT($8004804D);
  E_AbstractError = HRESULT($800457E7);
  E_IntfCastError = HRESULT($8004013A);
  E_InvalidContainer = HRESULT($80041139);
  E_InvalidInsert = HRESULT($80049214);
  E_PackageError = HRESULT($8004D209);
  E_Monitor = HRESULT($80042E4B);
  E_MonitorLockException = HRESULT($80044F0A);
  E_NoMonitorSupportException = HRESULT($8004C432);
  E_ProgrammerNotFound = HRESULT($80041ED9);
  E_StreamError = HRESULT($80041456);
  E_FileStreamError = HRESULT($80047D7F);
  E_FCreateError = HRESULT($800483F3);
  E_FOpenError = HRESULT($8004C072);
  E_FilerError = HRESULT($80040062);
  E_ReadError = HRESULT($80048365);
  E_WriteError = HRESULT($8004B995);
  E_ClassNotFound = HRESULT($80043784);
  E_MethodNotFound = HRESULT($8004A629);
  E_InvalidImage = HRESULT($80045BAB);
  E_ResNotFound = HRESULT($80041963);
  E_ListError = HRESULT($8004FF47);
  E_BitsError = HRESULT($80045D35);
  E_StringListError = HRESULT($80044BB8);
  E_ComponentError = HRESULT($8004ED1C);
  E_ParserError = HRESULT($80049974);
  E_OutOfResources = HRESULT($8004D01F);
  E_InvalidOperation = HRESULT($80041D56);

  E_CheckedInterfacedObjectError = HRESULT($80044383);
  E_CheckedInterfacedObjectDeleteError = HRESULT($80045A95);
  E_CheckedInterfacedObjectDoubleFreeError = HRESULT($80048672);
  E_CheckedInterfacedObjectUseDeletedError = HRESULT($8004D50D);

  E_InvalidCoreVersion = HRESULT($8004D63A);

implementation

end.
