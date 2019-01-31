unit HTTPServer;

interface

uses
  IdHTTPServer, IdContext, IdCustomHTTPServer, System.Classes,
  System.SysUtils, IdGlobal, IdGlobalProtocols,idMultipartFormData,
  IdCoderQuotedPrintable, IdCoderMIME, IdHeaderList, System.IOUtils;
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

      function getLocalServer : String;
    published
      property PathResource : String              read fPathResource write fPathResource;
      property RequestInfo  : TIdHTTPRequestInfo  read fRequestInfo ;
      property ResponseInfo : TIdHTTPResponseInfo read fResponseInfo;
  end;

resourceString
  FILE_INDEX = '/index.html';
  DEFAULT_PATH_RESOURCES = 'resource\';

implementation

uses
  routes;

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

function THTTPServer.getLocalServer: String;
begin
  result := 'http://127.0.0.1:' + DefaultPort.ToString;
end;

function THTTPServer.isResource(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo) : Boolean;
var
  path   : String;
  sExt   : String;
begin
  path := ARequestInfo.URI;
  if (path = '\') or (path = '/') then
    path := FILE_INDEX;

  sExt := ExtractFileExt(path);

  {$IF DEFINED(ANDROID) OR (DEFINED(IOS))}
    path := TPath.GetDocumentsPath + PathDelim + PathResource + path;
  {$ELSE}
    path := System.SysUtils.GetCurrentDir + '/'  + PathResource + path;
  {$ENDIF}

  if Not(FileExists(path)) then
    exit;

  AResponseInfo.ContentType := getContentType(sExt);
  AResponseInfo.ContentStream := TFileStream.Create(path, fmOpenRead);
  result := true;
end;

function THTTPServer.getContentType(sExt : String) : String;
begin
  //; charset=UTF-8
  sExt := StringReplace(sExt, '.', '', [rfReplaceAll]);

  if  (ansicomparestr(sExt,'htm') = 0) or  (ansicomparestr(sExt,'html') = 0) then
    exit('text/html; charset=UTF-8');

  if  (ansicomparestr(sExt,'js') = 0) then
    exit('text/javascript; charset=UTF-8');

  if  (ansicomparestr(sExt,'css') = 0) then
    exit('text/css; charset=UTF-8');

  if  (ansicomparestr(sExt,'woff') = 0) then
    exit('application/x-font-woff');

  if  (ansicomparestr(sExt,'ttf') = 0) then
    exit('application/octet-stream');

  if  (ansicomparestr(sExt,'jpeg') = 0) or (ansicomparestr(sExt,'jpg') = 0)then
    exit('image/jpeg');

  result := 'application/' + sExt;
end;

end.
