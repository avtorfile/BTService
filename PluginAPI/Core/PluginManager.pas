unit PluginManager;

interface

uses
{$IFDEF DELPHIXE3_LVL}
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.ExtCtrls,
{$ELSE}
  Windows,
  SysUtils,
  Classes,
  Graphics,
  ExtCtrls,
  Dialogs,
{$ENDIF }
  Helpers,
  Forms,
  uObjects,
  uConstsProg,
  sLabel;

type
  EPluginManagerError = class(Exception);
  EPluginLoadError = class(EPluginManagerError);
  EDuplicatePluginError = class(EPluginLoadError);

  EPluginsLoadError = class(EPluginLoadError)
  private
    FItems: TStrings;
  public
    constructor Create(const AText: String; const AFailedPlugins: TStrings);
    destructor Destroy; override;
    property FailedPluginFileNames: TStrings read FItems;
  end;

  IPlugin = interface
    // protected
    function GetIndex: Integer;
    function GetHandle: HMODULE;
    function GetIcon: TIcon;
    procedure DestroyIcon;
    function GetFileName: String;
    function GetID: TGUID;
    function GetName: String;
    function GetVersion: String;
    function GetAuthorName: String;
    function GetEmailAuthor: String;
    function GetSiteAuthor: String;
    function GetIndexIcon: Integer;
    procedure SetIndexIcon(i: Integer);
    function GetUpdatedIcons: Boolean;
    procedure SetUpdatedIcons(Value: Boolean);
    function GetUpdatedActive: Boolean;
    procedure SetUpdatedActive(Value: Boolean);
    function GetUpdatedPremium: Boolean;
    procedure SetUpdatedPremium(Value: Boolean);
    function GetOptionsIndexIcon: Integer;
    procedure SetOptionsIndexIcon(Value: Integer);
    function GetGetedGraphRating: Boolean;
    procedure SetGetedGraphRating(Value: Boolean);
    function GetImageGraphRating: TImage;
    procedure SetImageGraphRating(Value: TImage);
    function GetPanelStatistic: TPanel;
    procedure SetPanelStatistic(Value: TPanel);
    function GetPanelInfoRank: TPanel;
    procedure SetPanelInfoRank(Value: TPanel);
    function GetGlobalRank: String;
    procedure SetGlobalRank(Value: String);
    function GetGlobalRankLabel: TsLabelFX;
    procedure SetGlobalRankLabel(Value: TsLabelFX);
    function GetPictureRatings: TMemoryStream;
    procedure SetPictureRatings(Value: TMemoryStream);
    function GetTaskIndexIcon: Integer;
    procedure SetTaskIndexIcon(Value: Integer);
    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
    function GetSalePremIndexIcon: Integer;
    procedure SetSalePremIndexIcon(Value: Integer);

    function GetMask: String;
    function GetDescription: String;
    function GetFilterIndex: Integer;
    procedure SetFilterIndex(const AValue: Integer);

    // public
    property Index: Integer read GetIndex;
    property Handle: HMODULE read GetHandle;
    property FileName: String read GetFileName;

    property ID: TGUID read GetID;
    property Name: String read GetName;
    property Version: String read GetVersion;
    property AuthorName: String read GetAuthorName;
    property EmailAuthor: String read GetEmailAuthor;
    property SiteAuthor: String read GetSiteAuthor;
    property Icon: TIcon read GetIcon;
    property IndexIcon: Integer read GetIndexIcon write SetIndexIcon;
    property UpdatedIcons: Boolean read GetUpdatedIcons write SetUpdatedIcons;
    property UpdatedActive: Boolean read GetUpdatedActive
      write SetUpdatedActive;
    property UpdatedPremium: Boolean read GetUpdatedPremium
      write SetUpdatedPremium;
    property OptionsIndexIcon: Integer read GetOptionsIndexIcon
      write SetOptionsIndexIcon;

    property GetedGraphRating: Boolean read GetGetedGraphRating
      write SetGetedGraphRating;
    property ImageGraphRating: TImage read GetImageGraphRating
      write SetImageGraphRating;
    property PanelStatistic: TPanel read GetPanelStatistic
      write SetPanelStatistic;
    property PanelInfoRank: TPanel read GetPanelInfoRank write SetPanelInfoRank;
    property GlobalRank: string read GetGlobalRank write SetGlobalRank;
    property GlobalRankLabel: TsLabelFX read GetGlobalRankLabel
      write SetGlobalRankLabel;
    property PictureRatings: TMemoryStream read GetPictureRatings
      write SetPictureRatings;
    property TaskIndexIcon: Integer read GetTaskIndexIcon
      write SetTaskIndexIcon;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property SalePremIndexIcon: Integer read GetSalePremIndexIcon
      write SetSalePremIndexIcon;

    property Mask: String read GetMask;
    property Description: String read GetDescription;

    property FilterIndex: Integer read GetFilterIndex write SetFilterIndex;
  end;

  IServiceProvider = interface
    function CreateInterface(const APlugin: IPlugin; const AIID: TGUID;
      out Intf): Boolean;
  end;

  IProvider = interface(IServiceProvider)
    procedure Delete;
  end;

  IPluginManager = interface
    // protected
    function GetItem(const AIndex: Integer): IPlugin;
    function GetCount: Integer;
    // public
    function LoadPlugin(const AFileName: String): IPlugin;
    procedure UnloadPlugin(const AIndex: Integer);

    procedure LoadPlugins(const AFolder: String; const AFileExt: String = '');

    procedure Ban(const AFileName: String);
    procedure Unban(const AFileName: String);

    procedure SaveSettings(const ARegPath: String);
    procedure LoadSettings(const ARegPath: String);

    property Items[const AIndex: Integer]: IPlugin read GetItem; default;
    property Count: Integer read GetCount;

    function IndexOf(const AID: TGUID): Integer;

    procedure DoLoaded;

    procedure UnloadAll;
    procedure ProvidersListCreate;

    procedure SetVersion(const AVersion: Integer);
    procedure RegisterServiceProvider(const AProvider: IServiceProvider);
  end;

  TBasicProvider = class(TCheckedInterfacedObject, IUnknown, IServiceProvider,
    IProvider)
  private
    FManager: IPluginManager;
    FPlugin: PluginManager.IPlugin;
  protected
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    // IServiceProvider
    function CreateInterface(const APlugin: IPlugin; const AIID: TGUID;
      out Intf): Boolean; virtual;
    // IProvider
    procedure Delete;
  public
    constructor Create(const AManager: IPluginManager;
      const APlugin: PluginManager.IPlugin);
    property Manager: IPluginManager read FManager;
    property Plugin: PluginManager.IPlugin read FPlugin;
  end;

