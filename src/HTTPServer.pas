unit HTTPServer;

interface

uses
  IdHTTPServer, IdContext, IdCustomHTTPServer, System.Classes,
  System.SysUtils, IdGlobal, IdGlobalProtocols,idMultipartFormData,
  IdCoderQuotedPrintable, IdCoderMIME, IdHeaderList;
type
  THTTPServer = class(TIdHTTPServer)
    private
      fRequestInfo : TIdHTTPRequestInfo;
      fResponseInfo: TIdHTTPResponseInfo;

      procedure Connect(AContext: TIdContext);
      procedure CommandGet(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
      procedure CommandOther(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

      class var instance : THTTPServer;
    public
      constructor Create(AOwner: TComponent);reintroduce;
      
      class function getInstance() : THTTPServer;
    published
      property RequestInfo : TIdHTTPRequestInfo  read fRequestInfo ;
      property ResponseInfo: TIdHTTPResponseInfo read fResponseInfo;

  end;

implementation

uses
  routes;

procedure THTTPServer.CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
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
end;

class function THTTPServer.getInstance: THTTPServer;
begin
  if Not(Assigned(instance)) then
    THTTPServer.Create(nil);

  result := instance;
end;
  
end.
