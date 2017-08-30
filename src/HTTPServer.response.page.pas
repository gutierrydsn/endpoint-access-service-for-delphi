unit HTTPServer.response.page;

interface

uses
  IdCustomHTTPServer;

type
  HTTPServerResponsePage = class
    class function return_404(AResponseInfo: TIdHTTPResponseInfo) : String;
  end;

implementation

{ HTTPServerResponsePage }

class function HTTPServerResponsePage.return_404(AResponseInfo: TIdHTTPResponseInfo): String;
begin
  AResponseInfo.ResponseNo := 404;
  result := '<style>                     '+
            '   .title {                 '+
            '     border:0px;            '+
            '     height:30px;           '+
            '     width:100%;            '+
            '     background-color:red   '+
            '   }                        '+
            '</style>                    '+
            '                            '+
            '<div class="title">         '+
            '   <h2>Code status 404</h2> '+
            '</div>                      '+
            '<h1>                        '+
            '    Route does not implement'+
            '</h1>                       '
end;

end.
