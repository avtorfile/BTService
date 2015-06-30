unit DllForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Spin, ExtCtrls, uSettings, uPluginInfo,
  vars_global,helper_registry, IniFiles,
  SHDocVw, ShellApi, PluginForm;

type
  TfDllForm = class(TForm)
    PageControl1: TPageControl;
    ts0: TTabSheet;
    ts1: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    grp1: TGroupBox;
    rb1: TRadioButton;
    rb2: TRadioButton;
    se1: TSpinEdit;
    edt1: TEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    edt2: TEdit;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    cbb1: TComboBox;
    cbb2: TComboBox;
    lbl13: TLabel;
    lbl14: TLabel;
    lbl15: TLabel;
    cbb3: TComboBox;
    pgcPageControl2: TPageControl;
    ts4: TTabSheet;
    ts5: TTabSheet;
    ts6: TTabSheet;
    ts7: TTabSheet;
    pgc2: TPageControl;
    ts8: TTabSheet;
    ts9: TTabSheet;
    rb3: TRadioButton;
    rb4: TRadioButton;
    edt3: TEdit;
    cbb4: TComboBox;
    lbl16: TLabel;
    lbl17: TLabel;
    se4: TSpinEdit;
    lbl18: TLabel;
    se5: TSpinEdit;
    pnl1: TPanel;
    btn1: TButton;
    btn2: TButton;
    chk2: TCheckBox;
    chk3: TCheckBox;
    chk4: TCheckBox;
    btn3: TButton;
    chk5: TCheckBox;
    lbl19: TLabel;
    edt4: TEdit;
    lbl20: TLabel;
    edt5: TEdit;
    btn4: TButton;
    btn5: TButton;
    edt6: TEdit;
    btn6: TButton;
    lbl21: TLabel;
    tmr1: TTimer;
    dlgOpen1: TOpenDialog;
    se6: TSpinEdit;
    lbl22: TLabel;
    lbl23: TLabel;
    se7: TSpinEdit;
    grp3: TGroupBox;
    lbl25: TLabel;
    lbl26: TLabel;
    se9: TSpinEdit;
    se10: TSpinEdit;
    lbl24: TLabel;
    lbl28: TLabel;
    chk_opt_tran_inconidle: TCheckBox;
    pnl2: TPanel;
    se8: TSpinEdit;
    lbl1: TLabel;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure cbb3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure chk5Click(Sender: TObject);   
    procedure rb1Click(Sender: TObject);
    procedure rb2Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure lbl11Click(Sender: TObject);
    procedure lbl6Click(Sender: TObject);
    
  private
    { Private declarations }
  public
    Language: string;
    { Public declarations }
  end;

var
  fDllForm: TfDllForm;
  Browser: IWebBrowser2;

implementation

{$R *.dfm}

uses uFunctions;

