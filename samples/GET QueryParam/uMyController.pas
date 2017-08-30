unit uMyController;

interface
uses System.SysUtils,System.Classes, controller;

type
  MyController = class (TController)
  public
    function hello : String;
  end;

implementation

function MyController.hello: String;
begin
  result := 'Hello '+ QueryParamByName('nome') +'!';
end;


initialization
  RegisterClass(MyController);

finalization
  UnRegisterClass(MyController);
end.
