unit uUpdateThread;

interface

uses windows, classes, uTasks, uObjects, uConstsProg;

type

  TUpdateVisualThread = class(TThread)
  public
    constructor Create(CreateSuspended: Boolean);
  protected
    procedure Execute; override;

  end;

implementation

uses uMainForm;

constructor TUpdateVisualThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure TUpdateVisualThread.Execute;
var
  i: integer;
  DataTask: TTask;

begin
  repeat
    try
      PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 12121);
    except
    end;
    CountSeeding := 0;
    CountLoading := 0;
    CountQueue := 0;
    CountStoped := 0;
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];
          if DataTask.Status = tsSeeding then
            Inc(CountSeeding);
          if (DataTask.Status = tsLoading) or (DataTask.Status = tsGetURL) then
            Inc(CountLoading);
          if DataTask.Status = tsQueue then
            Inc(CountQueue);
          if DataTask.Status = tsStoped then
            Inc(CountStoped);
        end;
      finally
        TasksList.UnLockList;
      end;
    try
      PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 10008);
    except
    end;

    AllSpeeds := 0;
    AllUpSpeeds := 0;
    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do // for i:=Count-1 downto 0 do
        begin
          DataTask := Items[i];
          try
            if (DataTask.Status = tsLoading) then
              AllSpeeds := AllSpeeds + DataTask.Speed;
            if (DataTask.Status = tsLoading) or (DataTask.Status = tsSeeding) or
              (DataTask.Status = tsLoad) then
              AllUpSpeeds := AllUpSpeeds + DataTask.UploadSpeed;
          except
          end;
        end;
      finally
        TasksList.UnLockList;
      end;

    try
      PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 10009);
    except
    end;

    if not terminated then
      sleep(500);
  until terminated;

end;

end.
