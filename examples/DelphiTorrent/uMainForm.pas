unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Menus,
  Forms, Dialogs, ComCtrls, Buttons, ExtCtrls, ImgList, Graphics,
{$IFDEF VER290}
  System.ImageList,
{$ENDIF}
  uObjects, uTasks, uConstsProg, uAddTorrent, uStartThreads,
  uHelperThreads, uAMultiProgressBar, uProcedures, uUpdateThread,
  uTorrentThreads, uAddTask, uCreateTorrent,
  PluginAPI, PluginManager;

type
  TfMainForm = class(TForm, IServiceProvider)
    lvTasks: TListView;
    OpenDialog1: TOpenDialog;
    pmTasks: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    PageControl3: TPageControl;
    TabSheet4: TTabSheet;
    Panel2: TPanel;
    tshPeers: TTabSheet;
    tshFiles: TTabSheet;
    tshTrackers: TTabSheet;
    lvFiles: TListView;
    lvPeers: TListView;
    lvTrackers: TListView;
    pmTrackers: TPopupMenu;
    N97: TMenuItem;
    Panel1: TPanel;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    Image5: TImage;
    Panel4: TPanel;
    Image6: TImage;
    Panel5: TPanel;
    Image7: TImage;
    Panel6: TPanel;
    Image8: TImage;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ImageList16_2: TImageList;
    procedure lvTasksData(Sender: TObject; Item: TListItem);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sSpeedButton8Click(Sender: TObject);
    procedure sSpeedButton3Click(Sender: TObject);
    procedure sSpeedButton2Click(Sender: TObject);
    procedure sSpeedButton1Click(Sender: TObject);
    procedure sSpeedButton18Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure lvTasksSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure PageControl3Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvFilesData(Sender: TObject; Item: TListItem);
    procedure lvPeersData(Sender: TObject; Item: TListItem);
    procedure lvTrackersData(Sender: TObject; Item: TListItem);
    procedure N97Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    procedure MyMsg(var Message: TMessage); message WM_MYMSG;
    procedure UpdateVisual;
    procedure UpdatePeersVisual;
    procedure UpdateTrackersVisual;
    procedure UpdateFilesVisual;
    procedure UpdateInfPanel;
  public
    procedure LoadPlugins;
    function CreateInterface(const APlugin: IPlugin; const AIID: TGUID;
      out Intf): Boolean;
  end;

  TMainFormProvider = class(TBasicProvider, IApplicationWindows, IAppIcon)
  private
    FForm: TfMainForm;
  protected
    // IApplicationWindows
    function GetApplicationWnd: HWND; safecall;
    function GetMainWnd: HWND; safecall;
    function GetActiveWnd: HWND; safecall;
    function GetClientWnd: HWND; safecall;
    function GetPopupCtrlWnd: HWND; safecall;
    procedure ModalStarted; safecall;
    procedure ModalFinished; safecall;
    procedure ProcessMessages; safecall;
    procedure HandleMessage; safecall;
    // IAppIcon
    function GetSmall: HICON; safecall;
    function GetLarge: HICON; safecall;
  public
    constructor Create(const AManager: IPluginManager; const APlugin: IPlugin;
      const AForm: TfMainForm); reintroduce;
    property Form: TfMainForm read FForm;
    // destructor Destroy; override;
  end;

var
  fMainForm: TfMainForm;
  TasksList: TThreadList;
  SeedingThreads: TThreadList;
  LoadTorrentThreads: TThreadList;
  TorrentSection: TRTLCriticalSection;
  BackGroundColor: cardinal;
  GraphColor: cardinal;
  ProgressBackColor: cardinal;
  CountSeeding: Integer;
  CountStoped: Integer;
  CountLoading: Integer;
  CountQueue: Integer;
  AllSpeeds: int64;
  AllUpSpeeds: int64;
  Exiting: Boolean;
  ExitComplete: Boolean;
  CreateTorrentID: Integer;
  IDSelected: string;
  UpdateVisualThread: TUpdateVisualThread;

implementation

{$R *.dfm}

function GetTimeStr(Secs: Integer): String;

  function LeadingZero(N: Integer): String;
  begin
    if N < 10 then
      Result := '0' + IntToStr(N)
    else
      Result := IntToStr(N);
  end;

var
  Hours, Mins: Integer;
begin
  Hours := Secs div 3600;
  Secs := Secs - Hours * 3600;
  Mins := Secs div 60;
  Secs := Secs - Mins * 60;
  Result := LeadingZero(Hours) + ':' + LeadingZero(Mins) + ':' +
    LeadingZero(Secs);
end;

procedure TfMainForm.MyMsg(var Message: TMessage);
var
  MessTime: string;
begin
  MessTime := IntToStr(Message.LParam);

  if pos('12345', MessTime) > 0 then
  begin
    UpdateVisual;
  end;

  if pos('10008', MessTime) > 0 then
  begin
    StatusBar1.Panels.Items[1].Text := IntToStr(CountSeeding);
    StatusBar1.Panels.Items[2].Text := IntToStr(CountLoading);
    StatusBar1.Panels.Items[3].Text := IntToStr(CountQueue);
    StatusBar1.Panels.Items[4].Text := IntToStr(CountStoped);
  end;

  if pos('10009', MessTime) > 0 then
  begin
    if AllSpeeds < 1024 then
      StatusBar1.Panels.Items[5].Text := 'С.З:' + ' ' +
        IntToStr(AllSpeeds) + ' B/s';
    if (AllSpeeds >= 1024) and (AllSpeeds < 1048576) then
      StatusBar1.Panels.Items[5].Text := 'С.З:' + ' ' +
        BytesToKiloBytes(AllSpeeds) + ' KB/s';
    if AllSpeeds >= 1048576 then
      StatusBar1.Panels.Items[5].Text := 'С.З:' + ' ' +
        BytesToMegaBytes(AllSpeeds) + ' MB/s';

    if AllUpSpeeds < 1024 then
      StatusBar1.Panels.Items[6].Text := 'С.О:' + ' ' +
        IntToStr(AllUpSpeeds) + ' B/s';
    if (AllUpSpeeds >= 1024) and (AllUpSpeeds < 1048576) then
      StatusBar1.Panels.Items[6].Text := 'С.О:' + ' ' +
        BytesToKiloBytes(AllUpSpeeds) + ' KB/s';
    if AllUpSpeeds >= 1048576 then
      StatusBar1.Panels.Items[6].Text := 'С.О:' + ' ' +
        BytesToMegaBytes(AllUpSpeeds) + ' MB/s';

  end;

  if pos('12121', MessTime) > 0 then
  begin
    try
      lvTasks.Items.BeginUpdate;
      lvTasks.Items.EndUpdate;
    except
    end;
    UpdateInfPanel;
  end;
end;

procedure TfMainForm.N1Click(Sender: TObject);
var
  i, k: Integer;
  DataTask: TTask;
  IDDeletedList: TStringList;
