unit HTTPServer;

interface

uses
  IdHTTPServer, IdContext, IdCustomHTTPServer, System.Classes,
  System.SysUtils, IdGlobal, IdGlobalProtocols,idMultipartFormData,
  IdCoderQuotedPrintable, IdCoderMIME, IdHeaderList;
type
  THTTPServer = class(TIdHTTPServer)
    private
      fPathResource : String;
      fRequestInfo  : TIdHTTPRequestInfo;
      fResponseInfo : TIdHTTPResponseInfo;

      procedure Connect(AContext: TIdContext);
      procedure CommandGet(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
      procedure CommandOther(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

      class var instance : THTTPServer;
    function isResource(ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo): Boolean;
    function getContentType(sExt : String): String;
    public
      constructor Create(AOwner: TComponent);reintroduce;
      
      class function getInstance() : THTTPServer;
    published
      property PathResource : String              read fPathResource write fPathResource;
      property RequestInfo  : TIdHTTPRequestInfo  read fRequestInfo ;
      property ResponseInfo : TIdHTTPResponseInfo read fResponseInfo;

  end;

resourceString
  FILE_INDEX = 'index.html';
  DEFAULT_PATH_RESOURCES = 'resource\';

implementation

uses
  routes, Vcl.Forms;

procedure THTTPServer.CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin

  if (isResource(ARequestInfo, AResponseInfo)) then
    exit;

  fRequestInfo  := ARequestInfo;
  fResponseInfo := AResponseInfo;
  AResponseInfo.ContentText := TRoutes.getInstance.endpoint(ARequestInfo,AResponseInfo);

end;

procedure THTTPServer.CommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  fRequestInfo  := ARequestInfo;
  fResponseInfo := AResponseInfo;
  AResponseInfo.ContentText := TRoutes.getInstance.endpoint(ARequestInfo,AResponseInfo);
end;

procedure THTTPServer.Connect(AContext: TIdContext);
begin
  TRoutes.getInstance;
end;

constructor THTTPServer.Create(AOwner: TComponent);
begin
  if Assigned(instance) then
    raise Exception.Create('Classe deve ser instancia via getInstance');

  inherited;
   
  instance := self;
    
  self.OnConnect     := Connect;
  self.OnCommandGet  := CommandGet;
  self.OnCommandOther:= CommandOther;

  fPathResource := DEFAULT_PATH_RESOURCES;
end;

class function THTTPServer.getInstance: THTTPServer;
begin
  if Not(Assigned(instance)) then
    THTTPServer.Create(nil);

  result := instance;
end;

function THTTPServer.isResource(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo) : Boolean;
var
  strm   : TFileStream;
  path   : String;
  sExt   : String;
begin
  path := ARequestInfo.URI;
  if (path = '\') or (path = '/') then
    path := FILE_INDEX;

  sExt := ExtractFileExt(path);

  path := ExtractFilePath(application.ExeName) + PathResource + path;

  if Not(FileExists(path)) then
    exit;

  strm := TFileStream.Create(path, fmOpenRead);
  try
    AResponseInfo.ContentType := getContentType(sExt);
    AResponseInfo.ContentStream := strm;
    result := true;
  finally
    //strm.free;
  end;
end;

function THTTPServer.getContentType(sExt : String) : String;
begin
  //; charset=UTF-8
  sExt := StringReplace(sExt, '.', '', [rfReplaceAll]);

  if  (ansicomparestr(sExt,'htm') = 0) or  (ansicomparestr(sExt,'html') = 0) then
    exit('text/html');

  if  (ansicomparestr(sExt,'js') = 0) then
    exit('text/javascript');

  if  (ansicomparestr(sExt,'css') = 0) then
    exit('text/css');

  if  (ansicomparestr(sExt,'woff') = 0) then
    exit('application/x-font-woff');

  if  (ansicomparestr(sExt,'ttf') = 0) then
    exit('application/octet-stream');

  if  (ansicomparestr(sExt,'jpeg') = 0) or (ansicomparestr(sExt,'jpg') = 0)then
    exit('image/jpeg');

  result := 'application/' + sExt;
end;

end.
