unit controller;

interface

uses
  System.Classes, class_.util, IdCustomHTTPServer, IdGlobal;

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
  Vcl.Dialogs, System.SysUtils, System.Rtti, HTTPServer;

{ TController }
class function TController.addCount: Integer;
begin
  inc(fCount);
  result := fCount;
end;

function TController.execMethod(MethodName : String; parametes : TArrayValue) : variant;
var
  ctxRtti : TRttiContext;
  typeRtti: TRttiType;
  metRtti : TRttiMethod;
begin
  ctxRtti := TRttiContext.Create;
  try
    typeRtti := ctxRtti.GetType(self.ClassType);
    metRtti  := typeRtti.GetMethod(MethodName);

    if not(Assigned(metRtti)) then
    begin
      getResponseInfo.ResponseNo := 500;
      getResponseInfo.ContentText := 'Metodo '+MethodName+ ' não localizado!';
      Exit;
    end;

    result   := metRtti.Invoke(self, parametes).ToString;
  finally
    ctxRtti.Free;
  end;
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
  result := ReadStringFromStream(RequestInfo.PostStream);
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
    if (v_param.Split(['='])[0] = param) then
    begin
      result := v_param.Split(['='])[1];

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