begin
  if assigned(lvTasks.Selected) then
  begin
    IDDeletedList := TStringList.Create;
    with TasksList.LockList do
      try
        for i := 0 to lvTasks.Items.Count - 1 do
        begin
          if lvTasks.Items[i].Selected then
          begin
            for k := 0 to Count - 1 do
            begin
              if i = k then
              begin
                DataTask := Items[k];
                begin
                  if (DataTask.Status = tsLoading) or
                    (DataTask.Status = tsGetUrl) or
                    (DataTask.Status = tsStoping) or
                    (DataTask.Status = tsErroring) then
                  else
                  begin
                    DataTask.Status := tsDeleted;
                    IDDeletedList.Add(IntToStr(DataTask.ID));
                  end;
                end;
              end;
            end;
          end;
        end;

      finally
        TasksList.UnLockList;
        TDeleteTaskThread.Create(false, IDDeletedList);
      end;
  end;
  StatusBar1.Panels.Items[0].Text := '';
  UpdateVisual;
end;

procedure TfMainForm.N2Click(Sender: TObject);
var
  i, k: Integer;
  DataTask: TTask;
  IDDeletedList: TStringList;
begin
  if assigned(lvTasks.Selected) then
  begin
    IDDeletedList := TStringList.Create;
    with TasksList.LockList do
      try
        for i := 0 to lvTasks.Items.Count - 1 do
        begin
          if lvTasks.Items[i].Selected then
          begin
            for k := 0 to Count - 1 do
            begin
              if i = k then
              begin
                DataTask := Items[k];
                begin
                  if (DataTask.Status = tsLoading) or
                    (DataTask.Status = tsGetUrl) or
                    (DataTask.Status = tsStoping) or
                    (DataTask.Status = tsErroring) then
                  else
                  begin
                    DataTask.Status := tsDeleted;
                    IDDeletedList.Add(IntToStr(DataTask.ID));
                  end;
                end;
              end;
            end;
          end;
        end;
      finally
        TasksList.UnLockList;
        TDeleteTaskWithFileThread.Create(false, IDDeletedList);
      end;
  end;
  StatusBar1.Panels.Items[0].Text := '';
  UpdateVisual;
end;

procedure TfMainForm.N97Click(Sender: TObject);
var
  BTPluginUpdateTracker: IBTServicePluginUpdateTracker;
  FindHashValue: Boolean;
  X: Integer;
  DataTask: TTask;
  HashValue: string;
  URL: string;
  i, k: Integer;
  TrackerInfo: TTrackers;
begin
  if lvTrackers.SelCount > 0 then
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask then
            for k := 0 to DataTask.Trackers.Count - 1 do
            begin
              if k = lvTrackers.Selected.Index then
              begin
                TrackerInfo := DataTask.Trackers.Items[k];
                URL := TrackerInfo.URL;
                break;
              end;
            end;
        end;
      finally
        TasksList.UnLockList;
      end;

  FindHashValue := false;
  with TasksList.LockList do
    try
      for X := 0 to Count - 1 do
      begin
        DataTask := Items[X];
        if IDSelected = IntToStr(DataTask.ID) then
        begin
          if DataTask.Status <> tsDeleted then
          begin
            HashValue := DataTask.HashValue;
            FindHashValue := true;
            break;
          end;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;

  if FindHashValue then
  begin
    begin
      for X := 0 to Plugins.Count - 1 do
      begin
        if (Supports(Plugins[X], IBTServicePluginUpdateTracker,
          BTPluginUpdateTracker)) then
        begin
          try
            BTPluginUpdateTracker.UpdateTracker(HashValue, URL);
          except
          end;
          break;
        end;
      end;
    end;
  end;
end;

procedure TfMainForm.PageControl3Change(Sender: TObject);
begin
  UpdateInfPanel;
end;

function TfMainForm.CreateInterface(const APlugin: IPlugin; const AIID: TGUID;
  out Intf): Boolean;
var
  ID: TGUID;
  I3: IApplicationWindows;
begin
  Pointer(Intf) := nil;

  ID := IApplicationWindows;
  if CompareMem(@ID, @AIID, SizeOf(TGUID)) then
  begin
    I3 := TMainFormProvider.Create(Plugins, APlugin, Self);
    IApplicationWindows(Intf) := I3;
    Result := true;
    Exit;
  end;

  Result := false;
end;

procedure TfMainForm.UpdateInfPanel;
begin
  if PageControl3.ActivePage = tshFiles then
  begin
    UpdateFilesVisual;
    try
      lvFiles.Items.BeginUpdate;
      lvFiles.Items.EndUpdate;
    except
    end;
  end
  else if PageControl3.ActivePage = tshPeers then
  begin
    UpdatePeersVisual;
    try
      lvPeers.Items.BeginUpdate;
      lvPeers.Items.EndUpdate;
    except
    end;
  end
  else if PageControl3.ActivePage = tshTrackers then
  begin
    UpdateTrackersVisual;
    try
      lvTrackers.Items.BeginUpdate;
      lvTrackers.Items.EndUpdate;
    except
    end;
  end;
end;

procedure TfMainForm.sSpeedButton18Click(Sender: TObject);
begin
  if Options.CreateTorrentHandle = 0 then
  begin
    fCreateTorrent := TfCreateTorrent.Create(Application);
    Options.CreateTorrentHandle := fCreateTorrent.Handle;
    try
      fCreateTorrent.Show;
    except
    end;
  end;
end;

procedure TfMainForm.sSpeedButton1Click(Sender: TObject);
begin
  if Options.AddTaskHandle = 0 then
  begin
    fAddTask := TfAddTask.Create(Application);
    Options.AddTaskHandle := fAddTask.Handle;
    try
      fAddTask.Show;
    except
    end;
  end;
end;

procedure TfMainForm.sSpeedButton2Click(Sender: TObject);
var
  i, k: Integer;
  DataTask: TTask;
  Find: Boolean;
begin
  if not assigned(lvTasks.Selected) then
    Exit;
  Find := false;
  with TasksList.LockList do
    try
      for i := 0 to lvTasks.Items.Count - 1 do
      begin
        if lvTasks.Items[i].Selected then
        begin
          for k := 0 to Count - 1 do
          begin
            if i = k then
            begin
              DataTask := Items[k];
              begin
                if (DataTask.Status = tsError) or (DataTask.Status = tsReady) or
                  (DataTask.Status = tsStoped) then
                begin
                  DataTask.Status := tsQueue;
                  DataTask.Status := tsStartProcess;
                  Find := true;
                  break;
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;
  if Find then
    LoadTorrentThreads.Add(TLoadTorrent.Create(false, DataTask, true));
end;

procedure TfMainForm.sSpeedButton3Click(Sender: TObject);
var
  i, k: Integer;
  DataTask: TTask;
begin
  if not assigned(lvTasks.Selected) then
    Exit;
  with TasksList.LockList do
    try
      for i := 0 to lvTasks.Items.Count - 1 do
      begin
        if lvTasks.Items[i].Selected then
        begin
          for k := 0 to Count - 1 do
          begin
            if i = k then
            begin
              DataTask := Items[k];
              begin
                if (DataTask.Status = tsLoading) or (DataTask.Status = tsGetUrl)
                  or (DataTask.Status = tsErroring) or
                  (DataTask.Status = tsProcessing) or
                  (DataTask.Status = tsBittorrentMagnetDiscovery) or
                  (DataTask.Status = tsAllocating) then
                begin
                  DataTask.Status := tsStoping;
                end;
                if (DataTask.Status = tsQueue) then
                  DataTask.Status := tsStoped;
              end;
            end;
          end;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;
end;

