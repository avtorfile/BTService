unit uHelperThreads;

interface

uses
{$IFDEF DELPHIXE3_LVL}
  Winapi.Windows, System.Classes, System.SysUtils,
{$ELSE}
  Windows, Classes, SysUtils,
{$ENDIF }
  uObjects, uProcedures, uTasks, uConstsProg,
  PluginApi, PluginManager;

type

  TDeleteTaskThread = class(TThread)
  public
    constructor Create(CreateSuspended: Boolean; DeletedList: TStringList);
  private
    IDList: TStringList;
  protected
    procedure Execute; override;
  end;

  TDeleteTaskWithFileThread = class(TThread)
  public
    constructor Create(CreateSuspended: Boolean; DeletedList: TStringList);
  private
    IDList: TStringList;
  protected
    procedure Execute; override;
  end;

implementation

uses uMainForm;

constructor TDeleteTaskThread.Create(CreateSuspended: Boolean;
  DeletedList: TStringList);
begin
  FreeOnTerminate := true;
  IDList := DeletedList;
  inherited Create(CreateSuspended);
end;

procedure TDeleteTaskThread.Execute;
var
  i, k, X, a: Integer;
  DataTask: TTask;
  BTPlugin: IBTServicePlugin;
  DeletedTorrentList: TList;
  CheckDeletedTorrentList: TStringList;
  DeletedTorrent: TDeletedTorrent;
  HashDeleted: widestring;
  FindBTPlugin: Boolean;
  FinfDel: Boolean;
begin
  DeletedTorrentList := TList.Create;
  CheckDeletedTorrentList := TStringList.Create;

  with TasksList.LockList do
    try

      for i := 0 to IDList.Count - 1 do
      begin
        if trim(IDList[i]) <> '' then
        begin
          for k := 0 to Count - 1 do
          begin
            DataTask := Items[k];
            if IDList[i] = IntToStr(DataTask.ID) then
            begin
              if (DataTask.Status = tsLoading) or (DataTask.Status = tsGetUrl)
                or (DataTask.Status = tsStoping) or
                (DataTask.Status = tsErroring) then
              else
              begin
                DataTask.Status := tsDeleted;
                CheckDeletedTorrentList.Add(IntToStr(DataTask.ID));
                begin
                  DeletedTorrent := TDeletedTorrent.Create;
                  DeletedTorrent.HashDeleted := DataTask.HashValue;
                  DeletedTorrentList.Add(DeletedTorrent);
                end;
                DataTask.Status := tsDeleted;
              end;
            end;
          end;
        end;
      end;

    finally
      TasksList.UnLockList;
    end;

  EnterCriticalSection(TorrentSection);
  try
    for X := 0 to Plugins.Count - 1 do
    begin
      if (Supports(Plugins[X], IBTServicePlugin, BTPlugin)) then
      begin
        FindBTPlugin := true;
        break;
      end;
    end;
  finally
    LeaveCriticalSection(TorrentSection);
  end;

  if FindBTPlugin then
    for i := 0 to DeletedTorrentList.Count - 1 do
    begin
      HashDeleted := TDeletedTorrent(DeletedTorrentList[i]).HashDeleted;
      if trim(HashDeleted) <> '' then
      begin
        EnterCriticalSection(TorrentSection);
        try
          BTPlugin.DeleteTorrent(HashDeleted);
        finally
          LeaveCriticalSection(TorrentSection);
        end;
      end;
    end;

  DeletedTorrentList.Free;

  for i := 0 to CheckDeletedTorrentList.Count - 1 do
  begin
    if trim(CheckDeletedTorrentList[i]) <> '' then
    begin
      with TasksList.LockList do
        try
          for k := 0 to Count - 1 do
          begin
            DataTask := Items[k];
            if CheckDeletedTorrentList[i] = IntToStr(DataTask.ID) then
              if DataTask.Status <> tsDeleted then
                DataTask.Status := tsDeleted;
          end;
        finally
          TasksList.UnLockList;
        end;
    end;
  end;

  CheckDeletedTorrentList.Free;

  with TasksList.LockList do
    try
      repeat
        FinfDel := false;
        for a := 0 to Count - 1 do
        begin
          DataTask := Items[a];
          begin
            if (DataTask.Status = tsDeleted) or (DataTask.Status = tsDelete)
            then
            begin
              Delete(a);
              FinfDel := true;
              break;
            end;
          end;
        end;
      until FinfDel = false;
    finally
      TasksList.UnLockList;
    end;

  PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 12345);
end;

constructor TDeleteTaskWithFileThread.Create(CreateSuspended: Boolean;
  DeletedList: TStringList);
