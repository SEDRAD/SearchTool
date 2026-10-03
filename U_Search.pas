{
  SearchTool
  Copyright (C) 2026 SEDRAD

  This Source Code Form is subject to the terms of the
  Mozilla Public License, v. 2.0. If a copy of the MPL was not
  distributed with this file, You can obtain one at
  https://mozilla.org/MPL/2.0/.
}

unit U_Search;

interface

uses
  System.SysUtils, System.Classes, System.Masks, Vcl.Forms;

type
  TSearchResultEvent = procedure(const FileName: string; LineNumber: Integer;
    const LineText: string) of object;
  TSearchErrorEvent = procedure(const FileName, ErrorText: string) of object;
  TSearchProgressEvent = procedure(const FileName: string; FilesScanned,
    ResultsFound: Integer) of object;

  TSearchOptions = record
    RootPath: string;
    Masks: string;
    SearchText: string;
    Recursive: Boolean;
    CaseSensitive: Boolean;
  end;

function LoadTextAuto(const FileName, SearchText: string;
  CaseSensitive: Boolean): string;
procedure ResetSearchStop;
procedure StopSearch;
function SearchStopped: Boolean;
procedure SearchFiles(const Options: TSearchOptions;
  OnResult: TSearchResultEvent; OnError: TSearchErrorEvent;
  OnProgress: TSearchProgressEvent);

implementation

var
  GStopSearch: Boolean = False;

procedure ResetSearchStop;
begin
  GStopSearch := False;
end;

procedure StopSearch;
begin
  GStopSearch := True;
end;

function SearchStopped: Boolean;
begin
  Result := GStopSearch;
end;

function MatchMaskList(const FileName, Masks: string): Boolean;
var
  L: TStringList;
  I: Integer;
  M: string;
begin
  Result := False;
  L := TStringList.Create;
  try
    L.StrictDelimiter := True;
    L.Delimiter := ';';
    L.DelimitedText := Masks;

    for I := 0 to L.Count - 1 do
    begin
      M := Trim(L[I]);
      if (M <> '') and MatchesMask(ExtractFileName(FileName), M) then
        Exit(True);
    end;
  finally
    L.Free;
  end;
end;

