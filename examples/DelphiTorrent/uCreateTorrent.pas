unit uCreateTorrent;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Contnrs, Buttons, ImgList, FileCtrl,
  uProcedures, uTorrentThreads, uTorrentMethods, uTasks,
  PluginApi, PluginManager;

const
  WM_MYMSG = WM_USER + 200;

type
  TTracker = record
    Name, Announce, Webpage: String;
    Down: Boolean;
  end;

  TfCreateTorrent = class(TForm)
    ComboBox1: TComboBox;
    btnAddFile: TButton;
    btnAddFolder: TButton;
    Tabs: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Panel1: TPanel;
    btnCreate: TButton;
    mmoAnnounceURL: TMemo;
    mmWebSeeds: TMemo;
    mmoComment: TMemo;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Timer1: TTimer;
    Label2: TLabel;
    StatusBar1: TStatusBar;
    sGauge1: TProgressBar;
    sGauge2: TProgressBar;
    procedure btnCreateClick(Sender: TObject);
    procedure btnAddFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure btnAddFolderClick(Sender: TObject);
    function GetAnnounceURL: String;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabSheet2Show(Sender: TObject);
    procedure TabSheet3Show(Sender: TObject);
    procedure TabSheet1Show(Sender: TObject);
  private
    Trackers: array of TTracker;

    GetedId: string;
    GetedStatus: string;
    GetedFileName: string;
    GetedProgressMax1: Int64;
    GetedProgressMax2: Int64;
    GetedProgressPosition1: Int64;
    GetedProgressPosition2: Int64;
    TorrentFileName: WideString;

    procedure GetInGeted(GetedData: WideString);
    procedure UpdateCreatingInfo;
    procedure WaitingCreation;
    procedure ReleaseCreateTorrentThread(BTCreateTorrent: IBTCreateTorrent;
      Id: string);
    procedure StopCreateTorrentThread(Id: string;
      BTCreateTorrent: IBTCreateTorrent);
    procedure StartTorrent;
    procedure MyMsg(var Message: TMessage); message WM_MYMSG;
    { Private declarations }
  public
    Stop: Boolean;
    ButtonSave: Boolean;
    { Public declarations }
  end;

var
  fCreateTorrent: TfCreateTorrent;

implementation

uses uMainForm, uObjects;
{$R *.dfm}

procedure TfCreateTorrent.MyMsg(var Message: TMessage);
var
  MessSelect: string;
begin
  MessSelect := IntToStr(Message.LParam);

  if (pos('10007', MessSelect) > 0) then
  begin

  end;
end;

procedure TfCreateTorrent.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfCreateTorrent.btnAddFileClick(Sender: TObject);
begin
  FormStyle := fsNormal;
  if OpenDialog1.Execute then
  begin
    ComboBox1.Text := PChar(OpenDialog1.Filename);
    btnCreate.Enabled := true;
  end;
  FormStyle := fsStayOnTop;
end;

function TfCreateTorrent.GetAnnounceURL: String;
var
  i: Integer;
  found: Boolean;
begin
  found := False;
  for i := 0 to high(Trackers) do
    if Trackers[i].Name = mmoAnnounceURL.Text then
    begin
      result := Trackers[i].Announce;
      found := true;
    end;

  if not found then
  begin
    result := mmoAnnounceURL.Text;
  end;
end;

procedure TfCreateTorrent.TabSheet1Show(Sender: TObject);
begin
  ActiveControl := mmoAnnounceURL;
end;

procedure TfCreateTorrent.TabSheet2Show(Sender: TObject);
begin
  ActiveControl := mmWebSeeds;
end;

procedure TfCreateTorrent.TabSheet3Show(Sender: TObject);
begin
  ActiveControl := mmoComment;
end;

procedure TfCreateTorrent.btnAddFolderClick(Sender: TObject);
var
  chosenDirectory: string;
begin
  FormStyle := fsNormal;
  if SelectDirectory('Выберите каталог: ', '', chosenDirectory) then
  begin
    ComboBox1.Text := chosenDirectory;
    btnCreate.Enabled := true;
  end;
  FormStyle := fsStayOnTop;