procedure TfMainForm.sSpeedButton8Click(Sender: TObject);
var
  BTPlugin: IBTServicePlugin;
  BTPluginAddTrackers: IBTServicePluginAddTrackers;
  X: Integer;
  TorrentFileName: WideString;
  InfoTorrent: WideString;
  InfoTorrentSL: TStringList;
  HashValue, Trackers: string;
  i: Integer;
  DataTask: TTask;
  Find: Boolean;
begin
  OpenDialog1.Filter := 'Torrent Files (*.torrent)|*.torrent';
  if OpenDialog1.Execute then
  begin
    TorrentFileName := OpenDialog1.FileName;

    for X := 0 to Plugins.Count - 1 do
    begin
      if (Supports(Plugins[X], IBTServicePlugin, BTPlugin)) then
      begin
        try
          InfoTorrent := BTPlugin.GetInfoTorrentFile(TorrentFileName);
        except
        end;
        break;
      end;
    end;

    InfoTorrentSL := TStringList.Create;
    try
      InfoTorrentSL.Text := (InfoTorrent);
      try
        HashValue := (InfoTorrentSL[5]);
      except
      end;
      try
        Trackers := InfoTorrentSL[9];
      except
      end;
    finally
      InfoTorrentSL.Free;
    end;

    if Trim(HashValue) = '' then
    begin
      MessageBox(Application.Handle,
        PChar('Нет доступа к торрент файлу или ошибка при открытии торрент-файла'),
        PChar(Options.Name), MB_OK or MB_ICONWARNING or MB_TOPMOST);
      Exit;
    end;

    Find := false;
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
        TasksList.UnLockList
      end;

    if Find then
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
              BTPluginAddTrackers.AddTrackers(HashValue, Trackers);
            except
            end;
            break;
          end;
        end;
      end
      else
        Exit;
    end
    else
    begin
      if Options.AddTorrentHandle = 0 then
      begin
        fAddTorrent := TfAddTorrent.Create(Application);
        Options.AddTorrentHandle := fAddTorrent.Handle;
        fAddTorrent.TorrentFileName := TorrentFileName;
        fAddTorrent.InfoTorrent := (InfoTorrent);
        fAddTorrent.Show;
      end;
    end;
  end;

end;

procedure TfMainForm.UpdateVisual;
begin
  with TasksList.LockList do
    try
      lvTasks.Items.BeginUpdate;
      try
        lvTasks.Items.Clear;
        lvTasks.Items.Count := Count;
      finally
        lvTasks.Items.EndUpdate;
      end;
    finally
      TasksList.UnLockList;
    end;
end;

procedure TfMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UpdateVisualThread.Terminate;
  UpdateVisualThread.WaitFor;
  UpdateVisualThread.Free;
  Plugins.UnloadAll;
  SaveTasksList;
  Options.Save;
  DeleteCriticalSection(TorrentSection);
end;

procedure TfMainForm.LoadPlugins;
begin
  SetErrorMode(SetErrorMode(0) or SEM_NOOPENFILEERRORBOX or
    SEM_FAILCRITICALERRORS);
  Plugins.SetVersion(1);
  Plugins.RegisterServiceProvider(Self);
  try
    Plugins.LoadPlugins(ansilowercase(ExtractFilePath(ParamStr(0)) +
      'plugins'), '.pld');
  finally
    Plugins.DoLoaded;
  end;
end;

procedure TfMainForm.FormCreate(Sender: TObject);
begin
  GraphColor := rgb(27, 161, 226);
  BackGroundColor := rgb(200, 237, 255);
  ProgressBackColor := rgb(255, 255, 255);
  Options := TOptions.Create;
  Options.Version := '1.0.0.0';
  Options.TasksListName := 'TasksList';
  Options.Name := 'DelphiTorrent';
  Options.Path := ExtractFileDir(Application.ExeName);
  Options.MainFormHandle := Handle;
  Options.Load;
  SeedingThreads := TThreadList.Create;
  TasksList := TThreadList.Create;
  LoadTorrentThreads := TThreadList.Create;
  InitializeCriticalSection(TorrentSection);
  LoadTasksList;
  LoadPlugins;
  UpdateVisual;
  UpdateVisualThread := TUpdateVisualThread.Create(false);
  TStartThread.Create(false);
end;

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
  Plugins.UnloadAll;
end;

procedure TfMainForm.FormResize(Sender: TObject);
begin
  Panel3.Left := 452;
  Panel4.Left := 502;
  Panel5.Left := 552;
  Panel6.Left := 602;
  Panel3.Top := ClientHeight - 18;
  Panel4.Top := ClientHeight - 18;
  Panel5.Top := ClientHeight - 18;
  Panel6.Top := ClientHeight - 18;
end;

procedure TfMainForm.lvFilesData(Sender: TObject; Item: TListItem);
var
  DataTask: TTask;
  i, k: Integer;
  FileInfo: TFiles;
  FilePath: string;
  FileName: string;
begin
  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask then
            for k := 0 to DataTask.Files.Count - 1 do
            begin
              if k = Item.Index then
              begin
                FileInfo := DataTask.Files.Items[Item.Index];

                Item.Caption := IntToStr(k);

                FilePath := (DataTask.Directory);
                FileName := FileInfo.ffilename;
                FileName := StringReplace(FileName, FilePath + '\', '',
                  [rfReplaceAll, rfIgnoreCase]);
                FileName := StringReplace(FileName, FilePath, '',
                  [rfReplaceAll, rfIgnoreCase]);
                FileName := StringReplace(FileName, '__INCOMPLETE__', '',
                  [rfReplaceAll, rfIgnoreCase]);
                FileName := Utf8ToAnsi(FileName);

                Item.SubItems.Add(FileName);
                Item.SubItems.Add(BytesToText(FileInfo.fsize));
                Item.SubItems.Add(BytesToText(FileInfo.fprogress));

                if FileInfo.fsize > 0 then
                  Item.SubItems.Add
                    ((FloatToStrF((FileInfo.fprogress / FileInfo.fsize) * 100,
                    ffFixed, 6, 1) + '% '))
                else
                  Item.SubItems.Add('');

                break;
              end;
            end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;
end;

procedure TfMainForm.lvPeersData(Sender: TObject; Item: TListItem);
var
  DataTask: TTask;
  i, k: Integer;
  PeersInfo: TPeer;
begin
  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask then
            for k := 0 to DataTask.Peers.Count - 1 do
            begin
              if k = Item.Index then
              begin
                PeersInfo := DataTask.Peers.Items[k];
                Item.Caption := PeersInfo.ipS;
                if IntToStr(PeersInfo.port) = '0' then
                  Item.SubItems.Add('')
                else
                  Item.SubItems.Add(IntToStr(PeersInfo.port));
                Item.SubItems.Add(PeersInfo.Client);
                Item.SubItems.Add(IntToStr(PeersInfo.Progress));
                Item.SubItems.Add((BytesToText(PeersInfo.speed_recv) + '/s'));
                Item.SubItems.Add((BytesToText(PeersInfo.recv)));
                Item.SubItems.Add((BytesToText(PeersInfo.speed_send) + '/s'));
                Item.SubItems.Add((BytesToText(PeersInfo.sent)));
                break;
              end;
            end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;
end;

procedure TfMainForm.lvTasksData(Sender: TObject; Item: TListItem);
var
  i: Integer;
  Task: TTask;
  Procent, Procent1, Procent2: string;
  EndPoint: Integer;
