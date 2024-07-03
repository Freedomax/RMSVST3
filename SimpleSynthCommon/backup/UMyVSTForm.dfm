object FormMyVST: TFormMyVST
  Left = 0
  Height = 338
  Top = 0
  Width = 651
  BorderStyle = bsNone
  Caption = 'FormMyVST'
  ClientHeight = 338
  ClientWidth = 651
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  LCLVersion = '3.99.0.0'
  Scaled = False
  OnCreate = FormCreate
  object Label1: TLabel
    Left = 32
    Height = 16
    Top = 48
    Width = 34
    Caption = 'Cutoff'
  end
  object Label2: TLabel
    Left = 32
    Height = 16
    Top = 176
    Width = 37
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 32
    Height = 16
    Top = 80
    Width = 62
    Caption = 'Resonance'
  end
  object Label4: TLabel
    Left = 32
    Height = 16
    Top = 112
    Width = 67
    Caption = 'Pulse Width'
  end
  object ScrollBar1: TScrollBar
    Left = 136
    Height = 21
    Top = 48
    Width = 265
    PageSize = 0
    TabOrder = 0
    OnChange = ScrollBar1Change
  end
  object ScrollBar2: TScrollBar
    Left = 136
    Height = 21
    Top = 80
    Width = 265
    PageSize = 0
    TabOrder = 1
    OnChange = ScrollBar1Change
  end
  object ScrollBar3: TScrollBar
    Left = 136
    Height = 21
    Top = 112
    Width = 265
    PageSize = 0
    TabOrder = 2
    OnChange = ScrollBar1Change
  end
  object Button1: TButton
    Left = 160
    Height = 25
    Top = 167
    Width = 75
    Caption = 'Set Prgm 1'
    TabOrder = 3
    OnClick = Button1Click
  end
end