function ContainsText(const LineText, SearchText: string;
  CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
    Result := Pos(SearchText, LineText) > 0
  else
    Result := Pos(UpperCase(SearchText), UpperCase(LineText)) > 0;
end;

function IsValidUTF8(const Bytes: TBytes; StartIndex: Integer): Boolean;
var
  I, Need, J: Integer;
  B: Byte;
begin
  Result := False;
  I := StartIndex;

  while I < Length(Bytes) do
  begin
    B := Bytes[I];

    if B < $80 then
      Inc(I)
    else
    begin
      if (B and $E0) = $C0 then
        Need := 1
      else if (B and $F0) = $E0 then
        Need := 2
      else if (B and $F8) = $F0 then
        Need := 3
      else
        Exit;

      if I + Need >= Length(Bytes) then
        Exit;

      for J := 1 to Need do
        if (Bytes[I + J] and $C0) <> $80 then
          Exit;

      Inc(I, Need + 1);
    end;
  end;

  Result := True;
end;

function BytesToText(const Bytes: TBytes; Encoding: TEncoding;
  SkipBytes: Integer = 0): string;
begin
  if Length(Bytes) <= SkipBytes then
    Exit('');

  Result := Encoding.GetString(Bytes, SkipBytes, Length(Bytes) - SkipBytes);
end;

function LoadTextAuto(const FileName, SearchText: string;
  CaseSensitive: Boolean): string;
var
  Stream: TFileStream;
  Bytes: TBytes;
  Enc1251: TEncoding;
  TextDefault, Text1251: string;
begin
  Result := '';

  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Bytes, Stream.Size);
    if Stream.Size > 0 then
      Stream.ReadBuffer(Bytes[0], Stream.Size);
  finally
    Stream.Free;
  end;

  { UTF-8 BOM }
  if (Length(Bytes) >= 3) and
     (Bytes[0] = $EF) and (Bytes[1] = $BB) and (Bytes[2] = $BF) then
  begin
    Result := BytesToText(Bytes, TEncoding.UTF8, 3);
    Exit;
  end;

  { UTF-16 little endian BOM }
  if (Length(Bytes) >= 2) and
     (Bytes[0] = $FF) and (Bytes[1] = $FE) then
  begin
    Result := BytesToText(Bytes, TEncoding.Unicode, 2);
    Exit;
  end;

  { UTF-16 big endian BOM }
  if (Length(Bytes) >= 2) and
     (Bytes[0] = $FE) and (Bytes[1] = $FF) then
  begin
    Result := BytesToText(Bytes, TEncoding.BigEndianUnicode, 2);
    Exit;
  end;

  { UTF-8 sans BOM }
  if IsValidUTF8(Bytes, 0) then
  begin
    Result := BytesToText(Bytes, TEncoding.UTF8);
    Exit;
  end;

  { Ancien texte ANSI : essayer d'abord la page de codes Windows courante. }
  TextDefault := BytesToText(Bytes, TEncoding.Default);

  { Pour un fichier cyrillique ancien, Windows-1251 n'a souvent aucun BOM.
    Si la recherche n'existe pas avec l'ANSI courant, on essaie CP1251. }
  if ContainsText(TextDefault, SearchText, CaseSensitive) then
  begin
    Result := TextDefault;
    Exit;
  end;

  Enc1251 := TEncoding.GetEncoding(1251);
  try
    Text1251 := BytesToText(Bytes, Enc1251);
  finally
    Enc1251.Free;
  end;

  if ContainsText(Text1251, SearchText, CaseSensitive) then
    Result := Text1251
  else
    Result := TextDefault;
end;

procedure SearchOneFile(const FileName: string; const Options: TSearchOptions;
  OnResult: TSearchResultEvent; OnError: TSearchErrorEvent;
  var ResultsFound: Integer);
var
  Lines: TStringList;
  I: Integer;
  FileText: string;
begin
  Lines := TStringList.Create;
  try
    try
      FileText := LoadTextAuto(FileName, Options.SearchText,
        Options.CaseSensitive);
      Lines.Text := FileText;

      for I := 0 to Lines.Count - 1 do
      begin
        if GStopSearch then
          Exit;

        if ContainsText(Lines[I], Options.SearchText, Options.CaseSensitive) then
        begin
          Inc(ResultsFound);
          if Assigned(OnResult) then
            OnResult(FileName, I + 1, Lines[I]);
        end;
      end;
    except
      on E: Exception do
        if Assigned(OnError) then
          OnError(FileName, E.Message);
    end;
  finally
    Lines.Free;
  end;
end;

procedure SearchDirectory(const Path: string; const Options: TSearchOptions;
  OnResult: TSearchResultEvent; OnError: TSearchErrorEvent;
  OnProgress: TSearchProgressEvent; var FilesScanned, ResultsFound: Integer);
var
  SR: TSearchRec;
  FullName: string;
begin
  if GStopSearch then
    Exit;

  if FindFirst(IncludeTrailingPathDelimiter(Path) + '*', faAnyFile, SR) <> 0 then
    Exit;
  try
    repeat
      if GStopSearch then
        Exit;

      if (SR.Name = '.') or (SR.Name = '..') then
        Continue;

      FullName := IncludeTrailingPathDelimiter(Path) + SR.Name;

      if (SR.Attr and faDirectory) <> 0 then
      begin
        if Options.Recursive then
          try
            SearchDirectory(FullName, Options, OnResult, OnError,
              OnProgress, FilesScanned, ResultsFound);
          except
            on E: Exception do
              if Assigned(OnError) then
                OnError(FullName, E.Message);
          end;
      end
      else if MatchMaskList(SR.Name, Options.Masks) then
      begin
        Inc(FilesScanned);
        SearchOneFile(FullName, Options, OnResult, OnError, ResultsFound);

        if Assigned(OnProgress) then
          OnProgress(FullName, FilesScanned, ResultsFound);
      end;

      Application.ProcessMessages;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

procedure SearchFiles(const Options: TSearchOptions;
  OnResult: TSearchResultEvent; OnError: TSearchErrorEvent;
  OnProgress: TSearchProgressEvent);
var
  FilesScanned, ResultsFound: Integer;
begin
  FilesScanned := 0;
  ResultsFound := 0;
  ResetSearchStop;

  SearchDirectory(ExcludeTrailingPathDelimiter(Options.RootPath), Options,
    OnResult, OnError, OnProgress, FilesScanned, ResultsFound);
end;

end.