function Plugins: IPluginManager;

implementation

uses
{$IFDEF DELPHIXE3_LVL}
  System.Win.Registry,
{$ELSE}
  Registry,
{$ENDIF }
  uProcedures,
  PluginAPI;

resourcestring
  rsPluginsLoadError = 'One or more plugins has failed to load:' +
    sLineBreak + '%s';
  rsDuplicatePlugin = 'Plugin is already loaded.' + sLineBreak +
    'ID: %s; Name: %s;' + sLineBreak + 'File name 1: %s' + sLineBreak +
    'File name 2: %s';

type
  IProviderManager = interface
    ['{799F9F9F-9030-43B1-B184-0950962B09A5}']
    procedure RegisterProvider(const AProvider: IProvider);
  end;

  // TPlugin = class;

  TPluginManager = class(TCheckedInterfacedObject, IUnknown, IPluginManager)
  private
    FItems: array of IPlugin;
    FCount: Integer;
    FBanned: TStringList;
    FVersion: Integer;
    FProviders: TInterfaceList;
  protected
    function CreateInterface(const APlugin: PluginManager.IPlugin;
      const AIID: TGUID; out Intf): Boolean;

    // PluginManager.IPluginManager
    function GetItem(const AIndex: Integer): PluginManager.IPlugin;
    function GetCount: Integer;
    function CanLoad(const AFileName: String): Boolean;
    procedure SetVersion(const AVersion: Integer);
    procedure RegisterServiceProvider(const AProvider: IServiceProvider);

    // ICore
    function GetVersion: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    property Count: Integer read GetCount;
    property Items[const AIndex: Integer]: PluginManager.IPlugin
      read GetItem; default;

    // PluginManager.IPluginManager
    function LoadPlugin(const AFileName: String): IPlugin;
    procedure UnloadPlugin(const AIndex: Integer);
    procedure LoadPlugins(const AFolder, AFileExt: String);
    function IndexOf(const APlugin: IPlugin): Integer; overload;
    function IndexOf(const AID: TGUID): Integer; overload;
    procedure Ban(const AFileName: String);
    procedure Unban(const AFileName: String);
    procedure SaveSettings(const ARegPath: String);
    procedure LoadSettings(const ARegPath: String);
    procedure UnloadAll;
    procedure DoLoaded;
    procedure ProvidersListCreate;
  end;

  TPlugin = class(TCheckedInterfacedObject, IUnknown, IPlugin, IProviderManager,
    IDestroyNotify, IPlugins, ICore)
  private
    FManager: TPluginManager;
    FFileName: String;
    FHandle: HMODULE;
    FIconPlugin: TIcon;
    FIndexIcon: Integer;
    FUpdatedIcons: Boolean;
    FUpdatedActive: Boolean;
    FUpdatedPremium: Boolean;
    FOptionsIndexIcon: Integer;
    FGetedGraphRating: Boolean;
    FImageGraphRating: TImage;
    FPanelStatistic: TPanel;
    FPanelInfoRank: TPanel;
    FGlobalRank: String;
    FGlobalRankLabel: TsLabelFX;
    FPictureRatings: TMemoryStream;
    FTaskIndexIcon: Integer;
    FItemIndex: Integer;
    FSalePremIndexIcon: Integer;

    FInit: TInitPluginFunc;
    FDone: TDonePluginFunc;
    FFilterIndex: Integer;
    FPlugin: PluginAPI.IPlugin;
    FID: TGUID;
    FName: String;
    FVersion: String;
    FAuthorName: String;
    FEmailAuthor: String;
    FSiteAuthor: String;
    FPluginType: Integer;
    FInfoRetrieved: Boolean;
    FMask: String;
    FDescription: String;
    FProviders: array of IProvider;
    procedure GetInfo;
    procedure ReleasePlugin;
    procedure ReleaseProviders;
  protected
    function CreateInterface(const AIID: TGUID; out Intf): Boolean;
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // IPlugin
    function GetFileName: String;
    function GetID: TGUID;
    function GetName: String;
    function GetVersion: String;
    function GetAuthorName: String;
    function GetEmailAuthor: String;
    function GetSiteAuthor: String;
    function GetIndex: Integer;
    function GetHandle: HMODULE;
    function GetIcon: TIcon;
    procedure DestroyIcon;
    function GetIndexIcon: Integer;
    procedure SetIndexIcon(i: Integer);
    function GetUpdatedIcons: Boolean;
    procedure SetUpdatedIcons(Value: Boolean);
    function GetUpdatedActive: Boolean;
    procedure SetUpdatedActive(Value: Boolean);
    function GetUpdatedPremium: Boolean;
    procedure SetUpdatedPremium(Value: Boolean);
    function GetOptionsIndexIcon: Integer;
    procedure SetOptionsIndexIcon(Value: Integer);
    function GetGetedGraphRating: Boolean;
    procedure SetGetedGraphRating(Value: Boolean);
    function GetImageGraphRating: TImage;
    procedure SetImageGraphRating(Value: TImage);
    function GetPanelStatistic: TPanel;
    procedure SetPanelStatistic(Value: TPanel);
    function GetPanelInfoRank: TPanel;
    procedure SetPanelInfoRank(Value: TPanel);
    function GetGlobalRank: String;
    procedure SetGlobalRank(Value: String);
    function GetGlobalRankLabel: TsLabelFX;
    procedure SetGlobalRankLabel(Value: TsLabelFX);
    function GetPictureRatings: TMemoryStream;
    procedure SetPictureRatings(Value: TMemoryStream);
    function GetTaskIndexIcon: Integer;
    procedure SetTaskIndexIcon(Value: Integer);
    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
    function GetSalePremIndexIcon: Integer;
    procedure SetSalePremIndexIcon(Value: Integer);

    function GetMask: String;
    function GetDescription: String;
    function GetFilterIndex: Integer;
    procedure SetFilterIndex(const AValue: Integer);

    // ICore
    function GetCoreVersion: Integer; safecall;
    function ICore.GetVersion = GetCoreVersion;
    // IPlugins
    function GetCount: Integer; safecall;
    function GetPlugin(const AIndex: Integer): PluginAPI.IPlugin; safecall;
    // IProviderManager
    procedure RegisterProvider(const AProvider: IProvider);
    // IDestroyNotify
    procedure Delete; safecall;

  public
    constructor Create(const APluginManger: TPluginManager;
      const AFileName: String); virtual;
    destructor Destroy; override;
  end;

  { TPluginManager }

