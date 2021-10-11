object MainForm: TMainForm
  Left = 224
  Top = 132
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Res Collection'
  ClientHeight = 442
  ClientWidth = 930
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object AddResBtn: TButton
    Left = 8
    Top = 408
    Width = 97
    Height = 28
    Caption = 'Add'
    TabOrder = 5
    OnClick = AddResBtnClick
  end
  object ResGrid: TDrawGrid
    Left = 8
    Top = 8
    Width = 497
    Height = 393
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
    TabOrder = 0
    OnDblClick = ResGridDblClick
    OnDrawCell = ResGridDrawCell
    ColWidths = (
      41
      118
      44
      170
      89)
  end
  object DeleteResBtn: TButton
    Left = 216
    Top = 408
    Width = 97
    Height = 28
    Caption = 'Delete'
    TabOrder = 2
    OnClick = DeleteResBtnClick
  end
  object ModifyResBtn: TButton
    Left = 112
    Top = 408
    Width = 97
    Height = 28
    Caption = 'Modify'
    TabOrder = 4
    OnClick = ModifyResBtnClick
  end
  object MoveBtn: TButton
    Left = 320
    Top = 408
    Width = 97
    Height = 28
    Caption = 'Replace'
    TabOrder = 3
    OnClick = MoveBtnClick
  end
  object GroupBox1: TGroupBox
    Left = 512
    Top = 0
    Width = 409
    Height = 401
    Caption = ' View resource: double-click on the row of the grid  '
    TabOrder = 1
    DesignSize = (
      409
      401)
    object Image1: TImage
      Left = 8
      Top = 24
      Width = 393
      Height = 369
      Center = True
      Proportional = True
      Visible = False
    end
    object RichEdit1: TRichEdit
      Left = 8
      Top = 24
      Width = 393
      Height = 369
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      Visible = False
    end
    object StopSoundBtn: TButton
      Left = -30
      Top = 29
      Width = 208
      Height = 31
      Anchors = [akTop, akRight]
      Caption = 'Stopper lecture'
      TabOrder = 1
      Visible = False
      OnClick = StopSoundBtnClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 64
    Top = 24
  end
  object MainMenu1: TMainMenu
    Left = 28
    Top = 24
    object Fichier1: TMenuItem
      Caption = 'File'
      object MINewFile: TMenuItem
        Caption = 'New'
        OnClick = MINewFileClick
      end
      object MIOpenResFile: TMenuItem
        Caption = 'Open'
        OnClick = MIOpenResFileClick
      end
      object MISaveResFile: TMenuItem
        Caption = 'Clear'
        OnClick = MISaveResFileClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object MIQuit: TMenuItem
        Caption = 'Exit'
        OnClick = MIQuitClick
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 96
    Top = 24
  end
end
