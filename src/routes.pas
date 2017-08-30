unit routes;

interface

uses
  IdCustomHTTPServer, System.Rtti, class_.util, parameter,  System.Classes,
  System.JSON, System.SysUtils, System.Types;

type
  TRouteType = (rtNone,rtGET, rtPOST, rtPUT, rtDELETE);

  TListTMetodoHTTP = TArray<TRouteType>;

  TRouteTypeHelper = record helper for TRouteType
    public
      function StrToTRouteType(route_type : String) : TRouteType;
      function toString : String;
  end;

  TRoute = class
    private
      froute_type  : TRouteType;
      fendpoint    : String;
      fmethod      : String;
      fparameters  : TListParameter;
      fmethod_name : String ;
      fclass_name  : String ;

      procedure setMethod(const Value: String);
    public
      property route_type : TRouteType     read froute_type  write froute_type ;
      property endpoint   : String         read fendpoint    write fendpoint   ;
      property method     : String         read fmethod      write setMethod   ;
      property parameters : TListParameter read fparameters  ;
      property method_name: String         read fmethod_name ;
      property class_name : String         read fclass_name  ;
  end;

  TListRoutes = array of TRoute;

  TRoutes = class
    private
      froutes_get    : TListRoutes;
      froutes_post   : TListRoutes;
      froutes_put    : TListRoutes;
      froutes_delete : TListRoutes;

      class var instance : TRoutes;

      function addRoute(var list : TListRoutes; route : TRoute) : Integer;
      function getListRoutes(route_type : TRouteType) : TListRoutes;
      
      procedure loadFileConfig();
      procedure loadEndPoits(json : TJSONObject; MetodoHTTP : TRouteType);
    protected
      constructor create;

      function FindRoute(ARequestInfo: TIdHTTPRequestInfo) : TRoute; Overload;
      function FindRoute(list : TListRoutes; uri : String) : TRoute; Overload;

      function callMethod(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; route : TRoute): variant;
      function error404(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo): variant;
    public
      class function getInstance : TRoutes;
      class procedure releaseInstance;

      function endpoint(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo) : variant;
  end;

var
  ListTMetodoHTTP : TListTMetodoHTTP;

  procedure setListTMetodoHTTP;
implementation

uses
  controller, HTTPServer.response.page;

procedure setListTMetodoHTTP;
begin
  SetLength(ListTMetodoHTTP,4);

  ListTMetodoHTTP[0] := rtGET;
  ListTMetodoHTTP[1] := rtPOST;
  ListTMetodoHTTP[2] := rtPUT;
  ListTMetodoHTTP[3] := rtDELETE;
end;

{ TRoutes }
function TRoutes.addRoute(var list: TListRoutes; route: TRoute): Integer;
var
  nPos : Integer;
begin
  nPos := Length(list)+1;

  SetLength(list,nPos);
  list[nPos-1] := route;

  result := nPos;
end;

function TRoutes.callMethod(ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo; route : TRoute): variant;
var
  controller  : TObject;
begin
  controller := TClassUtil.instantiateClassViaRTTI(route.class_name);

  if Not(controller.InheritsFrom(TController))  then
    raise Exception.Create('Class must be of the type TController');

  try
    TController(controller).setRequestInfo(ARequestInfo);
    TController(controller).setResponseInfo(AResponseInfo);

    result := TController(controller).execMethod(route.method_name,route.parameters.getArray);
  finally
    FreeAndNil(controller);
  end;

end;

constructor TRoutes.create;
begin

  if Assigned(TRoutes.instance) then
    raise Exception.Create('This class can be called by the method getInstace');

  TRoutes.instance := self;
  loadFileConfig;
end;

function TRoutes.endpoint(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo): variant;
var
  route : TRoute;
begin

  route := FindRoute(ARequestInfo);

  if Assigned(route) then
    result := callMethod(ARequestInfo, AResponseInfo, route)
  else 
    result := error404(ARequestInfo, AResponseInfo);  
end;

function TRoutes.error404(ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo): variant;
begin
  result := HTTPServerResponsePage.return_404(AResponseInfo);
end;

function TRoutes.FindRoute(ARequestInfo: TIdHTTPRequestInfo): TRoute;
begin
  result := FindRoute(getListRoutes(rtNone.StrToTRouteType(ARequestInfo.Command)),ARequestInfo.URI);
end;

function TRoutes.FindRoute(list: TListRoutes; uri : String): TRoute;
var
  i, j         : Integer;
  nPassed      : Integer;
  blocks_route : TStringList;
  blocks_uri   : TStringList;
