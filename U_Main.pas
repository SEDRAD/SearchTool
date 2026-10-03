{
  SearchTool
  Copyright (C) 2026 SEDRAD

  This Source Code Form is subject to the terms of the
  Mozilla Public License, v. 2.0. If a copy of the MPL was not
  distributed with this file, You can obtain one at
  https://mozilla.org/MPL/2.0/.
}

unit U_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.FileCtrl, Vcl.Clipbrd,
  U_Language, U_History, U_Search;

type
  TF_Main = class(TForm)
    PN_Search: TPanel;
    LB_Search: TLabel;
    LB_Ext: TLabel;
    LB_Path: TLabel;
    ED_Search: TEdit;
    CB_Ext: TComboBox;
    CB_Path: TComboBox;
    B_Browse: TButton;
    CK_SubFolders: TCheckBox;
    CK_Case: TCheckBox;
    B_Search: TButton;
    B_Stop: TButton;
    B_Errors: TButton;
    LV_Result: TListView;
    PN_Errors: TPanel;
    PN_ErrorHeader: TPanel;
    LB_Errors: TLabel;
    B_CloseErrors: TButton;
    MM_Errors: TMemo;
    SB_Main: TStatusBar;
    PM_Language: TPopupMenu;
    MI_LanguageAuto: TMenuItem;
    MI_LanguageFrench: TMenuItem;
    MI_LanguageEnglish: TMenuItem;
    B_Language: TButton;
    PM_Result: TPopupMenu;
    MI_OpenFile: TMenuItem;
    MI_OpenFolder: TMenuItem;
    MI_ResultSeparator: TMenuItem;
    MI_CopyPath: TMenuItem;
    PN_Preview: TPanel;
    LB_Preview: TLabel;
    MM_Preview: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure B_ErrorsClick(Sender: TObject);
    procedure B_CloseErrorsClick(Sender: TObject);
    procedure B_LanguageClick(Sender: TObject);
    procedure MI_LanguageAutoClick(Sender: TObject);
    procedure MI_LanguageFrenchClick(Sender: TObject);
    procedure MI_LanguageEnglishClick(Sender: TObject);
    procedure B_SearchClick(Sender: TObject);
    procedure B_StopClick(Sender: TObject);
    procedure B_BrowseClick(Sender: TObject);
    procedure LV_ResultDblClick(Sender: TObject);
    procedure PM_ResultPopup(Sender: TObject);
    procedure MI_OpenFileClick(Sender: TObject);
    procedure MI_OpenFolderClick(Sender: TObject);
    procedure MI_CopyPathClick(Sender: TObject);
    procedure LV_ResultSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    FAppLanguage: TAppLanguage;
    FErrorCount: Integer;
    procedure ApplyLanguage;
    procedure SetLanguage(ALanguage: TAppLanguage);
    procedure LoadSettings;
    procedure SaveCurrentHistory;
    procedure SearchResult(const FileName: string; LineNumber: Integer;
      const LineText: string);
    procedure SearchError(const FileName, ErrorText: string);
    procedure SearchProgress(const FileName: string; FilesScanned,
      ResultsFound: Integer);
    procedure ResetSearchDisplay;
    procedure AddDefaultExtensions;
    function SelectedResultFileName: string;
    procedure OpenSelectedFile;
    procedure OpenSelectedFolder;
    procedure ShowResultPreview;
  public
  end;

var
  F_Main: TF_Main;

implementation

{$R *.dfm}

procedure TF_Main.FormCreate(Sender: TObject);
begin
  LoadSettings;
  ApplyLanguage;
end;

procedure TF_Main.ApplyLanguage;
var
  S: TLanguageStrings;
begin
  S := GetLanguageStrings(FAppLanguage);

  LB_Search.Caption := S.SearchLabel;
  LB_Ext.Caption := S.ExtensionsLabel;
  LB_Path.Caption := S.PathLabel;
  CK_SubFolders.Caption := S.SubFolders;
  CK_Case.Caption := S.CaseSensitive;
  B_Search.Caption := S.SearchButton;
  B_Stop.Caption := S.StopButton;
  B_Errors.Caption := S.ErrorsButton;
  LB_Errors.Caption := S.ReadErrors;
  B_Language.Caption := S.LanguageMenu;

  LV_Result.Columns[0].Caption := S.FileColumn;
  LV_Result.Columns[1].Caption := S.LineColumn;
  LV_Result.Columns[2].Caption := S.PathColumn;

  SB_Main.Panels[0].Text := S.FilesAnalyzed;
  SB_Main.Panels[1].Text := S.Results;
  SB_Main.Panels[2].Text := S.Ready;

  MI_LanguageAuto.Caption := S.LanguageAuto;
  MI_LanguageFrench.Caption := S.LanguageFrench;
  MI_LanguageEnglish.Caption := S.LanguageEnglish;

  MI_LanguageAuto.Checked := FAppLanguage = lngAuto;
  MI_LanguageFrench.Checked := FAppLanguage = lngFrench;
  MI_LanguageEnglish.Checked := FAppLanguage = lngEnglish;
