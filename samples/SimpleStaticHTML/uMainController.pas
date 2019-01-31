unit uMainController;

interface
uses System.SysUtils,System.Classes, controller;

type
  mainController = class (TController)
  public
    class var nrVersion : String;

    function version : String;
    function ping : String;
  end;

implementation

function mainController.version: String;
const
  response = '{"version" : "%s"}';
begin
  result := Format(response, [nrVersion]);
end;


function mainController.ping : String;
const
  response = '{"response" : "true"}';
begin
  result := response;
end;

initialization
  RegisterClass(mainController);

finalization
  UnRegisterClass(mainController);
end.