constructor TPluginManager.Create;
begin
  OutputDebugString('TPluginManager.Create');
  SetName('TPluginManager');
  inherited Create;
  FBanned := TStringList.Create;
  FProviders := TInterfaceList.Create;
  SetVersion(1);
end;

destructor TPluginManager.Destroy;
begin
  OutputDebugString('TPluginManager.Destroy');
  UnloadAll;
  FreeAndNil(FProviders);
  FreeAndNil(FBanned);
  inherited;
end;

procedure TPluginManager.DoLoaded;
var
  X: Integer;
  LoadNotify: ILoadNotify;
begin
  for X := 0 to GetCount - 1 do
    if Supports(Plugins[X], ILoadNotify, LoadNotify) then
      LoadNotify.Loaded;
end;

function TPluginManager.LoadPlugin(const AFileName: String): IPlugin;
begin
  if CanLoad(AFileName) then
  begin
    Result := nil;
    Exit;
  end;

  // Загружаем плагин
  try
    Result := TPlugin.Create(Self, AFileName);
  except
    on E: Exception do
      raise EPluginLoadError.Create
        (Format('[%s] %s', [E.ClassName, E.Message]));
  end;

  // Заносим в список
  if Length(FItems) <= FCount then // "Capacity"
    SetLength(FItems, Length(FItems) + 64);
  FItems[FCount] := Result;
  Inc(FCount);
