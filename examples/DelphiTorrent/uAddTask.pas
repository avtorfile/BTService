unit uAddTask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, Clipbrd, Dialogs, ExtCtrls, ComCtrls, ImgList, MMSystem, Mask,
  Buttons, FileCtrl,
{$IFDEF VER290}
  System.ImageList,
{$ENDIF}
  uTorrentThreads, uTasks, uAMultiProgressBar,
  PluginManager, PluginApi;

const
  WM_MYMSG = WM_USER + 200;

type
  TCommandTask = class(TObject)
    Url: String;
    Referer: String;
    Cookies: String;
  end;

  TfAddTask = class(TForm)
    cbDirectory: TComboBox;
    btnDownload: TButton;
    btnAddToList: TButton;
    Panel1: TPanel;
    OnShowTimer: TTimer;
    OpenDialog1: TOpenDialog;
    Tabs: TPageControl;
    AddFileName: TTabSheet;
    PasteTimer: TTimer;
    DelBackTimer: TTimer;
    pnl2: TPanel;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ImageList1: TImageList;
    MemoLink: TMemo;
    MemoName: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbDirectoryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnDownloadClick(Sender: TObject);
    procedure btnAddToListClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OnShowTimerTimer(Sender: TObject);
    procedure sSpeedButton2Click(Sender: TObject);
    procedure MemoLinkKeyPress(Sender: TObject; var Key: Char);
    procedure MemoLinkKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    function ReName(FileName: string): string;
    procedure TabsChange(Sender: TObject);
    procedure PasteTimerTimer(Sender: TObject);
    procedure DelBackTimerTimer(Sender: TObject);
    procedure MemoLinkChange(Sender: TObject);
    procedure cbDirectoryChange(Sender: TObject);
    procedure cbDirectoryMouseEnter(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    Data: TTask;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure InsertFromClipboardInUrlMemo;
    function CheckProtocol(var Url: string; NumberString: Integer): Integer;
    procedure MyMsg(var Message: TMessage); message WM_MYMSG;
    procedure InsertFromCommandLine;
    procedure UpdateFormSizes;
    procedure DriveFreeSpace;
    function AddTask(Now: Boolean; ShowPrev: Boolean): Boolean;

  public
    CommandTaskList: TThreadList;
    IDUrlString: Integer;
    SectionsList: TThreadList;
  end;

var
  fAddTask: TfAddTask;

implementation

uses uObjects, uMainForm, uProcedures;
{$R *.dfm}

procedure TfAddTask.MyMsg(var Message: TMessage);
var
  MessSelect: string;
begin
  MessSelect := IntToStr(Message.LParam);

  if (pos('10001', MessSelect) > 0) then
  begin

  end;
end;

procedure TfAddTask.InsertFromCommandLine;
var
  i: Integer;
  number: Integer;
  CommandTask: TCommandTask;
begin
  number := 0;
  with CommandTaskList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        CommandTask := Items[i];
        if number > 0 then
        begin
          MemoLink.Lines.Insert(i, CommandTask.Url);
          MemoLink.Lines.Delete(i + 1);
        end
        else
        begin
          MemoLink.Lines.Insert(i, CommandTask.Url);
          MemoLink.Lines.Delete(i + 1);
          inc(number);
        end;
      end;
    finally
      CommandTaskList.UnLockList;
    end;
end;

procedure TfAddTask.UpdateFormSizes;
begin
  Constraints.MaxHeight := 0;
  Constraints.MinHeight := 0;
  Label2.Align := alTop;
  MemoLink.Align := alTop;

  if MemoLink.Lines.Count >= 9 then
    MemoLink.Height := 9 * 17
  else
  begin
    if MemoLink.Lines.Count <= 1 then
      MemoLink.Height := 18
    else
      MemoLink.Height := MemoLink.Lines.Count * 17;
  end;

  ClientHeight := (MemoLink.Height * 2) + Panel1.Height + 50;
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;

  Tabs.Visible := True;
end;

procedure TfAddTask.DriveFreeSpace;
var
  TextBytes: string;
  FileDrive: string;
begin
  try
    try
      FileDrive := ExtractFileDrive(cbDirectory.Text);
      if Trim(FileDrive) <> '' then
      begin
        try
          TextBytes := BytesToText(GetFreeSpace(FileDrive));
        except
        end;
      end
      else
        TextBytes := '';
    except
      Label4.Caption := '';
    end;
  finally
    Label4.Caption := TextBytes;
  end;
end;

function TfAddTask.AddTask(Now: Boolean; ShowPrev: Boolean): Boolean;
var
  DataTask: TTask;
  hash: string;
  Url: string;
  Data2: TTask;
  IndexPlugin: Integer;
  FindProtocol: Integer;
  a: string;
  Plugin: IServicePlugin;
  Find: Boolean;
  c: string;
  i: Integer;
  FindCategory: Boolean;
  r: Integer;
  k: Integer;
  CreatedName: string;
  b: string;
begin
  result := false;

  if Trim(cbDirectory.Text) = '' then
  begin
    MessageBox(Application.Handle,
      PChar('Не указан каталог для сохранения файла!'), PChar(Options.Name),
      MB_OK or MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  for i := 0 to MemoLink.Lines.Count - 1 do
  begin
    if (Trim(MemoLink.Lines.Strings[i]) = '') then
    begin
      MessageBox(Application.Handle, PChar('Не указана ссылка в строке:' + ' ' +
        IntToStr(i + 1)), PChar(Options.Name), MB_OK or MB_ICONWARNING or
        MB_TOPMOST);
      Exit;
    end;
    FindProtocol := -1;
    Url := MemoLink.Lines.Strings[i];
    FindProtocol := CheckProtocol(Url, i + 1);
    if FindProtocol = 0 then
    begin
      MessageBox(Application.Handle,
        PChar('Не указан протокол (magnet:?) ссылки в строке' + ' ' +
        IntToStr(i + 1)), PChar(Options.Name), MB_OK or MB_ICONWARNING or
        MB_TOPMOST);
      Exit;
    end;
    if FindProtocol = 2 then
      MemoLink.Lines.Strings[i] := Url;
    hash := HashFromMagnet(Url);
    if hash <> '' then
    begin
      Find := false;
      with TasksList.LockList do
        try
          for k := 0 to Count - 1 do
          begin
            DataTask := Items[k];
            if ansilowercase(DataTask.HashValue) = ansilowercase(hash) then
            begin
              if DataTask.Status <> tsDeleted then
                Find := True;
              Break;
            end;
          end;
        finally
          TasksList.UnLockList;
        end;
      if Find then
      begin
        MessageBox(Application.Handle,
          PChar(Format
          ('Magnet-ссылка из строки %s уже имеется в списке закачек',
          [IntToStr(i + 1)])), PChar(Options.Name), MB_OK or MB_ICONWARNING or
          MB_TOPMOST);
        Exit;
      end;
    end;

  end;

  try
    for i := 0 to MemoLink.Lines.Count - 1 do
    begin
      if (Trim(MemoLink.Lines.Strings[i]) = '') then
      begin
        MessageBox(Application.Handle,
          PChar('Не указана ссылка в строке:' + ' ' + IntToStr(i + 1)),
          PChar(Options.Name), MB_OK or MB_ICONWARNING or MB_TOPMOST);
        Exit;
      end;

      if i <= (MemoName.Lines.Count - 1) then
      begin
        if (Trim(MemoName.Lines.Strings[i]) = '') then
          MemoName.Lines.Strings[i] := 'NoName';
      end
      else
        MemoName.Lines.Insert(i, 'NoName');

      if not DirectoryExists(ExcludeTrailingBackSlash(cbDirectory.Text)) then
      begin
        cbDirectory.Text := TrimLeft(cbDirectory.Text);
        cbDirectory.Text := TrimRight(cbDirectory.Text);
        cbDirectory.Text := ExcludeTrailingBackSlash(cbDirectory.Text);
        try
          MkDir(cbDirectory.Text);
        except
        end;
      end;

      Options.Directory := (cbDirectory.Text);

      Data := TTask.Create;
      Data.ID := Options.LastID + 1;
      Options.LastID := Data.ID;
      /// /////////////////////////////////////////////////////////////////////////////
      /// /////////////////////Переименование имени файла /////////////////////////////
      CreatedName := MemoName.Lines.Strings[i];
      if FileExists(Trim(cbDirectory.Text) + '\' +
        Trim(MemoName.Lines.Strings[i])) then
      begin
        a := ExtractFileExt(MemoName.Lines.Strings[i]);
        b := ChangeFileExt(MemoName.Lines.Strings[i], '');
        b := b + '[' + IntToStr(Data.ID) + ']' + a;
        CreatedName := b;
      end;
      with TasksList.LockList do
        try
          for r := 0 to Count - 1 do
          begin
            Data2 := Items[r];
            if (Data2.FileName = CreatedName) then
            begin
              a := ExtractFileExt(CreatedName);
              c := ChangeFileExt(CreatedName, '');
              CreatedName := c + '[' + IntToStr(Data.ID) + ']' + a;
            end;
          end;
        finally
          TasksList.UnLockList;
        end;

      if Now then
        Data.Status := tsQueue
      else
        Data.Status := tsReady;

      Data.LinkToFile := Trim(MemoLink.Lines.Strings[i]);
      Data.FileName := CreatedName;
      Data.Directory := ExcludeTrailingBackSlash(cbDirectory.Text);
      if CheckBox1.Checked then
        Data.ProgressiveDownload := True
      else
        Data.ProgressiveDownload := false;
      Data.TotalSize := 0;
      Data.LoadSize := 0;
      Data.TimeBegin := 0;
      Data.TimeEnd := 0;
      Data.TimeTotal := 0;
      Data.MPBar := TAMultiProgressBar.Create(nil);
      // Data.MPBar.Color:=GraphColor;

      if pos('magnet:?', ansilowercase(Data.LinkToFile)) = 1 then
      begin
        Data.HashValue := HashFromMagnet(Data.LinkToFile);
      end;

      Plugin := nil;
      DeterminePlugin2('bittorrent', IServicePlugin, Plugin, IndexPlugin);
      if Plugin <> nil then
        if Plugins[IndexPlugin] <> nil then
          if (Plugins[IndexPlugin].TaskIndexIcon > 0) then
            Data.TaskServPlugIndexIcon := Plugins[IndexPlugin].TaskIndexIcon
          else
          begin
            if pos('magnet:?', ansilowercase(Data.LinkToFile)) = 1 then
              Data.TaskServPlugIndexIcon := 34;
          end;

      Application.ProcessMessages;
      TasksList.Add(Data);
    end;
  finally

  end;

  PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 12345);

  LoadTorrentThreads.Add(TLoadTorrent.Create(false, Data, True));

  result := True;
end;

procedure TfAddTask.PasteTimerTimer(Sender: TObject);
begin
  PasteTimer.Enabled := false;

  Constraints.MaxHeight := 0;
  Constraints.MinHeight := 0;
  Label2.Align := alTop;
  MemoLink.Align := alTop;

  if MemoLink.Lines.Count >= 9 then
    MemoLink.Height := 9 * 17
  else
  begin
    if MemoLink.Lines.Count = 1 then
      MemoLink.Height := 1 * 18
    else
      MemoLink.Height := (MemoLink.Lines.Count) * 17;
  end;

  if Tabs.TabIndex = 0 then
    Height := (MemoLink.Height * 2) + Panel1.Height + 84;
  if Tabs.TabIndex = 1 then
    Height := (MemoLink.Height * 2) + Panel1.Height + 123;
  if Tabs.TabIndex = 2 then
    Height := (MemoLink.Height * 2) + Panel1.Height + 84;
  if Tabs.TabIndex = 3 then
    Height := (MemoLink.Height * 2) + Panel1.Height + 84;
  if Tabs.TabIndex = 4 then
    Height := (MemoLink.Height) + Panel1.Height + 180;

  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
end;

procedure TfAddTask.DelBackTimerTimer(Sender: TObject);
begin
  DelBackTimer.Enabled := false;
  Constraints.MaxHeight := 0;
  Constraints.MinHeight := 0;
  Label2.Align := alTop;
  MemoLink.Align := alTop;

  if MemoLink.Lines.Count >= 9 then
    MemoLink.Height := 9 * 17
  else
  begin
    if MemoLink.Lines.Count = 1 then
      MemoLink.Height := 1 * 18
    else
      MemoLink.Height := (MemoLink.Lines.Count) * 17;
  end;

  UpdateFormSizes;
end;

procedure TfAddTask.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfAddTask.FormResize(Sender: TObject);
begin
  cbDirectory.Width := Width - cbDirectory.Left - 179;
  SpeedButton1.Left := cbDirectory.Left + cbDirectory.Width + 2;
  Label3.Left := Width - 145;
  Label4.Left := Width - 75;
end;

procedure TfAddTask.FormShow(Sender: TObject);
var
  i: Integer;
  Find: Boolean;
  CommandTask: TCommandTask;
begin
  OnShowTimer.Enabled := True;

  if assigned(CommandTaskList) then
  begin
    with CommandTaskList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          CommandTask := Items[i];
          if (pos('magnet:?', ansilowercase(CommandTask.Url)) = 1) then
          begin
            Find := True;
            Break;
          end;
        end;
      finally
        CommandTaskList.UnLockList;
      end;
    if Find = True then
    begin
      InsertFromCommandLine;
    end
    else
    begin
      InsertFromClipboardInUrlMemo;
    end;
  end
  else
  begin
    InsertFromClipboardInUrlMemo;
  end;

  Position := poMainFormCenter;

  UpdateFormSizes;
end;

procedure TfAddTask.OnShowTimerTimer(Sender: TObject);
var
  i: Integer;
  CreaName: string;
begin
  OnShowTimer.Enabled := false;
  /// //////////////////// Создаем имена файлов ///////////////////////////////////
  for i := 0 to MemoLink.Lines.Count - 1 do
  begin
    CreaName := MemoLink.Lines.Strings[i];
    if i = 0 then
    begin
      CreaName := ExtractUrlFileName(CreaName);
      if CreaName <> '' then
      begin
        if RightFileName(CreaName) then
          MemoName.Lines.Strings[i] := CreaName
        else
          MemoName.Lines.Strings[i] := 'NoName';
      end
      else
        MemoName.Lines.Strings[i] := 'NoName'
    end
    else
    begin
      CreaName := ExtractUrlFileName(CreaName);
      if CreaName <> '' then
      begin
        if RightFileName(CreaName) then
          MemoName.Lines.Add(CreaName)
        else
          MemoName.Lines.Add('NoName');
      end
      else
        MemoName.Lines.Add('NoName')
    end;
    Application.ProcessMessages;
  end;
end;

procedure TfAddTask.sSpeedButton2Click(Sender: TObject);
var
  chosenDirectory: string;
begin
  FormStyle := fsNormal;
  if SelectDirectory('Выберите каталог: ', '' , chosenDirectory) then
  begin
    cbDirectory.Text := chosenDirectory;
    cbDirectory.Text := ExcludeTrailingBackSlash(cbDirectory.Text);
  end;
  FormStyle := fsStayOnTop;
end;

procedure TfAddTask.TabsChange(Sender: TObject);
begin
  UpdateFormSizes;
end;

procedure TfAddTask.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Options.AddTaskHandle := 0;
  Options.Directory := cbDirectory.Text;
end;

procedure TfAddTask.MemoLinkChange(Sender: TObject);
begin
  UpdateFormSizes;
end;

procedure TfAddTask.MemoLinkKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) or (Key = VK_BACK) then
  begin
    UpdateFormSizes;
  end;