procedure TfDllForm.btn1Click(Sender: TObject);
var ini:TMemIniFile;
begin
  Settings.UseNumThreadsPlug := rb1.Checked;
  Settings.UseNumThreadsFromProg := rb2.Checked;
  Settings.CountThreads := se1.Value;
  Settings.TimeRecognition := (StrToInt(cbb1.Text) * 60000) +
    (StrToInt(cbb2.Text) * 1000);
  Settings.MethodRecognition := cbb3.ItemIndex;
  Settings.UseAntigateKey := rb3.Checked;
  Settings.UseAntigateKeyFromProg := rb4.Checked;
  Settings.AntigateKey := edt3.Text;
  Settings.RecognitionProg := edt6.Text;
  Settings.CapIniFile := edt4.Text;
  Settings.CatalogLetters := edt5.Text;
  Settings.phrase := chk2.Checked;
  Settings.regsense := chk3.Checked;
  Settings.numeric := cbb4.ItemIndex;
  Settings.calc := chk4.Checked;
  Settings.min_len := se4.Value;
  Settings.max_len := se5.Value;
  Settings.MainPControl := PageControl1.TabIndex;
  Settings.UsePremium := chk5.Checked;
  Settings.LoginPremium := edt1.Text;
  Settings.PasswordPremium := edt2.Text;
  Settings.RecPControl := pgc2.TabIndex;
  //Settings.NumUsualSect := se2.Value;
  //Settings.NumProxySect := se3.Value;
  //Settings.SubstituteProxySection := chk1.Checked;

  //port:=se8.Value;//strtointdef(Edit_opt_tran_port.text,80);
  //if ((port<1) or (port>65535)) then port:=80;

  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     vars_global.myport:=se8.Value;
     if ((vars_global.myport<1) or (vars_global.myport>65535)) then vars_global.myport:=80;
     Ini.WriteInteger('Transfer','ServerPort', vars_global.myport);

     vars_global.up_band_allow:=se9.Value;//strtointdef(Edit_opt_tran_upband.text,0);
     Ini.WriteInteger('Transfer','AllowedUpBand', vars_global.up_band_allow);

     vars_global.down_band_allow:=se10.Value;//strtointdef(Edit_opt_tran_dnband.text,0);
     Ini.WriteInteger('Transfer','AllowedDownBand', vars_global.down_band_allow);

     vars_global.check_opt_tran_inconidle_checked:=chk_opt_tran_inconidle.checked;
     Ini.WriteInteger('Transfer','MaximizeUpBandOnIdle', integer(vars_global.check_opt_tran_inconidle_checked));

     vars_global.limite_upload:=se6.Value;//strtointdef(Edit_opt_tran_limup.text,4);
     Ini.WriteInteger('Transfer','MaxUpCount', vars_global.limite_upload);

     vars_global.max_ul_per_ip:=se7.Value;//strtointdef(Edit_opt_tran_upip.text,3);
     Ini.WriteInteger('Transfer','MaxUpPerUser', vars_global.max_ul_per_ip);

     vars_global.max_dl_allowed:=se1.Value;//strtointdef(Edit_opt_tran_limdn.text,MAXNUM_ACTIVE_DOWNLOADS);
     Ini.WriteInteger('Transfer','MaxDlCount', vars_global.max_dl_allowed);
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
  vars_global.myport:=se8.Value;
  if ((vars_global.myport<1) or (vars_global.myport>65535)) then vars_global.myport:=80;
  set_reginteger('Transfer.ServerPort',vars_global.myport);

  vars_global.up_band_allow:=se9.Value;//strtointdef(Edit_opt_tran_upband.text,0);
  set_reginteger('Transfer.AllowedUpBand',vars_global.up_band_allow);

  vars_global.down_band_allow:=se10.Value;//strtointdef(Edit_opt_tran_dnband.text,0);
  set_reginteger('Transfer.AllowedDownBand',vars_global.down_band_allow);

  vars_global.check_opt_tran_inconidle_checked:=chk_opt_tran_inconidle.checked;
  set_reginteger('Transfer.MaximizeUpBandOnIdle',integer(vars_global.check_opt_tran_inconidle_checked));

  vars_global.limite_upload:=se6.Value;//strtointdef(Edit_opt_tran_limup.text,4);
  set_reginteger('Transfer.MaxUpCount',vars_global.limite_upload);

  vars_global.max_ul_per_ip:=se7.Value;//strtointdef(Edit_opt_tran_upip.text,3);
  set_reginteger('Transfer.MaxUpPerUser',vars_global.max_ul_per_ip);

  vars_global.max_dl_allowed:=se1.Value;//strtointdef(Edit_opt_tran_limdn.text,MAXNUM_ACTIVE_DOWNLOADS);
  set_reginteger('Transfer.MaxDlCount',vars_global.max_dl_allowed);
  end;

  WriteIniParams;
  Close;
end;

procedure TfDllForm.btn2Click(Sender: TObject);
begin
Close;
end;

procedure TfDllForm.cbb3Change(Sender: TObject);
begin
  if cbb3.ItemIndex = 0 then // ïÑÂÌÍÈ
    pgcPageControl2.ActivePage := ts4;
  if cbb3.ItemIndex = 1 then // Antigate
    pgcPageControl2.ActivePage := ts5;
  if cbb3.ItemIndex = 2 then // CAP
    pgcPageControl2.ActivePage := ts6;
  if cbb3.ItemIndex = 3 then // äÏÑÖÍÈ
    pgcPageControl2.ActivePage := ts7;
end;

procedure TfDllForm.FormCreate(Sender: TObject);
var
  min: integer;
  sec: integer;
  Time: integer;
  Buffer: array [byte] of char;
  NamePlugin: string;