begin
  result:= nil;

  blocks_route := TStringList.Create;
  blocks_uri   := TStringList.Create;
  try
    blocks_uri.Text := uri.Replace('/',sLineBreak).Trim;
    for i := 0 to length(list)-1 do
    begin
      blocks_route.Text := list[i].endpoint.Replace('/',sLineBreak).Trim;

      if (blocks_route.Count <> blocks_uri.Count) then
        continue;

      nPassed := 0;
      for j := 0 to blocks_route.Count-1 do
      begin
        if (pos(PREFIX_PARAMETER, blocks_route[j]) = 0) and (UpperCase(blocks_route[j]) <> UpperCase(blocks_uri[j])) then
          break;

        inc(nPassed);
      end;

      if (nPassed <> blocks_uri.Count) then
        Continue;

      list[i].parameters.setParameters(uri,list[i].endpoint);
      result := list[i];
      Break;
    end;

  finally
    FreeAndNil(blocks_route);
    FreeAndNil(blocks_uri);
  end;
end;

class function TRoutes.getInstance: TRoutes;
begin
  if Not(Assigned(TRoutes.instance)) then
    TRoutes.create;

  result := TRoutes.instance;
end;

function TRoutes.getListRoutes(route_type: TRouteType): TListRoutes;
begin
  case route_type of
    rtGET   : result := froutes_get   ;
    rtPOST  : result := froutes_post  ;
    rtPUT   : result := froutes_put   ;
    rtDELETE: result := froutes_delete;
  end;
end;

procedure TRoutes.loadEndPoits(json : TJSONObject; MetodoHTTP : TRouteType);
var
  list_ep   : TJSONObject;
  i         : Integer    ;
  pair      : TJSONPair  ;
  route     : TRoute     ;
  metodo    : String     ;
begin

  metodo := MetodoHTTP.toString;
  try
    list_ep := TJSONObject(json.GetValue(metodo));
  except
    on e: exception do
    begin
      releaseInstance;
      raise Exception.Create('Error while load object ' + metodo);
    end;
  end;

  for i := 0 to list_ep.Count-1 do
  begin
    pair := TJSONPair(list_ep.Pairs[i]);
    route  := TRoute.Create;
    route.route_type := MetodoHTTP;
    route.endpoint   := pair.JsonString.ToString.Replace('"','');
    route.method     := pair.JsonValue.ToString.Replace('"','');

    case MetodoHTTP of
      rtGET    : addRoute(froutes_get   ,route);
      rtPOST   : addRoute(froutes_post  ,route);
      rtPUT    : addRoute(froutes_put   ,route);
      rtDELETE : addRoute(froutes_delete,route);
    end;
  end;
end;

procedure TRoutes.loadFileConfig;
var
  list   : TStringList;
  json   : TJSONObject;
  i      : integer;
begin
  list := TStringList.Create;
  try
    list.LoadFromStream(TResourceStream.Create(HInstance,'routes',RT_RCDATA));

    json := TJSONObject(TJSONObject.ParseJSONValue('{'+list.Text+'}'));

    for i:=0 to Length(ListTMetodoHTTP)-1 do
      loadEndPoits(json,ListTMetodoHTTP[i]);

  finally
    FreeAndNil(list);
  end;

end;


class procedure TRoutes.releaseInstance;
begin
  if Assigned(TRoutes.instance) then
    FreeAndNil(TRoutes.instance);
end;

{ TRouteTypeHelper }

function TRouteTypeHelper.StrToTRouteType(route_type : String): TRouteType;
begin
  if (UpperCase(route_type) = 'GET') then
    result := rtGET
  else if (UpperCase(route_type) = 'POST')then
    result := rtPOST
  else if (UpperCase(route_type) = 'PUT')then
    result := rtPUT
  else if (UpperCase(route_type) = 'DELETE')then
    result := rtDELETE
  else
    result := rtNone
end;

function TRouteTypeHelper.toString: String;
begin
  if (self = rtGET) then
    result := 'GET'
  else if (self = rtPOST) then
    result := 'POST'
  else if (self = rtPUT) then
    result := 'PUT'
  else if (self = rtDELETE) then
    result := 'DELETE'
  else
    result := 'NA'
end;

{ TRoute }
procedure TRoute.setMethod(const Value: String);
var
  strList   : TStringList;
  params    : TStringList;
  i         : integer;
  pos_ini   : integer;
  nPos      : integer;
begin
  fmethod := Value;

  strList := TStringList.Create;
  params  := TStringList.Create;
  try
    pos_ini := Pos('(',fmethod);
    nPos    := Pos(')',fmethod) - pos_ini;
    params.Text  := Copy(fmethod,pos_ini+1,nPos-1).Replace(',',sLineBreak).Trim;

    strList.Text := fmethod.Replace('.',sLineBreak).Trim;

    fmethod_name := strList[strList.Count-1];
    if (pos_ini > 0) then
      fmethod_name := copy(fmethod_name,0,Pos('(',fmethod_name)-1);

    for i := 0 to params.Count-1 do
      parameters.addParameter(params[i]);

    fclass_name := strList[0];
    for i := 1 to strList.Count-2 do
      fclass_name := fclass_name + '.' + strList[i];

  finally
    FreeAndNil(strList);
    FreeAndNil(params);
  end;
end;


initialization
    setListTMetodoHTTP;
finalization
    TRoutes.releaseInstance;

end.
