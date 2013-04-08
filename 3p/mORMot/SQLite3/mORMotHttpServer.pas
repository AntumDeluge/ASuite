/// HTTP/1.1 RESTFUL JSON Server classes for mORMot
// - this unit is a part of the freeware Synopse mORMot framework,
// licensed under a MPL/GPL/LGPL tri-license; version 1.18
unit mORMotHttpServer;

{
    This file is part of Synopse mORMot framework.

    Synopse mORMot framework. Copyright (C) 2013 Arnaud Bouchez
      Synopse Informatique - http://synopse.info

  *** BEGIN LICENSE BLOCK *****
  Version: MPL 1.1/GPL 2.0/LGPL 2.1

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.

  The Original Code is Synopse mORMot framework.

  The Initial Developer of the Original Code is Arnaud Bouchez.

  Portions created by the Initial Developer are Copyright (C) 2013
  the Initial Developer. All Rights Reserved.

  Contributor(s):
  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.

  ***** END LICENSE BLOCK *****


     HTTP/1.1 RESTFUL JSON Client/Server for mORMot
    ************************************************

   - use internaly the JSON format for content communication
   - can be called by TSQLHttpClient class from direct Delphi clients
     (see mORMotHttpClient unit)
   - can be called by any JSON-aware AJAX application
   - can optionaly compress the returned data to optimize Internet bandwidth
   - speed is very high: more than 20MB/sec R/W localy on a 1.8GHz Sempron,
     i.e. 400Mb/sec of duplex raw IP data, with about 200 �s only elapsed
     by request (direct call is 50 �s, so bottle neck is the Win32 API),
     i.e. 5000 requests per second, with 113 result rows (i.e. 4803 bytes
     of JSON data each)... try to find a faster JSON HTTP server! ;)

    Initial version: 2009 May, by Arnaud Bouchez

    Version 1.1
      - code rewrite for FPC and Delphi 2009/2010 compilation

    Version 1.3 - January 22, 2010
      - some small fixes and multi-compiler enhancements

    Version 1.4 - February 8, 2010
      - whole Synopse SQLite3 database framework released under the GNU Lesser
        General Public License version 3, instead of generic "Public Domain"
      - HTTP/1.1 RESTFUL JSON Client and Server split into two units
        (SQLite3HttpClient and SQLite3HttpServer)

    Version 1.5 - February 22, 2010
      - by default, the SQlite3 unit is now not included, in order to save
        some space

    Version 1.8
      - includes Unitary Testing class and functions
      - allows content-type changing for GET blob fields

    Version 1.12
      - TSQLHttpServer now handle multiple TSQLRestServer instances
        per one server (dispatching requests via the Root URI used)
      - new AddServer method, to register a TSQLRestServer after launch
      - new TSQLRestServer.OnlyJSONRequests property

    Version 1.13
      - can now use fast http.sys kernel-mode server (THttpApiServer) if
        available, and our pure Delphi THttpServer on default
      - now can compress its content using deflate or faster SynLZ algorithm
      - by default, will handle SynLZ compression for TSQLHttpClient
      - can make TCP/IP stream not HTTP compliant (for security visions)
      - TSQLHttpServer.Request now uses the new THttpServerGeneric.Request
        virtual abstract method prototype to handle THttpApiServer

    Version 1.16
      - added optional aRestAccessRights parameter in TSQLHttpServer.AddServer
        to override the default HTTP_DEFAULT_ACCESS_RIGHTS settings
      - added ServerThreadPoolCount parameter to TSQLHttpServer.Create()
        constructor, set by default to 32 - will speed up process of slow
        requests (e.g. a POST with some huge data transmitted at slow rate)
      - fixed error in case of URI similar to 'root?session_signature=...'
      - fixed incorect thread count in TSQLHttpServer.Create
      - regression tests are now extracted from this unit, in order to allow
        construction of a TSQLHttpServer instance without the need
        of linking the SQLite3 engine to the executable

    Version 1.17
      - made URI check case-insensitive (as for official RFC)
      - TSQLHttpServer will now call virtual TSQLRestServer.EndCurrentThread
        method in each of its terminating threads, to release any thread-specific
        resources (for instance, external connections in SQlite3DB)

    Version 1.18
      - renamed SQLite3HttpServer.pas unit to mORMotHttpServer.pas
      - classes TSQLHttpServer* renamed as TSQLHttpServer*
      - added TSQLHttpServer.RemoveServer() method
      - added TSQLHttpServer.AccessControlAllowOrigin property to handle
        cross-site AJAX requests via cross-origin resource sharing (CORS)
      - TSQLHttpServer now handles sub-domains generic matching (via
        TSQLModel.URIMatch call) at database model level (e.g. you can set
        root='/root/sub1' URIs)
      - declared TSQLHttpServer.Request method as virtual, to allow easiest
        customization, like direct file sending to the clients

}

