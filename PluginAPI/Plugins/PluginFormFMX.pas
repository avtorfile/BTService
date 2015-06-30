unit PluginFormFMX;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.UITypes,
  System.Types,
  FMX.Types,
  FMX.Forms,
  FMX.Platform,
  FMX.Platform.Win,
  PluginAPI;

type
  TCreateMode = (cmDefault, cmStandalone, cmPopup, cmPopupTB);

  TCreateParams = record
    Style: DWORD;
    ExStyle: DWORD;
    X, Y: Integer;
    Width, Height: Integer;
    WndParent: HWnd;
    Param: Pointer;
  end;

  TForm = class(FMX.Forms.TForm)
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

    function CreateWindow: TFmxHandle; virtual;
    procedure CreateParams(var Params: TCreateParams); virtual;

    procedure CreateHandle; override;
  public
    constructor Create(const ACore: ICore); reintroduce;
    constructor CreateStandalone(const ACore: ICore);
    constructor CreatePopup(const ACore: ICore; const AOwnerWnd: HWND);
    constructor CreatePopupTB(const ACore: ICore; const AOwnerWnd: HWND);
    function ShowModal: TModalResult;
  end;

implementation

uses
  Winapi.Messages;

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

procedure TForm.CreateHandle;
var
  P: Pointer;
begin
  // TCommonCustomForm.CreateHandle
  Handle := CreateWindow;
  if TFmxFormState.fsRecreating in FormState then
    Platform.SetWindowRect(Self, RectF(Left, Top, Left + Width, Top + Height));

  // TCustomForm.CreateHandle
  if DefaultCanvasClass <> nil then
  begin
    P := @Self.Canvas;
    NativeInt(P^) := NativeInt(DefaultCanvasClass.CreateFromWindow(Handle, ClientWidth, ClientHeight));
  end;

  SetupWndIcon;
end;

function TForm.CreateWindow: TFmxHandle;
var
  Params: TCreateParams;
  Wnd: HWND;
begin
  Result := Platform.CreateWindow(Self);

  Wnd := FmxHandleToHWND(Result);
  CreateParams(Params);
  SetWindowLong(Wnd, GWL_EXSTYLE, NativeInt(Params.ExStyle));
  SetWindowLong(Wnd, GWL_HWNDPARENT, NativeInt(Params.WndParent));
end;

procedure TForm.CreateParams(var Params: TCreateParams);

  procedure DefaultCreateParams(var Params: TCreateParams);
  begin
    FillChar(Params, SizeOf(Params), 0);
    Params.X := Integer(CW_USEDEFAULT);
    Params.Y := Integer(CW_USEDEFAULT);
    Params.Width := Integer(CW_USEDEFAULT);
    Params.Height := Integer(CW_USEDEFAULT);

    // TPlatformWin.CreateWindow
    if Transparency then
    begin
      Params.Style := Params.Style or WS_POPUP;
      Params.ExStyle := Params.ExStyle or WS_EX_LAYERED;
      if (Application.MainForm <> nil) and (Self <> Application.MainForm) then
        Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW; // disable taskbar
    end
    else
    begin
      case Self.BorderStyle of
        TFmxFormBorderStyle.bsNone:
          begin
            Params.Style := Params.Style or WS_POPUP or WS_SYSMENU;
            Params.ExStyle := Params.ExStyle { or WS_EX_TOOLWINDOW }; // disable taskbar
          end;
        TFmxFormBorderStyle.bsSingle, TFmxFormBorderStyle.bsToolWindow:
          Params.Style := Params.Style or (WS_CAPTION or WS_BORDER);
        TFmxFormBorderStyle.bsSizeable, TFmxFormBorderStyle.bsSizeToolWin:
          Params.Style := Params.Style or (WS_CAPTION or WS_THICKFRAME);
      end;
      if Self.BorderStyle in [TFmxFormBorderStyle.bsToolWindow, TFmxFormBorderStyle.bsSizeToolWin] then
      begin
        Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW;
        if (Application.MainForm = nil) or (Application.MainForm = Self) then
          Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
      end;
      if Self.BorderStyle <> TFmxFormBorderStyle.bsNone then
      begin
        if TBorderIcon.biMinimize in Self.BorderIcons then
          Params.Style := Params.Style or WS_MINIMIZEBOX;
        if TBorderIcon.biMaximize in Self.BorderIcons then
          Params.Style := Params.Style or WS_MAXIMIZEBOX;
        if TBorderIcon.biSystemMenu in Self.BorderIcons then
          Params.Style := Params.Style or WS_SYSMENU;
      end;
    end;

    // modal forms must have an owner window
    if TFmxFormState.fsModal in Self.FormState then
      Params.WndParent := GetActiveWindow
    else
      Params.WndParent := GetDesktopWindow;
  end;

begin
  DefaultCreateParams(Params); // inherited;

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
  end;
end;

function TForm.ShowModal: TModalResult;
begin
  Wnds.ModalStarted;
  try
    Result := inherited ShowModal;
  finally
    Wnds.ModalFinished;
  end;
end;

procedure TForm.SetupWndIcon;
var
  AppIcon: IAppIcon;
  Icon: HICON;
  Wnd: HWND;
begin
  if Supports(FCore, IAppIcon, AppIcon) then
  begin
    Wnd := FmxHandleToHWND(Handle);

    Icon := AppIcon.Small;
    try
      Icon := HIcon(SendMessage(Wnd, WM_SETICON, ICON_SMALL, Integer(Icon)));
    finally
      DestroyIcon(Icon);
    end;
    Icon := AppIcon.Large;
    try
      Icon := HIcon(SendMessage(Wnd, WM_SETICON, ICON_BIG, Integer(Icon)));
    finally
      DestroyIcon(Icon);
    end;
  end;
end;

end.
