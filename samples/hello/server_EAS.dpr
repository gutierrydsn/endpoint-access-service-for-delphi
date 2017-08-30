program server_EAS;

{$R *.dres}

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  uMyController in 'uMyController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
