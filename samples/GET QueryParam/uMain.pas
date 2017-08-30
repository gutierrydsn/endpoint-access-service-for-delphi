unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HTTPServer, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    pnl_config_porta: TPanel;
    edt_porta: TEdit;
    value_porta: TEdit;
    pnl_bottom: TPanel;
    ButtonStart: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    HTTPServer : THTTPServer;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.ButtonStartClick(Sender: TObject);
begin
  HTTPServer.DefaultPort := StrToIntDef(value_porta.Text,9090);
  HTTPServer.Active := not(HTTPServer.Active);

  if (HTTPServer.Active) then
    ButtonStart.Caption := 'Stop'
  else
    ButtonStart.Caption := 'Start'
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  HTTPServer := THTTPServer.Create(Self);
end;

end.