end;

procedure TF_Main.SetLanguage(ALanguage: TAppLanguage);
begin
  FAppLanguage := ALanguage;
  SaveLanguage(FAppLanguage);
  ApplyLanguage;
end;

procedure TF_Main.LoadSettings;
begin
  FAppLanguage := LoadLanguage;
  LoadComboHistory('HistoryPath', CB_Path);
  LoadComboHistory('HistoryExtensions', CB_Ext);
  AddDefaultExtensions;

  if CB_Ext.Text = '' then
    CB_Ext.Text := '*.pas;*.dpr;*.dpk;*.dfm;*.inc';
end;

procedure TF_Main.SaveCurrentHistory;
begin
  AddComboHistory('HistoryPath', CB_Path);
  AddComboHistory('HistoryExtensions', CB_Ext);
end;

procedure TF_Main.ResetSearchDisplay;
begin
  LV_Result.Items.Clear;
  MM_Preview.Clear;
  MM_Errors.Clear;
  FErrorCount := 0;
  B_Errors.Visible := False;
  PN_Errors.Visible := False;

  SB_Main.Panels[0].Text := '0';
  SB_Main.Panels[1].Text := '0';
  SB_Main.Panels[2].Text := GetLanguageStrings(FAppLanguage).Ready;
end;

procedure TF_Main.B_SearchClick(Sender: TObject);
var
  Opt: TSearchOptions;
begin
  if Trim(ED_Search.Text) = '' then
  begin
    ED_Search.SetFocus;
    Exit;
  end;

  if not DirectoryExists(Trim(CB_Path.Text)) then
  begin
    CB_Path.SetFocus;
    Exit;
  end;

  if Trim(CB_Ext.Text) = '' then
    CB_Ext.Text := '*.*';

  SaveCurrentHistory;
  ResetSearchDisplay;

  Opt.RootPath := Trim(CB_Path.Text);
  Opt.Masks := Trim(CB_Ext.Text);
  Opt.SearchText := ED_Search.Text;
  Opt.Recursive := CK_SubFolders.Checked;
  Opt.CaseSensitive := CK_Case.Checked;

  B_Search.Enabled := False;
  B_Stop.Enabled := True;
  Screen.Cursor := crHourGlass;
  try
    SearchFiles(Opt, SearchResult, SearchError, SearchProgress);
  finally
    Screen.Cursor := crDefault;
    B_Stop.Enabled := False;
    B_Search.Enabled := True;
  end;
end;

procedure TF_Main.B_StopClick(Sender: TObject);
begin
  StopSearch;
end;

procedure TF_Main.B_BrowseClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := Trim(CB_Path.Text);
  if SelectDirectory(LB_Path.Caption, '', Dir) then
    CB_Path.Text := Dir;
end;

procedure TF_Main.SearchResult(const FileName: string; LineNumber: Integer;
  const LineText: string);
var
  Item: TListItem;
begin
  Item := LV_Result.Items.Add;
  Item.Caption := ExtractFileName(FileName);
  Item.SubItems.Add(IntToStr(LineNumber));
  Item.SubItems.Add(FileName);
end;

procedure TF_Main.SearchError(const FileName, ErrorText: string);
begin
  Inc(FErrorCount);
  MM_Errors.Lines.Add(FileName + ' : ' + ErrorText);
  B_Errors.Visible := True;
  B_Errors.Caption := 'Erreurs (' + IntToStr(FErrorCount) + ')';
end;

procedure TF_Main.SearchProgress(const FileName: string; FilesScanned,
  ResultsFound: Integer);