end;

procedure TPluginManager.LoadPlugins(const AFolder, AFileExt: String);
var
  Path: String;
  sr: TSearchRec;
  Failures: TStringList;
  FailedPlugins: TStringList;

  function PluginOK(const APluginName, AFileExt: String): Boolean;
  begin
    Result := (AFileExt = '');
    if Result then
      Exit;
    Result := SameFileName(ExtractFileExt(APluginName), AFileExt);
  end;

begin
  Path := IncludeTrailingPathDelimiter(AFolder);
  Sleep(100);
  Failures := TStringList.Create;
  FailedPlugins := TStringList.Create;
  try
    if FindFirst(Path + '*.*', 0, sr) = 0 then
      try
        repeat
          if ((sr.Attr and faDirectory) = 0) and PluginOK(sr.Name, AFileExt)
          then
          begin
            try
              LoadPlugin(Path + sr.Name);
            except
              on E: Exception do
              begin
                FailedPlugins.Add(sr.Name);
                Failures.Add(Format('%s: %s', [sr.Name, E.Message]));
              end;
            end;
          end;
          Application.ProcessMessages;
        until FindNext(sr) <> 0;
      finally
        FindClose(sr);
      end;

    if Failures.Count > 0 then
      raise EPluginsLoadError.Create(Format(rsPluginsLoadError, [Failures.Text]
        ), FailedPlugins);
  finally
    FreeAndNil(FailedPlugins);
    FreeAndNil(Failures);
  end;
end;

procedure TPluginManager.ProvidersListCreate;
begin
  if not Assigned(FProviders) then
    FProviders := TInterfaceList.Create;
end;

procedure TPluginManager.UnloadAll;

  procedure NotifyRelease;
  var
    X: Integer;
    Notify: IDestroyNotify;
  begin
    for X := FCount - 1 downto 0 do // for X := 0 to FCount - 1 do
    begin
      if Supports(FItems[X], IDestroyNotify, Notify) then
        Notify.Delete;
    end;
  end;

begin
  NotifyRelease;
  FCount := 0;
  Finalize(FItems);
  FreeAndNil(FProviders);
end;

procedure TPluginManager.UnloadPlugin(const AIndex: Integer);
var
  X: Integer;
  Notify: IDestroyNotify;
