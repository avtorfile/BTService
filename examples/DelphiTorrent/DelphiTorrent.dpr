program DelphiTorrent;

uses
  FastMM4,
  Forms,
  uMainForm in 'uMainForm.pas' {fMainForm},
  uTorrentThreads in 'uTorrentThreads.pas',
  uObjects in 'uObjects.pas',
  uTasks in 'uTasks.pas',
  uAddTorrent in 'uAddTorrent.pas' {fAddTorrent},
  Helpers in 'PluginAPI\Headers\Helpers.pas',
  CRC16 in 'PluginAPI\Headers\CRC16.pas',
  PluginAPI in 'PluginAPI\Headers\PluginAPI.pas',
  PluginManager in 'PluginAPI\Core\PluginManager.pas',
  uProcedures in 'uProcedures.pas',
  uConstsProg in 'uConstsProg.pas',
  uUpdateThread in 'uUpdateThread.pas',
  uStartThreads in 'uStartThreads.pas',
  uAddTask in 'uAddTask.pas' {fAddTask},
  uCreateTorrent in 'uCreateTorrent.pas' {fCreateTorrent},
  uTorrentMethods in 'uTorrentMethods.pas',
  uHelperThreads in 'uHelperThreads.pas',
  uAMultiProgressBar in 'uAMultiProgressBar.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMainForm, fMainForm);
  Application.Run;
end.