begin
  with TasksList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        if i = Item.Index then
        begin
          Task := Items[Item.Index];

          // Ожидание закачки
          if Task.Status = tsReady then
            Item.ImageIndex := 0;

          // В очереди
          if Task.Status = tsQueue then
            Item.ImageIndex := 1;

          // Ошибка завершена
          if Task.Status = tsError then
            Item.ImageIndex := 2;

          // Ошибка не завершена
          if Task.Status = tsErroring then
            Item.ImageIndex := 2;

          // Закачка
          if Task.Status = tsLoading then
            Item.ImageIndex := 3;

          // Остановка
          if Task.Status = tsStoping then
            Item.ImageIndex := 4;

          // Пауза
          if Task.Status = tsStoped then
            Item.ImageIndex := 5;

          // Закачено
          if Task.Status = tsLoad then
            Item.ImageIndex := 6;

          // Получение ссылки
          if Task.Status = tsGetUrl then
            Item.ImageIndex := 7;

          // Поиск
          if Task.Status = tsProcessing then
            Item.ImageIndex := 8;

          // Раздача
          if Task.Status = tsSeeding then
            Item.ImageIndex := 9;

          // Обработка магнет
          if Task.Status = tsBittorrentMagnetDiscovery then
            Item.ImageIndex := 10;

          // Удален
          if (Task.Status = tsDelete) or (Task.Status = tsDeleted) then
            Item.ImageIndex := 11;

          /// /////////////////////////////////////////////////////////////////////////////
          // item.Caption:=DataTask.FileName;
          Item.SubItems.Add(Task.FileName); // Имя Файла
          Item.SubItems.Add(Task.LinkToFile); // Ссылка

          Item.SubItemImages[1] := 12;

//          if (Task.TaskServPlugIndexIcon = -1) or
//            (Task.TaskServPlugIndexIcon = 0) then
//          else
//            Item.SubItemImages[1] := Task.TaskServPlugIndexIcon;

          // Состояние ///////////////////////////////////////////////////////////////////
          begin
            if Task.Status = tsReady then
              Item.SubItems.Add('Ожидание');

            if (Task.TotalSize > 0) and (Task.Status = tsStoped) then
              Item.SubItems.Add(FloatToStrF((Task.LoadSize / Task.TotalSize) *
                100, ffFixed, 6, 1) + '% ' + 'Пауза');

            if (Task.TotalSize <= 0) and (Task.Status = tsStoped) then
              Item.SubItems.Add('0% ' + 'Пауза');

            if Task.Status = tsQueue then
              Item.SubItems.Add('В очереди');

            if Task.Status = tsStoping then
              Item.SubItems.Add('Останавливается');

            if Task.Status = tsLoad then
              Item.SubItems.Add('Завершено');

            if Task.Status = tsError then
              Item.SubItems.Add('Ошибка');

            if (Task.Status = tsDelete) or (Task.Status = tsDeleted) then
              Item.SubItems.Add('Удалено');

            if Task.Status = tsBittorrentMagnetDiscovery then
              Item.SubItems.Add('Magnet-поиск');

            if Task.Status = tsSeeding then
              Item.SubItems.Add('Раздача');

            if Task.Status = tsFileError then
              Item.SubItems.Add('Ошибка торрента');

            if Task.Status = tsAllocating then
              Item.SubItems.Add('Распределение');

            if Task.Status = tsFinishedAllocating then
              Item.SubItems.Add('Распределение завершено');

            if Task.Status = tsRebuilding then
              Item.SubItems.Add('Восстановление');

            if Task.Status = tsProcessing then
              Item.SubItems.Add('Поиск');

            if Task.Status = tsJustCompleted then
              Item.SubItems.Add('Завершается');

            if Task.Status = tsCancelled then
              Item.SubItems.Add('Отменено');

            if Task.Status = tsQueuedSource then
              Item.SubItems.Add('Очередь');

            if Task.Status = tsUploading then
              Item.SubItems.Add('Раздача');

            if Task.Status = tsStartProcess then
              Item.SubItems.Add('Запуск');

            if Task.Status = tsLoading then
            begin
              if Task.TotalSize > 0 then
              begin
                Procent := FloatToStr((Task.LoadSize / Task.TotalSize) * 100);
                begin
                  EndPoint := pos(',', Procent);
                  if EndPoint <> 0 then
                  begin
                    Procent1 := copy(Procent, 1, EndPoint - 1);
                    Procent2 := copy(Procent, 1, EndPoint + 1);
                    Item.SubItems.Add(Procent2 + '% ' + 'Закачка');
                  end
                  else
                  begin
                    try
                      Procent2 := FloatToStrF(StrToInt(Procent), ffFixed, 6, 1);
                    except
                    end;
                    Item.SubItems.Add(Procent2 + '% ' + 'Закачка');
                  end;
                end;
              end
              else
                Item.SubItems.Add('');
            end;

          end;

          // Осталось ////////////////////////////////////////////////////////////////////
          if Task.Speed > 0 then
          begin
            Item.SubItems.Add(GetTimeStr((Task.TotalSize - Task.LoadSize)
              div Task.Speed));
          end
          else
            Item.SubItems.Add('');
          /// /////////////////////////////////////////////////////////////////////////////
          // Прошло
          // Item.SubItems.Add(FormatDateTime('hh:mm:ss', Task.TimeTotal));
          /// /////////////////////////////////////////////////////////////////////////////

          // Размер
          if Task.TotalSize > 0 then
            Item.SubItems.Add(BytesToText(Task.TotalSize))
          else
            Item.SubItems.Add(' ');
          // Закачано
          Item.SubItems.Add(BytesToText(Task.LoadSize));
          // Скорость
          if Task.Speed > 0 then
            Item.SubItems.Add(BytesToText(Task.Speed) + '/s')
          else
            Item.SubItems.Add('');
          // Сиды
          if Task.NumConnectedSeeders > 0 then
            Item.SubItems.Add(IntToStr(Task.NumConnectedSeeders))
          else
            Item.SubItems.Add('');
          // Пиры
          if Task.NumConnectedLeechers > 0 then
            Item.SubItems.Add(IntToStr(Task.NumConnectedLeechers))
          else
            Item.SubItems.Add('');
          // Скорость отдачи
          if Task.UploadSpeed > 0 then
            Item.SubItems.Add(BytesToText(Task.UploadSpeed) + '/s')
          else
            Item.SubItems.Add('');
          // Отдано
          if Task.UploadSize > 0 then
            Item.SubItems.Add(BytesToText(Task.UploadSize))
          else
            Item.SubItems.Add('');
          break;
        end;
      end;

    finally
      TasksList.UnLockList;
    end;
end;

procedure TfMainForm.lvTasksSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  DataTask: TTask;
  DataTask2: TTask;
  i: Integer;
  Find: Boolean;
  find2: Boolean;