//  b,c:Boolean; 
begin
  if GetModuleFileName(hInstance, @Buffer, SizeOf(Buffer) - 1) > 0 then
  begin
    NamePlugin := ExtractFileName(StrPas(Buffer));
  end;
  Caption := 'Íàñòðîéêè' + ' ' + NamePlugin;

  {if Settings.SkinActive then
  begin
    sSkinManager1.SkinDirectory := Settings.SkinDirectory;
    sSkinManager1.SkinName := Settings.SkinName;
    b := sSkinManager1.AnimEffects.SkinChanging.Active;
    sSkinManager1.AnimEffects.SkinChanging.Active := false;
    sSkinManager1.Saturation := Settings.Saturation;
    sSkinManager1.HueOffset := Settings.Hue;
    sSkinManager1.AnimEffects.SkinChanging.Active := b;
    sSkinManager1.Active:=Settings.SkinActive;
  end
  else
    sSkinManager1.Active := false;}

  rb1.Checked := Settings.UseNumThreadsPlug;
  rb2.Checked := Settings.UseNumThreadsFromProg;
  se1.Value := Settings.CountThreads;
  se1.Enabled := rb1.Checked;
  //se2.Value := Settings.NumUsualSect;
  //se3.Value := Settings.NumProxySect;
  //chk1.Checked := Settings.SubstituteProxySection;

  chk5.Checked := Settings.UsePremium;
  lbl3.Enabled := chk5.Checked;
  lbl4.Enabled := chk5.Checked;
  edt1.Enabled := chk5.Checked;
  edt2.Enabled := chk5.Checked;
  edt1.Text := Settings.LoginPremium;
  edt2.Text := Settings.PasswordPremium;

  Time := Settings.TimeRecognition div 1000;
  min := Time div 60;
  sec := Time mod 60;
  cbb1.ItemIndex := min;
  cbb2.ItemIndex := sec;
  cbb3.ItemIndex := Settings.MethodRecognition;

  rb3.Checked := Settings.UseAntigateKey;
  rb4.Checked := Settings.UseAntigateKeyFromProg;
  edt3.Text := Settings.AntigateKey;
  edt6.Text := Settings.RecognitionProg;
  edt4.Text := Settings.CapIniFile;
  edt5.Text := Settings.CatalogLetters;

  cbb3Change(self);

  pgc2.TabIndex := Settings.RecPControl;
  if pgc2.TabIndex = 0 then
    pgc2.ActivePage := ts7;
  if pgc2.TabIndex = 1 then
    pgc2.ActivePage := ts9;

  chk2.Checked := Settings.phrase;
  chk3.Checked := Settings.regsense;
  chk4.Checked := Settings.calc;
  cbb4.ItemIndex := Settings.numeric;
  se4.Value := Settings.min_len;
  se5.Value := Settings.max_len;

  lbl7.Caption := 'Plugin: ' + PluginName;
  lbl8.Caption := 'Service: ' + ServiceName;
  lbl9.Caption := 'Version: ' + GetPluginVersion;
  lbl10.Caption := 'Developer: ' + Author;
  lbl11.Caption := 'E-mail: ' + EmailAuthor;
  lbl6.Caption := 'Site: ' + SiteAuthor;

  if PremiumContent = false then
    PageControl1.Pages[1].TabVisible := false;

  if RecognitionUse = false then
    PageControl1.Pages[2].TabVisible := false;

  if PremiumContent then
  begin
    if RecognitionUse then
    begin
      PageControl1.TabIndex := Settings.MainPControl;
      if PageControl1.TabIndex = 0 then
        PageControl1.ActivePage :=ts0;
      if PageControl1.TabIndex = 1 then
        PageControl1.ActivePage := ts1;
      if PageControl1.TabIndex = 2 then
        PageControl1.ActivePage := ts2;
      if PageControl1.TabIndex = 3 then
        PageControl1.ActivePage := ts3;
    end
    else
    begin
      if Settings.MainPControl < 3 then
        PageControl1.TabIndex := Settings.MainPControl;
      if PageControl1.TabIndex = 0 then
        PageControl1.ActivePage := ts0;
      if PageControl1.TabIndex = 1 then
        PageControl1.ActivePage := ts1;
      if PageControl1.TabIndex = 2 then
        PageControl1.ActivePage := ts3;
      if PageControl1.TabIndex = 3 then
        PageControl1.ActivePage := ts3;
    end;
  end
  else
  begin
    if RecognitionUse then
    begin
      if Settings.MainPControl < 3 then
        PageControl1.TabIndex := Settings.MainPControl;
      if PageControl1.TabIndex = 0 then
        PageControl1.ActivePage := ts0;
      if PageControl1.TabIndex = 1 then
        PageControl1.ActivePage := ts2;
      if PageControl1.TabIndex = 2 then
        PageControl1.ActivePage := ts3;
      if PageControl1.TabIndex = 3 then
        PageControl1.ActivePage := ts3;
    end
    else
    begin
      if Settings.MainPControl < 2 then
        PageControl1.TabIndex := Settings.MainPControl;
      if PageControl1.TabIndex = 0 then
        PageControl1.ActivePage := ts0;
      if PageControl1.TabIndex = 1 then
        PageControl1.ActivePage := ts3;
      if PageControl1.TabIndex = 2 then
        PageControl1.ActivePage := ts3;
      if PageControl1.TabIndex = 3 then
        PageControl1.ActivePage := ts3;
    end;
  end;

  try
  //set_reginteger('Transfer.ServerPort',port);
  se8.Value:=vars_global.myport;
  se9.Value:=vars_global.up_band_allow;//strtointdef(Edit_opt_tran_upband.text,0);
  se10.Value:=vars_global.down_band_allow;//strtointdef(Edit_opt_tran_dnband.text,0);
  chk_opt_tran_inconidle.checked:=vars_global.check_opt_tran_inconidle_checked;
  se6.Value:=vars_global.limite_upload;//strtointdef(Edit_opt_tran_limup.text,4);
  se7.Value:=vars_global.max_ul_per_ip;//strtointdef(Edit_opt_tran_upip.text,3);
  se1.Value:=vars_global.max_dl_allowed;//strtointdef(Edit_opt_tran_limdn.text,MAXNUM_ACTIVE_DOWNLOADS);
  except
  end;
                                                         
  tmr1.Enabled:=true;

  try
    //Icon.LoadFromResourceName(hInstance, 'Icon_1');
    Icon.Handle := LoadIcon(hInstance, 'Icon_1');
  except
  end;
