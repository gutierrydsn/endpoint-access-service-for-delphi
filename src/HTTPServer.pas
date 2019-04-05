unit HTTPServer;

interface

uses
  IdHTTPServer, IdContext, IdCustomHTTPServer, System.Classes, System.Types,
  System.SysUtils, IdGlobal, IdGlobalProtocols,idMultipartFormData,
  IdCoderQuotedPrintable, IdCoderMIME, IdHeaderList, System.IOUtils;
type
  TRequestEvent = function (AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo) : Boolean of object;

  THTTPServer = class(TIdHTTPServer)
    private
      fProcessing            : boolean;
      fPathResource          : String;
      fRequestInfo           : TIdHTTPRequestInfo;
      fResponseInfo          : TIdHTTPResponseInfo;
      fAllowAllCors          : Boolean;
      fonEstablishConnection : TRequestEvent;

      procedure Connect(AContext: TIdContext);
      procedure CommandGet(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
      procedure CommandOther(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

      class var instance : THTTPServer;
      function isResource(ARequestInfo: TIdHTTPRequestInfo;
        AResponseInfo: TIdHTTPResponseInfo): Boolean;
      function getContentType(sExt : String): String;
      function getResFile(sFile : String) : String;

      procedure allowCors;
      procedure validEstablishConnection(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    public
      constructor Create(AOwner: TComponent);reintroduce;
      destructor Destroy; override;
      
      class function getInstance() : THTTPServer;

      function getLocalServer : String;
    published
      property AllowAllCors          : Boolean             read fAllowAllCors          write fAllowAllCors;
      property PathResource          : String              read fPathResource          write fPathResource;
      property RequestInfo           : TIdHTTPRequestInfo  read fRequestInfo           ;
      property ResponseInfo          : TIdHTTPResponseInfo read fResponseInfo          ;
      property onEstablishConnection : TRequestEvent       read fonEstablishConnection write fonEstablishConnection;
  end;

resourceString
  FILE_INDEX = '/index.html';
  DEFAULT_PATH_RESOURCES = 'resource\';

implementation

uses
  routes;

procedure THTTPServer.allowCors;
begin
  if not(allowAllCors) then
    exit;

  fResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin','*');
  fResponseInfo.CustomHeaders.Values['origin']                           := '*';
  fResponseInfo.CustomHeaders.Values['Access-Control-Allow-Headers']     := '*';
  fResponseInfo.CustomHeaders.Values['Access-Control-Expose-Headers']    := '*';
  fResponseInfo.CustomHeaders.Values['Access-Control-Request-Method']    := '*';
  fResponseInfo.CustomHeaders.Values['Access-Control-Request-Headers']   := '*';
  fResponseInfo.CustomHeaders.Values['Access-Control-Allow-Credentials'] := 'true';
  fResponseInfo.CustomHeaders.Values['Access-Control-Allow-Methods']     := '*';
end;

procedure THTTPServer.CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin

  while (fProcessing) do
    Sleep(100);

  fProcessing := true;
  try
    if (isResource(ARequestInfo, AResponseInfo)) then
      exit;

    fRequestInfo  := ARequestInfo;
    fResponseInfo := AResponseInfo;

    AllowCors();
    validEstablishConnection(AContext, ARequestInfo, AResponseInfo);

    AResponseInfo.ContentText := TRoutes.getInstance.endpoint(ARequestInfo,AResponseInfo);
  finally
    fProcessing := false;
  end;
end;

procedure THTTPServer.CommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  while (fProcessing) do
    Sleep(100);

  fProcessing := true;
  try
    fRequestInfo  := ARequestInfo;
    fResponseInfo := AResponseInfo;

    AllowCors();

    if (ARequestInfo.Command = 'OPTIONS') then
    begin
      AResponseInfo.ResponseNo := 204;
      exit;
    end;

    validEstablishConnection(AContext, ARequestInfo, AResponseInfo);
    AResponseInfo.ContentText := TRoutes.getInstance.endpoint(ARequestInfo,AResponseInfo);
  finally
    fProcessing := false;
  end;
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
    
  self.OnConnect      := Connect;
  self.OnCommandGet   := CommandGet;
  self.OnCommandOther := CommandOther;

  fPathResource := DEFAULT_PATH_RESOURCES;
end;

destructor THTTPServer.Destroy;
begin
  instance := nil;
  inherited;
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

function THTTPServer.getResFile(sFile: String): String;
var
  tempFile : String;
begin
  sFile := ExtractFileName(sFile.Replace('/','\'));

  tempFile := sFile.Replace('.', '_')
                   .Replace('-', '_')
                   .Replace('/', EmptyStr)
                   .Replace('\', EmptyStr);

  result := tempFile;
end;

function THTTPServer.isResource(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo) : Boolean;
var
  path   : String;
  sExt   : String;
  isRes  : Boolean;
  resFile: String;
begin
  path := ARequestInfo.URI;
  if (path = '\') or (path = '/') then
    path := FILE_INDEX;

  sExt := ExtractFileExt(path);
  if (sExt.IsEmpty) then
    exit(false);

  {$IF DEFINED(ANDROID) OR (DEFINED(IOS))}
    path := TPath.GetDocumentsPath + PathDelim + PathResource + path;
  {$ELSE}
    path := System.SysUtils.GetCurrentDir + '/'  + PathResource + path;
  {$ENDIF}

  isRes := UpperCase(ExtractFileExt(PathResource)) = '.RES';
  if (not(isRes) and Not(FileExists(path))) then
    exit;

  try
    AResponseInfo.ContentType := getContentType(sExt);
    if (isRes) then
      begin
        resFile := getResFile(path);
        AResponseInfo.ContentStream  := TResourceStream.Create(HInstance, resFile, RT_RCDATA);
      end
    else
      begin
        AResponseInfo.ContentStream := TFileStream.Create(path, fmOpenRead);
      end;

    result := true;
  except
    result := false;
  end;
end;

procedure THTTPServer.validEstablishConnection(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  if Assigned(onEstablishConnection) and not(onEstablishConnection(AContext, ARequestInfo, AResponseInfo))then
    raise Exception.Create('Connection denied');
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
