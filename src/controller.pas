unit controller;

interface

uses
  System.Classes, class_.util, IdCustomHTTPServer, IdGlobal, ObjAuto;

type
  TController = class(TInterfacedPersistent)
  private
    class var fCount : Integer;

    fRequestInfo : TIdHTTPRequestInfo;
    fResponseInfo: TIdHTTPResponseInfo;


    function getRequestInfo: TIdHTTPRequestInfo;
    function getResponseInfo: TIdHTTPResponseInfo;
    function getRequestBody: String;
    function getQueryParams:TStrings;
  protected
    class function addCount : Integer;
  public
    class function getCount : Integer;

    procedure setRequestInfo(RequestInfo: TIdHTTPRequestInfo);
    procedure setResponseInfo(ResponseInfo: TIdHTTPResponseInfo);

    function execMethod(MethodName : String; parametes : TArrayValue) : variant;
    function QueryParamByName(param : String) : variant;

  published
      property RequestInfo : TIdHTTPRequestInfo  read getRequestInfo ;
      property ResponseInfo: TIdHTTPResponseInfo read getResponseInfo;
      property RequestBody : String              read getRequestBody ;
      property QueryParams : TStrings            read getQueryParams ;
  end;

implementation

uses
  System.SysUtils, System.Rtti, HTTPServer;

{ TController }
class function TController.addCount: Integer;
begin
  inc(fCount);
  result := fCount;
end;

function TController.execMethod(MethodName : String; parametes : TArrayValue) : variant;
var
  MethodHeader: PMethodInfoHeader;
begin
  MethodHeader := GetMethodInfo(self, MethodName);

  if not(Assigned(MethodHeader)) then
  begin
    getResponseInfo.ResponseNo := 500;
    getResponseInfo.ContentText := 'Metodo '+MethodName+ ' não localizado!';
    Exit;
  end;

  result := ObjectInvoke(self, MethodHeader,[], parametes);
end;

class function TController.getCount: Integer;
begin
  result := fCount;
end;

function TController.getQueryParams: TStrings;
begin
  result := RequestInfo.Params;
end;

function TController.getRequestBody: String;
begin
  RequestInfo.PostStream.Position := 0;
  result := ReadStringFromStream(RequestInfo.PostStream, -1, IndyTextEncoding_UTF8);
end;

function TController.getRequestInfo: TIdHTTPRequestInfo;
begin
  result := fRequestInfo; //THTTPServer.getInstance.RequestInfo;
end;

function TController.getResponseInfo: TIdHTTPResponseInfo;
begin
  result := fResponseInfo; //THTTPServer.getInstance.ResponseInfo;
end;

function TController.QueryParamByName(param: String): variant;
var
  i : integer;
  v_param : String;
begin
  result := '';
  for v_param in QueryParams do
  begin
    if (UpperCase(v_param.Split(['='])[0].trim()) = UpperCase(param)) then
    begin
      result := v_param.Split(['='])[1].trim();

      if (upperCase(result) = upperCase('NULL')) then
        result := EmptyStr;

      Break;
    end;
  end;
end;

procedure TController.setRequestInfo(RequestInfo: TIdHTTPRequestInfo);
begin
  fRequestInfo := RequestInfo;
end;

procedure TController.setResponseInfo(ResponseInfo: TIdHTTPResponseInfo);
begin
  fResponseInfo := ResponseInfo;
end;

initialization
  TController.fCount := 0;
  RegisterClass(TController);

finalization
  UnRegisterClass(TController);

end.
