unit PluginSupport;

{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

interface

uses
  SysUtils,
  PluginAPI;

type
  // Переопределяем TNotifyEvent, чтобы не тащить Classes ради одного определения
  TNotifyEvent = procedure(Sender: TObject) of object;

  TPluginMenuItem = class(TObject, IUnknown, INotifyEvent)
  private
    FManager: IMenuManager;
    FItem: IMenuItem;
    FClick: TNotifyEvent;
  protected
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // INotifyEvent
    procedure Execute(Sender: IInterface); safecall;
  public
    constructor Create(const ACore: ICore);
    destructor Destroy; override;
    property Item: IMenuItem read FItem;

    procedure Click; virtual;
    property OnClick: TNotifyEvent read FClick write FClick;

    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
  end;

implementation

uses
  Helpers;

{ TPluginMenuItem }

constructor TPluginMenuItem.Create(const ACore: ICore);
begin
  inherited Create;
  if not Supports(ACore, IMenuManager, FManager) then
    Assert(False);

  FItem := FManager.CreateMenuItem;

  FItem.Caption := 'PluginMenuItem';
  FItem.Hint := '';
  FItem.Enabled := True;
  FItem.Checked := False;
  FItem.RegisterExecuteHandler(Self);
end;

destructor TPluginMenuItem.Destroy;
begin
  FManager.DeleteMenuItem(FItem);
  FManager := nil;
  inherited;
end;

procedure TPluginMenuItem.Execute(Sender: IInterface);
begin
  Click;
end;

procedure TPluginMenuItem.Click;
begin
  if FItem.Enabled then
  begin
    if Assigned(FClick) then
      FClick(Self);
  end;
end;

function TPluginMenuItem.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TPluginMenuItem._AddRef: Integer;
begin
  Result := -1;   // -1 indicates no reference counting is taking place
end;

function TPluginMenuItem._Release: Integer;
begin
  Result := -1;   // -1 indicates no reference counting is taking place
end;

function TPluginMenuItem.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
begin
  Result := HandleSafeCallException(Self, ExceptObject, ExceptAddr);
end;

end.
