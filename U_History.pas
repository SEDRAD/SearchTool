{
  SearchTool
  Copyright (C) 2026 SEDRAD

  This Source Code Form is subject to the terms of the
  Mozilla Public License, v. 2.0. If a copy of the MPL was not
  distributed with this file, You can obtain one at
  https://mozilla.org/MPL/2.0/.
}

unit U_History;

interface

uses
  System.SysUtils, System.IniFiles,
  Vcl.StdCtrls,
  U_Language;

const
  MAX_HISTORY = 15;

function GetIniFileName: string;
procedure LoadComboHistory(const Section: string; Combo: TComboBox);
procedure AddComboHistory(const Section: string; Combo: TComboBox);
function LoadLanguage: TAppLanguage;
procedure SaveLanguage(ALanguage: TAppLanguage);

implementation

function GetIniFileName: string;
begin
  Result := ChangeFileExt(ParamStr(0), '.ini');
end;

procedure SaveComboHistory(const Section: string; Combo: TComboBox);
var
  Ini: TIniFile;
  I: Integer;
begin
  Ini := TIniFile.Create(GetIniFileName);
  try
    Ini.EraseSection(Section);
    Ini.WriteInteger(Section, 'Count', Combo.Items.Count);

    for I := 0 to Combo.Items.Count - 1 do
      Ini.WriteString(Section, 'Item' + IntToStr(I), Combo.Items[I]);
  finally
    Ini.Free;
  end;
end;

procedure LoadComboHistory(const Section: string; Combo: TComboBox);
var
  Ini: TIniFile;
  I, Count: Integer;
  S: string;
begin
  Combo.Items.BeginUpdate;
  try
    Combo.Items.Clear;

    Ini := TIniFile.Create(GetIniFileName);
    try
      Count := Ini.ReadInteger(Section, 'Count', 0);
      if Count > MAX_HISTORY then
        Count := MAX_HISTORY;

      for I := 0 to Count - 1 do
      begin
        S := Trim(Ini.ReadString(Section, 'Item' + IntToStr(I), ''));
        if S <> '' then
          Combo.Items.Add(S);
      end;
    finally
      Ini.Free;
    end;

    if Combo.Items.Count > 0 then
      Combo.ItemIndex := 0;
  finally
    Combo.Items.EndUpdate;
  end;
end;

procedure AddComboHistory(const Section: string; Combo: TComboBox);
var
  S: string;
  I: Integer;
begin
  S := Trim(Combo.Text);
  if S = '' then
    Exit;

  I := Combo.Items.IndexOf(S);
  if I >= 0 then
    Combo.Items.Delete(I);

  Combo.Items.Insert(0, S);

  while Combo.Items.Count > MAX_HISTORY do
    Combo.Items.Delete(Combo.Items.Count - 1);

  Combo.ItemIndex := 0;
  SaveComboHistory(Section, Combo);
end;

function LoadLanguage: TAppLanguage;
var
  Ini: TIniFile;
  S: string;
begin
  Result := lngAuto;
  Ini := TIniFile.Create(GetIniFileName);
  try
    S := LowerCase(Trim(Ini.ReadString('Settings', 'Language', 'Auto')));

    if S = 'french' then
      Result := lngFrench
    else if S = 'english' then
      Result := lngEnglish;
  finally
    Ini.Free;
  end;
end;

procedure SaveLanguage(ALanguage: TAppLanguage);
var
  Ini: TIniFile;
  S: string;
begin
  case ALanguage of
    lngFrench:  S := 'French';
    lngEnglish: S := 'English';
  else
    S := 'Auto';
  end;

  Ini := TIniFile.Create(GetIniFileName);
  try
    Ini.WriteString('Settings', 'Language', S);
  finally
    Ini.Free;
  end;
end;

end.
