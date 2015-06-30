unit uStartThreads;

interface

uses
{$IFDEF DELPHIXE3_LVL}
  Winapi.Windows, System.Classes, System.SysUtils,
{$ELSE}
  Windows, Classes, SysUtils,
{$ENDIF}
  uObjects, uTorrentThreads, dialogs, uConstsProg, uTasks,
  PluginManager, PluginApi;

type

  TRestartingTorrent = class(TObject)
    ID: Integer;
    HashValue: String;
    URI: String;
    Directory: String;
  end;

  TStartThread = class(TThread)
  public
    constructor Create(CreateSuspended: Boolean);
  private
    DataTask: TTask;
  protected
    procedure Execute; override;
  end;

implementation

uses uMainForm;

constructor TStartThread.Create(CreateSuspended: Boolean);
begin
  FreeOnTerminate := true;
  inherited Create(CreateSuspended);
end;

procedure TStartThread.Execute;
var
  i, X, k: Integer;
  BTPlugin: IBTServicePlugin;
  State: Integer;
  FindTorrent: Boolean;
  RestartTorrentList: TList;
  HashRestarting: WideString;
  FindBTPlugin: Boolean;
  find: Boolean;
  RestartingTorrent: TRestartingTorrent;
begin
  FindBTPlugin := false;
  RestartTorrentList := TList.Create;
  with TasksList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        DataTask := Items[i];

        begin
          State := -1;
          FindTorrent := false;

          if FindBTPlugin = false then
            for X := 0 to Plugins.Count - 1 do
            begin
              if (Supports(Plugins[X], IBTServicePlugin, BTPlugin)) then
              begin
                FindBTPlugin := true;
                break;
              end;
            end;

          if FindBTPlugin then
          begin
            try
              if StrToBool(BTPlugin.FindTorrent(DataTask.HashValue)) then
              begin
                FindTorrent := true;
              end;
            except
            end;
          end;

          if (FindTorrent) and (DataTask.StartedLoadTorrentThread = false) then
          begin
            try
              State := StrToInt(BTPlugin.GetStatusTorrent(DataTask.HashValue));
            except
            end;

            try
              if State = 0 then
                DataTask.Status := tsBittorrentMagnetDiscovery
              else if State = 1 then
                DataTask.Status := tsSeeding
              else if State = 2 then
                DataTask.Status := tsFileError
              else if State = 3 then
                DataTask.Status := tsAllocating
              else if State = 4 then
                DataTask.Status := tsFinishedAllocating
              else if State = 5 then
                DataTask.Status := tsRebuilding
              else if State = 6 then
                DataTask.Status := tsProcessing
              else if State = 7 then
                DataTask.Status := tsJustCompleted
              else if State = 8 then
                DataTask.Status := tsLoad
              else if State = 9 then
                DataTask.Status := tsLoading
              else if State = 10 then
                DataTask.Status := tsStoped
              else if State = 11 then
                DataTask.Status := tsLeechPaused
              else if State = 12 then
                DataTask.Status := tsLocalPaused
              else if State = 13 then
                DataTask.Status := tsCancelled
              else if State = 14 then
                DataTask.Status := tsQueuedSource
              else if State = 15 then
                DataTask.Status := tsUploading;
            except
            end;

            if ((State = -1) and ((DataTask.Status <> tsSeeding) and
              (DataTask.Status <> tsLoad) and (DataTask.Status <> tsError)) and
              (DataTask.Status <> tsDeleted)) or
              (DataTask.Status = tsProcessing) or (DataTask.Status = tsLoading)
              or (DataTask.Status = tsAllocating) or
              (DataTask.Status = tsStartProcess) or
              (DataTask.Status = tsBittorrentMagnetDiscovery) then
            begin
              LoadTorrentThreads.Add(TLoadTorrent.Create(false,
                DataTask, true));
            end;

            if ((DataTask.Status = tsSeeding) or (DataTask.Status = tsUploading)
              ) and (DataTask.Status <> tsDeleted) then
            begin
              SeedingThreads.Add(TSeedingThread.Create(false, DataTask, false));
            end;
          end
          else
          begin
            if (((DataTask.Status <> tsSeeding) and (DataTask.Status <> tsLoad)
              and (DataTask.Status <> tsError)) and
              (DataTask.Status <> tsDeleted)) or
              (DataTask.Status = tsProcessing) or (DataTask.Status = tsLoading)
              or (DataTask.Status = tsAllocating) or
              (DataTask.Status = tsStartProcess) or
              (DataTask.Status = tsBittorrentMagnetDiscovery) then
            begin
              RestartingTorrent := TRestartingTorrent.Create;
              RestartingTorrent.ID := DataTask.ID;
              RestartingTorrent.HashValue := DataTask.HashValue;
              RestartingTorrent.Directory :=
                ExcludeTrailingBackSlash(DataTask.Directory);
              RestartTorrentList.Add(RestartingTorrent);
            end;
          end;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;

  if FindBTPlugin then
  begin
    for i := 0 to RestartTorrentList.Count - 1 do
    begin
      HashRestarting := TRestartingTorrent(RestartTorrentList[i]).HashValue;
      if trim(HashRestarting) <> '' then
      begin
        EnterCriticalSection(TorrentSection);
        try
          BTPlugin.DeleteTorrent(HashRestarting);
        finally
          LeaveCriticalSection(TorrentSection);
        end;

        find := false;
        with TasksList.LockList do
          try
            for k := 0 to Count - 1 do
            begin
              DataTask := Items[k];
              if (DataTask.ID = TRestartingTorrent(RestartTorrentList[i]).ID)
              then
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
          EnterCriticalSection(TorrentSection);
          try
            try
              DataTask.TorrentFileName := '';
              DataTask.Status := tsQueue;
              LoadTorrentThreads.Add(TLoadTorrent.Create(false,
                DataTask, true));
            except
            end;
          finally
            LeaveCriticalSection(TorrentSection);
          end;
        end;
      end;
    end;
    RestartTorrentList.Free;
  end;
end;

end.
