unit class_.util;

interface
Uses  System.Rtti, System.SysUtils;
type
   TArrayValue = Array of TValue;

   TClassUtil = class
      public
        class function instantiateClassViaRTTI(value: TValue) : TObject;
   end;

implementation

class function TClassUtil.instantiateClassViaRTTI(value: TValue): TObject;
var
  context  : TRttiContext;
  instance : TRttiInstanceType;
  rtti_type: TRttiType;
  error    : String;
begin
  result := nil;
  try
    case value.Kind of
      tkString ,
      tkLString,
      tkWString,
      tkUString:
        begin
          error   := value.AsString+' classe not found';
          instance:= TRttiInstanceType(context.FindType(value.AsString));
          result  := instance.MetaclassType.Create;
        end;
      tkClassRef:
        begin
          error     := 'the  parameter must be of type Tclass'+sLineBreak;
          rtti_type := context.GetType(value.AsClass);
          instance  := (context.FindType(rtti_type.QualifiedName) as TRttiInstanceType);

          result    := instance.MetaclassType.Create;
        end;
      else
        begin
          Error :='The parameter is not valid for'+sLineBreak;
          abort;
        end;
      end;
  except
    on e : Exception do
    begin
      raise Exception.Create(error);
    end;
  end;
end;

end.
