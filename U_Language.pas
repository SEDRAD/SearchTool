{
  SearchTool
  Copyright (C) 2026 SEDRAD

  This Source Code Form is subject to the terms of the
  Mozilla Public License, v. 2.0. If a copy of the MPL was not
  distributed with this file, You can obtain one at
  https://mozilla.org/MPL/2.0/.
}

unit U_Language;

interface

uses
  Winapi.Windows,
  System.SysUtils;

type
  TAppLanguage = (lngAuto, lngFrench, lngEnglish);

  TLanguageStrings = record
    SearchLabel: string;
    ExtensionsLabel: string;
    PathLabel: string;
    SubFolders: string;
    CaseSensitive: string;
    SearchButton: string;
    StopButton: string;
    ErrorsButton: string;
    ReadErrors: string;
    FileColumn: string;
    LineColumn: string;
    PathColumn: string;
    Ready: string;
    FilesAnalyzed: string;
    Results: string;
    LanguageMenu: string;
    LanguageAuto: string;
    LanguageFrench: string;
    LanguageEnglish: string;
  end;

function DetectSystemLanguage: TAppLanguage;
function EffectiveLanguage(ALanguage: TAppLanguage): TAppLanguage;
function GetLanguageStrings(ALanguage: TAppLanguage): TLanguageStrings;

implementation

function DetectSystemLanguage: TAppLanguage;
var
  L: LANGID;
begin
  L := GetUserDefaultUILanguage;

  case PRIMARYLANGID(L) of
    LANG_FRENCH: Result := lngFrench;
  else
    Result := lngEnglish;
  end;
end;

function EffectiveLanguage(ALanguage: TAppLanguage): TAppLanguage;
begin
  if ALanguage = lngAuto then
    Result := DetectSystemLanguage
  else
    Result := ALanguage;
end;

function GetLanguageStrings(ALanguage: TAppLanguage): TLanguageStrings;
begin
  ALanguage := EffectiveLanguage(ALanguage);
  Result := Default(TLanguageStrings);

  case ALanguage of
    lngFrench:
      begin
        Result.SearchLabel      := 'Rechercher :';
        Result.ExtensionsLabel  := 'Extensions :';
        Result.PathLabel        := 'Chemin :';
        Result.SubFolders       := 'Sous-dossiers';
        Result.CaseSensitive    := 'Respecter la casse';
        Result.SearchButton     := 'Rechercher';
        Result.StopButton       := 'Arr' + #$00EA + 'ter';
        Result.ErrorsButton     := 'Erreurs';
        Result.ReadErrors       := 'Erreurs de lecture';
        Result.FileColumn       := 'Fichier';
        Result.LineColumn       := 'Ligne';
        Result.PathColumn       := 'Chemin';
        Result.Ready            := 'Pr' + #$00EA + 't';
        Result.FilesAnalyzed    := '0 fichier analys' + #$00E9;
        Result.Results          := '0 r' + #$00E9 + 'sultat';
        Result.LanguageMenu     := 'Langue';
        Result.LanguageAuto     := 'Automatique (syst' + #$00E8 + 'me)';
        Result.LanguageFrench   := 'Fran' + #$00E7 + 'ais';
        Result.LanguageEnglish  := 'English';
      end;

    lngEnglish:
      begin
        Result.SearchLabel      := 'Search:';
        Result.ExtensionsLabel  := 'Extensions:';
        Result.PathLabel        := 'Path:';
        Result.SubFolders       := 'Subfolders';
        Result.CaseSensitive    := 'Case sensitive';
        Result.SearchButton     := 'Search';
        Result.StopButton       := 'Stop';
        Result.ErrorsButton     := 'Errors';
        Result.ReadErrors       := 'Read errors';
        Result.FileColumn       := 'File';
        Result.LineColumn       := 'Line';
        Result.PathColumn       := 'Path';
        Result.Ready            := 'Ready';
        Result.FilesAnalyzed    := '0 files analyzed';
        Result.Results          := '0 results';
        Result.LanguageMenu     := 'Language';
        Result.LanguageAuto     := 'Automatic (system)';
        Result.LanguageFrench   := 'Fran' + #$00E7 + 'ais';
        Result.LanguageEnglish  := 'English';
      end;
  end;
end;

end.
