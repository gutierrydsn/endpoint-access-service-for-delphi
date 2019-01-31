program SimpleStaticHTML_EAS;

{$R *.dres}

uses
  Vcl.Forms,
  uMain in '..\hello\uMain.pas' {Form1},
  uMainController in 'uMainController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