end;

procedure TfCreateTorrent.btnCreateClick(Sender: TObject);
var
  BTCreateTorrent: IBTCreateTorrent;
  X: Integer;
  FindBTPlugin: Boolean;
  Id: string;
begin
  if ButtonSave then
  begin
    if ComboBox1.Text[length(ComboBox1.Text)] = '\' then
      ComboBox1.Text := copy(ComboBox1.Text, 1, length(ComboBox1.Text) - 1);

    if FileExists(ComboBox1.Text) then
    begin
      SaveDialog1.Filter := 'Torrent Files (*.torrent)|*.torrent';
      SaveDialog1.Filename := ComboBox1.Text + '.torrent';
      SaveDialog1.DefaultExt := 'Torrent files (*.torrent)';
      FormStyle := fsNormal;
      if SaveDialog1.Execute then
      begin
        FormStyle := fsStayOnTop;
        TorrentFileName := SaveDialog1.Filename;
        ButtonSave := False;
        btnCreate.Caption := 'Остановить';

        EnterCriticalSection(TorrentSection);
        try
          for X := 0 to Plugins.Count - 1 do
          begin
            if (Supports(Plugins[X], IBTCreateTorrent, BTCreateTorrent)) then
            begin
              FindBTPlugin := true;
              break;
            end;
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;

        if FindBTPlugin then
        begin
          try
            Id := IntToStr(CreateTorrentID)
          except
          end;

          EnterCriticalSection(TorrentSection);
          try
            try
              BTCreateTorrent.SingleFileTorrent((Id), (ComboBox1.Text),
                (SaveDialog1.Filename), (mmoComment.Lines.Text),
                (GetAnnounceURL), (mmWebSeeds.Lines.Text), CheckBox2.checked,
                ComboBox2.ItemIndex, False, False, '', '', '', '');
            except
            end;
          finally
            LeaveCriticalSection(TorrentSection);
          end;

          repeat
            application.ProcessMessages;

            EnterCriticalSection(TorrentSection);
            try
              try
                GetInGeted(BTCreateTorrent.GetInfoTorrentCreating(Id));
              except
              end;
            finally
              LeaveCriticalSection(TorrentSection);
            end;

            if (Stop) and (not(GetedStatus = 'stoped')) then
            begin
              EnterCriticalSection(TorrentSection);
              try
                try
                  BTCreateTorrent.StopCreateTorrentThread(Id);
                except
                end;
              finally
                LeaveCriticalSection(TorrentSection);
              end;
            end;

            WaitingCreation;

            if (Stop) and (not(GetedStatus = 'stoped')) then
            begin
              EnterCriticalSection(TorrentSection);
              try
                try
                  BTCreateTorrent.StopCreateTorrentThread(Id);
                except
                end;
              finally
                LeaveCriticalSection(TorrentSection);
              end;
            end;

            sleep(10);
          until (GetedStatus = 'completed') or (GetedStatus = 'stoped');
        end;

        ReleaseCreateTorrentThread(BTCreateTorrent, Id);

        if (GetedStatus = 'completed') then
        begin
          sGauge2.Position := sGauge2.Max;
          sGauge1.Position := sGauge1.Max;
          StatusBar1.Panels[0].Text :=
            'Создание торрент-файла успешно завершено!';

          if CheckBox1.checked then
            StartTorrent;
        end;
        if (GetedStatus = 'stoped') then
        begin
          StatusBar1.Panels[0].Text := 'Остановлено.';
        end;

        Stop := False;
        btnCreate.Enabled := true;
        ButtonSave := true;
        btnCreate.Caption := 'Создать';
      end;
    end
    else if DirectoryExists(ComboBox1.Text) then
    begin
      SaveDialog1.Filter := 'Torrent Files (*.torrent)|*.torrent';
      SaveDialog1.Filename := ComboBox1.Text + '.torrent';
      SaveDialog1.DefaultExt := 'Torrent files (*.torrent)';
      FormStyle := fsNormal;
      if SaveDialog1.Execute then
      begin
        FormStyle := fsStayOnTop;
        TorrentFileName := SaveDialog1.Filename;
        ButtonSave := False;
        btnCreate.Caption := 'Остановить';

        EnterCriticalSection(TorrentSection);
        try
          for X := 0 to Plugins.Count - 1 do
          begin
            if (Supports(Plugins[X], IBTCreateTorrent, BTCreateTorrent)) then
            begin
              FindBTPlugin := true;
              break;
            end;
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;

        if FindBTPlugin then
        begin
          try
            Id := IntToStr(CreateTorrentID)
          except
          end;

          EnterCriticalSection(TorrentSection);
          try
            try
              BTCreateTorrent.CreateFolderTorrent((Id), (ComboBox1.Text),
                (SaveDialog1.Filename), (mmoComment.Lines.Text),
                (GetAnnounceURL), (mmWebSeeds.Lines.Text), CheckBox2.checked,
                ComboBox2.ItemIndex, False, False, '', '', '', '');
            except
            end;
          finally
            LeaveCriticalSection(TorrentSection);
          end;

          repeat
            application.ProcessMessages;

            EnterCriticalSection(TorrentSection);
            try
              try
                GetInGeted(BTCreateTorrent.GetInfoTorrentCreating(Id));
              except
              end;
            finally
              LeaveCriticalSection(TorrentSection);
            end;

            if (Stop) and (not(GetedStatus = 'stoped')) then
            begin
              EnterCriticalSection(TorrentSection);
              try
                try
                  BTCreateTorrent.StopCreateTorrentThread(Id);
                except
                end;
              finally
                LeaveCriticalSection(TorrentSection);
              end;
            end;

            WaitingCreation;

            if (Stop) and (not(GetedStatus = 'stoped')) then
            begin
              EnterCriticalSection(TorrentSection);
              try
                try
                  BTCreateTorrent.StopCreateTorrentThread(Id);
                except
                end;
              finally
                LeaveCriticalSection(TorrentSection);
              end;
            end;

            sleep(10);
          until (GetedStatus = 'completed') or (GetedStatus = 'stoped');

          try
            ReleaseCreateTorrentThread(BTCreateTorrent, Id);
          except
          end;

          if (GetedStatus = 'completed') then
          begin
            sGauge2.Position := sGauge2.Max;
            sGauge1.Position := sGauge1.Max;
            StatusBar1.Panels[0].Text :=
              'Создание торрент-файла успешно завершено!';
            if CheckBox1.checked then
              StartTorrent;
          end;
          if (GetedStatus = 'stoped') then
          begin
            StatusBar1.Panels[0].Text := 'Остановлено.';
          end;

          Stop := False;
          btnCreate.Enabled := true;
          ButtonSave := true;
          btnCreate.Caption := 'Создать';
        end;
      end;
    end
    else
    begin
      Stop := False;
      btnCreate.Enabled := true;
      ButtonSave := true;
      btnCreate.Caption := 'Создать';
    end;
  end
  else
  begin
    Stop := true;
    btnCreate.Enabled := False;
    ButtonSave := true;
    StatusBar1.Panels[0].Text := 'Приостановка процесса...';
    btnCreate.Caption := 'Останавливается...';
  end;
