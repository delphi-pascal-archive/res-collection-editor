object EditForm: TEditForm
  Left = 632
  Top = 174
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Editeur ResCollection'
  ClientHeight = 378
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 12
    Width = 97
    Height = 13
    Caption = 'Nom de la ressource'
  end
  object Label2: TLabel
    Left = 12
    Top = 68
    Width = 73
    Height = 13
    Caption = 'ResourceString'
  end
  object Label5: TLabel
    Left = 220
    Top = 12
    Width = 19
    Height = 13
    Caption = 'Tag'
  end
  object EditName: TEdit
    Left = 12
    Top = 32
    Width = 161
    Height = 21
    TabOrder = 0
  end
  object EditResString: TEdit
    Left = 12
    Top = 88
    Width = 437
    Height = 21
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 12
    Top = 132
    Width = 441
    Height = 197
    Caption = ' Resource bitmap ou stream '
    TabOrder = 3
    object Label4: TLabel
      Left = 12
      Top = 96
      Width = 377
      Height = 32
      AutoSize = False
      Caption = 
        'S'#233'lectionnez le type de ressource.'#13'Si "aucune ressource" est s'#233'l' +
        'ectionn'#233', la ressource existante sera supprim'#233'e.'
      WordWrap = True
    end
    object Label3: TLabel
      Left = 12
      Top = 72
      Width = 19
      Height = 13
      Caption = 'OU'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ComboBox1: TComboBox
      Left = 88
      Top = 131
      Width = 253
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
    end
    object OkWithResBtn: TButton
      Left = 12
      Top = 160
      Width = 413
      Height = 25
      Caption = 'Pour charger la ressource et valider, cliquer ici'
      TabOrder = 1
      OnClick = OkWithResBtnClick
    end
    object OkWithOutResBtn: TButton
      Left = 8
      Top = 32
      Width = 417
      Height = 25
      Caption = 
        'Pour ne pas ajouter de ressource ou ne pas modifier la ressource' +
        ' existante, cliquer ici'
      TabOrder = 2
      OnClick = OkWithOutResBtnClick
    end
  end
  object CancelBtn: TButton
    Left = 180
    Top = 344
    Width = 75
    Height = 25
    Caption = 'Annuler'
    ModalResult = 2
    TabOrder = 4
  end
  object EditTag: TEdit
    Left = 220
    Top = 32
    Width = 101
    Height = 21
    TabOrder = 1
    OnExit = EditTagExit
  end
  object OpenDialog1: TOpenDialog
    Left = 376
    Top = 20
  end
end
