unit uAddTorrent;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ImgList, StdCtrls, ExtCtrls, ComCtrls, ClipBrd, Menus,
  FileCtrl,
{$IFDEF VER290}
  System.ImageList,
{$ENDIF}
  uTorrentThreads, uAMultiProgressBar, uObjects, uTasks, uProcedures,
  PluginManager, PluginApi;

const
  WM_MYMSG = WM_USER + 200;

type
  TCustomer = class(TObject)
  public
    fL: TStringList;
    fn: string;
  end;

type
  TfAddTorrent = class(TForm)
    btnDownload: TButton;
    btnAdd: TButton;
    cbDirectory: TComboBox;
    Edit1: TEdit;
    Tabs: TPageControl;
    AddFileName: TTabSheet;
    Extra: TTabSheet;
    Edit2: TEdit;
    Label10: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    ListView1: TListView;
    Label1: TLabel;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    Panel2: TPanel;
    CheckBox1: TCheckBox;
    SpeedButton1: TSpeedButton;
    ImageList1: TImageList;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDownloadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sSpeedButton2Click(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure cbDirectoryChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure cbDirectoryEnter(Sender: TObject);
    procedure cbDirectoryClick(Sender: TObject);
    procedure cbDirectoryMouseEnter(Sender: TObject);

    procedure FormResize(Sender: TObject);

    procedure Button3Click(Sender: TObject);

    procedure N1Click(Sender: TObject);
  private
    SizeTorrent: int64;
    HashValue: string;
    Advt: string;
    Releaser: string;
    SiteReleaser: string;
    trackers: String;
    FilesList: TList;
    FList: TList;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DriveFreeSpace;
    function AddTask(Now: Boolean; ShowPrev: Boolean): Boolean;
    function AddTorrent(TorrData: string; HashValue: string; Now: Boolean;
      ShowPrev: Boolean): Boolean;
    procedure MyMsg(var Message: TMessage); message WM_MYMSG;
    { Private declarations }
  public
    TorrentFileName: string;
    InfoTorrent: string;
    { Public declarations }
  end;

var
  fAddTorrent: TfAddTorrent;

implementation

uses uMainForm;
{$R *.dfm}

procedure TfAddTorrent.MyMsg(var Message: TMessage);
var
  MessSelect: string;
begin
  MessSelect := IntToStr(Message.LParam);

  if (pos('10008', MessSelect) > 0) then
  begin

  end;
end;

procedure TfAddTorrent.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

function BytesToText(Bytes: int64): String;
begin
  if Bytes div 1024 < 1 then
    Result := IntToStr(Bytes) + ' B';
  if Bytes div 1024 >= 1 then
    Result := FloatToStrF(Bytes / 1024, ffNumber, 18, 1) + ' KB';
  if Bytes div 1024 >= 1024 then
    Result := FloatToStrF(Bytes / 1048576, ffNumber, 18, 1) + ' MB';
  if Bytes div 1024 >= 1048576 then
    Result := FloatToStrF(Bytes / 1073741824, ffNumber, 18, 2) + ' GB';
end;

procedure TfAddTorrent.DriveFreeSpace;
var
  TextBytes: string;
  FileDrive: string;
begin
  try
    try
      FileDrive := ExtractFileDrive(cbDirectory.Text);
      if Trim(FileDrive) <> '' then
        TextBytes := BytesToText(GetFreeSpace(FileDrive))
      else
        TextBytes := '';
    except
      Label5.Caption := '';
    end;
  finally
    Label5.Caption := TextBytes;
  end;
end;

function OriginalName(FileName: string; Directory: string; ID: string): string;
var
  a, b, c: string;
  r: Integer;
  DataTask: TTask;
begin
  if FileExists(Trim(Directory) + '\' + Trim(FileName)) then
  begin
    a := ExtractFileExt(FileName);
    b := ChangeFileExt(FileName, '');
    FileName := b + '[' + ID + ']' + a;
    Result := FileName;
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
          Result := c + '[' + ID + ']' + a;
          Exit;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;
  Result := FileName;
end;

function TfAddTorrent.AddTorrent(TorrData: string; HashValue: string;
  Now: Boolean; ShowPrev: Boolean): Boolean;
var
  AddDataTask: TTask;
  AddedData: TStringList;
  CreaName, CreatedName: string;
  Plugin2: IAddDownload;
  IndexPlugin2: Integer;
  Silent: Boolean;
  Down: Boolean;
begin
  Result := false;
  AddedData := TStringList.Create;

  try
    AddedData.Text := TorrData;
    try
      Silent := StrToBool(AddedData[0]);
      Down := StrToBool(AddedData[1]);
    except
      Down := true;
      Silent := true;
    end;
    if Silent then
    begin
      AddDataTask := TTask.Create;
      AddDataTask.TorrentFileName := AddedData[2];
      AddDataTask.HashValue := HashValue;
      AddDataTask.LinkToFile := 'magnet:?xt=urn:btih:' +
        AnsiLowerCase(AddDataTask.HashValue);
      AddDataTask.Directory := ExcludeTrailingBackSlash(AddedData[3]);
      AddDataTask.ID := Options.LastID + 1;
      Options.LastID := AddDataTask.ID;
      CreaName := AddedData[5];
      CreaName := trimleft(CreaName);
      CreaName := trimright(CreaName);
      CreatedName := CreaName;
      AddDataTask.FileName := CreatedName;
      AddDataTask.Description := '';
      if CheckBox1.Checked then
        AddDataTask.ProgressiveDownload := true
      else
        AddDataTask.ProgressiveDownload := false;

      if Down then
        AddDataTask.Status := tsQueue
      else
        AddDataTask.Status := tsReady;

      AddDataTask.TotalSize := SizeTorrent;
      AddDataTask.LoadSize := 0;
      AddDataTask.TimeBegin := 0;
      AddDataTask.TimeEnd := 0;
      AddDataTask.TimeTotal := 0;
      AddDataTask.MPBar := TAMultiProgressBar.Create(nil);
      // AddDataTask.MPBar.Color:=GraphColor;

      Plugin2 := nil;
      DeterminePlugin2('bittorrent', IServicePlugin, Plugin2, IndexPlugin2);
      if Plugin2 <> nil then
        if Plugins[IndexPlugin2] <> nil then
          if (Plugins[IndexPlugin2].TaskIndexIcon > 0) then
            AddDataTask.TaskServPlugIndexIcon := Plugins[IndexPlugin2]
              .TaskIndexIcon
          else
          begin
            if pos('magnet:?', AnsiLowerCase(AddDataTask.LinkToFile)) = 1 then
              AddDataTask.TaskServPlugIndexIcon := 34;
          end;

      TasksList.Add(AddDataTask);
      Result := true;

      PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 12345);

      if Now then
        LoadTorrentThreads.Add(TLoadTorrent.Create(false, AddDataTask, true));
    end;

  finally
    AddedData.Free;
  end;
end;

procedure TfAddTorrent.btnDownloadClick(Sender: TObject);
begin
  if AddTask(true, false) then
    close;
end;

procedure TfAddTorrent.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TfAddTorrent.btnAddClick(Sender: TObject);
begin
  if AddTask(false, false) then
    close;
end;

function TfAddTorrent.AddTask(Now: Boolean; ShowPrev: Boolean): Boolean;
var
  find: Boolean;
  TorrentDataSL: TStringList;
  X: Integer;
  DataTask: TTask;
  BTPluginAddTrackers: IBTServicePluginAddTrackers;
begin
  Result := false;
  if Trim(HashValue) = '' then
  begin
    MessageBox(Handle,
      PChar('Нет доступа к торрент файлу или ошибка чтения торрент-файла'),
      PChar(Options.Name), MB_OK or MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  find := false;
  with TasksList.LockList do
    try
      for X := 0 to Count - 1 do
      begin
        DataTask := Items[X];
        if DataTask.Status <> tsDeleted then
          if DataTask.HashValue = HashValue then
          begin
            find := true;
            break;
          end;
      end;
    finally
      TasksList.UnLockList;
    end;
  if find then
  begin
    if MessageBox(Application.Handle,
      PChar('Вы пытаетесь добавить торрент, который уже есть в списке. Хотите загрузить из него список трекеров?'),
      PChar(Options.Name), MB_OKCANCEL or MB_ICONWARNING) = ID_OK then
    begin
      for X := 0 to Plugins.Count - 1 do
      begin
        if (Supports(Plugins[X], IBTServicePluginAddTrackers,
          BTPluginAddTrackers)) then
        begin
          try
            BTPluginAddTrackers.AddTrackers(HashValue, trackers);
          except
          end;
          break;
        end;
      end;
    end;
    Exit;
  end;

  TorrentDataSL := TStringList.Create;
  try
    TorrentDataSL.Insert(0, BoolToStr(true));

    if Now then
      TorrentDataSL.Insert(1, BoolToStr(true))
    else
      TorrentDataSL.Insert(1, BoolToStr(false));

    TorrentDataSL.Insert(2, Edit1.Text);
    TorrentDataSL.Insert(3, ExcludeTrailingBackSlash(cbDirectory.Text));
    TorrentDataSL.Insert(4, IntToStr(0));
    TorrentDataSL.Insert(5, Edit2.Text);

    AddTorrent(TorrentDataSL.Text, HashValue, Now, ShowPrev);
  finally
    TorrentDataSL.Free;
  end;

  try
    ForceDirectories(ExcludeTrailingBackSlash(cbDirectory.Text));
  except
  end;

  SaveTasksList;

  Result := true;
end;

procedure TfAddTorrent.Button3Click(Sender: TObject);
begin
  AddTask(true, true);
  close;
end;

procedure TfAddTorrent.cbDirectoryChange(Sender: TObject);
begin
  DriveFreeSpace;
end;

procedure TfAddTorrent.cbDirectoryClick(Sender: TObject);
begin
  DriveFreeSpace;
end;

procedure TfAddTorrent.cbDirectoryEnter(Sender: TObject);
begin
  DriveFreeSpace;
end;

procedure TfAddTorrent.cbDirectoryMouseEnter(Sender: TObject);
begin
  DriveFreeSpace;
end;

procedure TfAddTorrent.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Options.AddTorrentHandle := 0;
  Options.Directory := cbDirectory.Text;
end;

procedure TfAddTorrent.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  cbDirectory.Text := Options.Directory;
end;

procedure TfAddTorrent.FormResize(Sender: TObject);
begin
  cbDirectory.Width := Width - cbDirectory.Left - 179;
  SpeedButton1.Left := Width - 175;
  Label4.Left := Width - 145;
  Label6.Left := Width - 145;
  Label5.Left := Width - 75;
  Label7.Left := Width - 75;
end;

procedure TfAddTorrent.FormShow(Sender: TObject);
var
  InfoTorrentSL: TStringList;
  FreeSpaceDisk: int64;
  TorrentSubFile: TTorrentSubFileClass;
  InfoList: TStringList;
  FileInfoList: TStringList;
  i: Integer;
  Customer: TCustomer;
begin
  Edit1.Text := TorrentFileName;
  InfoTorrentSL := TStringList.Create;
  try
    FreeSpaceDisk := GetFreeSpace(cbDirectory.Text);
    Label5.Caption := BytesToText(FreeSpaceDisk);
    InfoTorrentSL.Text := InfoTorrent;
    try
      Edit2.Text := Utf8ToAnsi(InfoTorrentSL[0]);
      Label10.Caption := InfoTorrentSL[1];
      SizeTorrent := StrToInt64(InfoTorrentSL[2]);
      Label7.Caption := BytesToText(SizeTorrent);
      Label13.Caption := (InfoTorrentSL[3]);
      HashValue := (InfoTorrentSL[5]);
      Advt := (InfoTorrentSL[6]);
      Releaser := (InfoTorrentSL[7]);
      SiteReleaser := (InfoTorrentSL[8]);
      trackers := (InfoTorrentSL[9]);
    except
    end;

    FilesList := TList.Create;
    InfoList := TStringList.Create;
    InfoList.Delimiter := ' ';
    InfoList.QuoteChar := '^';
    try
      InfoList.DelimitedText := InfoTorrentSL[4];
    except
    end;
    for i := 0 to InfoList.Count - 1 do
    begin
      FileInfoList := TStringList.Create;
      FileInfoList.Delimiter := ' ';
      FileInfoList.QuoteChar := '|';
      FileInfoList.DelimitedText := InfoList[i];
      TorrentSubFile := TTorrentSubFileClass.Create;
      TorrentSubFile.Name := Utf8ToAnsi(FileInfoList[0]);
      TorrentSubFile.Path := Utf8ToAnsi(FileInfoList[1]);
      try
        TorrentSubFile.Offset := StrToInt64(FileInfoList[2]);
      except
      end;
      try
        TorrentSubFile.Length := StrToInt64(FileInfoList[3]);
      except
      end;
      FilesList.Add(TorrentSubFile);
      FileInfoList.Free;
    end;
    InfoList.Free;

    ListView1.Items.BeginUpdate;
    try
      ListView1.Items.Clear;
      ListView1.Items.Count := FilesList.Count;
    finally
      ListView1.Items.EndUpdate;
    end;

    FList := TList.Create;
    for i := 0 to FilesList.Count - 1 do
    begin
      Customer := TCustomer.Create;
      Customer.fL := TStringList.Create;
      Customer.fL.Delimiter := '\';
      Customer.fL.StrictDelimiter := true;
      Customer.fL.DelimitedText := TTorrentSubFileClass(FilesList[i]).Path +
        TTorrentSubFileClass(FilesList[i]).Name;
      Customer.fn := TTorrentSubFileClass(FilesList[i]).Path +
        TTorrentSubFileClass(FilesList[i]).Name;
      FList.Add(Customer);
    end;
  finally
    InfoTorrentSL.Free;
  end;
end;

procedure TfAddTorrent.ListView1Data(Sender: TObject; Item: TListItem);
var
  i: Integer;
  TorrentSubFile: TTorrentSubFileClass;
begin
  for i := 0 to FilesList.Count - 1 do
  begin
    if i = Item.Index then
    begin
      TorrentSubFile := FilesList[i];
      Item.Caption := TorrentSubFile.Path + TorrentSubFile.Name;
      Item.SubItems.Add(BytesToText(TorrentSubFile.Length));
    end;
  end;
end;

procedure TfAddTorrent.N1Click(Sender: TObject);
var
  Buff: TStringList;
begin
  Clipboard.Open;
  Buff := TStringList.Create;
  Buff.Add(Label10.Caption);
  Clipboard.AsText := Buff.Text;
  Clipboard.close;
end;

procedure TfAddTorrent.sSpeedButton2Click(Sender: TObject);
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

end.