end;

procedure TfCreateTorrent.GetInGeted(GetedData: WideString);
var
  GetedList: tstringlist;
begin
  GetedList := tstringlist.Create;
  try
    try
      GetedList.Delimiter := ' ';
      GetedList.QuoteChar := '|';
      GetedList.DelimitedText := GetedData;
      GetedId := GetedList[0];
      GetedStatus := GetedList[1];
      GetedFileName := GetedList[2];
    except
    end;
    try
      GetedProgressMax1 := StrToInt64(GetedList[3]);
    except
    end;
    try
      GetedProgressMax2 := StrToInt64(GetedList[4]);
    except
    end;
    try
      GetedProgressPosition1 := StrToInt64(GetedList[5]);
    except
    end;
    try
      GetedProgressPosition2 := StrToInt64(GetedList[6]);
    except
    end;
  finally
    GetedList.Free;
  end;
end;

procedure TfCreateTorrent.UpdateCreatingInfo;
begin
  if (GetedProgressMax2 >= 2147483647) or (GetedProgressPosition2 >= 2147483647)
  then
  begin
    try
      sGauge2.Max := GetedProgressMax2 div 1024;
      sGauge2.Position := GetedProgressPosition2 div 1024;
    except
    end;
  end
  else
  begin
    try
      sGauge2.Max := GetedProgressMax2;
      sGauge2.Position := GetedProgressPosition2;
    except
    end;
  end;
  if (GetedProgressMax1 >= 2147483647) or (GetedProgressPosition1 >= 2147483647)
  then
  begin
    try
      sGauge1.Max := GetedProgressMax1 div 1024;
      sGauge1.Position := GetedProgressPosition1 div 1024;
    except
    end;
  end
  else
  begin
    try
      sGauge1.Max := GetedProgressMax1;
      sGauge1.Position := GetedProgressPosition1;
    except
    end;
  end;