end;

procedure TfDllForm.tmr1Timer(Sender: TObject);
begin
  tmr1.Enabled:=false;
//  Translate;
//  GroupBox2.Caption:=Language;
end;

procedure TfDllForm.chk5Click(Sender: TObject);
begin
  lbl3.Enabled := chk5.Checked;
  lbl4.Enabled := chk5.Checked;
  edt1.Enabled := chk5.Checked;
  edt2.Enabled := chk5.Checked;
end;

procedure TfDllForm.rb1Click(Sender: TObject);
begin
se1.Enabled := rb1.Checked;
end;

procedure TfDllForm.rb2Click(Sender: TObject);
begin
se1.Enabled := rb1.Checked;
end;

procedure TfDllForm.btn4Click(Sender: TObject);
begin
if dlgOpen1.Execute then
    edt4.Text := (dlgOpen1.FileName);
end;

procedure TfDllForm.btn5Click(Sender: TObject);
begin
edt5.Text := BrowserFolder(Handle);
end;

procedure TfDllForm.btn6Click(Sender: TObject);
begin
if dlgOpen1.Execute then
    edt6.Text := (dlgOpen1.FileName);
end;

procedure TfDllForm.btn3Click(Sender: TObject);
var
  flags, headers, TargetFrameName, PostData: OLEVariant;
  url: OLEVariant;
begin
  Browser := CoInternetExplorer.Create;
(Browser.Get_Application as IWebBrowserApp)
  .Visible := true;
  flags := '0';
  TargetFrameName := '';
  PostData := '';
  if Trim(UrlRefPremium) <> '' then
    headers := 'Referer: ' + UrlRefPremium + #10 + #13;
  url:=UrlSalePremium;
  Browser.Navigate2(url, flags, TargetFrameName, PostData, headers);
end;

procedure TfDllForm.lbl11Click(Sender: TObject);
var
  em_subject, em_body, em_mail: string;
begin
  em_subject := 'This is the subject line ';
  em_body := ' Message body text goes here';
  em_mail := 'mailto:' + EmailAuthor + '?subject=' + em_subject + '&body=' +
    em_body;
  ShellExecute(0, 'open', PChar(em_mail), nil, nil, SW_SHOWNORMAL);
end;

procedure TfDllForm.lbl6Click(Sender: TObject);
begin
  if pos('http://', SiteAuthor) > 0 then
    ShellExecute(0, 'open', PChar(SiteAuthor), NIL, NIL, SW_SHOWNORMAL)
  else
    ShellExecute(0, 'open', PChar('http://' + SiteAuthor), NIL, NIL,
      SW_SHOWNORMAL);
end; 

end.