begin
  if (Item <> lvTasks.Selected) or (lvTasks.SelCount > 1) or
    (lvTasks.SelCount = 0) then
  begin
    Exit;
  end;

  Find := false;
  with TasksList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        if i = Item.Index then
        begin
          DataTask := Items[i];
          IDSelected := IntToStr(DataTask.ID);
          Find := true;
          break;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;

  if Find then
  begin
    with TasksList.LockList do
      try
        find2 := false;
        for i := 0 to Count - 1 do
        begin
          DataTask2 := Items[i];
          if (DataTask2.SelectedTask) then
          begin
            find2 := true;
            break;
          end;
        end;

        if find2 then
        begin
          if DataTask2 <> DataTask then
          begin
            for i := 0 to Count - 1 do
            begin
              DataTask2 := Items[i];
              if DataTask2.SelectedTask = true then
              begin
                DataTask2.SelectedTask := false;
                DataTask2.UpdatePiecesInfo := false;
                DataTask2.MPBar.Visible := false;
              end;
              if assigned(DataTask2.Trackers) then
              begin
                FreeAndNil(DataTask2.Trackers);
              end;
              if assigned(DataTask2.Files) then
              begin
                FreeAndNil(DataTask2.Files);
              end;
              if assigned(DataTask2.Peers) then
              begin
                FreeAndNil(DataTask2.Peers);
              end;
            end;
            DataTask.SelectedTask := true;

            DataTask.MPBar.Parent := StatusBar1;
            DataTask.MPBar.Align := alLeft;
            DataTask.MPBar.Width := 446;
            DataTask.MPBar.Visible := true;
            DataTask.MPBar.Enabled := true;
            DataTask.MPBar.DoubleBuffered := true;
            DataTask.MPBar.Show;
            DataTask.MPBar.Update;
            DataTask.UpdatePiecesInfo := true;
            StatusBar1.Update;
          end;
        end
        else
        begin
          DataTask.SelectedTask := true;
          DataTask.MPBar.Parent := StatusBar1;
          DataTask.MPBar.Align := alLeft;
          DataTask.MPBar.Width := 446;
          DataTask.MPBar.Visible := true;
          DataTask.MPBar.Enabled := true;
          DataTask.MPBar.DoubleBuffered := true;
          DataTask.MPBar.Show;
          DataTask.MPBar.Update;
          DataTask.UpdatePiecesInfo := true;
          StatusBar1.Update;
        end;
      finally
        TasksList.UnLockList;
      end;
  end;
  UpdateInfPanel;
end;

procedure TfMainForm.lvTrackersData(Sender: TObject; Item: TListItem);
var
  DataTask: TTask;
  i, k: Integer;
  TrackerInfo: TTrackers;
  NowTime: Integer;

  function format_time(Secs: Integer): string;
  var
    ore, minuti, secondi, variabile: Integer;
  begin
    if Secs > 0 then
    begin

      if Secs < 60 then
      begin
        ore := 0;
        minuti := 0;
        secondi := Secs;
      end
      else if Secs < 3600 then
      begin
        ore := 0;
        minuti := (Secs div 60);
        secondi := (Secs - ((Secs div 60) * 60));
      end
      else
      begin
        ore := (Secs div 3600);
        variabile := (Secs - ((Secs div 3600) * 3600));
        minuti := variabile div 60;
        secondi := variabile - ((minuti) * 60);
      end;

      if ore = 0 then
        Result := ''
      else
        Result := IntToStr(ore) + ':';

      if ((minuti = 0) and (ore = 0)) then
        Result := '0:'
      else
      begin
        if minuti < 10 then
        begin
          if ore = 0 then
            Result := IntToStr(minuti) + ':'
          else
            Result := Result + '0' + IntToStr(minuti) + ':';
        end
        else
          Result := Result + IntToStr(minuti) + ':';
      end;

      if secondi < 10 then
        Result := Result + '0' + IntToStr(secondi)
      else
        Result := Result + IntToStr(secondi);

    end
    else
      Result := '0:00';
  end;

begin
  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask then
            for k := 0 to DataTask.Trackers.Count - 1 do
            begin
              if k = Item.Index then
              begin
                TrackerInfo := DataTask.Trackers.Items[Item.Index];
                NowTime := GetTickCount;
                Item.Caption := IntToStr(k);
                Item.SubItems.Add(TrackerInfo.URL);
                Item.SubItems.Add(TrackerInfo.visualStr);
                if TrackerInfo.URL = '[DHT]' then
                  Item.SubItems.Add(format_time(TrackerInfo.tick))
                else
                  Item.SubItems.Add
                    (format_time((TrackerInfo.Next_Poll - NowTime) div 1000));
                Item.SubItems.Add(IntToStr(TrackerInfo.Seeders));
                Item.SubItems.Add(IntToStr(TrackerInfo.Leechers));
                Item.SubItems.Add(format_time(TrackerInfo.Interval));
                break;
              end;
            end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;
end;

procedure TfMainForm.UpdateTrackersVisual;
var
  i, X, k: Integer;
  DataTask: TTask;
  Find: Boolean;
  IBTTrackersInfo: IBTServicePluginTrackersInfo;
  TrackersInfo: WideString;
  StatusStr: string;
  StatusInt: Integer;

  procedure TrackersInfoInGeted(GetedData: WideString; DataTask: TTask);
  var
    GetedList: TStringList;
    GetedTrackersList: TStringList;
    i, k: Integer;
    TrackersInfo: TTrackers;
  begin
    GetedList := TStringList.Create;
    try
      GetedList.Delimiter := ' ';
      GetedList.QuoteChar := '^';
      GetedList.DelimitedText := GetedData;
      if DataTask.SelectedTask then
        if assigned(DataTask.Trackers) then
        begin
          for i := 0 to GetedList.Count - 1 do
          begin
            if GetedList[i] <> '' then
            begin
              try
                GetedTrackersList := TStringList.Create;
                try
                  GetedTrackersList.Delimiter := ' ';
                  GetedTrackersList.QuoteChar := '|';
                  GetedTrackersList.DelimitedText := (GetedList[i]);
                except
                end;

                for k := 0 to DataTask.Trackers.Count - 1 do
                begin
                  if i = k then
                  begin
                    try
                      TTrackers(DataTask.Trackers.Items[k]).Host :=
                        (GetedTrackersList[0]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).URL :=
                        (GetedTrackersList[1]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).TrackerID :=
                        (GetedTrackersList[2]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).CurrTrackerEvent :=
                        (GetedTrackersList[3]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).BufferReceive :=
                        (GetedTrackersList[4]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).WarningMessage :=
                        (GetedTrackersList[5]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).FError :=
                        (GetedTrackersList[6]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).visualStr :=
                        (GetedTrackersList[7]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).Status :=
                        StrToInt(GetedTrackersList[8]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).Interval :=
                        StrToInt(GetedTrackersList[9]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).Seeders :=
                        StrToInt(GetedTrackersList[10]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).Leechers :=
                        StrToInt(GetedTrackersList[11]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).tick :=
                        StrToInt(GetedTrackersList[12]);
                    except
                    end;
                    try
                      TTrackers(DataTask.Trackers.Items[k]).Next_Poll :=
                        StrToInt(GetedTrackersList[13]);
                    except
                    end;
                  end;
                end;
              finally
                GetedTrackersList.Free;
              end;
            end
          end
        end
        else
        begin
          DataTask.Trackers := TList.Create;
          try
            for i := 0 to GetedList.Count - 1 do
            begin
              if GetedList[i] <> '' then
              begin
                try
                  TrackersInfo := TTrackers.Create;
                  GetedTrackersList := TStringList.Create;
                  try
                    GetedTrackersList.Delimiter := ' ';
                    GetedTrackersList.QuoteChar := '|';
                    GetedTrackersList.DelimitedText := (GetedList[i]);
                  except
                  end;

                  try
                    TrackersInfo.Host := (GetedTrackersList[0]);
                  except
                  end;
                  try
                    TrackersInfo.URL := (GetedTrackersList[1]);
                  except
                  end;
                  try
                    TrackersInfo.TrackerID := (GetedTrackersList[2]);
                  except
                  end;
                  try
                    TrackersInfo.CurrTrackerEvent := (GetedTrackersList[3]);
                  except
                  end;
                  try
                    TrackersInfo.BufferReceive := (GetedTrackersList[4]);
                  except
                  end;
                  try
                    TrackersInfo.WarningMessage := (GetedTrackersList[5]);
                  except
                  end;
                  try
                    TrackersInfo.FError := (GetedTrackersList[6]);
                  except
                  end;
                  try
                    TrackersInfo.visualStr := (GetedTrackersList[7]);
                  except
                  end;
                  try
                    TrackersInfo.Status := StrToInt(GetedTrackersList[8]);
                  except
                  end;
                  try
                    TrackersInfo.Interval := StrToInt(GetedTrackersList[9]);
                  except
                  end;
                  try
                    TrackersInfo.Seeders := StrToInt(GetedTrackersList[10]);
                  except
                  end;
                  try
                    TrackersInfo.Leechers := StrToInt(GetedTrackersList[11]);
                  except
                  end;
                  try
                    TrackersInfo.tick := StrToInt(GetedTrackersList[12]);
                  except
                  end;
                  try
                    TrackersInfo.Next_Poll := StrToInt(GetedTrackersList[13]);
                  except
                  end;

                  with TasksList.LockList do
                    try
                      if assigned(DataTask.Trackers) then
                      begin
                        DataTask.Trackers.Add(TrackersInfo);
                        lvTrackers.Items.Clear;
                        lvTrackers.Items.Count := DataTask.Trackers.Count;
                      end;
                    finally
                      TasksList.UnLockList;
                    end;
                finally
                  GetedTrackersList.Free;
                end;
              end;
            end;
          finally

          end;
        end;
    finally
      GetedList.Free;
    end;
  end;

