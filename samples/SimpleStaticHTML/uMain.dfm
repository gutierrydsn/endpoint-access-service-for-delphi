object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'EAS for Delphi'
  ClientHeight = 81
  ClientWidth = 229
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnl_config_porta: TPanel
    Left = 0
    Top = 0
    Width = 229
    Height = 25
    Align = alTop
    TabOrder = 0
    object edt_porta: TEdit
      Left = 1
      Top = 1
      Width = 104
      Height = 23
      Align = alLeft
      ReadOnly = True
      TabOrder = 0
      Text = 'Porta :'
      ExplicitHeight = 21
    end
    object value_porta: TEdit
      Left = 105
      Top = 1
      Width = 123
      Height = 23
      Align = alClient
      NumbersOnly = True
      TabOrder = 1
      Text = '9090'
      ExplicitHeight = 21
    end
  end
  object pnl_bottom: TPanel
    Left = 0
    Top = 50
    Width = 229
    Height = 31
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 25
    object ButtonStart: TButton
      Left = 136
      Top = 1
      Width = 92
      Height = 29
      Align = alRight
      Caption = 'Start'
      TabOrder = 0
      OnClick = ButtonStartClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 25
    Width = 229
    Height = 25
    Align = alTop
    TabOrder = 2
    ExplicitTop = 8
    object Edit1: TEdit
      Left = 1
      Top = 1
      Width = 104
      Height = 23
      Align = alLeft
      ReadOnly = True
      TabOrder = 0
      Text = 'Version :'
      ExplicitHeight = 21
    end
    object value_version: TEdit
      Left = 105
      Top = 1
      Width = 123
      Height = 23
      Align = alClient
      NumbersOnly = True
      TabOrder = 1
      Text = '1.0.2'
      ExplicitHeight = 21
    end
  end
end
