unit uTorrentMethods;

interface

uses windows, Classes, SysUtils,
  uTorrentThreads, uConstsProg, uAMultiProgressBar,
  uProcedures, uObjects, uTasks, PluginManager, PluginApi;

function AddTorrent(TorrData: string; HashValue: string; Now: Boolean;
  ShowPrev: Boolean): Boolean;

implementation

uses uMainForm;

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
          result := c + '[' + ID + ']' + a;
          Exit;
        end;
      end;
    finally
      TasksList.UnLockList;
    end;
  result := FileName;
end;

function AddTorrent(TorrData: string; HashValue: string; Now: Boolean;
  ShowPrev: Boolean): Boolean;
var
  AddDataTask: TTask;
  AddedData: TStringList;
  CreaName, CreatedName: string;
  Plugin2: IAddDownload;
  IndexPlugin2: Integer;
  Silent: Boolean;
  Down: Boolean;
begin
  result := false;
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

      if CreaName <> '' then
      begin
        if RightFileName(CreaName) then
          CreatedName := CreaName
        else
          CreatedName := 'NoName';
      end
      else
        CreatedName := 'NoName';

      AddDataTask.FileName := CreatedName;
      AddDataTask.Description := '';

      if Down then
        AddDataTask.Status := tsQueue
      else
        AddDataTask.Status := tsReady;

      try
        AddDataTask.TotalSize := StrToInt64(AddedData[9]);
      finally
        AddDataTask.TotalSize := 0
      end;

      AddDataTask.LoadSize := 0;
      AddDataTask.TimeBegin := 0;
      AddDataTask.TimeEnd := 0;
      AddDataTask.TimeTotal := 0;
      AddDataTask.MPBar := TAMultiProgressBar.Create(nil);
//      AddDataTask.MPBar.Color:=GraphColor;

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
              AddDataTask.TaskServPlugIndexIcon := 34
          end;

      TasksList.Add(AddDataTask);
      result := true;

      PostMessage(Options.MainFormHandle, WM_MYMSG, 0, 12345);

      if Now then
        LoadTorrentThreads.Add(TLoadTorrent.Create(false, AddDataTask, true));
    end;

  finally
    AddedData.Free;
  end;
end;

end.