begin
  SB_Main.Panels[0].Text := IntToStr(FilesScanned);
  SB_Main.Panels[1].Text := IntToStr(ResultsFound);
  SB_Main.Panels[2].Text := FileName;

  { Seulement pour laisser Windows rafraichir l'affichage pendant le scan. }
  Application.ProcessMessages;
end;

procedure TF_Main.AddDefaultExtensions;

  procedure AddIfMissing(const S: string);
  begin
    if CB_Ext.Items.IndexOf(S) < 0 then
      CB_Ext.Items.Add(S);
  end;

begin
  { L'historique reste en haut. Les filtres standards sont toujours disponibles. }
  AddIfMissing('*.pas;*.dpr;*.dpk;*.dfm;*.inc');
  AddIfMissing('*.c;*.h');
  AddIfMissing('*.cpp;*.cxx;*.cc;*.hpp;*.hxx');
  AddIfMissing('*.cs');
  AddIfMissing('*.java');
  AddIfMissing('*.py');
  AddIfMissing('*.js;*.ts');
  AddIfMissing('*.php');
  AddIfMissing('*.html;*.htm;*.css');
  AddIfMissing('*.xml;*.json');
  AddIfMissing('*.sql');
  AddIfMissing('*.bat;*.cmd;*.ps1');
  AddIfMissing('*.sh');
  AddIfMissing('*.txt;*.log;*.ini');
  AddIfMissing('*.*');
end;

function TF_Main.SelectedResultFileName: string;
begin
  Result := '';
  if not Assigned(LV_Result.Selected) then
    Exit;

  if LV_Result.Selected.SubItems.Count >= 2 then
    Result := LV_Result.Selected.SubItems[1];
end;

procedure TF_Main.OpenSelectedFile;
var
  FileName: string;
begin
  FileName := SelectedResultFileName;
  if (FileName = '') or not FileExists(FileName) then
    Exit;

  ShellExecute(Handle, 'open', PChar(FileName), nil,
    PChar(ExtractFilePath(FileName)), SW_SHOWNORMAL);
end;

procedure TF_Main.OpenSelectedFolder;
var
  FileName: string;
  Params: string;
begin
  FileName := SelectedResultFileName;
  if FileName = '' then
    Exit;

  Params := '/select,"' + FileName + '"';
  ShellExecute(Handle, 'open', 'explorer.exe', PChar(Params), nil, SW_SHOWNORMAL);
end;

procedure TF_Main.LV_ResultDblClick(Sender: TObject);
begin
  OpenSelectedFile;
end;

procedure TF_Main.PM_ResultPopup(Sender: TObject);
var
  HasSelection: Boolean;
begin
  HasSelection := SelectedResultFileName <> '';
  MI_OpenFile.Enabled := HasSelection;
  MI_OpenFolder.Enabled := HasSelection;
  MI_CopyPath.Enabled := HasSelection;
end;

procedure TF_Main.MI_OpenFileClick(Sender: TObject);
begin
  OpenSelectedFile;
end;

procedure TF_Main.MI_OpenFolderClick(Sender: TObject);
begin
  OpenSelectedFolder;
end;

procedure TF_Main.MI_CopyPathClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := SelectedResultFileName;
  if FileName <> '' then
    Clipboard.AsText := FileName;
end;

procedure TF_Main.LV_ResultSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
    ShowResultPreview
  else if LV_Result.Selected = nil then
    MM_Preview.Clear;
end;

procedure TF_Main.ShowResultPreview;
var
  FileName, FileText: string;
  Lines: TStringList;
  LineNumber, FirstLine, LastLine, I: Integer;
begin
  MM_Preview.Clear;

  FileName := SelectedResultFileName;
  if (FileName = '') or not FileExists(FileName) then
    Exit;

  if LV_Result.Selected.SubItems.Count < 1 then
    Exit;

  LineNumber := StrToIntDef(LV_Result.Selected.SubItems[0], 0);
  if LineNumber <= 0 then
    Exit;

  Lines := TStringList.Create;
  try
    try
      { Même décodage que le moteur de recherche. }
      FileText := LoadTextAuto(FileName, ED_Search.Text, CK_Case.Checked);
      Lines.Text := FileText;

      { 6 lignes : 2 avant, la ligne trouvée, 3 après. }
      FirstLine := LineNumber - 2;
      if FirstLine < 1 then
        FirstLine := 1;

      LastLine := FirstLine + 5;
      if LastLine > Lines.Count then
      begin
        LastLine := Lines.Count;
        FirstLine := LastLine - 5;
        if FirstLine < 1 then
          FirstLine := 1;
      end;

      MM_Preview.Lines.BeginUpdate;
      try
        for I := FirstLine to LastLine do
        begin
          if I = LineNumber then
            MM_Preview.Lines.Add('> ' + Format('%.6d', [I]) + '  ' + Lines[I - 1])
          else
            MM_Preview.Lines.Add('  ' + Format('%.6d', [I]) + '  ' + Lines[I - 1]);
        end;
      finally
        MM_Preview.Lines.EndUpdate;
      end;
    except
      on E: Exception do
        MM_Preview.Lines.Text := E.Message;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TF_Main.B_LanguageClick(Sender: TObject);
var
  P: TPoint;
begin
  P := B_Language.ClientToScreen(Point(0, B_Language.Height));
  PM_Language.Popup(P.X, P.Y);
end;

procedure TF_Main.MI_LanguageAutoClick(Sender: TObject);
begin
  SetLanguage(lngAuto);
end;

procedure TF_Main.MI_LanguageFrenchClick(Sender: TObject);
begin
  SetLanguage(lngFrench);
end;

procedure TF_Main.MI_LanguageEnglishClick(Sender: TObject);
begin
  SetLanguage(lngEnglish);
end;

procedure TF_Main.B_ErrorsClick(Sender: TObject);
begin
  PN_Errors.Visible := not PN_Errors.Visible;
end;

procedure TF_Main.B_CloseErrorsClick(Sender: TObject);
begin
  PN_Errors.Visible := False;
end;

end.