begin
  FItems[AIndex] := nil;
  // Сдвинуть плагины в списке, чтобы закрыть "дырку"
  for X := AIndex to FCount - 1 do
    FItems[X] := FItems[X + 1];
  // Не забыть учесть последний
  FItems[FCount - 1] := nil;
  Dec(FCount);
end;

function TPluginManager.IndexOf(const APlugin: IPlugin): Integer;
begin
  Result := IndexOf(APlugin.ID);
end;

function TPluginManager.IndexOf(const AID: TGUID): Integer;
var
  X: Integer;
  ID: TGUID;
begin
  Result := -1;
  for X := 0 to FCount - 1 do
  begin
    ID := FItems[X].ID;
    if CompareMem(@ID, @AID, SizeOf(TGUID)) then
    begin
      Result := X;
      Break;
    end;
  end;
end;

procedure TPluginManager.Ban(const AFileName: String);
begin
  Unban(AFileName);
  FBanned.Add(AFileName);
end;

procedure TPluginManager.Unban(const AFileName: String);
var
  X: Integer;
begin
  for X := 0 to FBanned.Count - 1 do
    if SameFileName(FBanned[X], AFileName) then
    begin
      FBanned.Delete(X);
      Break;
    end;
end;

function TPluginManager.CanLoad(const AFileName: String): Boolean;
var
  X: Integer;
begin
  // Не грузить отключенные
  for X := 0 to FBanned.Count - 1 do
    if SameFileName(FBanned[X], AFileName) then
    begin
      Result := true;
      Exit;
    end;

  // Не грузить уже загруженные
  for X := 0 to FCount - 1 do
    if SameFileName(FItems[X].FileName, AFileName) then
    begin
      Result := true;
      Exit;
    end;

  Result := False;
end;

const
  SRegDisabledPlugins = 'Disabled plugins';
  SRegPluginX = 'Plugin%d';

procedure TPluginManager.SaveSettings(const ARegPath: String);
var
  Reg: TRegIniFile;
  Path: String;
  X: Integer;
begin
  Reg := TRegIniFile.Create(ARegPath, KEY_ALL_ACCESS);
  try
    // Удаляем старые
    Reg.EraseSection(SRegDisabledPlugins);
    Path := ARegPath + '\' + SRegDisabledPlugins;
    if not Reg.OpenKey(Path, true) then
      Exit;

    // Сохраняем новые
    for X := 0 to FBanned.Count - 1 do
      Reg.WriteString(Path, Format(SRegPluginX, [X]), FBanned[X]);
  finally
    FreeAndNil(Reg);
  end;
end;

procedure TPluginManager.SetVersion(const AVersion: Integer);
begin
  FVersion := AVersion;
end;

procedure TPluginManager.LoadSettings(const ARegPath: String);
var
  Reg: TRegIniFile;
  Path: String;
  X: Integer;
begin
  Reg := TRegIniFile.Create(ARegPath, KEY_READ);
  try
    FBanned.BeginUpdate;
    try
      FBanned.Clear;

      // Читаем
      Path := ARegPath + '\' + SRegDisabledPlugins;
      if not Reg.OpenKey(Path, true) then
        Exit;
      Reg.ReadSectionValues(Path, FBanned);

      // Убираем "Plugin5=" из строк
      for X := 0 to FBanned.Count - 1 do
        FBanned[X] := FBanned.ValueFromIndex[X];
    finally
      FBanned.EndUpdate;
    end;
  finally
    FreeAndNil(Reg);
  end;
end;

function TPluginManager.CreateInterface(const APlugin: PluginManager.IPlugin;
  const AIID: TGUID; out Intf): Boolean;
var
  Provider: IServiceProvider;
  X: Integer;
begin
  Pointer(Intf) := nil;
  Result := False;

  for X := 0 to FProviders.Count - 1 do
  begin
    Provider := IServiceProvider(FProviders[X]);
    if Provider.CreateInterface(APlugin, AIID, Intf) then
    begin
      Result := true;
      Exit;
    end;
  end;
end;

procedure TPluginManager.RegisterServiceProvider(const AProvider
  : IServiceProvider);
