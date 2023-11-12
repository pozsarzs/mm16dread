{ +--------------------------------------------------------------------------+ }
{ | MM16DRead v0.1 * Status reader program for MM16D device                  | }
{ | Copyright (C) 2023 Pozsár Zsolt <pozsarzs@gmail.com>                     | }
{ | frmmain.pas                                                              | }
{ | Main form                                                                | }
{ +--------------------------------------------------------------------------+ }

//   This program is free software: you can redistribute it and/or modify it
// under the terms of the European Union Public License 1.2 version.

//   This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.

unit frmmain;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Buttons, ExtCtrls, ValEdit, XMLPropStorage, StrUtils, process,
  untcommonproc;

type
  { TForm1 }
  TForm1 = class(TForm)
    Bevel1: TBevel;
    Bevel16: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Button7: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label10: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Process1: TProcess;
    Shape1: TShape;
    Shape15: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Timer1: TTimer;
    ValueListEditor1: TValueListEditor;
    procedure Button7Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label9MouseEnter(Sender: TObject);
    procedure Label9MouseLeave(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1:   TForm1;
  inifile: string;

const
  CNTNAME: string = 'MM16D';
  CNTVER:  string = '0.1.0';
  H:       string = 'H ';
  M:       string = 'M ';

resourcestring
  MESSAGE01 = 'Cannot read configuration file!';
  MESSAGE02 = 'Cannot write configuration file!';
  MESSAGE03 = 'Cannot read data from this URL!';
  MESSAGE04 = 'Not compatible controller!';
  MESSAGE05 = 'name';
  MESSAGE06 = 'value';
  MESSAGE07 = 'device';
  MESSAGE08 = 'software version';
  MESSAGE09 = 'MAC address';
  MESSAGE10 = 'IP address';
  MESSAGE11 = 'Modbus/RTU client UID';
  MESSAGE12 = 'serial port speed [baud]';
  MESSAGE13 = 'enable/disable channels';
  MESSAGE14 = 'time-dependent heating prohibition [h]';
  MESSAGE15 = 'heating switch-on temperature [°C]';
  MESSAGE16 = 'heating switch-off temperature [°C]';
  MESSAGE17 = 'minimum temperature [°C]';
  MESSAGE18 = 'maximum temperature [°C]';
  MESSAGE19 = 'minimum humidity [%]';
  MESSAGE20 = 'maximum humidity [%]';
  MESSAGE21 = 'time-dependent ventilation prohibition [h]';
  MESSAGE22 = 'high ext. temp. and time-dependent ventilation prohibition [h]';
  MESSAGE23 = 'low ext. temp. and time-dependent ventilation prohibition [h]';
  MESSAGE24 = 'external temperature upper limit [°C]';
  MESSAGE25 = 'external temperature lower limit [°C]';
  MESSAGE26 = 'lighting switch-on [h]';
  MESSAGE27 = 'lighting switch-off [h]';
  MESSAGE28 = 'ventilating switch-on [m]';
  MESSAGE29 = 'ventilating switch-off [m]';
  MESSAGE30 = 'MM17D internal relative humidity [%]';
  MESSAGE31 = 'MM17D internal temperature [°C]';
  MESSAGE32 = 'MM17D external temperature [°C]';
  MESSAGE33 = 'sign lights (0/1: red/green)';
  MESSAGE34 = 'alarm';
  MESSAGE35 = 'overcurrent breaker (1: error)';
  MESSAGE36 = 'no connection to the NTP server (1: error)';
  MESSAGE37 = 'no connection to the MM17D (1: error)';
  MESSAGE38 = 'stand-by operation mode';
  MESSAGE39 = 'growing hyphae operation mode';
  MESSAGE40 = 'growing mushroom operation mode';
  MESSAGE41 = 'manual switch (0/1: auto/manual)';
  MESSAGE42 = 'nable lamp output';
  MESSAGE43 = 'enable ventilator output';
  MESSAGE44 = 'enable heater output';
  MESSAGE45 = 'status of the lamp output';
  MESSAGE46 = 'status of the ventilator output';
  MESSAGE47 = 'status of the heater output';
  MESSAGE48 = 'internal humidity is less than requied';
  MESSAGE49 = 'internal humidity is more than requied';
  MESSAGE50 = 'internal temperature is less than requied';
  MESSAGE51 = 'internal temperature is more than requied';
  MESSAGE52 = 'MM17D green LED';
  MESSAGE53 = 'MM17D yellow LED';
  MESSAGE54 = 'MM17D red LED';
  MESSAGE55 = 'Cannot run default webbrowser!';

implementation

{$R *.lfm}
{ TForm1 }

// add URL to list
procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  line:    byte;
  thereis: boolean;
begin
  thereis := False;
  if ComboBox1.Items.Count > 0 then
    for line := 0 to ComboBox1.Items.Count - 1 do
      if ComboBox1.Items.Strings[line] = ComboBox1.Text then
        thereis := True;
  if (not thereis) and (ComboBox1.Items.Count < 64) then
    ComboBox1.Items.AddText(ComboBox1.Text);
end;

// remove URL from list
procedure TForm1.SpeedButton3Click(Sender: TObject);
var
  line: byte;
begin
  if ComboBox1.Items.Count > 0 then
  begin
    for line := 0 to ComboBox1.Items.Count - 1 do
      if ComboBox1.Items.Strings[line] = ComboBox1.Text then
        break;
    ComboBox1.Items.Delete(line);
    ComboBox1Change(Sender);
  end;
end;

// event of ComboBox1
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if length(ComboBox1.Text) = 0 then
  begin
    SpeedButton2.Enabled := False;
    SpeedButton3.Enabled := False;
    Button7.Enabled := False;
  end
  else
  begin
    SpeedButton2.Enabled := True;
    SpeedButton3.Enabled := True;
    Button7.Enabled := True;
  end;
end;

// automatic read from device
procedure TForm1.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled := false;
    Button7.Click;
    Timer1.Enabled := true;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked
    then
      Timer1.Enabled := true
    else
      Timer1.Enabled := false;
end;

// refresh displays
procedure TForm1.Button7Click(Sender: TObject);
var
  i, j, k, l: integer;
const
  t: array[1..60] of string =('name','version','mac_address','ip_address',
                              'modbus_uid','com_speed',
                              'enable_channels',
                              'hheater_disable1','hheater_disable2',
                              'hheater_on','hheater_off',
                              'htemperature_min','htemperature_max',
                              'hhumidity_min','hhumidity_max',
                              'mheater_disable1','mheater_disable2',
                              'mvent_disable1','mvent_disable2',
                              'mvent_disablehightemp1','mvent_disablehightemp2',
                              'mvent_disablelowtemp1','mvent_disablelowtemp2',
                              'mvent_hightemp','mvent_lowtemp',
                              'mheater_on','mheater_off',
                              'mtemperature_min','mtemperature_max',
                              'mhumidity_min','mhumidity_max',
                              'mlight_on','mlight_off',
                              'mvent_on','mvent_off',
                              'mm17drhint','mm17dtint','mm17dtext',
                              'signlight',
                              'alarm',
                              'breaker',
                              'errorntp','errormm17d',
                              'standby','hyphae','mushroom',
                              'manual',
                              'ena_lamp','ena_vent','ena_heater',
                              'lamp','vent','heater',
                              'rhintless','rhintmore',
                              'tintless','tintmore',
                              'mm17dgreen','mm17dyellow','mm17dred');

begin
  // clear pages
  Label3.Caption := '? %';
  Label4.Caption := '? °C';
  Label18.Caption := '? °C';
  ValueListEditor1.Cols[1].Clear;
  Memo1.Clear;
  l := 0;
  // get software information
  if getdatafromdevice(ComboBox1.Text, 0) then
  begin
    for k := 1 to 2 do
    begin
      for i := 0 to Value.Count - 1 do
      begin
        j := findpart(t[k], Value.Strings[i]);
        if j <> 0 then break;
      end;
      if j <> 0 then
      begin
        Value.Strings[i] := stringreplace(Value.Strings[i], '<' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '</' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := rmchr1(Value.Strings[i]);
        ValueListEditor1.Cells[1, k] := Value.Strings[i];
      end;
    end;
  end else
  begin
    ShowMessage(MESSAGE03);
    exit;
  end;
  // check compatibility
  if (CNTNAME = ValueListEditor1.Cells[1, 1]) and
     (CNTVER = ValueListEditor1.Cells[1, 2])
  then
    StatusBar1.Panels.Items[0].Text := ' ' + ValueListEditor1.Cells[1, 1] + ' v' + ValueListEditor1.Cells[1, 2]
  else
  begin
    ShowMessage(MESSAGE04);
    StatusBar1.Panels.Items[0].Text := '';
    exit;
  end;
  // get summary
  if getdatafromdevice(ComboBox1.Text, 0) then
  begin
    for k := 3 to 60 do
    begin
      for i := 0 to Value.Count - 1 do
      begin
        j := findpart(t[k], Value.Strings[i]);
        if j <> 0 then break;
      end;
      if j <> 0 then
      begin
        Value.Strings[i] := stringreplace(Value.Strings[i], '<' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '</' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := rmchr1(Value.Strings[i]);
        if (k = 9) or (k = 17) or (k = 19) or (k = 21) or (k = 23) then
        begin
          ValueListEditor1.Cells[1, k - 1 - l] := ValueListEditor1.Cells[1, k - 1 - l] + ' ' + Value.Strings[i];
          inc(l);
        end else
          ValueListEditor1.Cells[1, k-l] := Value.Strings[i];
      end;
    end;
  end else
  begin
    ShowMessage(MESSAGE03);
    exit;
  end;
  // K -> °C
  for i := 0 to 3 do
    ValueListEditor1.Cells[1, 9 + i] := inttostr(ValueListEditor1.Cells[1, 9 + i].ToInteger - 273);
  for i := 0 to 5 do
    ValueListEditor1.Cells[1, 19 + i] := inttostr(ValueListEditor1.Cells[1, 19 + i].ToInteger - 273);
  for i := 0 to 1 do
    ValueListEditor1.Cells[1, 32 + i] := inttostr(ValueListEditor1.Cells[1, 32 + i].ToInteger - 273);
  // display
  Label3.Caption := ValueListEditor1.Cells[1, 31] + ' %';
  Label4.Caption := ValueListEditor1.Cells[1, 32] + ' °C';
  Label18.Caption := ValueListEditor1.Cells[1, 33] + ' °C';
  // LEDs
  if ValueListEditor1.Cells[1, 53].ToBoolean
  then
    Shape3.Brush.Color:=clLime
  else
    Shape3.Brush.Color:=clGreen;
  if ValueListEditor1.Cells[1, 54].ToBoolean
  then
    Shape4.Brush.Color:=clYellow
  else
    Shape4.Brush.Color:=clOlive;
  if ValueListEditor1.Cells[1, 55].ToBoolean
  then
    Shape5.Brush.Color:=clRed
  else
    Shape5.Brush.Color:=clMaroon;
  ValueListEditor1.Cells[0, 0] := MESSAGE05;
  ValueListEditor1.Cells[1, 0] := MESSAGE06;
  // get log
  if getdatafromdevice(ComboBox1.Text, 1) then
  begin
    Memo1.Clear;
    for i := 0 to Value.Count - 1 do
      if findpart('<tr><td align=right><b>', Value.Strings[i]) <> 0 then
      begin
        Value.Strings[i] := rmchr3(Value.Strings[i]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '<tr><td align=right><b>', '', [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '</b></td><td>', #9, [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '</td></tr>', '', [rfReplaceAll]);
        Memo1.Lines.Insert(0, Value.Strings[i]);
      end;
    Memo1.SelStart := 0;
  end else
  begin
    ShowMessage(MESSAGE03);
    exit;
  end;
end;

// open homepage
procedure TForm1.Label9Click(Sender: TObject);
begin
  if length(BROWSER) > 0 then
  begin
    Process1.Executable := BROWSER;
    Process1.Parameters.Add(Label9.Caption);
    try
      Form1.Process1.Execute;
    except
      ShowMessage(MESSAGE19);
    end;
  end;
end;

procedure TForm1.Label9MouseEnter(Sender: TObject);
begin
  Label9.Font.Color := clPurple;
end;

procedure TForm1.Label9MouseLeave(Sender: TObject);
begin
  Label9.Font.Color := clBlue;
end;

// onCreate event
procedure TForm1.FormCreate(Sender: TObject);
var
  b: byte;
begin
  makeuserdir;
  getlang;
  getexepath;
  Form1.Caption := APPNAME + ' v' + VERSION;
  Label6.Caption := Form1.Caption;
  // load configuration
  inifile := untcommonproc.userdir + DIR_CONFIG + 'mm16dread.ini';
  if FileSearch('mm16dread.ini', untcommonproc.userdir + DIR_CONFIG) <> '' then
    if not loadconfiguration(inifile) then
      ShowMessage(MESSAGE01);
  for b := 0 to 63 do
    if length(urls[b]) > 0 then
      ComboBox1.Items.Add(untcommonproc.urls[b]);
  if ComboBox1.Items.Count > 0 then
  begin
    ComboBox1.ItemIndex := 0;
    Button7.Enabled := true;
    SpeedButton2.Enabled := true;
    SpeedButton3.Enabled := true;
  end;
  // others
  untcommonproc.Value := TStringList.Create;
  ValueListEditor1.Cells[0, 1] := MESSAGE07;
  ValueListEditor1.Cells[0, 2] := MESSAGE08;
  ValueListEditor1.Cells[0, 3] := MESSAGE09;
  ValueListEditor1.Cells[0, 4] := MESSAGE10;
  ValueListEditor1.Cells[0, 5] := MESSAGE11;
  ValueListEditor1.Cells[0, 6] := MESSAGE12;
  ValueListEditor1.Cells[0, 7] := MESSAGE13;
  ValueListEditor1.Cells[0, 8] := H + MESSAGE14;
  ValueListEditor1.Cells[0, 9] := H + MESSAGE15;
  ValueListEditor1.Cells[0, 10] := H + MESSAGE16;
  ValueListEditor1.Cells[0, 11] := H + MESSAGE17;
  ValueListEditor1.Cells[0, 12] := H + MESSAGE18;
  ValueListEditor1.Cells[0, 13] := H + MESSAGE19;
  ValueListEditor1.Cells[0, 14] := H + MESSAGE20;
  ValueListEditor1.Cells[0, 15] := M + MESSAGE14;
  ValueListEditor1.Cells[0, 16] := M + MESSAGE21;
  ValueListEditor1.Cells[0, 17] := M + MESSAGE22;
  ValueListEditor1.Cells[0, 18] := M + MESSAGE23;
  ValueListEditor1.Cells[0, 19] := MESSAGE24;
  ValueListEditor1.Cells[0, 20] := MESSAGE25;
  ValueListEditor1.Cells[0, 21] := M + MESSAGE15;
  ValueListEditor1.Cells[0, 22] := M + MESSAGE16;
  ValueListEditor1.Cells[0, 23] := M + MESSAGE17;
  ValueListEditor1.Cells[0, 24] := M + MESSAGE18;
  ValueListEditor1.Cells[0, 25] := M + MESSAGE19;
  ValueListEditor1.Cells[0, 26] := M + MESSAGE20;
  ValueListEditor1.Cells[0, 27] := M + MESSAGE26;
  ValueListEditor1.Cells[0, 28] := M + MESSAGE27;
  ValueListEditor1.Cells[0, 29] := M + MESSAGE28;
  ValueListEditor1.Cells[0, 30] := M + MESSAGE29;
  ValueListEditor1.Cells[0, 31] := MESSAGE30;
  ValueListEditor1.Cells[0, 32] := MESSAGE31;
  ValueListEditor1.Cells[0, 33] := MESSAGE32;
  ValueListEditor1.Cells[0, 34] := MESSAGE33;
  ValueListEditor1.Cells[0, 35] := MESSAGE34;
  ValueListEditor1.Cells[0, 36] := MESSAGE35;
  ValueListEditor1.Cells[0, 37] := MESSAGE36;
  ValueListEditor1.Cells[0, 38] := MESSAGE37;
  ValueListEditor1.Cells[0, 39] := MESSAGE38;
  ValueListEditor1.Cells[0, 40] := MESSAGE39;
  ValueListEditor1.Cells[0, 41] := MESSAGE40;
  ValueListEditor1.Cells[0, 42] := MESSAGE41;
  ValueListEditor1.Cells[0, 43] := MESSAGE42;
  ValueListEditor1.Cells[0, 44] := MESSAGE43;
  ValueListEditor1.Cells[0, 45] := MESSAGE44;
  ValueListEditor1.Cells[0, 46] := MESSAGE45;
  ValueListEditor1.Cells[0, 47] := MESSAGE46;
  ValueListEditor1.Cells[0, 48] := MESSAGE47;
  ValueListEditor1.Cells[0, 49] := MESSAGE48;
  ValueListEditor1.Cells[0, 50] := MESSAGE49;
  ValueListEditor1.Cells[0, 51] := MESSAGE50;
  ValueListEditor1.Cells[0, 52] := MESSAGE51;
  ValueListEditor1.Cells[0, 53] := MESSAGE52;
  ValueListEditor1.Cells[0, 54] := MESSAGE53;
  ValueListEditor1.Cells[0, 55] := MESSAGE54;
  ValueListEditor1.AutoSizeColumn(0);
end;

// onClose
procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  b: byte;
begin
  for b := 0 to 63 do
    untcommonproc.urls[b] := '';
  if ComboBox1.Items.Count > 0 then
    for b := 0 to ComboBox1.Items.Count - 1 do
      untcommonproc.urls[b] := ComboBox1.Items.Strings[b];
  if not saveconfiguration(inifile) then
    ShowMessage(MESSAGE02);
  untcommonproc.Value.Free;
end;

end.