end;

procedure TfAddTask.MemoLinkKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then { КОД клавиши Enter }
  begin
    UpdateFormSizes;
  end;
end;

procedure TfAddTask.cbDirectoryChange(Sender: TObject);
begin
  DriveFreeSpace;
end;

procedure TfAddTask.cbDirectoryClick(Sender: TObject);
begin
  DriveFreeSpace;
end;

procedure TfAddTask.cbDirectoryMouseEnter(Sender: TObject);
begin
  DriveFreeSpace;
end;

procedure TfAddTask.InsertFromClipboardInUrlMemo;
var
  ClipboardStrings: TStringList;
  i: Integer;
begin
  if Clipboard.HasFormat(CF_TEXT) then
  begin
    ClipboardStrings := TStringList.Create;
    try
      ClipboardStrings.Text := (Clipboard.AsText);
    except
    end;

    for i := 0 to ClipboardStrings.Count - 1 do
    begin
      if (pos('magnet:?', ansilowercase(ClipboardStrings[i])) > 0) then
      begin
        if Trim(ClipboardStrings[i]) <> '' then
          if i > 0 then
          begin
            try
              MemoLink.Lines.Insert(i, ClipboardStrings[i]);
              MemoLink.Lines.Delete(i + 1);
            except
            end;
          end
          else
          begin
            try
              MemoLink.Lines.Insert(i, ClipboardStrings[i]);
              MemoLink.Lines.Delete(i + 1);
            except
            end;
          end;
      end;
    end;
  end;