begin
  FProviders.Add(AProvider);
end;

function TPluginManager.GetCount: Integer;
begin
  Result := FCount;
end;

function TPluginManager.GetItem(const AIndex: Integer): PluginManager.IPlugin;
begin
  Result := FItems[AIndex];
end;

function TPluginManager.GetVersion: Integer;
begin
  Result := FVersion;
end;

{ TBasicProvider }

constructor TBasicProvider.Create(const AManager: IPluginManager;
  const APlugin: PluginManager.IPlugin);
var
  Manager: IProviderManager;
begin
  inherited Create;
  FManager := AManager;
  FPlugin := APlugin;
  if Supports(APlugin, IProviderManager, Manager) then
    Manager.RegisterProvider(Self);
  SetName(Format('TBasicProvider(%s): %s', [ExtractFileName(APlugin.FileName),
    ClassName]));
end;

function TBasicProvider.CreateInterface(const APlugin: IPlugin;
  const AIID: TGUID; out Intf): Boolean;
begin
  Result := Succeeded(inherited QueryInterface(AIID, Intf));
end;

function TBasicProvider.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := inherited QueryInterface(IID, Obj);
  if Failed(Result) then
    Result := FPlugin.QueryInterface(IID, Obj);
end;

procedure TBasicProvider.Delete;
begin
  FPlugin := nil;
  FManager := nil;
end;

{ TPlugin }

constructor TPlugin.Create(const APluginManger: TPluginManager;
  const AFileName: String);

  function SafeLoadLibrary(const FileName: string; ErrorMode: UINT): HMODULE;
  const
    LOAD_WITH_ALTERED_SEARCH_PATH = $008;
  var
    OldMode: UINT;
    FPUControlWord: Word;
  begin
    OldMode := SetErrorMode(ErrorMode);
    try
{$IFNDEF CPUX64}
      asm
        FNSTCW  FPUControlWord
      end;
      try
{$ENDIF}
        Result := LoadLibraryEx(PChar(FileName), 0,
          LOAD_WITH_ALTERED_SEARCH_PATH);
{$IFNDEF CPUX64}
      finally
        asm
          FNCLEX
          FLDCW FPUControlWord
        end;
      end;
{$ENDIF}
    finally
      SetErrorMode(OldMode);
    end;
  end;

var
  Ind: Integer;
begin
  OutputDebugString(PChar('TPlugin.Create: ' + ExtractFileName(AFileName)));
  SetName(Format('TPlugin(%s)', [ExtractFileName(AFileName)]));
  inherited Create;
  FManager := APluginManger;
  FFileName := AFileName;
  FFilterIndex := -1;
  FHandle := SafeLoadLibrary(AFileName, SEM_NOOPENFILEERRORBOX or
    SEM_FAILCRITICALERRORS);
  Win32Check(FHandle <> 0);
  FDone := GetProcAddress(FHandle, SPluginDoneFuncName);
  FInit := GetProcAddress(FHandle, SPluginInitFuncName);
  Win32Check(Assigned(FInit));
  FPlugin := FInit(Self);
  Win32Check(Assigned(FPlugin));

  Ind := FManager.IndexOf(FPlugin.ID);
  if Ind >= 0 then
    raise EDuplicatePluginError.CreateFmt(rsDuplicatePlugin,
      [GUIDToString(FPlugin.ID), FPlugin.Name, FManager[Ind].FileName,
      AFileName]);

  FID := FPlugin.ID;
  FName := FPlugin.Name;
  FVersion := FPlugin.Version;
  FAuthorName := FPlugin.AuthorName;
  FEmailAuthor := FPlugin.EmailAuthor;
  FSiteAuthor := FPlugin.SiteAuthor;
  FPluginType := FPlugin.PluginType;
  // FServiceName := FServicePlugin.ServiceName;
  // FServices := FServicePlugin.Services;

  SetName(Format('TPlugin(%s): %s', [ExtractFileName(AFileName),
    GUIDToString(FID)]));
end;

destructor TPlugin.Destroy;
begin
  OutputDebugString(PChar('TPlugin.Destroy: ' + ExtractFileName(FFileName)));
  Delete;

  if Assigned(FDone) then
    FDone;

  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

