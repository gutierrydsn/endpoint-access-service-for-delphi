unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, HTTPServer, uMainController;

type
  TForm1 = class(TForm)
    pnl_config_porta: TPanel;
    edt_porta: TEdit;
    value_porta: TEdit;
    pnl_bottom: TPanel;
    ButtonStart: TButton;
    Panel1: TPanel;
    Edit1: TEdit;
    value_version: TEdit;
    Panel2: TPanel;
    Edit2: TEdit;
    StaticPath: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    HTTPServer : THTTPServer;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ButtonStartClick(Sender: TObject);
begin
  mainController.nrVersion := value_version.Text;

  HTTPServer.DefaultPort  := StrToIntDef(value_porta.Text, 9090);
  HTTPServer.PathResource := StaticPath.Text;
  HTTPServer.AllowAllCors := true;
  HTTPServer.Active := not(HTTPServer.Active);

  if (HTTPServer.Active) then
    ButtonStart.Caption := 'Stop'
  else
    ButtonStart.Caption := 'Start'
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  HTTPServer := THTTPServer.Create(Self);
end;

end.