begin
  Find := false;
  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask = true then
          begin
            Find := true;
            break;
          end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;

  if Find then
  begin
    begin
      for X := 0 to Plugins.Count - 1 do
      begin
        if (Supports(Plugins[X], IBTServicePluginTrackersInfo, IBTTrackersInfo))
        then
        begin
          EnterCriticalSection(TorrentSection);
          try
            try
              StatusStr := IBTTrackersInfo.CheckTrackersStatus
                (DataTask.HashValue);
            except
            end;
          finally
            LeaveCriticalSection(TorrentSection);
          end;
          if Trim(StatusStr) = '' then
            StatusInt := 0
          else
          begin
            try
              StatusInt := StrToInt(StatusStr);
            except
            end;
          end;

          if StatusInt = 0 then
          begin
            EnterCriticalSection(TorrentSection);
            try
              try
                IBTTrackersInfo.GetTrackersInfo(DataTask.HashValue);
              except
              end;
            finally
              LeaveCriticalSection(TorrentSection);
            end;
          end
          else if StatusInt = 3 then
          begin
            try
              EnterCriticalSection(TorrentSection);
              try
                TrackersInfo := IBTTrackersInfo.GetDataTrackers
                  (DataTask.HashValue);
                IBTTrackersInfo.ReleaseTrackersThread(DataTask.HashValue);
              finally
                LeaveCriticalSection(TorrentSection);
              end;
            except
            end;
          end;
          if Trim(TrackersInfo) <> '' then
            TrackersInfoInGeted(TrackersInfo, DataTask);
        end;
      end;
    end;
  end;

  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask = true then
          begin
            for k := 0 to DataTask.Trackers.Count - 1 do
            begin
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.Index := k;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fHost :=
                DataTask.Directory;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fURL :=
                TTrackers(DataTask.Trackers.Items[k]).URL;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fTrackerID :=
                TTrackers(DataTask.Trackers.Items[k]).TrackerID;
              TTrackers(DataTask.Trackers.Items[k])
                .VisualData^.fCurrTrackerEvent :=
                TTrackers(DataTask.Trackers.Items[k]).CurrTrackerEvent;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fBufferReceive
                := TTrackers(DataTask.Trackers.Items[k]).BufferReceive;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fWarningMessage
                := TTrackers(DataTask.Trackers.Items[k]).WarningMessage;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fFError :=
                TTrackers(DataTask.Trackers.Items[k]).FError;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fvisualStr :=
                TTrackers(DataTask.Trackers.Items[k]).visualStr;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fStatus :=
                TTrackers(DataTask.Trackers.Items[k]).Status;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fInterval :=
                TTrackers(DataTask.Trackers.Items[k]).Interval;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fSeeders :=
                TTrackers(DataTask.Trackers.Items[k]).Seeders;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fLeechers :=
                TTrackers(DataTask.Trackers.Items[k]).Leechers;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.ftick :=
                TTrackers(DataTask.Trackers.Items[k]).tick;
              TTrackers(DataTask.Trackers.Items[k]).VisualData^.fNext_Poll :=
                TTrackers(DataTask.Trackers.Items[k]).Next_Poll;
            end;
            break;
          end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;
end;

