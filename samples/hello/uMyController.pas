unit uMyController;

interface
uses System.SysUtils,System.Classes, controller, System.Rtti;

type

  {$METHODINFO ON}
  MyController = class (TController)
  public
    function ping : String;
    function hello : String;
    function helloWithParam(param : String; parami : integer) : String;
    function helloWithAllParam(param1 : String; param2 : integer; param3 : String; param4 : String) : String;
    function helloWithParamInt(param: integer): String;
  end;
  {$METHODINFO OFF}

implementation

function MyController.hello: String;
begin
  result := 'Hello!';
end;


function MyController.helloWithAllParam(param1: String; param2: integer; param3,param4: String): String;
begin
  result := 'ok';
end;

function MyController.helloWithParam(param: String;parami : integer): String;
begin
  result := 'Hello '+ param + ' - ' + parami.ToString +'! ';
end;

function MyController.helloWithParamInt(param: integer): String;
begin
  result := 'Hello '+ param.ToString ;
end;


function MyController.ping: String;
begin
  result := 'OK';
end;

initialization
  RegisterClass(MyController);

finalization
  UnRegisterClass(MyController);
end.