interface

{$define COMPRESSSYNLZ}
{ if defined, will use SynLZ for content compression
  - SynLZ is much faster than deflate/zip, so is preferred
  - can be set global for Client and Server applications
  - with SynLZ, the 440 KB JSON for TTestClientServerAccess._TSQLHttpClient
    is compressed into 106 KB with no speed penalty (it's even a bit faster)
    whereas deflate, even with its level set to 1 (fastest), is 25 % slower
  - TSQLHttpClientGeneric.Compression shall contain hcSynLZ to handle it }

{$define COMPRESSDEFLATE}
{ if defined, will use deflate/zip for content compression
  - can be set global for Client and Server applications
  - SynLZ is faster but only known by Delphi clients: you can enable deflate
    when the server is connected an AJAX application (not defined by default)
  - if you define both COMPRESSSYNLZ and COMPRESSDEFLATE, the server will use
    SynLZ if available, and deflate if not called from a Delphi client
  - TSQLHttpClientGeneric.Compression shall contain hcSynDeflate to handle it }

{.$define USETCPPREFIX}
{ if defined, a prefix will be added to the TCP/IP stream so that it won't be
  valid HTTP content any more: it could increase the client/server speed with
  some anti-virus software, but the remote access won't work any more with
  Internet Browsers nor AJAX applications
  - will work only with our THttpServer pure Delphi code, of course
  - not defined by default - should be set globally to the project conditionals,
  to be defined in both mORMotHttpClient and mORMotHttpServer units }

{$define USETHREADPOOL}
// define this to use TSynThreadPool for faster multi-connection
// shall match SynCrtSock.pas definition

{$I Synopse.inc} // define HASINLINE USETYPEINFO CPU32 CPU64 WITHLOG

uses
  Windows,
  SysUtils,
  Classes,
{$ifdef COMPRESSDEFLATE}
  SynZip,
{$endif}
{$ifdef COMPRESSSYNLZ}
  SynLZ,
{$endif}
  SynCrtSock,
  SynCommons,
  mORMot;


const
  /// the default access rights used by the HTTP server if none is specified
  HTTP_DEFAULT_ACCESS_RIGHTS: PSQLAccessRights = @SUPERVISOR_ACCESS_RIGHTS;

type
  /// HTTP/1.1 RESTFUL JSON mORMot Server class
  // - this server is multi-threaded and not blocking
  // - will first try to use fastest http.sys kernel-mode server (i.e. create a
  // THttpApiServer instance); it should work OK under XP or WS 2K3 - but
  // you need to have administrator rights under Vista or Seven: if http.sys
  // fails to initialize, it will use a pure Delphi THttpServer instance; a
  // solution is to call the THttpApiServer.AddUrlAuthorize class method during
  // program setup for the desired port, in order to allow it for every user
  // - just create it and it will serve SQL statements as UTF-8 JSON
  // - for a true AJAX server, expanded data is prefered - your code may contain:
  // ! DBServer.NoAJAXJSON := false;
  TSQLHttpServer = class
  private
    fAccessControlAllowOrigin: RawUTF8;
    fAccessControlAllowOriginHeader: RawUTF8;
    procedure SetAccessControlAllowOrigin(const Value: RawUTF8);
  protected
    fOnlyJSONRequests: boolean;
    fHttpServer: THttpServerGeneric;
    fPort, fDomainName: AnsiString;
    /// internal servers to compute responses
    fDBServers: array of record
      Server: TSQLRestServer;
      RestAccessRights: PSQLAccessRights;
    end;
    // assigned to fHttpServer.OnHttpThreadStart/Terminate e.g. to handle connections
    procedure HttpThreadStart(Sender: TThread);
    procedure HttpThreadTerminate(Sender: TObject);
    /// implement the server response - must be thread-safe
    function Request(Ctxt: THttpServerRequest): cardinal; virtual;
    function GetDBServerCount: integer;
    function GetDBServer(Index: Integer): TSQLRestServer;
    procedure SetDBServerAccessRight(Index: integer; Value: PSQLAccessRights);
  public
    /// create a Server Thread, binded and listening on a TCP port to HTTP JSON requests
    // - raise a EHttpServer exception if binding failed
    // - specify one or more TSQLRestServer server class to be used: each
    // class must have an unique Model.Root value, to identify which TSQLRestServer
    // instance must handle a particular request from its URI
    // - port is an AnsiString, as expected by the WinSock API
    // - aDomainName is the URLprefix to be used for HttpAddUrl API call:
    // it could be either a fully qualified case-insensitive domain name
    // an IPv4 or IPv6 literal string, or a wildcard ('+' will bound
    // to all domain names for the specified port, '*' will accept the request
    // when no other listening hostnames match the request for that port) - this
    // parameter is ignored by the TSQLHttpApiServer instance
    // - if DontUseHttpApiServer is set, kernel-mode HTTP.SYS server won't be used
    // and standard Delphi code will be called instead (not recommended)
    // - by default, the PSQLAccessRights will be set to nil
    // - the ServerThreadPoolCount parameter will set the number of threads
    // to be initialized to handle incoming connections (default is 32, which
    // may be sufficient for most cases, maximum is 256)
    constructor Create(const aPort: AnsiString;
      const aServers: array of TSQLRestServer; const aDomainName: AnsiString='+';
      DontUseHttpApiServer: Boolean=false; ServerThreadPoolCount: Integer=32); reintroduce; overload;
    /// create a Server Thread, binded and listening on a TCP port to HTTP JSON requests
    // - raise a EHttpServer exception if binding failed
    // - specify one TSQLRestServer server class to be used
    // - port is an AnsiString, as expected by the WinSock API
    // - aDomainName is the URLprefix to be used for HttpAddUrl API call
    constructor Create(const aPort: AnsiString; aServer: TSQLRestServer;
      const aDomainName: AnsiString='+';
      DontUseHttpApiServer: Boolean=false; aRestAccessRights: PSQLAccessRights=nil;
      ServerThreadPoolCount: Integer=32); reintroduce; overload;
    /// release all memory, internal mORMot server and HTTP handlers
    destructor Destroy; override;
    /// try to register another TSQLRestServer instance to the HTTP server
    // - each TSQLRestServer class must have an unique Model.Root value, to
    // identify which instance must handle a particular request from its URI
    // - an optional aRestAccessRights parameter is available to override the
    // default HTTP_DEFAULT_ACCESS_RIGHTS access right setting - but you shall
    // better rely on the authentication feature included in the framework
    // - return true on success, false on error (e.g. duplicated Root value)
    function AddServer(aServer: TSQLRestServer; aRestAccessRights: PSQLAccessRights=nil): boolean;
    /// un-register a TSQLRestServer from the HTTP server
    // - each TSQLRestServer class must have an unique Model.Root value, to
    // identify which instance must handle a particular request from its URI
    // - return true on success, false on error (e.g. specified server not found)
    function RemoveServer(aServer: TSQLRestServer): boolean;
    /// the associated running HTTP server instance
    // - either THttpApiServer, either THttpServer
    property HttpServer: THttpServerGeneric read fHttpServer;
    /// read-only access to the number of registered internal servers
    property DBServerCount: integer read GetDBServerCount;
    /// read-only access to all internal servers
    property DBServer[Index: integer]: TSQLRestServer read GetDBServer;
    /// write-only access to all internal servers access right
    // - can be used to override the default HTTP_DEFAULT_ACCESS_RIGHTS setting
    property DBServerAccessRight[Index: integer]: PSQLAccessRights write SetDBServerAccessRight;
    /// set this property to TRUE if the server must only respond to
    // request of MIME type APPLICATION/JSON
    // - the default is false, in order to allow direct view of JSON from
    // any browser
    property OnlyJSONRequests: boolean read fOnlyJSONRequests write fOnlyJSONRequests;
    /// enable cross-origin resource sharing (CORS) for proper AJAX process
    // - see @https://developer.mozilla.org/en-US/docs/HTTP/Access_control_CORS
    // - can be set e.g. to '*' to allow requests from any sites
    // - or specify an URI to be allowed as origin (e.g. 'http://foo.example')
    // - current implementation is pretty basic, and does not check the incoming
    // "Origin: " header value
    property AccessControlAllowOrigin: RawUTF8 read fAccessControlAllowOrigin write SetAccessControlAllowOrigin;
  end;


implementation


{ TSQLHttpServer }

function TSQLHttpServer.AddServer(aServer: TSQLRestServer;
  aRestAccessRights: PSQLAccessRights): boolean;
var i, n: integer;
{$ifdef WITHLOG}
    Log: ISynLog;
{$endif}
begin
  result := False;
{$ifdef WITHLOG}
  Log := TSQLLog.Enter(self);
  try
{$endif}
    if (self=nil) or (aServer=nil) or (aServer.Model=nil) then
      exit;
    for i := 0 to high(fDBServers) do
      if fDBServers[i].Server.Model.Root=aServer.Model.Root then
        exit; // register only once per URI Root address
    if fHttpServer.InheritsFrom(THttpApiServer) then
      // try to register the URL to http.sys
      if THttpApiServer(fHttpServer).
          AddUrl(aServer.Model.Root,fPort,false,fDomainName)<>NO_ERROR then
        exit;
    n := length(fDBServers);
    SetLength(fDBServers,n+1);
    fDBServers[n].Server := aServer;
    if aRestAccessRights=nil then
      aRestAccessRights := HTTP_DEFAULT_ACCESS_RIGHTS;
    fDBServers[n].RestAccessRights := aRestAccessRights;
    result := true;
  {$ifdef WITHLOG}
  finally
    Log.Log(sllDebug,'result=% for Root=%',[JSON_BOOLEAN[Result],aServer.Model.Root]);
  end;
  {$endif}
end;

function TSQLHttpServer.RemoveServer(aServer: TSQLRestServer): boolean;
var i,j,n: integer;
{$ifdef WITHLOG}
    Log: ISynLog;
{$endif}
begin
  result := False;
  if (self=nil) or (aServer=nil) or (aServer.Model=nil) then
    exit;
{$ifdef WITHLOG}
  Log := TSQLLog.Enter(self);
  try
{$endif}
  n := high(fDBServers);
  for i := 0 to n do
    if fDBServers[i].Server=aServer then begin
      if fHttpServer.InheritsFrom(THttpApiServer) then
        if THttpApiServer(fHttpServer).
            RemoveUrl(aServer.Model.Root,fPort,false,fDomainName)<>NO_ERROR then
          exit;
      for j := i to n-1 do
        fDBServers[j] := fDBServers[j+1];
      SetLength(fDBServers,n);
      break;
    end;
  {$ifdef WITHLOG}
  finally
    Log.Log(sllDebug,'result=% for Root=%',[JSON_BOOLEAN[Result],aServer.Model.Root]);
  end;
  {$endif}
end;

constructor TSQLHttpServer.Create(const aPort: AnsiString;
  const aServers: array of TSQLRestServer; const aDomainName: AnsiString;
  DontUseHttpApiServer: Boolean; ServerThreadPoolCount: Integer);
var i,j: integer;
    ErrMsg: string;
{$ifdef WITHLOG}
    Log: ISynLog;
{$endif}
begin
{$ifdef WITHLOG}
  Log := TSQLLog.Enter(self);
{$endif}
  inherited Create;
  fDomainName := aDomainName;
  fPort := aPort;
  if high(aServers)<0 then
    ErrMsg := 'Invalid TSQLRestServer' else
  for i := 0 to high(aServers) do
    if (aServers[i]=nil) or (aServers[i].Model=nil) then
      ErrMsg := 'Invalid TSQLRestServer';
  if ErrMsg='' then
    for i := 0 to high(aServers) do
    with aServers[i].Model do
    for j := i+1 to high(aServers) do
      if aServers[j].Model.URIMatch(Root) then
        ErrMsg:= Format('Duplicated Root URI: %s and %s',[Root,aServers[j].Model.Root]);
  if ErrMsg<>'' then
     raise EModelException.CreateFmt('%s.Create: %s',[ClassName,ErrMsg]);
  SetAccessControlAllowOrigin(''); // deny CORS by default
  SetLength(fDBServers,length(aServers));
  for i := 0 to high(aServers) do
  with fDBServers[i] do begin
    Server := aServers[i];
    RestAccessRights := HTTP_DEFAULT_ACCESS_RIGHTS;
  end;
  {$ifndef USETCPPREFIX}
  if not DontUseHttpApiServer then
  try
    // first try to use fastest http.sys
    fHttpServer := THttpApiServer.Create(false);
    for i := 0 to high(aServers) do begin
      j := THttpApiServer(fHttpServer).AddUrl(
        aServers[i].Model.Root,aPort,false,aDomainName);
      if j<>NO_ERROR then begin
        ErrMsg := 'Impossible to register URL';
        if j=ERROR_ACCESS_DENIED then
          ErrMsg := ErrMsg+' (administrator rights needed)';
        raise ECommunicationException.CreateFmt('%s.Create: %s for %s',
          [ClassName,ErrMsg,aServers[i].Model.Root]);
        break;
      end;
    end;
  except
    on E: Exception do begin
      {$ifdef WITHLOG}
      Log.Log(sllError,'% for %',[E,fHttpServer],self);
      {$endif}
      FreeAndNil(fHttpServer); // if http.sys initialization failed
    end;
  end;
  {$endif}
  if fHttpServer=nil then begin
    // http.sys failed -> create one instance of our pure Delphi server
    fHttpServer := THttpServer.Create(aPort
      {$ifdef USETHREADPOOL},ServerThreadPoolCount{$endif});
    {$ifdef USETCPPREFIX}
    THttpServer(fHttpServer).TCPPrefix := 'magic';
    {$endif}
  end;
  fHttpServer.OnHttpThreadStart := HttpThreadStart;
  fHttpServer.OnRequest := Request;
  fHttpServer.OnHttpThreadTerminate := HttpThreadTerminate;
{$ifdef COMPRESSSYNLZ}
  fHttpServer.RegisterCompress(CompressSynLZ);
{$endif}
{$ifdef COMPRESSDEFLATE}
  fHttpServer.RegisterCompress(CompressDeflate);
{$endif}
  if fHttpServer.InheritsFrom(THttpApiServer) then
    // allow fast multi-threaded requests
    if ServerThreadPoolCount>1 then
      THttpApiServer(fHttpServer).Clone(ServerThreadPoolCount-1);
{$ifdef WITHLOG}
  for i := 0 to high(aServers) do
    with aServers[i] do
      Log.Log(sllInfo,'% initialized at http://localhost/%:%',[fHttpServer,Model.Root,aPort],self);
{$endif}
end;

constructor TSQLHttpServer.Create(const aPort: AnsiString;
  aServer: TSQLRestServer; const aDomainName: AnsiString;
  DontUseHttpApiServer: boolean; aRestAccessRights: PSQLAccessRights;
  ServerThreadPoolCount: integer);
begin
  Create(aPort,[aServer],aDomainName,DontUseHttpApiServer,ServerThreadPoolCount);
  if aRestAccessRights<>nil then
    DBServerAccessRight[0] := aRestAccessRights;
end;

destructor TSQLHttpServer.Destroy;
begin
  fHttpServer.Free;
  inherited;
end;

function TSQLHttpServer.GetDBServer(Index: Integer): TSQLRestServer;
begin
  if (Self<>nil) and (cardinal(Index)<cardinal(length(fDBServers))) then
    result := fDBServers[Index].Server else
    result := nil;
end;

function TSQLHttpServer.GetDBServerCount: integer;
begin
  result := length(fDBServers);
end;

procedure TSQLHttpServer.SetDBServerAccessRight(Index: integer;
  Value: PSQLAccessRights);
begin
  if Value=nil then
    Value := HTTP_DEFAULT_ACCESS_RIGHTS;
  if (Self<>nil) and (cardinal(Index)<cardinal(length(fDBServers))) then
    fDBServers[Index].RestAccessRights := Value;
end;

function TSQLHttpServer.Request(Ctxt: THttpServerRequest): cardinal;
var call: TSQLRestServerURIParams;
    i: integer;
    P: PUTF8Char;
begin
  if (Ctxt.URL='') or (Ctxt.Method='') or
     (OnlyJSONRequests and
      not IdemPChar(pointer(Ctxt.InContentType),'APPLICATION/JSON')) then
    // wrong Input parameters or not JSON request: 400 BAD REQUEST
    result := HTML_BADREQUEST else
  if Ctxt.Method='OPTIONS' then begin
    Ctxt.OutCustomHeaders := 'Access-Control-Allow-Headers: '+
      FindIniNameValue(pointer(Ctxt.InHeaders),'ACCESS-CONTROL-REQUEST-HEADERS: ')+
      fAccessControlAllowOriginHeader;
    result := HTML_SUCCESS;
  end else begin
    if Ctxt.URL[1]='/' then  // trim any left '/' from URL
      call.Url := copy(Ctxt.URL,2,maxInt) else
      call.Url := Ctxt.URL;
    result := HTML_NOTFOUND; // page not found by default (in case of wrong URL)
    for i := 0 to high(fDBServers) do
    with fDBServers[i] do
      if Server.Model.URIMatch(call.Url) then begin
        call.Method := Ctxt.Method;
        call.InHead := Ctxt.InHeaders;
        call.InBody := Ctxt.InContent;
        call.RestAccessRights := RestAccessRights;
        Server.URI(call);
        result := call.OutStatus;
        P := pointer(call.OutHead);
        if IdemPChar(P,'CONTENT-TYPE: ') then begin
          // change mime type if modified in HTTP header (e.g. GET blob fields)
          Ctxt.OutContentType := GetNextLine(P+14,P);
          call.OutHead := P;
        end else
          // default content type is JSON
          Ctxt.OutContentType := JSON_CONTENT_TYPE;
        Ctxt.OutCustomHeaders := Trim(call.OutHead)+
          #13#10'Server-InternalState: '+Int32ToUtf8(call.OutInternalState);
        if ExistsIniName(pointer(call.InHead),'ORIGIN:') then
          Ctxt.OutCustomHeaders := Trim(Ctxt.OutCustomHeaders+fAccessControlAllowOriginHeader) else
          Ctxt.OutCustomHeaders := Trim(Ctxt.OutCustomHeaders);
        Ctxt.OutContent := call.OutBody;
        break;
      end;
  end;
end;

procedure TSQLHttpServer.HttpThreadTerminate(Sender: TObject);
var i: integer;
begin
  if self<>nil then
    for i := 0 to high(fDBServers) do
      fDBServers[i].Server.EndCurrentThread(self);
end;

procedure TSQLHttpServer.HttpThreadStart(Sender: TThread);
var i: integer;
begin
  if self<>nil then
    for i := 0 to high(fDBServers) do
      fDBServers[i].Server.BeginCurrentThread(Sender);
end;

procedure TSQLHttpServer.SetAccessControlAllowOrigin(const Value: RawUTF8);
begin
  fAccessControlAllowOrigin := Value;
  if Value='' then
    fAccessControlAllowOriginHeader :=
      #13#10'Access-Control-Allow-Origin: ' else
    fAccessControlAllowOriginHeader :=
      #13#10'Access-Control-Allow-Methods: POST, PUT, GET, DELETE, LOCK, OPTIONS'+
      #13#10'Access-Control-Max-Age: 1728000'+
      #13#10'Access-Control-Allow-Origin: '+Value;
end;

end.
