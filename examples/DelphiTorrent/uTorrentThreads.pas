unit uTorrentThreads;

interface

uses
  Windows, Classes, SySUtils, Messages, Dialogs, MMSystem, Forms, uTasks,
  uObjects, Graphics,
  PluginManager, PluginApi;

type

  TLoadTorrent = class(TThread)
  public
    constructor Create(CreateSuspended: Boolean; P: Pointer;
      CalculateThread: Boolean);
  private
    DataTask: TTask;
    procedure GetInGeted(GetedData: WideString);
    procedure AfterLoad;
    procedure UpdatePieces;
  protected
    procedure Execute; override;
  end;

  TSeedingThread = class(TThread)
  public
    constructor Create(CreateSuspended: Boolean; P: Pointer;
      CalculateThread: Boolean);
  private
    DataTask: TTask;
    procedure GetInGeted(GetedData: WideString);

  protected
    procedure Execute; override;
  end;

implementation

uses uMainForm;

procedure GetDirSize(const aPath: string; var SizeDir: Int64);
var
  SR: TSearchRec;
  tPath: string;
begin
  tPath := IncludeTrailingBackSlash(aPath);
  if FindFirst(tPath + '*.*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name = '.') or (SR.Name = '..') then
          Continue;
        if (SR.Attr and faDirectory) <> 0 then
        begin
          GetDirSize(tPath + SR.Name, SizeDir);
          Continue;
        end;
        SizeDir := SizeDir + (SR.FindData.nFileSizeHigh *
          4294967296 { shl 32 } ) + SR.FindData.nFileSizeLow;
      until FindNext(SR) <> 0;
    finally
      SySUtils.FindClose(SR);
    end;
  end;
end;

function SizeFile(s: string): Int64;
var
  SearchRec: _WIN32_FIND_DATAW;
begin
  FindFirstFile(pchar(s), SearchRec);
  // result := (SearchRec.nFileSizeHigh shl 32) + (SearchRec.nFileSizeLow);
  // result := (SearchRec.nFileSizeHigh * (MAXDWORD+1)) + (SearchRec.nFileSizeLow);
  result := (SearchRec.nFileSizeHigh * 4294967296) + (SearchRec.nFileSizeLow);
end;

constructor TLoadTorrent.Create(CreateSuspended: Boolean; P: Pointer;
  CalculateThread: Boolean);
begin
  FreeOnTerminate := false;
  DataTask := P;
  DataTask.StartedLoadTorrentThread := true;
  inherited Create(CreateSuspended);
end;

procedure TLoadTorrent.Execute;
var
  X, X2: Integer;
  BTPlugin: IBTServicePlugin;
  BTPluginProgressive: IBTServicePluginProgressive;
  DataTorrentSL: TStringList;
  DataTorrent: WideString;
  GetedData: WideString;
  FindTorrent: Boolean;
  FindProgressiveInterface: Boolean;
  Load: Boolean;
  StateStr: String;
  State: Integer;
  SizeNow: Int64;
  OldSize: Int64;
  FilesSize: Int64;
  BTAddSeeding: IBTServiceAddSeeding;
  DataList: TStringList;
begin
  FindTorrent := false;
  FindProgressiveInterface := false;
  Load := false;

  if terminated then
    exit;

  EnterCriticalSection(TorrentSection);
  try
    for X := 0 to Plugins.Count - 1 do
    begin
      if (Supports(Plugins[X], IBTServicePlugin, BTPlugin)) then
      begin
        if StrToBool(BTPlugin.FindTorrent(DataTask.HashValue)) then
        begin
          FindTorrent := true;
          break;
        end;
      end;
    end;
  finally
    LeaveCriticalSection(TorrentSection);
  end;

  EnterCriticalSection(TorrentSection);
  try
    if not terminated then
      for X := 0 to Plugins.Count - 1 do
      begin
        if (Supports(Plugins[X], IBTServicePluginProgressive,
          BTPluginProgressive)) then
        begin
          FindProgressiveInterface := true;
          break;
        end;
      end;
  finally
    LeaveCriticalSection(TorrentSection);
  end;

  if not terminated then
    if (DataTask.Status <> tsProcessing) and (DataTask.Status <> tsSeeding) and
      (DataTask.Status <> tsLoading) and
      (DataTask.Status <> tsBittorrentMagnetDiscovery) then
      if FindTorrent = false then
      begin
        EnterCriticalSection(TorrentSection);
        try
          if not terminated then
            for X := 0 to Plugins.Count - 1 do
            begin
              if (Supports(Plugins[X], IBTServicePlugin, BTPlugin)) then
              begin
                if (trim(DataTask.TorrentFileName) = '') and
                  (trim(DataTask.LinkToFile) <> '') then
                begin
                  if (DataTask.ProgressiveDownload) and
                    (FindProgressiveInterface) then
                  begin
                    DataTorrentSL := TStringList.Create;
                    try
                      DataTorrentSL.Insert(0, IntToStr(DataTask.ID));
                      DataTorrentSL.Insert(1, DataTask.LinkToFile);
                      DataTorrentSL.Insert(2,
                        ExcludeTrailingBackSlash(DataTask.Directory));
                      DataTorrent := DataTorrentSL.Text;
                    finally
                      DataTorrentSL.Free;
                    end;
                    if not terminated then
                    begin
                      BTPluginProgressive.StartMagnetTorrentProgressive
                        (DataTorrent);
                    end;
                  end
                  else
                  begin
                    DataTorrentSL := TStringList.Create;
                    try
                      DataTorrentSL.Insert(0, IntToStr(DataTask.ID));
                      DataTorrentSL.Insert(1, DataTask.LinkToFile);
                      DataTorrentSL.Insert(2,
                        ExcludeTrailingBackSlash(DataTask.Directory));
                      DataTorrent := DataTorrentSL.Text;
                    finally
                      DataTorrentSL.Free;
                    end;
                    if not terminated then
                    begin
                      BTPlugin.StartMagnetTorrent(DataTorrent);
                    end;
                  end;
                end
                else
                begin
                  if (DataTask.ProgressiveDownload) and
                    (FindProgressiveInterface) then
                  begin
                    if not terminated then
                    begin
                      DataTorrentSL := TStringList.Create;
                      try
                        DataTorrentSL.Insert(0, IntToStr(DataTask.ID));
                        DataTorrentSL.Insert(1, DataTask.TorrentFileName);
                        DataTorrentSL.Insert(2,
                          ExcludeTrailingBackSlash(DataTask.Directory));
                        DataTorrent := DataTorrentSL.Text;
                      finally
                        DataTorrentSL.Free;
                      end;
                      if not terminated then
                      begin
                        BTPluginProgressive.StartTorrentProgressive
                          (DataTorrent);
                      end;
                    end;
                  end
                  else
                  begin
                    DataTorrentSL := TStringList.Create;
                    try
                      DataTorrentSL.Insert(0, IntToStr(DataTask.ID));
                      DataTorrentSL.Insert(1, DataTask.TorrentFileName);
                      DataTorrentSL.Insert(2,
                        ExcludeTrailingBackSlash(DataTask.Directory));
                      DataTorrent := DataTorrentSL.Text;
                    finally
                      DataTorrentSL.Free;
                    end;
                    if not terminated then
                    begin
                      FilesSize := 0;
                      if DirectoryExists(DataTask.Directory + '\' +
                        DataTask.FileName) then
                      begin
                        GetDirSize(DataTask.Directory + '\' + DataTask.FileName,
                          FilesSize);
                      end
                      else if FileExists(DataTask.Directory + '\' +
                        DataTask.FileName) then
                      begin
                        FilesSize :=
                          SizeFile(DataTask.Directory + '\' +
                          DataTask.FileName);
                      end;

                      if (FilesSize > 0) and (FilesSize = DataTask.TotalSize)
                      then
                      begin
                        for X2 := 0 to Plugins.Count - 1 do
                        begin
                          if (Supports(Plugins[X2], IBTServiceAddSeeding,
                            BTAddSeeding)) then
                          begin
                            DataList := TStringList.Create;
                            EnterCriticalSection(TorrentSection);
                            try
                              try
                                DataList.Insert(0, IntToStr(DataTask.ID));
                                DataList.Insert(1, DataTask.TorrentFileName);
                                DataList.Insert(2,
                                  ExcludeTrailingBackSlash(DataTask.Directory));
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
                        TSeedingThread.Create(false, DataTask, false);
                        DataTask.Status := tsSeeding;
                        exit;
                      end
                      else
                      begin
                        BTPlugin.StartTorrent(DataTorrent);
                      end;
                    end;
                  end;
                end;
                DataTask.Status := tsLoading;
                break;
              end;
            end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;
      end;

  if DataTask.Status = tsStartProcess then
  begin
    EnterCriticalSection(TorrentSection);
    try
      try
        if not terminated then
        begin
          BTPlugin.ResumeTorrent(DataTask.HashValue, DataTask.Directory);
        end;
      except
      end;
    finally
      LeaveCriticalSection(TorrentSection);
    end;
  end;

  repeat
    if DataTask.Status = tsStoping then
    begin
      repeat
        EnterCriticalSection(TorrentSection);
        try
          try
            if not terminated then
              BTPlugin.StopTorrent(DataTask.HashValue);
          except
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;

        try
          EnterCriticalSection(TorrentSection);
          try
            if not terminated then
              StateStr := BTPlugin.GetStatusTorrent(DataTask.HashValue);
          except
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;

        try
          State := StrToInt(StateStr);
        except
        end;
        if State <> 10 then
        begin
          sleep(1000);
          EnterCriticalSection(TorrentSection);
          try
            try
              if not terminated then
                StateStr := BTPlugin.GetStatusTorrent(DataTask.HashValue);
            except
            end;
          finally
            LeaveCriticalSection(TorrentSection);
          end;

          try
            State := StrToInt(StateStr);
          except
          end;
        end;
      until (State = 10) or (terminated);

      DataTask.Speed := 0;
      DataTask.UploadSpeed := 0;
      AfterLoad;
    end
    else
    begin
      if (DataTask.Status = tsSeeding) or (DataTask.Status = tsUploading) then
      begin
        AfterLoad;
        Load := true;
      end
      else
      begin
        EnterCriticalSection(TorrentSection);
        try
          try
            if not terminated then
              GetedData := BTPlugin.GetInfoTorrent(DataTask.HashValue);
          except
          end;
          if not terminated then
            GetInGeted(GetedData);

          if not terminated then
            if FindProgressiveInterface then
            begin
              try
                DataTask.SizeProgressiveDownloaded :=
                  StrToInt64(BTPluginProgressive.SizeProgressiveDownloaded
                  (DataTask.HashValue));
                SizeNow := DataTask.SizeProgressiveDownloaded;
              except
              end;
              if DataTask.SizeProgressiveDownloaded > 0 then
                if SizeNow <> OldSize then
                begin
                  OldSize := SizeNow;
                end;
            end;

        finally
          LeaveCriticalSection(TorrentSection);
        end;

        if DataTask.UpdatePiecesInfo then
        begin
          if not terminated then
            UpdatePieces;
        end;

      end;
    end;

    sleep(1000);
  until (DataTask.Status = tsStoped) or (Load) or (DataTask.Status = tsDeleted)
    or (terminated);
  DataTask.StartedLoadTorrentThread := false;
end;

procedure TLoadTorrent.UpdatePieces;
var
  IBTPiecesInfo: IBTServicePluginPiecesInfo;
  StatusStr: string;
  StatusInt: Integer;
  X: Integer;
  PiecesInfo: WideString;

  procedure PiecesInfoInGeted(GetedData: WideString; DataTask: TTask);
  var
    GetedList: TStringList;
    GetedPieceList: TStringList;
    i, k: Integer;
    PieceInfo: TPieces;
  begin
    GetedList := TStringList.Create;
    try
      GetedList.Delimiter := ' ';
      GetedList.QuoteChar := '^';
      GetedList.DelimitedText := GetedData;
      if DataTask.UpdatePiecesInfo then
        if assigned(DataTask.Pieces) then
        begin
          for i := 0 to GetedList.Count - 1 do
          begin
            if GetedList[i] <> '' then
            begin
              try
                GetedPieceList := TStringList.Create;
                try
                  GetedPieceList.Delimiter := ' ';
                  GetedPieceList.QuoteChar := '|';
                  GetedPieceList.DelimitedText := GetedList[i];
                except
                end;

                for k := 0 to DataTask.Pieces.Count - 1 do
                begin
                  if i = k then
                  begin
                    try
                      TPieces(DataTask.Pieces.Items[k]).foffset :=
                        StrToInt64(GetedPieceList[0]);
                    except
                    end;
                    try
                      TPieces(DataTask.Pieces.Items[k]).fsize :=
                        StrToInt64(GetedPieceList[1]);
                    except
                    end;
                    try
                      TPieces(DataTask.Pieces.Items[k]).findex :=
                        StrToInt64(GetedPieceList[2]);
                    except
                    end;
                    try
                      TPieces(DataTask.Pieces.Items[k]).fprogress :=
                        StrToInt64(GetedPieceList[3]);
                    except
                    end;
                    try
                      DataTask.MPBar.SetPosition
                        (TPieces(DataTask.Pieces.Items[k]).findex,
                        TPieces(DataTask.Pieces.Items[k]).foffset +
                        TPieces(DataTask.Pieces.Items[k]).fprogress, GraphColor,
                        ProgressBackColor);
                    except
                    end;
                  end;
                end;
              finally
                GetedPieceList.Free;
              end;
            end
          end
        end
        else
        begin
          DataTask.Pieces := TList.Create;
          DataTask.LastAddedIndex := 0;
          DataTask.MPBar.Clear;
          DataTask.MPBar.Visible := false;
          for i := 0 to GetedList.Count - 1 do
          begin
            if GetedList[i] <> '' then
            begin
              try
                PieceInfo := TPieces.Create;
                GetedPieceList := TStringList.Create;
                try
                  GetedPieceList.Delimiter := ' ';
                  GetedPieceList.QuoteChar := '|';
                  GetedPieceList.DelimitedText := GetedList[i];
                except
                end;

                try
                  PieceInfo.foffset := StrToInt64(GetedPieceList[0]);
                except
                end;
                try
                  PieceInfo.fsize := StrToInt64(GetedPieceList[1]);
                except
                end;
                try
                  PieceInfo.findex := StrToInt64(GetedPieceList[2]);
                except
                end;
                try
                  PieceInfo.fprogress := StrToInt64(GetedPieceList[3]);
                except
                end;

                // if PieceInfo.findex = 1 then
                // begin
                // showmessage('PieceInfo.findex: ' + IntToStr(PieceInfo.findex)
                // + sLineBreak + 'PieceInfo.foffset: ' +
                // IntToStr(PieceInfo.foffset) + sLineBreak +
                // 'PieceInfo.fsize: ' + IntToStr(PieceInfo.fsize) + sLineBreak
                // + 'PieceInfo.fprogress: ' + IntToStr(PieceInfo.fprogress));
                // end;
                //
                // if PieceInfo.findex = 200 then
                // begin
                // showmessage('PieceInfo.findex: ' + IntToStr(PieceInfo.findex)
                // + sLineBreak + 'PieceInfo.foffset: ' +
                // IntToStr(PieceInfo.foffset) + sLineBreak +
                // 'PieceInfo.fsize: ' + IntToStr(PieceInfo.fsize) + sLineBreak
                // + 'PieceInfo.fprogress: ' + IntToStr(PieceInfo.fprogress));
                // end;
                //
                // if PieceInfo.findex = 500 then
                // begin
                // showmessage('PieceInfo.findex: ' + IntToStr(PieceInfo.findex)
                // + sLineBreak + 'PieceInfo.foffset: ' +
                // IntToStr(PieceInfo.foffset) + sLineBreak +
                // 'PieceInfo.fsize: ' + IntToStr(PieceInfo.fsize) + sLineBreak
                // + 'PieceInfo.fprogress: ' + IntToStr(PieceInfo.fprogress));
                // end;

                PieceInfo.AddedSegment := false;
                try
                  DataTask.MPBar.AddSegment(PieceInfo.foffset, PieceInfo.fsize,
                    PieceInfo.foffset + PieceInfo.fprogress, GraphColor,
                    ProgressBackColor);
                  { DataTask.MPBar.AddSegment(PieceInfo.foffset,
                    PieceInfo.fsize,
                    PieceInfo.foffset + PieceInfo.fprogress, $00FBA900,
                    clWindow); } // $ffffff
                  PieceInfo.IndexSegment := DataTask.LastAddedIndex;
                  inc(DataTask.LastAddedIndex);
                except
                end;
                PieceInfo.AddedSegment := true;

                with TasksList.LockList do
                  try
                    if assigned(DataTask.Pieces) then
                      DataTask.Pieces.Add(PieceInfo);
                  finally
                    TasksList.UnlockList;
                  end;
              finally
                GetedPieceList.Free;
              end;
            end;
          end;
          DataTask.MPBar.Visible := true;
          // showmessage('DataTask.LastAddedIndex: '+inttostr(DataTask.LastAddedIndex));
        end;
    finally
      GetedList.Free;
    end;
  end;

begin
  if DataTask.UpdatePiecesInfo = true then
  begin
    for X := 0 to Plugins.Count - 1 do
    begin
      if (Supports(Plugins[X], IBTServicePluginPiecesInfo, IBTPiecesInfo)) then
      begin
        try
          StatusStr := IBTPiecesInfo.CheckPiecesStatus(DataTask.HashValue);
        except
        end;

        if trim(StatusStr) = '' then
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
            IBTPiecesInfo.GetPiecesInfo(DataTask.HashValue);
          except
          end;
        end
        else if StatusInt = 3 then
        begin
          try
            PiecesInfo := IBTPiecesInfo.GetDataPieces(DataTask.HashValue);
            IBTPiecesInfo.ReleasePiecesThread(DataTask.HashValue);
          except
          end;
        end;
        if trim(PiecesInfo) <> '' then
          PiecesInfoInGeted(PiecesInfo, DataTask);
      end;
    end;
  end;
end;

procedure TLoadTorrent.GetInGeted(GetedData: WideString);
var
  GetedList: TStringList;
  fsize: Int64;
  State: Integer;
  FileNameTorr: string;
  StateStr: string;
begin
  GetedList := TStringList.Create;

  try
    try
      GetedList.Delimiter := ' ';
      GetedList.QuoteChar := '|';
      GetedList.DelimitedText := (GetedData);
    except
    end;

    try
      FileNameTorr := GetedList[0];
      DataTask.FileName := Utf8ToAnsi(ExtractFileName(FileNameTorr));
    except
    end;
    try
      DataTask.LoadSize := StrToInt64(GetedList[1]);
    except
    end;
    try
      DataTask.UploadSize := StrToInt64(GetedList[2]);
    except
    end;
    try
      StateStr := GetedList[3];
      StateStr := trim(StateStr);
      fsize := StrToInt64(StateStr);
      DataTask.TotalSize := fsize;
    except
    end;
    try
      DataTask.NumConnected := StrToInt(GetedList[4]);
    except
    end;
    try
      DataTask.NumConnectedSeeders := StrToInt(GetedList[5]);
    except
    end;
    try
      DataTask.NumConnectedLeechers := StrToInt(GetedList[6]);
    except
    end;

    try
      StateStr := GetedList[7];
      StateStr := trim(StateStr);
      State := StrToInt(StateStr);
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
        DataTask.Status := tsRebuilding;
      if State = 6 then
        DataTask.Status := tsProcessing;
      if State = 7 then
        DataTask.Status := tsJustCompleted;
      if State = 8 then
        DataTask.Status := tsLoad;
      if State = 9 then
        DataTask.Status := tsLoading;
      if State = 10 then
        DataTask.Status := tsStoped;
      if State = 11 then
        DataTask.Status := tsLeechPaused;
      if State = 12 then
        DataTask.Status := tsLocalPaused;
      if State = 13 then
        DataTask.Status := tsCancelled;
      if State = 14 then
        DataTask.Status := tsQueuedSource;
      if State = 15 then
        DataTask.Status := tsUploading;
    except
    end;

    try
      DataTask.Speed := StrToInt(GetedList[8]);
    except
    end;

    try
      DataTask.UploadSpeed := StrToInt(GetedList[9]);
    except
    end;

    try
      // DataTask.HashValue := Utf8ToAnsi(GetedList[10]);
    except
    end;

    try
      DataTask.NumFiles := StrToInt(GetedList[11]);
    except
    end;

    try
      DataTask.NumAllSeeds := StrToInt(GetedList[12]);
    except
    end;
  finally
    GetedList.Free;
  end;

end;

constructor TSeedingThread.Create(CreateSuspended: Boolean; P: Pointer;
  CalculateThread: Boolean);
begin
  FreeOnTerminate := false;
  DataTask := P;
  inherited Create(CreateSuspended);
end;

procedure TSeedingThread.Execute;
var
  X: Integer;
  BTPlugin: IBTServicePlugin;
  FindTorrent: Boolean;
  GetedData: WideString;
begin
  FindTorrent := false;

  EnterCriticalSection(TorrentSection);
  try
    if not terminated then
      for X := 0 to Plugins.Count - 1 do
      begin
        if not terminated then
          if (Supports(Plugins[X], IBTServicePlugin, BTPlugin)) then
          begin
            try
              if not terminated then
              begin
                try
                  FindTorrent :=
                    StrToBool(BTPlugin.FindTorrent(DataTask.HashValue));
                  break;
                except
                end;
              end;
            except
            end;
          end;
      end;
  finally
    LeaveCriticalSection(TorrentSection);
  end;

  repeat
    if not terminated then
      if DataTask.Status = tsStoping then
      begin
        EnterCriticalSection(TorrentSection);
        try
          try
            BTPlugin.StopTorrent(DataTask.HashValue);
          except
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;
        with TasksList.LockList do
          try
            try
              DataTask.Status := tsStoped;
            except
            end;
          finally
            TasksList.UnlockList;
          end;
      end
      else
      begin
        EnterCriticalSection(TorrentSection);
        try
          try
            if not terminated then
              GetedData := BTPlugin.GetInfoTorrent(DataTask.HashValue);
          except
          end;
        finally
          LeaveCriticalSection(TorrentSection);
        end;
        if not terminated then
          GetInGeted(GetedData);
      end;

    sleep(1000);
  until (DataTask.Status = tsStoped) or (DataTask.Status = tsDeleted) or
    (terminated);
end;

procedure TSeedingThread.GetInGeted(GetedData: WideString);
var
  GetedList: TStringList;
  fsize: Int64;
  State: Integer;
  FileNameTorr: string;
  StateStr: string;

begin
  GetedList := TStringList.Create;
  try
    try
      GetedList.Delimiter := ' ';
      GetedList.QuoteChar := '|';
      GetedList.DelimitedText := (GetedData);
    except
    end;
    try
      FileNameTorr := GetedList[0];
      DataTask.FileName := Utf8ToAnsi(ExtractFileName(FileNameTorr));
    except
    end;
    try
      DataTask.LoadSize := StrToInt64(GetedList[1]);
    except
    end;
    try
      DataTask.UploadSize := StrToInt64(GetedList[2]);
    except
    end;
    try
      StateStr := GetedList[3];
      StateStr := trim(StateStr);
      fsize := StrToInt64(StateStr);
      DataTask.TotalSize := fsize;
    except
    end;
    try
      DataTask.NumConnected := StrToInt(GetedList[4]);
    except
    end;
    try
      DataTask.NumConnectedSeeders := StrToInt(GetedList[5]);
    except
    end;
    try
      DataTask.NumConnectedLeechers := StrToInt(GetedList[6]);
    except
    end;
    try
      StateStr := GetedList[7];
      StateStr := trim(StateStr);
      State := StrToInt(StateStr);

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
    try
      DataTask.Speed := StrToInt(GetedList[8]);
    except
    end;
    try
      DataTask.UploadSpeed := StrToInt(GetedList[9]);
    except
    end;
    try
      // DataTask.HashValue := Utf8ToAnsi(GetedList[10]);
    except
    end;
    try
      DataTask.NumFiles := StrToInt(GetedList[11]);
    except
    end;
    try
      DataTask.NumAllSeeds := StrToInt(GetedList[12]);
    except
    end;
  finally
    GetedList.Free;
  end;

end;

procedure TLoadTorrent.AfterLoad;
var
  i: Integer;
begin
  /// ///////////////////// При ошибке без циклирования ///////////////////////////
  if (DataTask.Status = tsErroring) then
  begin
    DataTask.Status := tsError;
  end;

  /// //////////////////////// После остановки закачки ////////////////////////////
  if (DataTask.Status = tsStoping) then
  begin
    DataTask.Status := tsStoped;
  end;
  /// /////////////////////////////////////////////////////////////////////////////

  /// ///////////////////// После завершения закачки //////////////////////////////
  if (DataTask.Status = tsSeeding) or (DataTask.Status = tsUploading) then
  begin
    DataTask.TimeEnd := Now;
    try
      for i := 0 to DataTask.Pieces.Count - 1 do
      begin
        DataTask.MPBar.SetPosition(TPieces(DataTask.Pieces.Items[i]).findex,
          TPieces(DataTask.Pieces.Items[i]).foffset +
          TPieces(DataTask.Pieces.Items[i]).fsize, GraphColor,
          ProgressBackColor);
      end;
    except
    end;
    SeedingThreads.Add(TSeedingThread.Create(false, DataTask, false));
  end;

  if (DataTask.Status = tsLoading) then
  begin
    DataTask.Status := tsLoad;
  end;
end;

end.
