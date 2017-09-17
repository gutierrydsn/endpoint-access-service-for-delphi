unit parameter;

interface
uses System.Classes, System.SysUtils, class_.util;

type
  TparameterType =(ptInteger, ptString, ptFloat, ptBoolean);

  TParameter = class
    private
      fname        : String ;
      fvalue       : variant;
      fparam_type  : TparameterType;
    public
      property name       : String         read fname       write fname;
      property value      : variant        read fvalue      write fvalue;
      property param_type : TparameterType read fparam_type write fparam_type ;
  end;

  TListParameter = array of TParameter;

  TListParameterHelper = record helper for TListParameter
    public
      procedure addParameter(parameter : TParameter);overload;
      procedure addParameter(name : String);overload;
      procedure setParameters(uri, endpoint : String);

      function getArray : TArrayValue;
      function addParameter : TParameter;overload;
      function getParameter(name : String) : TParameter;
  end;

const
  PREFIX_PARAMETER = ':';
implementation

procedure TListParameterHelper.addParameter(parameter: TParameter);
begin
  SetLength(self,length(self)+1);
  self[length(self)-1] := parameter;
end;

function TListParameterHelper.addParameter: TParameter;
begin
  result := TParameter.Create;
  addParameter(result);
end;

procedure TListParameterHelper.addParameter(name: String);
begin
  addParameter.name := name;
end;

function TListParameterHelper.getArray: TArrayValue;
var i : integer;
begin
  for i := 0 to length(Self)-1 do
  begin
    SetLength(result, i+1);
    result[i] := String(Self[i].value);
  end;
end;

function TListParameterHelper.getParameter(name: String): TParameter;
var i : integer;
begin
  result := nil;
  for i := 0 to Length(self)-1 do
  begin
    if (UpperCase(self[i].name).trim <> UpperCase(name).trim)  then
      continue;

    result := self[i];
    break;
  end;
end;

procedure TListParameterHelper.setParameters(uri, endpoint : String);
var
  i            : Integer    ;
  blocks_route : TStringList;
  blocks_uri   : TStringList;
begin
  blocks_route := TStringList.Create;
  blocks_uri   := TStringList.Create;
  try
    blocks_uri.Text   := uri.Replace('/',sLineBreak).Trim;
    blocks_route.Text := endpoint.Replace('/',sLineBreak).Trim;

    for i := 0 to blocks_route.Count-1 do
    begin
      if (pos(PREFIX_PARAMETER,blocks_route[i]) <= 0) then
        continue;

      getParameter(blocks_route[i].Replace(PREFIX_PARAMETER,EmptyStr)).value := blocks_uri[i];
    end;

  finally
    FreeAndNil(blocks_route);
    FreeAndNil(blocks_uri);
  end;
end;

end.