procedure TPlugin.Delete;
begin
  ReleaseProviders;
  ReleasePlugin;
end;

procedure TPlugin.ReleaseProviders;
var
  X: Integer;
begin
  for X := High(FProviders) downto 0 do
    FProviders[X].Delete;
  Finalize(FProviders);
end;

procedure TPlugin.ReleasePlugin;
var
  Notify: IDestroyNotify;
begin
  if Supports(FPlugin, IDestroyNotify, Notify) then
    Notify.Delete;
  FPlugin := nil;
end;

function TPlugin.CreateInterface(const AIID: TGUID; out Intf): Boolean;
var
  X: Integer;
begin
  Pointer(Intf) := nil;
  Result := False;

  for X := 0 to High(FProviders) do
  begin
    Result := FProviders[X].CreateInterface(Self, AIID, Intf);
    if Result then
      Break;
  end;
end;

function TPlugin.GetFileName: String;
begin
  Result := FFileName;
end;

function TPlugin.GetID: TGUID;
begin
  Result := FID;
end;

function TPlugin.GetName: String;
begin
  Result := FName;
end;

function TPlugin.GetVersion: String;
begin
  Result := FVersion;
end;

function TPlugin.GetAuthorName: String;
begin
  Result := FAuthorName;
end;

function TPlugin.GetEmailAuthor: String;
begin
  Result := FEmailAuthor;
end;

function TPlugin.GetSiteAuthor: String;
begin
  Result := FSiteAuthor;
end;

function TPlugin.GetIndexIcon: Integer;
begin
  Result := FIndexIcon;
end;

procedure TPlugin.SetIndexIcon(i: Integer);
begin
  FIndexIcon := i;
end;

function TPlugin.GetUpdatedIcons: Boolean;
begin
  Result := FUpdatedIcons;
end;

procedure TPlugin.SetUpdatedIcons(Value: Boolean);
begin
  FUpdatedIcons := Value;
end;

function TPlugin.GetUpdatedActive: Boolean;
begin
  Result := FUpdatedActive;
end;

procedure TPlugin.SetUpdatedActive(Value: Boolean);
begin
  FUpdatedActive := Value;
end;

function TPlugin.GetUpdatedPremium: Boolean;
begin
  Result := FUpdatedPremium;
end;

procedure TPlugin.SetUpdatedPremium(Value: Boolean);
begin
  FUpdatedPremium := Value;
end;

function TPlugin.GetOptionsIndexIcon: Integer;
begin
  Result := FOptionsIndexIcon;
end;

procedure TPlugin.SetOptionsIndexIcon(Value: Integer);
begin
  FOptionsIndexIcon := Value;
end;

function TPlugin.GetGetedGraphRating: Boolean;
begin
  Result := FGetedGraphRating;
end;

procedure TPlugin.SetGetedGraphRating(Value: Boolean);
begin
  FGetedGraphRating := Value;
end;

function TPlugin.GetImageGraphRating: TImage;
begin
  Result := FImageGraphRating;
end;

procedure TPlugin.SetImageGraphRating(Value: TImage);
begin
  FImageGraphRating := Value;
end;

function TPlugin.GetPanelStatistic: TPanel;
begin
  Result := FPanelStatistic;
end;

procedure TPlugin.SetPanelStatistic(Value: TPanel);
begin
  FPanelStatistic := Value;
end;

function TPlugin.GetPanelInfoRank: TPanel;
begin
  Result := FPanelInfoRank;
end;

procedure TPlugin.SetPanelInfoRank(Value: TPanel);
begin
  FPanelInfoRank := Value;
end;

function TPlugin.GetGlobalRank: String;
begin
  Result := FGlobalRank;
end;

procedure TPlugin.SetGlobalRank(Value: String);
begin
  FGlobalRank := Value;
end;

function TPlugin.GetGlobalRankLabel: TsLabelFX;
begin
  Result := FGlobalRankLabel;
end;

procedure TPlugin.SetGlobalRankLabel(Value: TsLabelFX);
begin
  FGlobalRankLabel := Value;
end;

function TPlugin.GetPictureRatings: TMemoryStream;
begin
  Result := FPictureRatings;
end;

procedure TPlugin.SetPictureRatings(Value: TMemoryStream);
begin
  FPictureRatings := Value;
