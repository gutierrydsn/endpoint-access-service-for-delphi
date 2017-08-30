unit uMyController;

interface
uses System.SysUtils,System.Classes, controller,
Rest.Json, Data.DB;

type
  MyController = class (TController)
  public
    function hello : String;
    function helloWithParam(param : String) : String;
  end;

implementation

uses
  System.Rtti, System.JSON;

function MyController.hello: String;
begin
  result := 'Hello!';
end;


function MyController.helloWithParam(param: String): String;
begin
  result := 'Hello '+param+'!';
end;

initialization
  RegisterClass(MyController);

finalization
  UnRegisterClass(MyController);
end.