begin
  FreeOnTerminate := true;
  IDList := DeletedList;
  inherited Create(CreateSuspended);
end;

procedure TDeleteTaskWithFileThread.Execute;
var
  i, k, X, a: Integer;
  DataTask: TTask;
  BTDeleteTorrent: IBTDeleteTorrent;
  DeletedTorrentList: TList;
  DeletedTorrent: TDeletedTorrent;
  CheckDeletedTorrentList: TStringList;
  HashDeleted: widestring;
  FindBTPlugin: Boolean;
  FinfDel: Boolean;
begin
  DeletedTorrentList := TList.Create;
  CheckDeletedTorrentList := TStringList.Create;
  with TasksList.LockList do
    try
      for i := 0 to IDList.Count - 1 do
      begin
        if trim(IDList[i]) <> '' then
        begin
          for k := 0 to Count - 1 do
          begin
            DataTask := Items[k];
            if IDList[i] = IntToStr(DataTask.ID) then
            begin
              if (DataTask.Status = tsLoading) or (DataTask.Status = tsGetUrl)
                or (DataTask.Status = tsStoping) or
                (DataTask.Status = tsErroring) then
              else
              begin
                begin
                  DataTask.Status := tsDeleted;
                  CheckDeletedTorrentList.Add(IntToStr(DataTask.ID));
                  begin
                    DeletedTorrent := TDeletedTorrent.Create;
                    DeletedTorrent.HashDeleted := DataTask.HashValue;
                    if DataTask.NumFiles > 1 then
                    begin
                      DeletedTorrent.Path := true;
                      DeletedTorrent.Filename := DataTask.Directory + '\' +
                        DataTask.Filename + '\';
                      DeletedTorrent.Filename2 := DataTask.Directory +
                        '\__INCOMPLETE__' + DataTask.Filename + '\'
                    end
                    else
                    begin
                      DeletedTorrent.Path := false;
                      DeletedTorrent.Filename := DataTask.Directory + '\' +
                        DataTask.Filename;
                      DeletedTorrent.Filename2 := DataTask.Directory +
                        '\__INCOMPLETE__' + DataTask.Filename;
                    end;
                    DeletedTorrentList.Add(DeletedTorrent);
                  end;
                  DataTask.Status := tsDeleted;
                end;
              end;
            end;
          end;
        end;
      end;

    finally
      TasksList.UnLockList;
    end;

  EnterCriticalSection(TorrentSection);
  try
    for X := 0 to Plugins.Count - 1 do
    begin
      if (Supports(Plugins[X], IBTDeleteTorrent, BTDeleteTorrent)) then
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
    for i := 0 to DeletedTorrentList.Count - 1 do
    begin
      HashDeleted := TDeletedTorrent(DeletedTorrentList[i]).HashDeleted;
      if trim(HashDeleted) <> '' then
      begin
        EnterCriticalSection(TorrentSection);
        try
          try
            BTDeleteTorrent.DeleteTorrentWithFiles(HashDeleted);
          except
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;
        sleep(100);
      end;
    end;
    for i := 0 to DeletedTorrentList.Count - 1 do
    begin
      HashDeleted := TDeletedTorrent(DeletedTorrentList[i]).HashDeleted;
      if trim(HashDeleted) <> '' then
      begin
        EnterCriticalSection(TorrentSection);
        try
          try
            BTDeleteTorrent.DeleteTorrentWithFiles(HashDeleted);
          except
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;
        sleep(100);
      end;
    end;
  end;

  DeletedTorrentList.Free;

  for i := 0 to CheckDeletedTorrentList.Count - 1 do
  begin
    if trim(CheckDeletedTorrentList[i]) <> '' then
    begin
      with TasksList.LockList do
        try
          for k := 0 to Count - 1 do
          begin
            DataTask := Items[k];
            if CheckDeletedTorrentList[i] = IntToStr(DataTask.ID) then
              if DataTask.Status <> tsDeleted then
                DataTask.Status := tsDeleted;
          end;
        finally
          TasksList.UnLockList;
        end;
    end;
  end;
  CheckDeletedTorrentList.Free;

  with TasksList.LockList do
    try
      repeat
        FinfDel := false;
        for a := 0 to Count - 1 do
        begin
          DataTask := Items[a];
          begin
            if (DataTask.Status = tsDeleted) or (DataTask.Status = tsDelete)
            then
            begin
              Delete(a);
              FinfDel := true;
              break;
            end;
          end;
        end;
      until FinfDel = false;
    finally
      TasksList.UnLockList;
    end;

  PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 12345);
end;

end.