end;

function TPlugin.GetTaskIndexIcon: Integer;
begin
  Result := FTaskIndexIcon;
end;

procedure TPlugin.SetTaskIndexIcon(Value: Integer);
begin
  FTaskIndexIcon := Value;
end;

function TPlugin.GetItemIndex: Integer;
begin
  Result := FItemIndex;
end;

procedure TPlugin.SetItemIndex(Value: Integer);
begin
  FItemIndex := Value;
end;

function TPlugin.GetSalePremIndexIcon: Integer;
begin
  Result := FSalePremIndexIcon;
end;

procedure TPlugin.SetSalePremIndexIcon(Value: Integer);
begin
  FSalePremIndexIcon := Value;
end;

function TPlugin.GetHandle: HMODULE;
begin
  Result := FHandle;
end;

function TPlugin.GetIcon: TIcon;
begin
  FIconPlugin := TIcon.Create;
  try
    FIconPlugin.LoadFromResourceName(FHandle, 'Icon_1');
    Result := FIconPlugin;
  except
  end;
end;

procedure TPlugin.DestroyIcon;
begin
  try
    if Assigned(FIconPlugin { <> nil } ) then
      FIconPlugin.Free;
  except
  end;
end;

function TPlugin.GetIndex: Integer;
begin
  Result := FManager.IndexOf(Self);
end;

procedure TPlugin.GetInfo;
var
  Plugin: IExportImportPluginInfo;
begin
  if FInfoRetrieved then
    Exit;
  if Supports(FPlugin, IExportImportPluginInfo, Plugin) then
  begin
    FMask := Plugin.Mask;
    FDescription := Plugin.Description;
  end
  else
  begin
    FMask := '';
    FDescription := '';
  end;
  FInfoRetrieved := true;
end;

function TPlugin.GetMask: String;
begin
  GetInfo;
  Result := FMask;
end;

function TPlugin.GetDescription: String;
begin
  GetInfo;
  Result := FDescription;
end;

function TPlugin.GetFilterIndex: Integer;
begin
  Result := FFilterIndex;
end;

procedure TPlugin.SetFilterIndex(const AValue: Integer);
begin
  FFilterIndex := AValue;
end;

function TPlugin._AddRef: Integer;
begin
  Result := inherited _AddRef;
end;

function TPlugin._Release: Integer;
begin
  Result := inherited _Release;
end;

function TPlugin.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  // Оболочка TPlugin
  Result := inherited QueryInterface(IID, Obj);

  // Сам плагин
  if Failed(Result) and Assigned(FPlugin) then
    Result := FPlugin.QueryInterface(IID, Obj);

  // Уже созданные провайдеры
  if Failed(Result) then
  begin
    if CreateInterface(IID, Obj) then
      Result := S_OK;
  end;

  // Потенциальные провайдеры (создаются)
  if Failed(Result) then
  begin
    if FManager.CreateInterface(Self, IID, Obj) then
      Result := S_OK;
  end;
end;

procedure TPlugin.RegisterProvider(const AProvider: IProvider);
begin
  SetLength(FProviders, Length(FProviders) + 1);
  FProviders[High(FProviders)] := AProvider;
end;

function TPlugin.GetCoreVersion: Integer;
begin
  Result := FManager.GetVersion;
end;

function TPlugin.GetCount: Integer;
begin
  Result := FManager.Count;
end;

function TPlugin.GetPlugin(const AIndex: Integer): PluginAPI.IPlugin;
begin
  Supports(FManager[AIndex], PluginAPI.IPlugin, Result);
end;

{ EPluginsLoadError }

constructor EPluginsLoadError.Create(const AText: String;
  const AFailedPlugins: TStrings);
begin
  inherited Create(AText);
  FItems := TStringList.Create;
  FItems.Assign(AFailedPlugins);
end;

destructor EPluginsLoadError.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

// ________________________________________________________________

var
  FPluginManager: IPluginManager;

function Plugins: IPluginManager;
begin
  Result := FPluginManager;
end;

initialization

FPluginManager := TPluginManager.Create;

finalization

if Assigned(FPluginManager) then
  FPluginManager.UnloadAll;
FPluginManager := nil;

end.
