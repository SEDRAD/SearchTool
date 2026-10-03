object F_Main: TF_Main
  Left = 0
  Top = 0
  Caption = 'SearchTool 1.0'
  ClientHeight = 526
  ClientWidth = 1069
  Color = clBtnFace
  Constraints.MinHeight = 430
  Constraints.MinWidth = 680
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PN_Search: TPanel
    Left = 0
    Top = 0
    Width = 1069
    Height = 145
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 820
    DesignSize = (
      1069
      145)
    object LB_Search: TLabel
      Left = 16
      Top = 18
      Width = 65
      Height = 15
      Caption = 'Rechercher :'
    end
    object LB_Ext: TLabel
      Left = 16
      Top = 52
      Width = 62
      Height = 15
      Caption = 'Extensions :'
    end
    object LB_Path: TLabel
      Left = 16
      Top = 86
      Width = 48
      Height = 15
      Caption = 'Chemin :'
    end
    object ED_Search: TEdit
      Left = 96
      Top = 14
      Width = 957
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      ExplicitWidth = 708
    end
    object CB_Ext: TComboBox
      Left = 96
      Top = 48
      Width = 957
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = '*.pas;*.dpr;*.dfm;*.inc'
      Items.Strings = (
        '*.pas;*.dpr;*.dfm;*.inc'
        '*.pas'
        '*.txt;*.log;*.ini'
        '*.c;*.cpp;*.h;*.hpp'
        '*.py;*.js;*.ts;*.java')
      ExplicitWidth = 708
    end
    object CB_Path: TComboBox
      Left = 96
      Top = 82
      Width = 902
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      ExplicitWidth = 653
    end
    object B_Browse: TButton
      Left = 1006
      Top = 81
      Width = 47
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 3
      OnClick = B_BrowseClick
      ExplicitLeft = 757
    end
    object CK_SubFolders: TCheckBox
      Left = 96
      Top = 116
      Width = 112
      Height = 17
      Caption = 'Sous-dossiers'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object CK_Case: TCheckBox
      Left = 224
      Top = 116
      Width = 129
      Height = 17
      Caption = 'Respecter la casse'
      TabOrder = 5
    end
    object B_Search: TButton
      Left = 403
      Top = 111
      Width = 104
      Height = 27
      Caption = 'Rechercher'
      Default = True
      TabOrder = 6
      OnClick = B_SearchClick
    end
    object B_Stop: TButton
      Left = 515
      Top = 111
      Width = 82
      Height = 27
      Caption = 'Arr'#195#170'ter'
      Enabled = False
      TabOrder = 7
      OnClick = B_StopClick
    end
    object B_Language: TButton
      Left = 854
      Top = 111
      Width = 87
      Height = 27
      Anchors = [akTop, akRight]
      Caption = 'Langue'
      TabOrder = 8
      OnClick = B_LanguageClick
      ExplicitLeft = 605
    end
    object B_Errors: TButton
      Left = 949
      Top = 111
      Width = 104
      Height = 27
      Anchors = [akTop, akRight]
      Caption = 'Erreurs'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 9
      Visible = False
      OnClick = B_ErrorsClick
      ExplicitLeft = 700
    end
  end
  object LV_Result: TListView
    Left = 0
    Top = 145
    Width = 1069
    Height = 70
    Align = alClient
    Columns = <
      item
        Caption = 'Fichier'
        Width = 190
      end
      item
        Alignment = taRightJustify
        Caption = 'Ligne'
        Width = 65
      end
      item
        Caption = 'Chemin'
        Width = 520
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = PM_Result
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = LV_ResultDblClick
    OnSelectItem = LV_ResultSelectItem
    ExplicitWidth = 820
    ExplicitHeight = 64
  end
  object PN_Preview: TPanel
    Left = 0
    Top = 215
    Width = 1069
    Height = 128
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 209
    ExplicitWidth = 820
    object LB_Preview: TLabel
      Left = 8
      Top = 5
      Width = 38
      Height = 15
      Caption = 'Aper'#231'u'
    end
    object MM_Preview: TMemo
      Left = 0
      Top = 24
      Width = 1069
      Height = 104
      Align = alBottom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
      ExplicitWidth = 820
    end
  end
  object PN_Errors: TPanel
    Left = 0
    Top = 343
    Width = 1069
    Height = 160
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    ExplicitTop = 337
    ExplicitWidth = 820
    object PN_ErrorHeader: TPanel
      Left = 0
      Top = 0
      Width = 1069
      Height = 32
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitWidth = 820
      DesignSize = (
        1069
        32)
      object LB_Errors: TLabel
        Left = 12
        Top = 8
        Width = 100
        Height = 15
        Caption = 'Erreurs de lecture'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object B_CloseErrors: TButton
        Left = 1028
        Top = 3
        Width = 29
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'X'
        TabOrder = 0
        OnClick = B_CloseErrorsClick
        ExplicitLeft = 779
      end
    end
    object MM_Errors: TMemo
      Left = 0
      Top = 32
      Width = 1069
      Height = 128
      Align = alClient
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
      WordWrap = False
      ExplicitWidth = 820
    end
  end
  object SB_Main: TStatusBar
    Left = 0
    Top = 503
    Width = 1069
    Height = 23
    Panels = <
      item
        Text = '0'
        Width = 80
      end
      item
        Text = '0'
        Width = 80
      end
      item
        Text = 'Pr'#195#170't'
        Width = 640
      end>
    ExplicitTop = 497
    ExplicitWidth = 820
  end
  object PM_Result: TPopupMenu
    OnPopup = PM_ResultPopup
    Left = 536
    Top = 168
    object MI_OpenFile: TMenuItem
      Caption = 'Ouvrir le fichier'
      OnClick = MI_OpenFileClick
    end
    object MI_OpenFolder: TMenuItem
      Caption = 'Ouvrir le dossier'
      OnClick = MI_OpenFolderClick
    end
    object MI_ResultSeparator: TMenuItem
      Caption = '-'
    end
    object MI_CopyPath: TMenuItem
      Caption = 'Copier le chemin'
      OnClick = MI_CopyPathClick
    end
  end
  object PM_Language: TPopupMenu
    Left = 632
    Top = 168
    object MI_LanguageAuto: TMenuItem
      AutoCheck = True
      Caption = 'Automatique (syst'#195#168'me)'
      GroupIndex = 1
      RadioItem = True
      OnClick = MI_LanguageAutoClick
    end
    object MI_LanguageFrench: TMenuItem
      AutoCheck = True
      Caption = 'Fran'#195#167'ais'
      GroupIndex = 1
      RadioItem = True
      OnClick = MI_LanguageFrenchClick
    end
    object MI_LanguageEnglish: TMenuItem
      AutoCheck = True
      Caption = 'English'
      GroupIndex = 1
      RadioItem = True
      OnClick = MI_LanguageEnglishClick
    end
  end
end