procedure TfMainForm.UpdatePeersVisual;
var
  k: Integer;
  i, X: Integer;
  DataTask: TTask;
  IBTPeersInfo: IBTServicePluginPeersInfo;
  PeersInfo: WideString;
  Find: Boolean;
  StatusPeerStr: string;
  StatusPeerInt: Integer;
  StopRepeat: Boolean;
  FindDeleted: Boolean;

  procedure PeersInfoInGeted(GetedData: WideString; DataTask: TTask);
  var
    GetedList: TStringList;
    GetedPeersList: TStringList;
    i, k: Integer;
    PeerInfo: TPeer;
    FindPeer: Boolean;
  begin
    GetedList := TStringList.Create;
    try
      GetedList.Delimiter := ' ';
      GetedList.QuoteChar := '^';
      GetedList.DelimitedText := GetedData;
      if DataTask.SelectedTask then
        if assigned(DataTask.Peers) then
        begin
          with TasksList.LockList do
            try
              for k := 0 to DataTask.Peers.Count - 1 do
              begin
                TPeer(DataTask.Peers.Items[k]).FindIP := false;
              end;

              for i := 0 to GetedList.Count - 1 do
              begin
                if GetedList[i] <> '' then
                begin
                  try
                    GetedPeersList := TStringList.Create;
                    try
                      GetedPeersList.Delimiter := ' ';
                      GetedPeersList.QuoteChar := '|';
                      GetedPeersList.DelimitedText := GetedList[i];
                    except
                    end;

                    if GetedPeersList[0] = '6' then
                    begin
                      FindPeer := false;
                      for k := 0 to DataTask.Peers.Count - 1 do
                      begin
                        if TPeer(DataTask.Peers.Items[k]).ipS = GetedPeersList[1]
                        then
                          FindPeer := true;
                      end;

                      if FindPeer = false then
                      begin
                        if GetedPeersList[0] = '6' then
                        begin
                          PeerInfo := TPeer.Create;
                          PeerInfo.FindIP := true;
                          try
                            PeerInfo.ID := (GetedPeersList[0]);
                          except
                          end;
                          try
                            PeerInfo.ipS := (GetedPeersList[1]);
                          except
                          end;
                          try
                            PeerInfo.Client := (GetedPeersList[2]);
                            if (Trim(PeerInfo.Client) = '') or
                              (PeerInfo.ID <> '6') then
                              PeerInfo.FindIP := false;
                          except
                          end;
                          try
                            PeerInfo.Progress := StrToInt64(GetedPeersList[3]);
                          except
                          end;

                          try
                            PeerInfo.recv := (StrToInt64(GetedPeersList[4]));
                          except
                          end;

                          try
                            PeerInfo.sent := (StrToInt64(GetedPeersList[5]));
                          except
                          end;

                          try
                            PeerInfo.speed_recv :=
                              (StrToInt(GetedPeersList[6]));
                          except
                          end;

                          try
                            PeerInfo.speed_send :=
                              (StrToInt(GetedPeersList[7]));
                          except
                          end;

                          try
                            PeerInfo.port := StrToInt(GetedPeersList[8]);
                          except
                          end;

                          lvPeers.Items.BeginUpdate;
                          with TasksList.LockList do
                            try
                              if assigned(DataTask.Peers) then
                              begin
                                DataTask.Peers.Add(PeerInfo);
                                lvPeers.Items.Clear;
                                lvPeers.Items.Count := DataTask.Peers.Count;
                              end;
                            finally
                              TasksList.UnLockList;
                              lvPeers.Items.EndUpdate;
                            end;

                        end;
                      end
                      else
                      begin
                        for k := 0 to DataTask.Peers.Count - 1 do
                        begin
                          PeerInfo := DataTask.Peers[k];

                          if PeerInfo.ipS = GetedPeersList[1] then
                          begin
                            PeerInfo.FindIP := true;
                            try
                              PeerInfo.ID := (GetedPeersList[0]);
                            except
                            end;
                            try
                              PeerInfo.ipS := (GetedPeersList[1]);
                            except
                            end;
                            try
                              PeerInfo.Client := (GetedPeersList[2]);
                              if (Trim(PeerInfo.Client) = '') or
                                (PeerInfo.ID <> '6') then
                                PeerInfo.FindIP := false;
                            except
                            end;
                            try
                              PeerInfo.Progress :=
                                StrToInt64(GetedPeersList[3]);
                            except
                            end;

                            try
                              PeerInfo.recv := StrToInt64(GetedPeersList[4]);
                            except
                            end;

                            try
                              PeerInfo.sent := StrToInt64(GetedPeersList[5]);
                            except
                            end;

                            try
                              PeerInfo.speed_recv :=
                                StrToInt(GetedPeersList[6]);
                            except
                            end;

                            try
                              PeerInfo.speed_send :=
                                StrToInt(GetedPeersList[7]);
                            except
                            end;

                            try
                              PeerInfo.port := StrToInt(GetedPeersList[8]);
                            except
                            end;
                          end;

                        end;
                      end;
                    end;
                  finally
                    GetedPeersList.Free;
                  end;
                end
              end
            finally
              TasksList.UnLockList;
            end;
        end
        else
        begin
          DataTask.Peers := TList.Create;
          try
            for i := 0 to GetedList.Count - 1 do
            begin
              if GetedList[i] <> '' then
              begin
                try

                  GetedPeersList := TStringList.Create;
                  try
                    GetedPeersList.Delimiter := ' ';
                    GetedPeersList.QuoteChar := '|';
                    GetedPeersList.DelimitedText := GetedList[i];
                  except
                  end;

                  if GetedPeersList[0] = '6' then
                  begin
                    PeerInfo := TPeer.Create;
                    PeerInfo.FindIP := true;
                    try
                      PeerInfo.ID := (GetedPeersList[0]);
                    except
                    end;
                    try
                      PeerInfo.ipS := (GetedPeersList[1]);
                    except
                    end;
                    try
                      PeerInfo.Client := (GetedPeersList[2]);
                      if Trim(PeerInfo.Client) = '' then
                        PeerInfo.FindIP := false;
                    except
                    end;
                    try
                      PeerInfo.Progress := StrToInt64(GetedPeersList[3]);
                    except
                    end;

                    try
                      PeerInfo.recv := StrToInt64(GetedPeersList[4]);
                    except
                    end;

                    try
                      PeerInfo.sent := StrToInt64(GetedPeersList[5]);
                    except
                    end;

                    try
                      PeerInfo.speed_recv := StrToInt(GetedPeersList[6]);
                    except
                    end;

                    try
                      PeerInfo.speed_send := StrToInt(GetedPeersList[7]);
                    except
                    end;

                    try
                      PeerInfo.port := StrToInt(GetedPeersList[8]);
                    except
                    end;

                    lvPeers.Items.BeginUpdate;
                    with TasksList.LockList do
                      try
                        if assigned(DataTask.Peers) then
                        begin
                          DataTask.Peers.Add(PeerInfo);
                          lvPeers.Items.Clear;
                          lvPeers.Items.Count := DataTask.Peers.Count;
                        end;
                      finally
                        TasksList.UnLockList;
                        lvPeers.Items.EndUpdate;
                      end;
                  end;
                finally
                  GetedPeersList.Free;
                end;
              end;
            end;
          finally

          end;

        end;
    finally
      GetedList.Free;
    end;
  end;

begin
  Find := false;

  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask = true then
          begin
            Find := true;
            break;
          end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;

  if Find then
  begin
    begin
      for X := 0 to Plugins.Count - 1 do
      begin
        if (Supports(Plugins[X], IBTServicePluginPeersInfo, IBTPeersInfo)) then
        begin
          try
            StatusPeerStr := IBTPeersInfo.CheckPeersStatus(DataTask.HashValue);
          except
          end;
          if Trim(StatusPeerStr) = '' then
            StatusPeerInt := 0
          else
          begin
            try
              StatusPeerInt := StrToInt(StatusPeerStr);
            except
            end;
          end;

          if StatusPeerInt = 0 then
          begin
            try
              IBTPeersInfo.GetPeersInfo(DataTask.HashValue);
            except
            end;
          end
          else if StatusPeerInt = 3 then
          begin
            try
              PeersInfo := IBTPeersInfo.GetDataPeers(DataTask.HashValue);
              IBTPeersInfo.ReleasePeersThread(DataTask.HashValue);
            except
            end;
          end;

          if Trim(PeersInfo) <> '' then
          begin
            PeersInfoInGeted(PeersInfo, DataTask);
          end;
        end;
      end;
    end;
  end;

  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask = true then
          begin
            FindDeleted := false;
            repeat
              StopRepeat := true;
              for k := 0 to DataTask.Peers.Count - 1 do
              begin
                if (TPeer(DataTask.Peers.Items[k]).FindIP = false) then
                begin
                  DataTask.Peers.Delete(k);
                  StopRepeat := false;
                  FindDeleted := true;
                  break;
                end;
              end;
            until StopRepeat = true;

            if FindDeleted then
            begin
              lvPeers.Items.BeginUpdate;
              try
                lvPeers.Items.Clear;
                lvPeers.Items.Count := DataTask.Peers.Count;
              finally
                lvPeers.Items.EndUpdate;
              end;
            end;
            break;
          end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;
end;

