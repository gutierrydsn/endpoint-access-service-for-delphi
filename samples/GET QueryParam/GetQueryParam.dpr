program GetQueryParam;

{$R *.dres}

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uMyController in 'uMyController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