//  sGauge2.Suffix := '% (' + ExtractFileName(GetedFileName) + ')';
end;

procedure TfCreateTorrent.WaitingCreation;
begin

  if GetedStatus = 'start' then
  begin

  end;

  if GetedStatus = 'creating' then
  begin
    UpdateCreatingInfo;
    StatusBar1.Panels[0].Text := 'Хэширование...';
  end;

  if GetedStatus = 'done' then
  begin
    sGauge1.Position := GetedProgressMax1;
  end;

  if GetedStatus = 'abort' then
  begin

  end;

  if Stop then
  begin
    StatusBar1.Panels[0].Text := 'Приостановка процесса...';
  end;
end;

procedure TfCreateTorrent.ReleaseCreateTorrentThread(BTCreateTorrent
  : IBTCreateTorrent; Id: string);
begin
  EnterCriticalSection(TorrentSection);
  try
    BTCreateTorrent.ReleaseCreateTorrentThread(Id);
  finally
    LeaveCriticalSection(TorrentSection);
  end;
end;

procedure TfCreateTorrent.StopCreateTorrentThread(Id: string;
  BTCreateTorrent: IBTCreateTorrent);
begin
  EnterCriticalSection(TorrentSection);
  try
    try
      BTCreateTorrent.StopCreateTorrentThread(Id);
    except
    end;
  finally
    LeaveCriticalSection(TorrentSection);
  end;
end;

procedure TfCreateTorrent.StartTorrent;
var
  BTPlugin: IBTServicePlugin;
  HashValue: string;
  Find: Boolean;
  i: Integer;
  InfoTorrent: WideString;
  InfoTorrentSL: tstringlist;
  TorrentDataSL: tstringlist;
  DataTask: TTask;
  Local_X: Integer;
  Local_X1: Integer;
  X: Integer;
  DataList: tstringlist;
  BTAddSeeding: IBTServiceAddSeeding;
