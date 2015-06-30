unit uTasks;

interface

uses Windows, Classes, SysUtils, XMLDoc, XMLIntf,
  uObjects, uAMultiProgressBar;

type

  TTask = class(TObject)
  public
    ID: Integer;
    CountErrors: Integer;
    Name: String;
    Version: String;
    Path: String;
    LinkToFile: String;
    FileName: String;
    FilePath: String;
    Directory: String;
    TotalSize: Int64;
    LoadSize: Int64;
    TimeBegin: TDateTime;
    TimeEnd: TDateTime;
    TimeTotal: TDateTime;
    Speed: Int64;
    Status: TTaskStatus;
    Handle: Cardinal;
    Description: String;
    MPBar: TAMultiProgressBar;
    CriticalINI: TRTLCriticalSection;
    TaskServPlugIndexIcon: Integer;
    Trackers: TList;
    Pieces: TList;
    Files: TList;
    Peers: TList;
    SelectedTask: Boolean;
    UpdatePiecesInfo: Boolean;
    LastAddedIndex: Integer;
    StartedLoadTorrentThread: Boolean;
    HashValue: String;
    TorrentFileName: String;
    UploadSpeed: Int64;
    UploadSize: Int64;
    NumFiles: Integer;
    NumConnected: Integer;
    NumConnectedSeeders: Integer;
    NumConnectedLeechers: Integer;
    NumAllSeeds: Integer;
    Renamed: Boolean;
    SizeProgressiveDownloaded: Int64;
    ProgressiveDownload: Boolean;
  end;

procedure SaveTasksList;
procedure LoadTasksList;

implementation

uses uMainForm;

procedure SaveTasksList;
var
  Xml: TXMLDocument;
  Parent: IXMLNode;
  Child: IXMLNode;
  Value: IXMLNode;
  i: Integer;
  DataTask: TTask;
begin
  Xml := TXMLDocument.Create(nil);
  Xml.Active := True;

  if Xml.IsEmptyDoc then
    Xml.DocumentElement := Xml.CreateElement('TorrentList', '');

  Xml.DocumentElement.Attributes['Name'] := Options.Version;

  Xml.DocumentElement.Attributes['Version'] := Options.TasksListName;

  if TasksList <> nil then
  begin
    Parent := Xml.DocumentElement.AddChild('Tasks');

    with TasksList.LockList do
      try
        for i := 0 to Count - 1 do
        begin
          DataTask := Items[i];

          if DataTask.Status <> tsDelete then
          begin
            Child := Parent.AddChild('Task');

            Value := Child.AddChild('LinkToFile');
            Value.Text := DataTask.LinkToFile;
            Value := Child.AddChild('HashValue');
            Value.Text := DataTask.HashValue;
            Value := Child.AddChild('TorrentFileName');
            Value.Text := DataTask.TorrentFileName;
            Value := Child.AddChild('FileName');
            Value.Text := DataTask.FileName;
            Value := Child.AddChild('Directory');
            Value.Text := ExcludeTrailingBackSlash(DataTask.Directory);
            Value := Child.AddChild('TotalSize');
            Value.Text := IntToStr(DataTask.TotalSize);
            Value := Child.AddChild('LoadSize');
            Value.Text := IntToStr(DataTask.LoadSize);
            Value := Child.AddChild('UploadSize');
            Value.Text := IntToStr(DataTask.UploadSize);
            Value := Child.AddChild('NumFiles');
            Value.Text := IntToStr(DataTask.NumFiles);
            Value := Child.AddChild('ID');
            Value.Text := IntToStr(DataTask.ID);
            Value := Child.AddChild('Speed');
            Value.Text := IntToStr(DataTask.Speed);
            Value := Child.AddChild('Status');
            Value.Text := IntToStr(Integer(DataTask.Status));
            Value := Child.AddChild('Description');
            Value.Text := DataTask.Description;
          end;
        end;
      finally
        TasksList.UnlockList;
      end;
  end;
  Xml.SaveToFile(Options.Path + '\' + Options.TasksListName + '.xml');
  Xml.Free;
end;

procedure LoadTasksList;
var
  Xml: IXMLDocument;
  Parent: IXMLNode;
  Child: IXMLNode;
  Value: IXMLNode;
  i: Integer;
  Data: TTask;
  FirstIDSortList: Boolean;
begin
  FirstIDSortList := True;
  TasksList := TThreadList.Create;

  if not FileExists(Options.Path + '\' + Options.TasksListName + '.xml') then
    Exit;

  Xml := TXMLDocument.Create(nil);
  Xml.Active := True;
  Xml.LoadFromFile(Options.Path + '\' + Options.TasksListName + '.xml');

  Parent := Xml.DocumentElement.ChildNodes['Tasks'];

  for i := 0 to Parent.ChildNodes.Count - 1 do
  begin
    Data := TTask.Create;

    Child := Parent.ChildNodes[i];
    Value := Child.ChildNodes['LinkToFile'];
    Data.LinkToFile := Value.Text;
    Value := Child.ChildNodes['HashValue'];
    Data.HashValue := Value.Text;
    Value := Child.ChildNodes['TorrentFileName'];
    Data.TorrentFileName := Value.Text;

    Value := Child.ChildNodes['FileName'];
    Data.FileName := Value.Text;

    Value := Child.ChildNodes['Directory'];
    Data.Directory := ExcludeTrailingBackSlash(Value.Text);

    Value := Child.ChildNodes['TotalSize'];
    if (Trim(Value.Text) = '') then
      Data.TotalSize := 0
    else
      Data.TotalSize := StrToInt64(Value.Text);

    Value := Child.ChildNodes['LoadSize'];
    if (Trim(Value.Text) = '') then
      Data.LoadSize := 0
    else
      Data.LoadSize := StrToInt64(Value.Text);

    Value := Child.ChildNodes['UploadSize'];
    if (Trim(Value.Text) = '') then
      Data.UploadSize := 0
    else
      Data.UploadSize := StrToInt64(Value.Text);

    Value := Child.ChildNodes['NumFiles'];
    if (Trim(Value.Text) = '') then
      Data.NumFiles := 1
    else
      Data.NumFiles := StrToInt(Value.Text);

    Value := Child.ChildNodes['ID'];
    Data.ID := StrToInt(Value.Text);
    Value := Child.ChildNodes['Speed'];
    Data.Speed := StrToInt(Value.Text);
    Value := Child.ChildNodes['Status'];
    Data.Status := TTaskStatus(StrToInt(Value.Text));
    Value := Child.ChildNodes['Description'];
    Data.Description := Value.Text;
    Data.MPBar := TAMultiProgressBar.Create(nil);
//    Data.MPBar.Color:=GraphColor;

    TasksList.Add(Data);
  end;
  Xml := nil;
end;

end.
