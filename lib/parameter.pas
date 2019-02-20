unit parameter;

interface
uses System.Classes, System.SysUtils, class_.util, System.Rtti;

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
  private
    function getValueParameter(pValue: String): String;
    public
      procedure addParameter(parameter : TParameter);overload;
      procedure addParameter(name : String);overload;
      procedure setParameters(uri, endpoint : String);

      function getArray(pInvert : Boolean = false) : TArrayValue;
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

function TListParameterHelper.getArray(pInvert : Boolean): TArrayValue;
var
 i   : integer;
 len : integer;
begin
  len := length(Self)-1;
  for i := 0 to len do
  begin
    SetLength(result, i+1);

    result[i] := Self[i].value;
    if (pInvert) then
      result[i] := Self[len-i].value;
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
  value        : String     ;
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

      value := getValueParameter(blocks_uri[i]);

      getParameter(blocks_route[i].Replace(PREFIX_PARAMETER,EmptyStr)).value := value;
    end;

  finally
    FreeAndNil(blocks_route);
    FreeAndNil(blocks_uri);
  end;
end;

function TListParameterHelper.getValueParameter(pValue : String) : String;
const
  values : array of array of string = [
      ['%21', '!'],
      ['%22', '"'],
      ['%23', '#'],
      ['%24', '$'],
      ['%25', '%'],
      ['%26', '&'],
      ['%27', ''''],
      ['%28', '('],
      ['%29', ')'],
      ['%2a', '*'],
      ['%2b', '+'],
      ['%2c', ','],
      ['%2d', '-'],
      ['%2e', '.'],
      ['%2f', '/'],
      ['%3a', ':'],
      ['%3b', ';'],
      ['%3c', '<'],
      ['%3d', '='],
      ['%3e', '>'],
      ['%3f', '?'],
      ['%40', '@'],
      ['%5b', '['],
      ['%5c', '\'],
      ['%5d', ']'],
      ['%5e', '^'],
      ['%5f', '_'],
      ['%60', '`'],
      ['%7b', '{'],
      ['%7c', '|'],
      ['%7d', '}'],
      ['%7e', '~']
  ];
var
  i : integer;
begin
  result := pValue;
  for i := 0 to Length(values)-1 do
    result := StringReplace(result, values[i][0], values[i][1], [rfReplaceAll, rfIgnoreCase]);
end;

end.