begin
  for Local_X := 0 to Plugins.Count - 1 do
  begin
    if (Supports(Plugins[Local_X], IBTServicePlugin, BTPlugin)) then
    begin
      try
        InfoTorrent := BTPlugin.GetInfoTorrentFile(TorrentFileName);
      except
      end;
      break;
    end;
  end;
  InfoTorrentSL := tstringlist.Create;
  try
    InfoTorrentSL.Text := (InfoTorrent);
    HashValue := (InfoTorrentSL[5]);
  except
  end;
  if Trim(HashValue) = '' then
  begin
    MessageBox(application.Handle,
      PChar('Нет доступа к торрент файлу или ошибка при открытии торрент-файла'),
      PChar(Options.Name), MB_OK or MB_ICONWARNING or MB_TOPMOST);
    exit;
  end;
  Find := False;
  with TasksList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        DataTask := Items[i];
        if ansilowercase(DataTask.HashValue) = ansilowercase(HashValue) then
        begin
          if DataTask.Status <> tsDeleted then
          begin
            Find := true;
            break;
          end;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;

  if Find then
  begin
    MessageBox(application.Handle,
      PChar('Этот торрент уже имеется в списке закачек'), PChar(Options.Name),
      MB_OK or MB_ICONWARNING or MB_TOPMOST);
    exit;
  end;

  Find := False;
  with TasksList.LockList do
    try
      for Local_X1 := 0 to Count - 1 do
      begin
        DataTask := Items[Local_X1];
        if DataTask.Status <> tsDeleted then
          if DataTask.HashValue = HashValue then
          begin
            Find := true;
            break;
          end;
      end;
    finally
      TasksList.UnLockList;
    end;

  if Find then
  begin
    MessageBox(application.Handle, PChar('Торрент имеется в списке заданий'),
      PChar(Options.Name), MB_OK or MB_ICONWARNING or MB_TOPMOST);
    exit;
  end;

  TorrentDataSL := tstringlist.Create;
  try
    TorrentDataSL.Insert(0, BoolToStr(true));
    TorrentDataSL.Insert(1, BoolToStr(False));
    TorrentDataSL.Insert(2, TorrentFileName);
    TorrentDataSL.Insert(3, ExtractFilePath(ComboBox1.Text));
    TorrentDataSL.Insert(4, IntToStr(50));
    TorrentDataSL.Insert(5, InfoTorrentSL[0]);
    TorrentDataSL.Insert(6, InfoTorrentSL[6]);
    TorrentDataSL.Insert(7, InfoTorrentSL[7]);
    TorrentDataSL.Insert(8, InfoTorrentSL[8]);
    TorrentDataSL.Insert(9, InfoTorrentSL[2]);
    AddTorrent(TorrentDataSL.Text, HashValue, False, False);
  finally
    TorrentDataSL.Free;
    InfoTorrentSL.Free;
  end;

  Find := False;
  with TasksList.LockList do
    try
      for Local_X1 := 0 to Count - 1 do
      begin
        DataTask := Items[Local_X1];
        if DataTask.Status <> tsDeleted then
          if DataTask.HashValue = HashValue then
          begin
            Find := true;
            break;
          end;
      end;
    finally
      TasksList.UnLockList;
    end;

  if Find then
  begin
    for X := 0 to Plugins.Count - 1 do
    begin
      if (Supports(Plugins[X], IBTServiceAddSeeding, BTAddSeeding)) then
      begin
        DataList := tstringlist.Create;
        EnterCriticalSection(TorrentSection);
        try
          try
            DataList.Insert(0, IntToStr(DataTask.Id));
            DataList.Insert(1, DataTask.TorrentFileName);
            DataList.Insert(2, ExcludeTrailingBackSlash(DataTask.Directory));
            BTAddSeeding.AddSeeding(DataList.Text);
          except
          end;
        finally
          LeaveCriticalSection(TorrentSection);
          DataList.Free;
        end;
        break;
      end;
    end;

    TSeedingThread.Create(False, DataTask, False);
    DataTask.Status := tsSeeding;
  end;

  PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 12345);
  LoadTorrentThreads.Add(TLoadTorrent.Create(False, DataTask, true));
end;

procedure TfCreateTorrent.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Options.StartSeeding := CheckBox1.checked;
  Options.PrivateTorrent := CheckBox2.checked;
  Options.Trackers := mmoAnnounceURL.Lines.Text;
  Options.PartSize := ComboBox2.ItemIndex;
  Dec(CreateTorrentID);
  Options.CreateTorrentHandle := 0;
end;

procedure TfCreateTorrent.FormCreate(Sender: TObject);
begin
  Stop := False;
  ButtonSave := true;
  btnCreate.Enabled := False;
  Position := poMainFormCenter;
  CheckBox1.checked := Options.StartSeeding;
  CheckBox2.checked := Options.PrivateTorrent;
  mmoAnnounceURL.Lines.Text := Options.Trackers;
  ComboBox2.ItemIndex := Options.PartSize;
  Inc(CreateTorrentID);
end;

end.
