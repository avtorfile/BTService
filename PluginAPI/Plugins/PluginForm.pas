unit PluginForm;

interface

uses
  Windows,
  SysUtils,
  Controls,
  Forms,
  PluginAPI;

type
  TCreateMode = (cmDefault, cmStandalone, cmPopup, cmPopupTB, cmParented);

  TForm = class(Forms.TForm)
  private
    FCore: ICore;
    FWnds: IApplicationWindows;
    FMode: TCreateMode;
    FOwnerWnd: HWND;
    procedure SetupWndIcon;
  protected
    property Core: ICore read FCore;
    property Wnds: IApplicationWindows read FWnds;
    property Mode: TCreateMode read FMode;
    function MessageBox(const AText, ACaption: String; const AFlags: DWORD): Integer;

    procedure DoShow; override;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(const ACore: ICore); reintroduce;
    constructor CreateStandalone(const ACore: ICore);
    constructor CreatePopup(const ACore: ICore; const AOwnerWnd: HWND);
    constructor CreatePopupTB(const ACore: ICore; const AOwnerWnd: HWND);
    constructor CreateParented(const ACore: ICore; const AParentWnd: HWND);
    function ShowModal: Integer; override;
  end;

implementation

uses
  Messages;

constructor TForm.Create(const ACore: ICore);
begin
  FCore := ACore;
  if not Supports(FCore, IApplicationWindows, FWnds) then
    Assert(False);
  inherited Create(nil);
end;

constructor TForm.CreateStandalone(const ACore: ICore);
begin
  FMode := cmStandalone;
  Create(ACore);
end;

constructor TForm.CreatePopup(const ACore: ICore; const AOwnerWnd: HWND);
begin
  FMode := cmPopup;
  FOwnerWnd := AOwnerWnd;
  Create(ACore);
end;

constructor TForm.CreatePopupTB(const ACore: ICore; const AOwnerWnd: HWND);
begin
  FMode := cmPopupTB;
  FOwnerWnd := AOwnerWnd;
  Create(ACore);
end;

constructor TForm.CreateParented(const ACore: ICore; const AParentWnd: HWND);
begin
  FMode := cmParented;
  FOwnerWnd := AParentWnd;
  Create(ACore);
end;

procedure TForm.CreateParams(var Params: TCreateParams);
begin
  inherited;

  if Mode = cmStandalone then
    Params.WndParent := 0
  else
  if (Mode = cmPopup) or
     (Mode = cmPopupTB) then
  begin
    Params.WndParent := FOwnerWnd;
    if Mode = cmPopupTB then
      Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW
    else
      Params.ExStyle := Params.ExStyle and (not WS_EX_APPWINDOW);
  end
  else
  if Mode = cmParented then
  begin
    Params.WndParent := FOwnerWnd;
    Params.Style := Params.Style or WS_CHILD;
  end;
end;

function TForm.ShowModal: Integer;
begin
  Wnds.ModalStarted;
  try
    Result := inherited ShowModal;
  finally
    Wnds.ModalFinished;
  end;
end;

function TForm.MessageBox(const AText, ACaption: String; const AFlags: DWORD): Integer;
begin
  Wnds.ModalStarted;
  try
    Result := Windows.MessageBox(Wnds.MainWnd, PChar(AText), PChar(ACaption), (AFlags and (not MB_SYSTEMMODAL)) or MB_TASKMODAL);
  finally
    Wnds.ModalFinished;
  end;
end;

procedure TForm.DoShow;
begin
//  SetupWndIcon;
end;

procedure TForm.SetupWndIcon;
var
  AppIcon: IAppIcon;
  Icon: HICON;
begin
  if Supports(FCore, IAppIcon, AppIcon) then
  begin
    Icon := AppIcon.Small;
    try
      Icon := HIcon(SendMessage(Handle, WM_SETICON, ICON_SMALL, Integer(Icon)));
    finally
      DestroyIcon(Icon);
    end;
    Icon := AppIcon.Large;
    try
      Icon := HIcon(SendMessage(Handle, WM_SETICON, ICON_BIG, Integer(Icon)));
    finally
      DestroyIcon(Icon);
    end;
  end;
end;

end.