end;

procedure TfAddTask.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  DriveFreeSpace;
  cbDirectory.Text := Options.Directory;
end;

function TfAddTask.CheckProtocol(var Url: string;
  NumberString: Integer): Integer;
var
  Find: Boolean;
begin
  Find := false;
  result := -1;
  if (pos('magnet:?', Trim(Url)) > 0) then
  begin
    Find := True;
    result := 1;
  end;
  if Find = false then
  begin
    result := 0;
    Exit;
  end;
end;

procedure TfAddTask.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfAddTask.btnAddToListClick(Sender: TObject);
begin
  if AddTask(false, false) then
    Close;
end;

procedure TfAddTask.Button3Click(Sender: TObject);
begin
  if AddTask(True, True) then
  begin
    Close;
  end;
end;

procedure TfAddTask.btnDownloadClick(Sender: TObject);
begin
  if AddTask(True, false) then
    Close;
end;

function TfAddTask.ReName(FileName: string): string;
var
  a, b, c: string;
  r: Integer;
  DataTask: TTask;
begin
  if FileExists(ExcludeTrailingBackSlash(cbDirectory.Text) + '\' +
    Trim(FileName)) then
  begin
    a := ExtractFileExt(FileName);
    b := ChangeFileExt(FileName, '');
    FileName := b + '[' + IntToStr(Data.ID) + ']' + a;
    result := FileName;
  end;

  with TasksList.LockList do
    try
      for r := 0 to Count - 1 do
      begin
        DataTask := Items[r];
        if (DataTask.FileName = FileName) then
        begin
          a := ExtractFileExt(FileName);
          c := ChangeFileExt(FileName, '');
          result := c + '[' + IntToStr(Data.ID) + ']' + a;
          Exit;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;
  result := FileName;
end;

end.