procedure TfMainForm.UpdateFilesVisual;
var
  k: Integer;
  i, X: Integer;
  DataTask: TTask;
  Find: Boolean;
  IBTFilesInfo: IBTServicePluginFilesInfo;
  FilesInfo: WideString;
  StatusStr: string;
  StatusInt: Integer;

  procedure FilesInfoInGeted(GetedData: WideString; DataTask: TTask);
  var
    GetedList: TStringList;
    GetedFilesList: TStringList;
    i, k: Integer;
    FileInfo: TFiles;
  begin
    GetedList := TStringList.Create;
    try
      GetedList.Delimiter := ' ';
      GetedList.QuoteChar := '^';
      GetedList.DelimitedText := GetedData;
      if DataTask.SelectedTask then
        if assigned(DataTask.Files) then
        begin
          for i := 0 to GetedList.Count - 1 do
          begin
            if GetedList[i] <> '' then
            begin
              try
                GetedFilesList := TStringList.Create;
                try
                  GetedFilesList.Delimiter := ' ';
                  GetedFilesList.QuoteChar := '|';
                  GetedFilesList.DelimitedText := (GetedList[i]);
                except
                end;

                for k := 0 to DataTask.Files.Count - 1 do
                begin
                  if i = k then
                  begin
                    try
                      TFiles(DataTask.Files.Items[k]).ffilename :=
                        (GetedFilesList[0]);
                    except
                    end;
                    try
                      TFiles(DataTask.Files.Items[k]).fsize :=
                        StrToInt64(GetedFilesList[1]);
                    except
                    end;
                    try
                      TFiles(DataTask.Files.Items[k]).fprogress :=
                        StrToInt64(GetedFilesList[2]);
                    except
                    end;
                    try
                      TFiles(DataTask.Files.Items[k]).foffset :=
                        StrToInt64(GetedFilesList[3]);
                    except
                    end;
                  end;
                end;
              finally
                GetedFilesList.Free;
              end;
            end
          end
        end
        else
        begin
          DataTask.Files := TList.Create;
          try
            for i := 0 to GetedList.Count - 1 do
            begin
              if GetedList[i] <> '' then
              begin
                try
                  FileInfo := TFiles.Create;
                  GetedFilesList := TStringList.Create;
                  try
                    GetedFilesList.Delimiter := ' ';
                    GetedFilesList.QuoteChar := '|';
                    GetedFilesList.DelimitedText := (GetedList[i]);
                  except
                  end;

                  try
                    FileInfo.ffilename := (GetedFilesList[0]);
                  except
                  end;
                  try
                    FileInfo.fsize := StrToInt64(GetedFilesList[1]);
                  except
                  end;
                  try
                    FileInfo.fprogress := StrToInt64(GetedFilesList[2]);
                  except
                  end;
                  try
                    FileInfo.foffset := StrToInt64(GetedFilesList[3]);
                  except
                  end;

                  with TasksList.LockList do
                    try
                      if assigned(DataTask.Files) then
                      begin
                        DataTask.Files.Add(FileInfo);
                        lvFiles.Items.Clear;
                        lvFiles.Items.Count := DataTask.Files.Count;
                      end;
                    finally
                      TasksList.UnLockList;
                    end;
                finally
                  GetedFilesList.Free;
                end;
              end;
            end;
          finally

          end;

        end;
    finally
      GetedList.Free;
    end;
  end;

begin
  Find := false;
  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask = true then
          begin
            Find := true;
            break;
          end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;

  if Find then
  begin
    begin
      for X := 0 to Plugins.Count - 1 do
      begin
        if (Supports(Plugins[X], IBTServicePluginFilesInfo, IBTFilesInfo)) then
        begin
          try
            StatusStr := IBTFilesInfo.CheckFilesStatus(DataTask.HashValue);
          except
          end;
          if Trim(StatusStr) = '' then
            StatusInt := 0
          else
          begin
            try
              StatusInt := StrToInt(StatusStr);
            except
            end;
          end;

          if StatusInt = 0 then
          begin
            try
              IBTFilesInfo.GetFilesInfo(DataTask.HashValue);
            except
            end;
          end
          else if StatusInt = 3 then
          begin
            try
              FilesInfo := IBTFilesInfo.GetDataFiles(DataTask.HashValue);
              IBTFilesInfo.ReleaseFilesThread(DataTask.HashValue);
            except
            end;
          end;

          if Trim(FilesInfo) <> '' then
            FilesInfoInGeted(FilesInfo, DataTask);
        end;
      end;
    end;
  end;

  try
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.SelectedTask = true then
          begin
            for k := 0 to DataTask.Files.Count - 1 do
            begin
              TFiles(DataTask.Files.Items[k]).VisualData^.Index := k;
              TFiles(DataTask.Files.Items[k]).VisualData^.ffilepath :=
                DataTask.Directory;
              TFiles(DataTask.Files.Items[k]).VisualData^.ffilename :=
                TFiles(DataTask.Files.Items[k]).ffilename;
              TFiles(DataTask.Files.Items[k]).VisualData^.fsize :=
                TFiles(DataTask.Files.Items[k]).fsize;
              TFiles(DataTask.Files.Items[k]).VisualData^.fprogress :=
                TFiles(DataTask.Files.Items[k]).fprogress;
              TFiles(DataTask.Files.Items[k]).VisualData^.foffset :=
                TFiles(DataTask.Files.Items[k]).foffset;
            end;
            break;
          end;
        end;
      finally
        TasksList.UnLockList;
      end;
  except
  end;
end;

{ TMainFormProvider }
//
constructor TMainFormProvider.Create(const AManager: IPluginManager;
  const APlugin: IPlugin; const AForm: TfMainForm);
begin
  inherited Create(AManager, APlugin);
  FForm := AForm;
end;

// IApplicationWindows
function TMainFormProvider.GetApplicationWnd: HWND;
begin
  Result := Application.Handle;
end;

function TMainFormProvider.GetMainWnd: HWND;
begin
  Result := Application.MainFormHandle;
end;

function TMainFormProvider.GetActiveWnd: HWND;
begin
  Result := Application.ActiveFormHandle;
end;

function TMainFormProvider.GetClientWnd: HWND;
begin
  Result := Application.MainForm.ClientHandle;
end;

function TMainFormProvider.GetPopupCtrlWnd: HWND;
begin
  Result := Application.PopupControlWnd;
end;

procedure TMainFormProvider.ModalStarted;
begin
  Application.ModalStarted;
end;

procedure TMainFormProvider.ModalFinished;
begin
  Application.ModalFinished;
end;

procedure TMainFormProvider.ProcessMessages;
begin
  Application.ProcessMessages;
end;

procedure TMainFormProvider.HandleMessage;
begin
  Application.HandleMessage;
end;

// IAppIcon
function TMainFormProvider.GetSmall: HICON;
var
  CX, CY: Integer;
begin
  CX := GetSystemMetrics(SM_CXSMICON);
  CY := GetSystemMetrics(SM_CYSMICON);
  Result := LoadImage(HInstance, 'MAINICON', IMAGE_ICON, CX, CY, ICON_SMALL);
  Win32Check(Result <> 0);
end;

function TMainFormProvider.GetLarge: HICON;
var
  CX, CY: Integer;
begin
  CX := GetSystemMetrics(SM_CXICON);
  CY := GetSystemMetrics(SM_CYICON);
  Result := LoadImage(HInstance, 'MAINICON', IMAGE_ICON, CX, CY, ICON_BIG);
  Win32Check(Result <> 0);
end;

end.
