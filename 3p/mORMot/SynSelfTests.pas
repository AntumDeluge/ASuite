/// automated tests for common units of the Synopse mORMot Framework
// - this unit is a part of the freeware Synopse mORMot framework,
// licensed under a MPL/GPL/LGPL tri-license; version 1.18
unit SynSelfTests;

{
    This file is part of Synopse mORMot framework.

    Synopse framework. Copyright (C) 2013 Arnaud Bouchez
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

  The Original Code is Synopse framework.

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

  Version 1.8
  - first public release, corresponding to SQLite3 Framework 1.8
  - includes Unitary Testing class and functions

  Version 1.9
  - test multi-threaded AES encryption/decryption of 4 MB blocks
  - added crc32 tests

  Version 1.11
  - added some more regression tests in TTestCompression.ZipFormat

  Version 1.12
  - handle producer version change in TTestSynopsePDF

  Version 1.13
  - code modifications to compile with Delphi 5 compiler
  - enhanced compression tests

  Version 1.15
  - unit now tested with Delphi XE2 (32 Bit)
  - new TTestSQLite3ExternalDB class to test TSQLRecordExternal records,
    i.e. external DB access from the mORMot framework (use an in-memory SQLite3
    database as an external SynDB engine for fast and reliable testing)
  - added test of TModTime published property (i.e. latest update time)
  - added test of TCreateTime published property (i.e. record creation time)

  Version 1.16
  - added interface-based remote service implementation tests
  - added test about per-database encryption in TTestExternalDatabase.CryptedDatabase
  - added TAESECB, TAESCBC, TAESCFB, TAESOFB and TAESCTR classes tests (+ PKCS7)
  - enhanced SynLZ tests (comparing asm and pas versions of the implementation)

  Version 1.17
  - added test for TInterfaceCollection kind of parameter
  - added multi-thread testing of ExecuteInMainThread() method
  - removed TSQLRecordExternal class type, to allow any TSQLRecord (e.g.
    TSQLRecordMany) to be used with VirtualTableExternalRegister()
  - added DBMS full test coverage in TTestExternalDatabase.AutoAdaptSQL

  Version 1.18
  - included some unit tests like TTestLowLevelTypes and TTestBasicClasses,
    previously included in SQLite3Commons.pas or TTestLowLevelCommon, extracted
    from SynCommons.pas, or TTestSQLite3Engine from SQLite3.pas
  - added test for variant JSON serialization for interface-based services and
    for ORM (aka TSQLRecord)
  - added external TSQLRecordOnlyBlob test associated to ticket [21c2d5ae96] 
  - included testing of interface-based services in sicSingle mode

}

interface

{$I Synopse.inc} // define HASINLINE USETYPEINFO CPU32 CPU64

uses
  Windows,
  Classes,
{$ifdef USEVARIANTS}
  Variants,
{$endif}
{$ifdef UNICODE}
  Generics.Collections,
{$endif}
  SysUtils,
{$ifndef FPC}
{$ifndef LVCL}
  Contnrs,
  SynDB,
{$endif LVCL}
  SynSQLite3,
  SynSQlite3Static,
  SynDBSQLite3,
{$ifndef DELPHI5OROLDER}
{$ifndef LVCL}
  mORMotDB,
{$endif LVCL}
  mORMot,
  mORMotSQLite3,
  mORMotHttpServer,
  mORMotHttpClient,
{$endif DELPHI5OROLDER}
{$endif FPC}
  SynCommons;


{$ifdef CPU64}
  {$define USEFASTCALL}
  // only one calling convention in the Win64 world
{$else}
  {.$define USEFASTCALL}
  { use the fastcall calling convention to access the SQLite3 library
    - BCC32 -pr fastcall (=Delphi resgister) is buggy, don't know why
     (because of issues with BCC32 itself, or some obfuscated calls in source?)
    - should be defined for SynSQLite3, SynSQLite3Static and mORMotSQLite3 units }
{$endif}

{ ************ Unit-Testing classes and functions }

type
  /// this test case will test most functions, classes and types defined and
  // implemented in the SynCommons unit
  TTestLowLevelCommon = class(TSynTestCase)
  published
    /// the faster CopyRecord function, enhancing the system.pas unit
    procedure SystemCopyRecord;
    /// test the TDynArray object and methods
    procedure _TDynArray;
    /// test the TDynArrayHashed object and methods (dictionary features)
    // - this test will create an array of 200,000 items to test speed
    procedure _TDynArrayHashed;
    /// test StrIComp() and AnsiIComp() functions
    procedure FastStringCompare;
    /// test IdemPropName() and IdemPropNameU() functions
    procedure _IdemPropName;
    /// test UrlEncode() and UrlDecode() functions
    procedure UrlEncoding;
    /// test IsMatch() function
    procedure _IsMatch;
    /// the Soundex search feature (i.e. TSynSoundex and all related
    // functions)
    procedure Soundex;
    /// low level fast Integer or Floating-Point to/from string conversion
    // - especially the RawUTF8 or PUTF8Char relative versions
    procedure NumericalConversions;
    /// the new fast Currency to/from string conversion
    procedure Curr64;
    /// the camel-case / camel-uncase features, used for i18n from Delphi RTII
    procedure _CamelCase;
    /// the low-level bit management functions
    procedure Bits;
    /// the fast .ini file content direct access
    procedure IniFiles;
    /// test UTF-8 and Win-Ansi conversion (from or to, through RawUnicode)
    procedure Unicode_UTF8;
    /// the ISO-8601 date and time encoding
    // - test especially the conversion to/from text
    procedure Iso8601DateAndTime;
    /// test UrlEncode() and UrlDecode() functions
    // - this method use some ISO-8601 encoded dates and times for the testing
    procedure UrlDecoding;
    /// test mime types recognition
    procedure MimeTypes;
    /// test TSynTable class and TSynTableVariantType new variant type
    procedure _TSynTable;
    /// test the TSynCache class
    procedure _TSynCache;
    /// low-level TSynFilter classes
    procedure _TSynFilter;
    /// low-level TSynValidate classes
    procedure _TSynValidate;
    /// low-level TSynLogFile class
    procedure _TSynLogFile;
  end;

  /// this test case will test most low-level functions, classes and types
  // defined and implemented in the mORMot.pas unit
  TTestLowLevelTypes = class(TSynTestCase)
  published
{$ifndef DELPHI5OROLDER}
{$ifndef FPC}
    /// some low-level RTTI access
    // - especially the field type retrieval from published properties
    procedure RTTI;
{$endif}
{$endif}
    /// some low-level Url encoding from parameters
    procedure UrlEncoding;
    /// some low-level JSON encoding/decoding
    procedure EncodeDecodeJSON;
  end;

{$ifndef DELPHI5OROLDER}
{$ifndef FPC}

/// this test case will test some generic classes
  // defined and implemented in the mORMot.pas unit
  TTestBasicClasses = class(TSynTestCase)
  published
    /// test the TSQLRecord class
    // - especially SQL auto generation, or JSON export/import
    procedure _TSQLRecord;
    /// test the digital signature of records
    procedure _TSQLRecordSigned;
    /// test the TSQLModel class
    procedure _TSQLModel;
  end;

  // a record mapping used in the test classes of the framework
  // - this class can be used for debugging purposes, with the database
  // created by TTestFileBased in mORMotSQLite3.pas
  // - this class will use 'People' as a table name
  TSQLRecordPeople = class(TSQLRecord)
  private
    fData: TSQLRawBlob;
    fFirstName: RawUTF8;
    fLastName: RawUTF8;
    fYearOfBirth: integer;
    fYearOfDeath: word;
  published
    property FirstName: RawUTF8 read fFirstName write fFirstName;
    property LastName: RawUTF8 read fLastName write fLastName;
    property Data: TSQLRawBlob read fData write fData;
    property YearOfBirth: integer read fYearOfBirth write fYearOfBirth;
    property YearOfDeath: word read fYearOfDeath write fYearOfDeath;
  public
    {/ method used to test the Client-Side
       ModelRoot/TableName/ID/MethodName RESTful request, i.e.
       ModelRoot/People/ID/DataAsHex in this case
     - this method calls the supplied TSQLRestClient to retrieve its results,
       with the ID taken from the current TSQLRecordPeole instance ID field
     - parameters and result types depends on the purpose of the function
     - TSQLRestServerTest.DataAsHex published method implements the result
       calculation on the Server-Side }
    function DataAsHex(aClient: TSQLRestClientURI): RawUTF8;
    {/ method used to test the Client-Side
       ModelRoot/MethodName RESTful request, i.e. ModelRoot/Sum in this case
     - this method calls the supplied TSQLRestClient to retrieve its results
     - parameters and result types depends on the purpose of the function
     - TSQLRestServerTest.Sum published method implements the result calculation
       on the Server-Side
     - this method doesn't expect any ID to be supplied, therefore will be
       called as class function - normally, it should be implement in a
       TSQLRestClient descendant, and not as a TSQLRecord, since it does't depend
       on TSQLRecordPeople at all
     - you could also call the same servce from the ModelRoot/People/ID/Sum URL,
       but it won't make any difference) }
    class function Sum(aClient: TSQLRestClientURI; a, b: double; Method2: boolean): double;
  end;

{$endif FPC}
{$endif DELPHI5OROLDER}

  /// this test case will test most functions, classes and types defined and
  // implemented in the SynZip unit
  TTestCompression = class(TSynTestCase)
  protected
    Data: RawByteString;
    M: THeapMemoryStream;
    crc: cardinal;
  public
    destructor Destroy; override;
  published
    /// direct LZ77 deflate/inflate functions
    procedure InMemoryCompression;
    /// .gzip archive handling
    procedure GZipFormat;
    /// .zip archive handling
    procedure ZipFormat;
    /// SynLZO internal format
    procedure _SynLZO;
    /// SynLZ internal format
    procedure _SynLZ;
  end;

  /// this test case will test most functions, classes and types defined and
  // implemented in the SynCrypto unit
  TTestCryptographicRoutines = class(TSynTestCase)
  published
    /// Adler32 hashing functions
    procedure Adler32;
    /// MD5 hashing functions
    procedure _MD5;
    /// SHA-1 hashing functions
    procedure _SHA1;
    /// SHA-256 hashing functions
    procedure _SHA256;
    /// AES encryption/decryption functions
    procedure _AES256;
    /// Base-64 encoding/decoding functions
    procedure Base64;
  end;

{$ifndef FPC}
{$ifndef LVCL}
  /// this test case will test most functions, classes and types defined and
  // implemented in the SynPDF unit
  TTestSynopsePDF = class(TSynTestCase)
  published
    /// create a PDF document, using the PDF Canvas property
    // - test font handling, especially standard font substitution
    procedure _TPdfDocument;
    /// create a PDF document, using a EMF content
    // - validates the EMF/TMetaFile enumeration, and its conversion into the
    // PDF content
    // - this method will produce a .pdf file in the executable directory,
    // if you want to check out the result (it's simply a curve drawing, with
    // data from NIST)
    procedure _TPdfDocumentGDI;
  end;
{$endif}
{$endif}

{$ifndef FPC}
{$ifndef DELPHI5OROLDER}

{$ifndef LVCL}
type
  TCollTest = class(TCollectionItem)
  private
    FLength: Integer;
    FColor: Integer;
    FName: RawUTF8;
  published
    property Color: Integer read FColor write FColor;
    property Length: Integer read FLength write FLength;
    property Name: RawUTF8 read FName write FName;
  end;

  TCollTestsI = class(TInterfacedCollection)
  protected
    class function GetClass: TCollectionItemClass; override;
  end;
{$endif LVCL}


type
  /// a parent test case which will test most functions, classes and types defined
  // and implemented in the mORMotSQLite3 unit, i.e. the SQLite3 engine itself
  // - it should not be called directly, but through TTestFileBased,
  // TTestMemoryBased and TTestMemoryBased children
  TTestSQLite3Engine = class(TSynTestCase)
  protected
    { these values are used internaly by the published methods below }
    TempFileName: TFileName;
    IsMemory: boolean;
    Demo: TSQLDataBase;
    Req: RawUTF8;
    JS: RawUTF8;
  published
    /// test direct access to the SQLite3 engine
    // - i.e. via TSQLDataBase and TSQLRequest classes
    procedure DatabaseDirectAccess;
    /// test direct access to the Virtual Table features of SQLite3
    procedure VirtualTableDirectAccess;
    /// test the TSQLTableJSON table
    // - the JSON content generated must match the original data
    // - a VACCUM is performed, for testing some low-level SQLite3 engine
    // implementation
    // - the SortField feature is also tested
    procedure _TSQLTableJSON;
    /// test the TSQLRestClientDB, i.e. a local Client/Server driven usage
    // of the framework
    // - validates TSQLModel, TSQLRestServer and TSQLRestServerStatic by checking
    // the coherency of the data between client and server instances, after
    // update from both sides
    // - use all RESTful commands (GET/UDPATE/POST/DELETE...)
    // - test the 'many to many' features (i.e. TSQLRecordMany) and dynamic
    // arrays published properties handling
    // - also test FTS implementation if INCLUDE_FTS3 conditional is defined
    // - test dynamic tables
    procedure _TSQLRestClientDB;
  end;

  /// this test case will test most functions, classes and types defined and
  // implemented in the mORMotSQLite3 unit, i.e. the SQLite3 engine itself,
  // with a file-based approach
  TTestFileBased = class(TTestSQLite3Engine);

  /// this test case will test most functions, classes and types defined and
  // implemented in the mORMotSQLite3 unit, i.e. the SQLite3 engine itself,
  // with a memory-based approach
  // - this class will also test the TSQLRestServerStatic class, and its
  // 100% Delphi simple database engine
  TTestMemoryBased = class(TTestSQLite3Engine);

  /// this test case will test most functions, classes and types defined and
  // implemented in the mORMotSQLite3 unit, i.e. the SQLite3 engine itself,
  // with a file-based approach
  // - purpose of this class is to test Write-Ahead Logging for the database
  TTestFileBasedWAL = class(TTestFileBased);

  /// this test case will test most functions, classes and types defined and
  // implemented in the mORMotSQLite3 unit, i.e. the SQLite3 engine itself,
  // used as a HTTP/1.1 server and client
  // - test a HTTP/1.1 server and client on the port 888 of the local machine
  // - require the 'test.db3' SQLite3 database file, as created by TTestFileBased
  TTestClientServerAccess = class(TSynTestCase)
  protected
    { these values are used internaly by the published methods below }
    Model: TSQLModel;
    DataBase: TSQLRestServerDB;
    Server: TSQLHttpServer;
    Client: TSQLRestClient;
    /// perform the tests of the current Client instance
    procedure ClientTest;
    /// release used instances (e.g. http server) and memory
    procedure CleanUp; override;
  public
    /// this could be called as administrator for THttpApiServer to work
    class function RegisterAddUrl(OnlyDelete: boolean): string;
  published
    /// initialize a TSQLHttpServer instance
    // - uses the 'test.db3' SQLite3 database file generated by TTestSQLite3Engine
    // - creates and validates a HTTP/1.1 server on the port 888 of the local
    // machine, using the THttpApiServer (using kernel mode http.sys) class
    // if available
    procedure _TSQLHttpServer;
    /// validate the HTTP/1.1 client implementation
    // - by using a request of all records data
    procedure _TSQLHttpClient;
    /// validate the HTTP/1.1 client multi-query implementation with one
    // connection for the all queries
    // - this method keep alive the HTTP connection, so is somewhat faster
    // - it runs 1000 remote SQL queries, and check the JSON data retrieved
    // - the time elapsed for this step is computed, and displayed on the report
    procedure HttpClientKeepAlive;
    /// validate the HTTP/1.1 client multi-query implementation with one
    // connection initialized per query
    // - this method don't keep alive the HTTP connection, so is somewhat slower:
    // a new HTTP connection is created for every query
    // - it runs 1000 remote SQL queries, and check the JSON data retrieved
    // - the time elapsed for this step is computed, and displayed on the report
    procedure HttpClientMultiConnect;
{
    /// validate the HTTP/1.1 client multi-query implementation with one
    // connection for all queries, and the THttpServer class instead
    // of the THttpApiServer kernel mode server
    procedure HttpClientKeepAliveDelphi;
    /// validate the HTTP/1.1 client multi-query implementation with one
    // connection initialized per query, and the THttpServer class instead
    // of the THttpApiServer kernel mode server
    // - this method don't keep alive the HTTP connection, so is somewhat slower:
    // a new HTTP connection is created for every query
    procedure HttpClientMultiConnectDelphi;
}
    /// validate the Named-Pipe client implementation
    // - it first launch the Server as Named-Pipe
    // - it then runs 1000 remote SQL queries, and check the JSON data retrieved
    // - the time elapsed for this step is computed, and displayed on the report
    procedure NamedPipeAccess;
    /// validate the Windows GDI Messages based client implementation
    // - it first launch the Server to handle GDI messages
    // - it then runs 1000 remote SQL queries, and check the JSON data retrieved
    // - the time elapsed for this step is computed, and displayed on the report
    procedure LocalWindowMessages;
    /// validate the client implementation, using direct access to the server
    // - it connects directly the client to the server, therefore use the same
    // process and memory during the run: it's the fastest possible way of
    // communicating
    // - it then runs 1000 remote SQL queries, and check the JSON data retrieved
    // - the time elapsed for this step is computed, and displayed on the report
    procedure DirectInProcessAccess;
  end;

  /// this class defined two published methods of type TSQLRestServerCallBack in
  //  order to test the Server-Side ModelRoot/TableName/ID/MethodName RESTful model
  TSQLRestServerTest = class(TSQLRestServerDB)
  published
    {/ test ModelRoot/People/ID/DataAsHex
     - this method is called by TSQLRestServer.URI when a
       ModelRoot/People/ID/DataAsHex GET request is provided
     - Parameters values are not used here: this service only need aRecord.ID
     - SentData is set with incoming data from a PUT method
     - if called from ModelRoot/People/ID/DataAsHex with GET or PUT methods,
       TSQLRestServer.URI will create a TSQLRecord instance and set its ID
       (but won't retrieve its other field values automaticaly)
     - if called from ModelRoot/People/DataAsHex with GET or PUT methods,
       TSQLRestServer.URI will leave aRecord.ID=0 before launching it
     - if called from ModelRoot/DataAsHex with GET or PUT methods,
       TSQLRestServer.URI will leave aRecord=nil before launching it
     - implementation must return the HTTP error code (e.g. 200 as success)
     - Table is overloaded as TSQLRecordPeople here, and still match the
       TSQLRestServerCallBack prototype: but you have to check the class
       at runtime: it can be called by another similar but invalid URL, like
       ModelRoot/OtherTableName/ID/DataAsHex }
    procedure DataAsHex(var Ctxt: TSQLRestServerCallBackParams);
    {/ method used to test the Server-Side ModelRoot/Sum or
       ModelRoot/People/Sum Requests with JSON process
      - implementation of this method returns the sum of two floating-points,
        named A and B, as in the public TSQLRecordPeople.Sum() method,
        which implements the Client-Side of this service
      - Table nor ID are never used here }
    procedure Sum(var Ctxt: TSQLRestServerCallBackParams);
    {/ method used to test the Server-Side ModelRoot/Sum or
       ModelRoot/People/Sum Requests with variant process }
    procedure Sum2(var Ctxt: TSQLRestServerCallBackParams);
  end;

{$ifndef LVCL}
  /// a test case which will test most external DB functions of the mORMotDB unit
  // - the external DB will be in fact a SynDBSQLite3 instance, expecting a
  // test.db3 SQlite3 file available in the current directory, populated with
  // some TSQLRecordPeople rows
  // - note that SQL statement caching at SQLite3 engine level makes those test
  // 2 times faster
  TTestExternalDatabase = class(TSynTestCase)
  protected
    fModel: TSQLModel;
    procedure Test(StaticVirtualTableDirect: boolean);
  public
    /// release the associated memory and object instances
    destructor Destroy; override;
  published
    /// initialize needed RESTful client (and server) instances
    // - i.e. a RESTful direct access to an external DB
    procedure ExternalRecords;
    /// check the SQL auto-adaptation features
    procedure AutoAdaptSQL;
    /// check the per-db encryption
    // - the testpass.db3-wal file is not encrypted, but the main
    // testpass.db3 file will (after the first 1024 bytes)
    procedure CryptedDatabase;
    /// test external DB implementation via faster REST calls
    // - will mostly call directly the TSQLRestServerStaticExternal instance,
    // bypassing the Virtual Table mechanism of SQLite3
    procedure ExternalViaREST;
    /// test external DB implementation via slower Virtual Table calls
    // - using the Virtual Table mechanism of SQLite3 is more than 2 times
    // slower than direct REST access
    procedure ExternalViaVirtualTable;
  end;

{$endif LVCL}

  /// a test class, used by TTestServiceOrientedArchitecture
  // - to test TPersistent objects used as parameters for remote service calls
  TComplexNumber = class(TPersistent)
  private
    fReal: Double;
    fImaginary: Double;
  public
    /// create an instance to store a complex number
    constructor Create(aReal, aImaginary: double); reintroduce;
  published
    /// the real part of this complex number
    property Real: Double read fReal write fReal;
    /// the imaginary part of this complex number
    property Imaginary: Double read fImaginary write fImaginary;
  end;



  /// a test interface, used by TTestServiceOrientedArchitecture
  // - to test basic and high-level remote service calls
  ICalculator = interface(IInvokable)
    ['{9A60C8ED-CEB2-4E09-87D4-4A16F496E5FE}']
    /// add two signed 32 bit integers
    function Add(n1,n2: integer): integer;
    /// multiply two signed 64 bit integers
    function Multiply(n1,n2: Int64): Int64;
    /// substract two floating-point values
    function Subtract(n1,n2: double): double;
    /// convert a currency value into text
    procedure ToText(Value: Currency; var Result: RawUTF8);
    /// convert a floating-point value into text
    function ToTextFunc(Value: double): string;
    /// do some work with strings, sets and enumerates parameters,
    // testing also var (in/out) parameters and set as a function result
    function SpecialCall(Txt: RawUTF8; var Int: integer; var Card: cardinal; field: TSynTableFieldTypes;
      fields: TSynTableFieldTypes; var options: TSynTableFieldOptions): TSynTableFieldTypes;
    /// test integer, strings and wide strings dynamic arrays, together with records
    function ComplexCall(const Ints: TIntegerDynArray; Strs1: TRawUTF8DynArray;
      var Str2: TWideStringDynArray; const Rec1: TVirtualTableModuleProperties;
      var Rec2: TSQLRestCacheEntryValue; Float1: double; var Float2: double): TSQLRestCacheEntryValue;
  end;

  /// a test interface, used by TTestServiceOrientedArchitecture
  // - to test remote service calls with objects as parameters (its published
  // properties will be serialized as standard JSON objects)
  // - since it inherits from ICalculator interface, it will also test
  // the proper interface inheritance handling (i.e. it will test that
  // ICalculator methods are also available)
  IComplexCalculator = interface(ICalculator)
    ['{8D0F3839-056B-4488-A616-986CF8D4DEB7}']
    /// purpose of this method is to substract two complex numbers
    // - using class instances as parameters
    procedure Substract(n1,n2: TComplexNumber; out Result: TComplexNumber);
    /// purpose of this method is to check for boolean handling
    function IsNull(n: TComplexNumber): boolean;
    /// this will test the BLOB kind of remote answer
    function TestBlob(n: TComplexNumber): TServiceCustomAnswer;
    {$ifdef USEVARIANTS}
    /// test variant kind of parameters
    function TestVariants(const Text: RawUTF8; V1: Variant; var V2: variant): variant; 
    {$endif}
    {$ifndef LVCL}
    /// test in/out collections
    procedure Collections(Item: TCollTest; var List: TCollTestsI; out Copy: TCollTestsI);
    {$endif}
  end;

  /// a test interface, used by TTestServiceOrientedArchitecture
  // - to test sicClientDriven implementation pattern: data will remain on
  // the server until the IComplexNumber instance is out of scope
  IComplexNumber = interface(IInvokable)
    ['{29D753B2-E7EF-41B3-B7C3-827FEB082DC1}']
    procedure Assign(aReal, aImaginary: double);
    function GetImaginary: double;
    function GetReal: double;
    procedure SetImaginary(const Value: double);
    procedure SetReal(const Value: double);
    procedure Add(aReal, aImaginary: double);
    property Real: double read GetReal write SetReal;
    property Imaginary: double read GetImaginary write SetImaginary;
  end;

const
  IID_ICalculator: TGUID = '{9A60C8ED-CEB2-4E09-87D4-4A16F496E5FE}';

type
  /// a test case which will test the interface-based SOA implementation of
  // the mORMot framework
  TTestServiceOrientedArchitecture = class(TSynTestCase)
  protected
    fModel: TSQLModel;
    fClient: TSQLRestClientDB;
    procedure Test(const I: ICalculator; const CC: IComplexCalculator; const CN: IComplexNumber);
    procedure ClientTest(aRouting: TServiceRoutingMode; RunInMainThread: boolean=false);
    class function CustomReader(P: PUTF8Char; var aValue; out aValid: Boolean): PUTF8Char;
    class procedure CustomWriter(const aWriter: TTextWriter; const aValue);
    procedure IntSubtractJSON(Ctxt: TOnInterfaceStubExecuteParamsJSON);
  {$ifdef USEVARIANTS}
    procedure IntSubtractVariant(Ctxt: TOnInterfaceStubExecuteParamsVariant);
  {$endif}
    /// release used instances (e.g. http server) and memory
    procedure CleanUp; override;
  public
  published
    /// test the SetWeak/SetWeakZero weak interface functions
    procedure WeakInterfaces;
    /// initialize the SOA implementation
    procedure ServiceInitialization;
    /// test direct call to the class instance
    procedure DirectCall;
    /// test the server-side implementation
    procedure ServerSide;
    /// test the client-side implementation in RESTful mode
    procedure ClientSideREST;
    /// test the client-side implementation in JSON-RPC mode
    procedure ClientSideJSONRPC;
    {$ifndef LVCL}
    /// test the client-side implementation of ExecuteInMainThread() method
    procedure ClientSideSynchronizedREST;
    {$endif}
    /// test the security features
    procedure Security;
    /// test the custom record JSON serialization
    procedure CustomRecordLayout;
    /// test interface stubbing / mocking
    procedure MocksAndStubs;
  end;

{$endif DELPHI5OROLDER}
{$endif FPC}


implementation

uses
{$ifndef FPC}
{$ifndef LVCL}
  SynPdf,
{$endif}
{$ifdef ISDELPHIXE2}
  VCL.Graphics,
{$else}
  Graphics,
{$endif}
{$endif}
  SynCrypto,
  SynCrtSock,
  SynLZ,
  SynLzo,
  SynZip;




{ TTestLowLevelCommon }

procedure TTestLowLevelCommon._CamelCase;
var v: RawUTF8;
begin
  v := UnCamelCase('On'); Check(v='On');
  v := UnCamelCase('ON'); Check(v='ON');
  v := UnCamelCase('OnLine'); Check(v='On line');
  v := UnCamelCase('OnLINE'); Check(v='On LINE');
  v := UnCamelCase('OnMyLINE'); Check(v='On my LINE');
end;

procedure TTestLowLevelCommon.Bits;
var Bits: array[byte] of byte;
    Bits64: Int64 absolute Bits;
    Si,i: integer;
begin
  fillchar(Bits,sizeof(Bits),0);
  for i := 0 to high(Bits)*8+7 do
    Check(not GetBit(Bits,i));
  RandSeed := 10; // will reproduce the same Random() values
  for i := 1 to 100 do begin
    Si := Random(high(Bits));
    SetBit(Bits,Si);
    Check(GetBit(Bits,Si));
  end;
  RandSeed := 10;
  for i := 1 to 100 do
    Check(GetBit(Bits,Random(high(Bits))));
  RandSeed := 10;
  for i := 1 to 100 do begin
    Si := Random(high(Bits));
    UnSetBit(Bits,Si);
    Check(not GetBit(Bits,Si));
  end;
  for i := 0 to high(Bits)*8+7 do
    Check(not GetBit(Bits,i));
  for i := 0 to 63 do
    Check(not GetBit64(Bits,i));
  RandSeed := 10;
  for i := 1 to 30 do begin
    Si := Random(63);
    SetBit64(Bits64,Si);
    Check(GetBit64(Bits,Si));
  end;
  RandSeed := 10;
  for i := 1 to 30 do
    Check(GetBit64(Bits,Random(63)));
  RandSeed := 10;
  for i := 1 to 30 do begin
    Si := Random(63);
    UnSetBit64(Bits64,Si);
    Check(not GetBit64(Bits,Si));
  end;
  for i := 0 to 63 do
    Check(not GetBit64(Bits,i));
  Randomize; // we fixed the RandSeed value above -> get true random now
end;

procedure TTestLowLevelCommon.Curr64;
var tmp: string[63];
    i, err: Integer;
    V1: currency;
    V2: extended;
    i64: Int64;
    v: RawUTF8;
begin
  Check(TruncTo2Digits(1)=1);
  Check(TruncTo2Digits(1.05)=1.05);
  Check(TruncTo2Digits(1.051)=1.05);
  Check(TruncTo2Digits(1.0599)=1.05);
  Check(TruncTo2Digits(-1)=-1);
  Check(TruncTo2Digits(-1.05)=-1.05);
  Check(TruncTo2Digits(-1.051)=-1.05);
  Check(TruncTo2Digits(-1.0599)=-1.05);
  Check(SimpleRoundTo2Digits(1)=1);
  Check(SimpleRoundTo2Digits(1.05)=1.05);
  Check(SimpleRoundTo2Digits(1.051)=1.05);
  Check(SimpleRoundTo2Digits(1.0549)=1.05);
  Check(SimpleRoundTo2Digits(1.0550)=1.05);
  Check(SimpleRoundTo2Digits(1.0551)=1.06);
  Check(SimpleRoundTo2Digits(1.0599)=1.06);
  Check(SimpleRoundTo2Digits(-1)=-1);
  Check(SimpleRoundTo2Digits(-1.05)=-1.05);
  Check(SimpleRoundTo2Digits(-1.051)=-1.05);
  Check(SimpleRoundTo2Digits(-1.0549)=-1.05);
  Check(SimpleRoundTo2Digits(-1.0550)=-1.05);
  Check(SimpleRoundTo2Digits(-1.0551)=-1.06);
  Check(SimpleRoundTo2Digits(-1.0599)=-1.06);
  Check(StrToCurr64('.5')=5000);
  Check(StrToCurr64('.05')=500);
  Check(StrToCurr64('.005')=50);
  Check(StrToCurr64('.0005')=5);
  Check(StrToCurr64('.00005')=0);
  Check(StrToCurr64('0.5')=5000);
  Check(StrToCurr64('0.05')=500);
  Check(StrToCurr64('0.005')=50);
  Check(StrToCurr64('0.0005')=5);
  Check(StrToCurr64('0.00005')=0);
  Check(StrToCurr64('1.5')=15000);
  Check(StrToCurr64('1.05')=10500);
  Check(StrToCurr64('1.005')=10050);
  Check(StrToCurr64('1.0005')=10005);
  Check(StrToCurr64('1.00005')=10000);
  Check(StrToCurr64(pointer(Curr64ToStr(1)))=1);
  Check(StrToCurr64(pointer(Curr64ToStr(12)))=12);
  Check(StrToCurr64(pointer(Curr64ToStr(123)))=123);
  Check(StrToCurr64(pointer(Curr64ToStr(1234)))=1234);
  Check(StrToCurr64(pointer(Curr64ToStr(12340000)))=12340000);
  Check(StrToCurr64(pointer(Curr64ToStr(12345000)))=12345000);
  Check(StrToCurr64(pointer(Curr64ToStr(12345600)))=12345600);
  Check(StrToCurr64(pointer(Curr64ToStr(12345670)))=12345670);
  tmp[0] := AnsiChar(Curr64ToPChar(1,@tmp[1])); Check(tmp='0.0001');
  tmp[0] := AnsiChar(Curr64ToPChar(12,@tmp[1])); Check(tmp='0.0012');
  tmp[0] := AnsiChar(Curr64ToPChar(123,@tmp[1])); Check(tmp='0.0123');
  tmp[0] := AnsiChar(Curr64ToPChar(1234,@tmp[1])); Check(tmp='0.1234');
  for i := 0 to 5000 do begin
    if i<500 then
      V1 := i*3 else
      V1 := Random;
    if Random(10)<4 then
      V1 := -V1;
    v := Curr64ToStr(PInt64(@V1)^);
    tmp[0] := AnsiChar(Curr64ToPChar(PInt64(@V1)^,@tmp[1]));
    Check(RawUTF8(tmp)=v);
    V2 := GetExtended(pointer(v),err);
    Check(err=0);
    Check(Abs(V1-V2)<1E-10);
    i64 := StrToCurr64(pointer(v));
    Check(PInt64(@V1)^=i64);
  end;
end;

procedure TTestLowLevelCommon.FastStringCompare;
begin
  Check(StrIComp('abcD','ABcd')=0);
  Check(StrIComp('abcD','ABcF')=StrComp('ABCD','ABCF'));
  Check(StrComp('ABCD','ABCD')=0);
  Check(AnsiIComp('abcD','ABcd')=0);
  Check(AnsiIComp('abcD','ABcF')=StrComp('ABCD','ABCF'));
  Check(StrIComp('abcD','ABcd')=AnsiIComp('abcD','ABcd'));
  Check(StrIComp('abcD','ABcF')=AnsiIComp('ABCD','ABCF'));
end;

procedure TTestLowLevelCommon.IniFiles;
var Content,S,N,V: RawUTF8;
    Si,Ni,Vi,i,j: integer;
begin
  Content := '';
  Randomize;
  //RandSeed := 10;
  for i := 1 to 1000 do begin
    Si := Random(20);
    Ni := Random(50);
    Vi := Si*Ni+Ni;
    if Si=0 then
      S := '' else
      S := 'Section'+{$ifndef ENHANCEDRTL}Int32ToUtf8{$else}IntToStr{$endif}(Si);
    N := {$ifndef ENHANCEDRTL}Int32ToUtf8{$else}IntToStr{$endif}(Ni);
    V := {$ifndef ENHANCEDRTL}Int32ToUtf8{$else}IntToStr{$endif}(Vi);
    UpdateIniEntry(Content,S,N,V);
    for j := 1 to 5 do
      Check(FindIniEntry(Content,S,N)=V,'FindIniEntry');
    Check(FindIniEntry(Content,S,'no')='');
    Check(FindIniEntry(Content,'no',N)='');
  end;
  Check(FileFromString(Content,'test.ini'));
  Check(FileSynLZ('test.ini','test.ini.synlz',$ABA51051));
  if CheckFailed(FileUnSynLZ('test.ini.synlz','test2.ini',$ABA51051)) then
    Exit;
  Check(StringFromFile('test2.ini')=Content);
end;

procedure TTestLowLevelCommon.Soundex;
var e: cardinal;
    PC: PAnsiChar;
    Soundex: TSynSoundEx;
begin
  Check(SoundExAnsi(' 120 ')=0);
  if SOUNDEX_BITS=8 then
    e := $2050206 else
    e := $2526;
  Check(SoundExAnsi('bonjour')=e);
  Check(SoundExAnsi(' 123 bonjour.  m',@PC)=e);
  Check((PC<>nil) and (PC^='.'));
  Check(SoundExAnsi(' 123 bonjourtr'+chr(232)+'slongmotquid'+chr(233)+'passe  m',@PC)<>0);
  Check((PC<>nil) and (PC^=' '));
  Check(SoundExAnsi('BOnjour')=e);
  Check(SoundExAnsi('Bnjr')=e);
  Check(SoundExAnsi('bonchour')=e);
  Check(SoundExAnsi('mohammad')=SoundExAnsi('mohhhammeeet'));
  if SOUNDEX_BITS=8 then
    e := $2050206 else
    e := $25262;
  Check(SoundExAnsi('bonjours')=e);
  Check(SoundExAnsi('BOnjours')=e);
  Check(SoundExAnsi('Bnjrs')=e);
  Check(SoundExAnsi(' 120 ')=0);
  if SOUNDEX_BITS=8 then
    e := $2050206 else
    e := $2526;
  Check(SoundExUTF8('bonjour')=e);
  Check(SoundExUTF8(' 123 bonjour.  m',@PC)=e);
  Check((PC<>nil) and (PC^='m'));
  Check(SoundExUTF8(Pointer(WinAnsiToUTF8(
    ' 123 bonjourtr'+chr(232)+'slongmotquid'+chr(233)+'passe  m')),@PC)<>0);
  Check((PC<>nil) and (PC^='m'));
  Check(SoundExUTF8('BOnjour')=e);
  Check(SoundExUTF8('Bnjr')=e);
  Check(SoundExUTF8('bonchour')=e);
  Check(SoundExUTF8('mohammad')=SoundExUTF8('mohhhammeeet'));
  if SOUNDEX_BITS=8 then
    e := $2050206 else
    e := $25262;
  Check(SoundExUTF8('bonjours')=e);
  Check(SoundExUTF8('BOnjours')=e);
  Check(SoundExUTF8('Bnjrs')=e);
  Check(Soundex.Prepare('mohamad'));
  Check(Soundex.Ansi('moi rechercher mohammed ici'));
  Check(Soundex.UTF8('moi rechercher mohammed ici'));
  Check(Soundex.Ansi('moi mohammed'));
  Check(Soundex.UTF8('moi mohammed'));
  Check(not Soundex.Ansi('moi rechercher mouette ici'));
  Check(not Soundex.UTF8('moi rechercher mouette ici'));
  Check(not Soundex.Ansi('moi rechercher mouette'));
  Check(not Soundex.UTF8('moi rechercher mouette'));
end;

type
  TCity = record
    Name: string;
    Country: string;
    Latitude: double;
    Longitude: double;
  end;
  TCityDynArray = array of TCity;

  TAmount = packed record
    firmID: integer;
    amount: RawUTF8;
  end;
  TAmountCollection = array of TAmount;
  TAmountI = packed record
    firmID: integer;
    amount: integer;
  end;
  TAmountICollection = array of TAmountI;

procedure TTestLowLevelCommon._TDynArrayHashed;
var ACities: TDynArrayHashed;
    Cities: TCityDynArray;
    CitiesCount: integer;
    City: TCity;
    added: boolean;
    N: string;
    i,j: integer;
    A: TAmount;
    AI: TAmountI;
    AmountCollection: TAmountCollection;
    AmountICollection: TAmountICollection;
    AmountDA: TDynArrayHashed;
const CITIES_MAX=200000;
begin
  // default Init() will hash and compare binary content before string, i.e. firmID
  AmountDA.Init(TypeInfo(TAmountCollection), AmountCollection);
  Check(AmountDA.KnownType=djInteger);
  Check(@AmountDA.HashElement=@HashInteger);
  for i := 1 to 100 do begin
    A.firmID := i;
    A.amount := Int32ToUTF8(i);
    Check(AmountDA.Add(A)=i-1);
  end;
  AmountDA.ReHash;
  for i := 1 to length(AmountCollection) do
    Check(AmountDA.FindHashed(i)=i-1);
  // default Init() will hash and compare the WHOLE binary content, i.e. 8 bytes
  AmountDA.Init(TypeInfo(TAmountICollection), AmountICollection);
  Check(AmountDA.KnownType=djInt64);
  Check(@AmountDA.HashElement=@HashInt64);
  for i := 1 to 100 do begin
    AI.firmID := i;
    AI.amount := i*2;
    Check(AmountDA.Add(AI)=i-1);
  end;
  AmountDA.ReHash;
  for i := 1 to length(AmountICollection) do begin
    AI.firmID := i;
    AI.amount := i*2;
    Check(AmountDA.FindHashed(AI)=i-1);
  end;
  // specific hash & compare of the firmID integer first field
  AmountDA.Clear;
  AmountDA.InitSpecific(TypeInfo(TAmountICollection), AmountICollection, djInteger);
  Check(AmountDA.KnownType=djInteger);
  Check(@AmountDA.HashElement=@HashInteger);
  for i := 1 to 100 do begin
    AI.firmID := i;
    AI.amount := i*2;
    Check(AmountDA.Add(AI)=i-1);
  end;
  AmountDA.ReHash;
  for i := 1 to length(AmountICollection) do
    Check(AmountDA.FindHashed(i)>=0);
  // valide generic-like features
  // see http://docwiki.embarcadero.com/CodeExamples/en/Generics_Collections_TDictionary_(Delphi)
  ACities.Init(TypeInfo(TCityDynArray),Cities,nil,nil,nil,@CitiesCount);
  City.Name := 'Iasi';
  City.Country := 'Romania';
  City.Latitude := 47.16;
  City.Longitude := 27.58;
  ACities.Add(City);
  City.Name := 'London';
  City.Country := 'United Kingdom';
  City.Latitude := 51.5;
  City.Longitude := -0.17;
  ACities.Add(City);
  City.Name := 'Buenos Aires';
  City.Country := 'Argentina';
  City.Latitude := 0;
  City.Longitude := 0;
  ACities.Add(City);
  Check(ACities.Count=3);
  ACities.ReHash; // will use default hash, and search by Name = 1st field
  City.Name := 'Iasi';
  Check(ACities.FindHashedAndFill(City)=0);
  Check(City.Name='Iasi');
  Check(City.Country='Romania');
  CheckSame(City.Latitude,47.16);
  CheckSame(City.Longitude,27.58);
  Check(ACities.FindHashedAndDelete(City)=0);
  Check(City.Name='Iasi');
  Check(ACities.Find(City)<0);
  Check(ACities.FindHashed(City)<0);
  City.Name := 'Buenos Aires';
  City.Country := 'Argentina';
  City.Latitude := -34.6;
  City.Longitude := -58.45;
  Check(ACities.FindHashedAndUpdate(City,false)>=0);
  City.Latitude := 0;
  City.Longitude := 0;
  Check(City.Name='Buenos Aires');
  Check(ACities.FindHashedAndFill(City)>=0);
  CheckSame(City.Latitude,-34.6);
  CheckSame(City.Longitude,-58.45);
  Check(ACities.FindHashedForAdding(City,added)>=0);
  Check(not added);
  City.Name := 'Iasi';
  City.Country := 'Romania';
  City.Latitude := 47.16;
  City.Longitude := 27.58;
  i := ACities.FindHashedForAdding(City,added);
  Check(added);
  Check(i>0);
  if i>0 then begin
    Check(Cities[i].Name=''); // FindHashedForAdding left void content
    Cities[i] := City; // should fill Cities[i] content by hand
  end;
  Check(ACities.Count=3);
  Check(City.Name='Iasi');
  Check(ACities.FindHashed(City)>=0);
  for i := 1 to 2000 do begin
    City.Name := IntToString(i);
    City.Latitude := i*3.14;
    City.Longitude := i*6.13;
    Check(ACities.FindHashedAndUpdate(City,true)=i+2,'multiple ReHash');
    Check(ACities.FindHashed(City)=i+2);
  end;
  ACities.Capacity := CITIES_MAX+3; // make it as fast as possible
  for i := 2001 to CITIES_MAX do begin
    City.Name := IntToString(i);
    City.Latitude := i*3.14;
    City.Longitude := i*6.13;
    Check(ACities.FindHashedAndUpdate(City,true)=i+2,'use Capacity: no ReHash');
    Check(ACities.FindHashed(City.Name)=i+2);
  end;
  for i := 1 to CITIES_MAX do begin
    N := IntToString(i);
    j := ACities.FindHashed(N);
    Check(j=i+2,'hashing with string not City.Name');
    Check(Cities[j].Name=N);
    CheckSame(Cities[j].Latitude,i*3.14);
    CheckSame(Cities[j].Longitude,i*6.13);
  end;
end;

type
  TRec = packed record A: integer; B: byte; C: double; D: Currency; end;
  TRecs = array of TRec;
  TProvince = record
    Name: RawUTF8;
    Comment: RawUTF8;
    Year: cardinal;
    Cities: TCityDynArray;
  end;
  TFV = packed record
    Major, Minor, Release, Build: integer;
    Main, Detailed: string;
    BuildDateTime: TDateTime;
    BuildYear: integer;
  end;
  TFVs = array of TFV;
  TFV2 = packed record
    V1: TFV;
    Value: integer;
    V2: TFV;
    Text: string;
  end;
  TFV2s = array of TFV2;
  TSynValidates = array of TSynValidate;

function FVSort(const A,B): integer;
begin
  result := SysUtils.StrComp(PChar(pointer(TFV(A).Detailed)),PChar(pointer(TFV(B).Detailed)));
end;

procedure TTestLowLevelCommon._TDynArray;
var AI, AI2: TIntegerDynArray;
    AU: TRawUTF8DynArray;
    AR: TRecs;
    AF: TFVs;
    AF2: TFV2s;
    i,j,k,Len, count,AIcount: integer;
    U: RawUTF8;
    P: PUTF8Char;
    PI: PIntegerArray;
    R: TRec;
    F, F1: TFV;
    F2: TFV2;
    City: TCity;
    Province: TProvince;
    AV: TSynValidates;
    V: TSynValidate;
    AIP, AUP, ARP, AFP, ACities, AVP: TDynArray;
    Test, Test2: RawByteString;
    ST: TCustomMemoryStream;
    Index: TIntegerDynArray;
    W: TTextWriter;
    JSON_BASE64_MAGIC_UTF8: RawUTF8;
const MAGIC: array[0..1] of word = (34,$fff0);
procedure Fill(var F: TFV; i: integer);
begin
  F.Major := i;
  F.Minor := i+1;
  F.Release := i+2;
  F.Build := i+3;
  F.Main := IntToString(i+1000);
  F.Detailed := IntToString(2000-i);
  F.BuildDateTime := 36215.12;
  F.BuildYear := i+2011;
end;
procedure TestAF2;
var i: integer;
    F: TFV;
begin
  for i := 0 to AFP.Count-1 do begin
    Fill(F,i*2);
    Check(RecordEquals(F,AF2[i].V1,TypeInfo(TFV)));
    Check(AF2[i].Value=i);
    Fill(F,i*2+1);
    Check(RecordEquals(F,AF2[i].V2,TypeInfo(TFV)));
    Check(AF2[i].Text=IntToString(i));
  end;
end;
procedure Test64K;
var i, E, n: integer;
    D: TDynArray;
    IA: TIntegerDynArray;
begin
  D.Init(TypeInfo(TIntegerDynArray),IA,@n);
  D.Capacity := 16300;
  for i := 0 to 16256 do begin
    E := i*5;
    D.Add(E);
    Check(IA[i]=i*5);
  end;
  Check(D.Count=16257);
  Check(D.Capacity=16300);
  Check(length(IA)=D.Capacity);
  for i := 0 to 16256 do
    Check(IA[i]=i*5);
  Check(Hash32(D.SaveTo)=$36937D84);
end;
procedure TestCities;
var i: integer;
begin
  for i := 0 to ACities.Count-1 do
  with Province.Cities[i] do begin
    {$ifdef UNICODE}
    Check(StrToInt(Name)=i);
    {$else}
    Check(GetInteger(pointer(Name))=i);
    {$endif}
    CheckSame(Latitude,i*3.14);
    CheckSame(Longitude,i*6.13);
  end;
end;
begin
  W := TTextWriter.CreateOwnedStream;
  // validate TIntegerDynArray
  Test64K;
  AIP.Init(TypeInfo(TIntegerDynArray),AI);
  for i := 0 to 1000 do begin
    Check(AIP.Count=i);
    Check(AIP.Add(i)=i);
    Check(AIP.Count=i+1);
    Check(AI[i]=i);
  end;
  for i := 0 to 1000 do
    Check(AIP.IndexOf(i)=i);
  Test := AIP.SaveTo;
  Check(Hash32(Test)=$924462C);
  PI := IntegerDynArrayLoadFrom(pointer(Test),AIcount);
  Check(AIcount=1001);
  Check(PI<>nil);
  for i := 0 to 1000 do
    Check(PI[i]=i);
  W.AddDynArrayJSON(AIP);
  U := W.Text;
  P := pointer(U);
  for i := 0 to 1000 do
    Check(GetNextItemCardinal(P)=cardinal(i));
  Check(Hash32(U)=$CBDFDAFC);
  for i := 0 to 1000 do begin
    Test2 := AIP.ElemSave(i);
    Check(length(Test2)=4);
    k := 0;
    AIP.ElemLoad(pointer(Test2),k);
    Check(k=i);
    Check(AIP.ElemLoadFind(pointer(Test2))=i);
  end;
  AIP.Reverse;
  for i := 0 to 1000 do
    Check(AI[i]=1000-i);
  AIP.Clear;
  Check(AIP.LoadFrom(pointer(Test))<>nil);
  for i := 0 to 1000 do
    Check(AIP.IndexOf(i)=i);
  for i := 1000 downto 0 do
    if i and 3=0 then
      AIP.Delete(i);
  Check(AIP.Count=750);
  for i := 0 to 1000 do
    if i and 3=0 then
      Check(AIP.IndexOf(i)<0) else
      Check(AIP.IndexOf(i)>=0);
  AIP.Clear;
  Check(AIP.LoadFromJSON(pointer(U))<>nil);
  for i := 0 to 1000 do
    Check(AI[i]=i);
  AIP.Init(TypeInfo(TIntegerDynArray),AI,@AIcount);
  for i := 0 to 50000 do begin
    Check(AIP.Count=i,'use of AIcount should reset it to zero');
    Check(AIP.Add(i)=i);
    Check(AIP.Count=i+1);
    Check(AI[i]=i);
  end;
  AIP.Compare := SortDynArrayInteger;
  AIP.Sort;
  Check(AIP.Count=50001);
  for i := 0 to AIP.Count-1 do
    Check(AIP.Find(i)=i);
  Test := AIP.SaveTo;
  Check(Hash32(Test)=$B9F2502A);
  AIP.Reverse;
  for i := 0 to 50000 do
    Check(AI[i]=50000-i);
  AIP.Slice(AI2,2000,1000);
  Check(length(AI2)=2000);
  for i := 0 to 1999 do
    Check(AI2[i]=49000-i);
  AIP.AddArray(AI2,1000,2000);
  Check(AIP.Count=51001);
  for i := 0 to 50000 do
    Check(AI[i]=50000-i);
  for i := 0 to 999 do
    Check(AI[i+50001]=48000-i);
  AIP.Clear;
  with DynArray(TypeInfo(TIntegerDynArray),AI) do begin
    Check(LoadFrom(pointer(Test))<>nil);
    for i := 0 to Count-1 do
      Check(AI[i]=i);
  end;
  // validate TSynValidates (an array of classes is an array of PtrInt)
  AVP.Init(TypeInfo(TSynValidates),AV);
  for i := 0 to 1000 do begin
    Check(AVP.Count=i);
    PtrInt(V) := i;
    Check(AVP.Add(V)=i);
    Check(AVP.Count=i+1);
    Check(AV[i]=V);
  end;
  Check(length(AV)=1001);
  Check(AVP.Count=1001);
  for i := 0 to 1000 do
    Check(AVP.IndexOf(i)=i);
  Test := AVP.SaveTo;
  Check(Hash32(Test)={$ifdef CPU64}$31484630{$else}$924462C{$endif});
  // validate TRawUTF8DynArray
  AUP.Init(TypeInfo(TRawUTF8DynArray),AU);
  for i := 0 to 1000 do begin
    Check(AUP.Count=i);
    U := Int32ToUtf8(i+1000);
    Check(AUP.Add(U)=i);
    Check(AUP.Count=i+1);
    Check(AU[i]=U);
  end;
  for i := 0 to 1000 do begin
    U := Int32ToUtf8(i+1000);
    Check(AUP.IndexOf(U)=i);
  end;
  Test := AUP.SaveTo;
  Check(Hash32(@Test[2],length(Test)-1)=$D9359F89); // trim Test[1]=ElemSize
  for i := 0 to 1000 do begin
    U := Int32ToUtf8(i+1000);
    Check(RawUTF8DynArrayLoadFromContains(pointer(Test),pointer(U),length(U),false)=i);
    Check(RawUTF8DynArrayLoadFromContains(pointer(Test),pointer(U),length(U),true)=i);
  end;
  for i := 0 to 1000 do begin
    U := Int32ToUtf8(i+1000);
    Test2 := AUP.ElemSave(U);
    Check(length(Test2)>4);
    U := '';
    AUP.ElemLoad(pointer(Test2),U);
    Check(GetInteger(pointer(U))=i+1000);
    Check(AUP.ElemLoadFind(pointer(Test2))=i);
  end;
  W.CancelAll;
  W.AddDynArrayJSON(AUP);
  W.SetText(U);
  Check(Hash32(U)=$1D682EF8);
  P := pointer(U);
  if not CheckFailed(P^='[') then inc(P);
  for i := 0 to 1000 do begin
    Check(P^='"'); inc(P);
    Check(GetNextItemCardinal(P)=cardinal(i+1000));
  end;
  Check(P=nil);
  AUP.Clear;
  Check(AUP.LoadFrom(pointer(Test))-pointer(Test)=length(Test));
  AUP.Clear;
  Check(AUP.LoadFromJSON(pointer(U))<>nil);
  for i := 0 to 1000 do
    Check(GetInteger(pointer(AU[i]))=i+1000);
  for i := 0 to 1000 do begin
    U := Int32ToUtf8(i+1000);
    Check(AUP.IndexOf(U)=i);
  end;
  for i := 1000 downto 0 do
    if i and 3=0 then
      AUP.Delete(i);
  Check(AUP.Count=750);
  for i := 0 to 1000 do begin
    U := Int32ToUtf8(i+1000);
    if i and 3=0 then
      Check(AUP.IndexOf(U)<0) else
      Check(AUP.IndexOf(U)>=0);
  end;
  U := 'inserted';
  AUP.Insert(500,U);
  Check(AUP.IndexOf(U)=500);
  j := 0;
  for i := 0 to AUP.Count-1 do
    if i<>500 then begin
      U := Int32ToUtf8(j+1000);
      if j and 3=0 then
        Check(AUP.IndexOf(U)<0) else
        Check(AUP.IndexOf(U)>=0);
      inc(j);
  end;
  AUP.CreateOrderedIndex(Index,SortDynArrayAnsiString);
  Check(StrComp(pointer(AU[Index[750]]),pointer(AU[Index[749]]))>0);
  for i := 1 to AUP.Count-1 do
    Check(AU[Index[i]]>AU[Index[i-1]]);
  AUP.Compare := SortDynArrayAnsiString;
  AUP.Sort;
  Check(AUP.Sorted);
  Check(AU[AUP.Count-1]='inserted');
  for i := 1 to AUP.Count-1 do
    Check(AU[i]>AU[i-1]);
  j := 0;
  for i := 0 to AUP.Count-1 do
    if i<>500 then begin
      U := Int32ToUtf8(j+1000);
      if j and 3=0 then
        Check(AUP.Find(U)<0) else
        Check(AUP.Find(U)>=0);
      inc(j);
  end;
  AUP.Sorted := false;
  j := 0;
  for i := 0 to AUP.Count-1 do
    if i<>500 then begin
      U := Int32ToUtf8(j+1000);
      if j and 3=0 then
        Check(AUP.Find(U)<0) else
        Check(AUP.Find(U)>=0);
      inc(j);
  end;
  // validate packed binary record (no string inside)
  ARP.Init(TypeInfo(TRecs),AR);
  for i := 0 to 1000 do begin
    Check(ARP.Count=i);
    R.A := i;
    R.B := i+1;
    R.C := i*2.2;
    R.D := i*3.25;
    Check(ARP.Add(R)=i);
    Check(ARP.Count=i+1);
  end;
  for i := 0 to 1000 do begin
    with AR[i] do begin
      Check(A=i);
      Check(B=byte(i+1));
      CheckSame(C,i*2.2);
      Check(D=i*3.25);
    end;
    R.A := i;
    R.B := i+1;
    R.C := i*2.2;
    R.D := i*3.25;
    Check(ARP.IndexOf(R)=i); // will work (packed + no ref-counted types inside)
  end;
  W.CancelAll;
  W.AddDynArrayJSON(ARP);
  U := W.Text;
  Check(Hash32(U)={$ifdef CPU64}$9F98936D{$else}$54659D65{$endif});
  P := pointer(U);
  JSON_BASE64_MAGIC_UTF8 := RawUnicodeToUtf8(@MAGIC,2);
  Check(U='['+JSON_BASE64_MAGIC_UTF8+BinToBase64(ARP.SaveTo)+'"]');
  ARP.Clear;
  Check(ARP.LoadFromJSON(pointer(U))<>nil);
  if not CheckFailed(ARP.Count=1001) then
    for i := 0 to 1000 do
    with AR[i] do begin
      Check(A=i);
      Check(B=byte(i+1));
      CheckSame(C,i*2.2);
      Check(D=i*3.25);
    end;
  // validate packed record with strings inside
  AFP.Init(TypeInfo(TFVs),AF);
  for i := 0 to 1000 do begin
    Check(AFP.Count=i);
    Fill(F,i);
    Check(AFP.Add(F)=i);
    Check(AFP.Count=i+1);
  end;
  Fill(F,100);
  Check(RecordEquals(F,AF[100],TypeInfo(TFV)));
  Len := RecordSaveLength(F,TypeInfo(TFV));
  Check(Len=38{$ifdef UNICODE}+length(F.Main)+length(F.Detailed){$endif});
  SetLength(Test,Len);
  Check(RecordSave(F,pointer(Test),TypeInfo(TFV))-pointer(Test)=Len);
  Fill(F,0);
  Check(RecordLoad(F,pointer(Test),TypeInfo(TFV))-pointer(Test)=Len);
  Check(RecordEquals(F,AF[100],TypeInfo(TFV)));
  for i := 0 to 1000 do
    with AF[i] do begin
      Check(Major=i);
      Check(Minor=i+1);
      Check(Release=i+2);
      Check(Build=i+3);
      Check(Main=IntToString(i+1000));
      Check(Detailed=IntToString(2000-i));
      CheckSame(BuildDateTime,36215.12);
      Check(BuildYear=i+2011);
    end;
  for i := 0 to 1000 do begin
    Fill(F,i);
    Check(AFP.IndexOf(F)=i);
  end;
  Test := AFP.SaveTo;
  Check(Hash32(Test)={$ifdef CPU64}$A29C10E{$else}
    {$ifdef UNICODE}$62F9C106{$else}$6AA2215E{$endif}{$endif});
  for i := 0 to 1000 do begin
    Fill(F,i);
    AFP.ElemCopy(F,F1);
    Check(AFP.ElemEquals(F,F1));
    Test2 := AFP.ElemSave(F);
    Check(length(Test2)>4);
    AFP.ElemClear(F);
    AFP.ElemLoad(pointer(Test2),F);
    Check(AFP.ElemEquals(F,F1));
    Check(AFP.ElemLoadFind(pointer(Test2))=i);
  end;
  W.CancelAll;
  W.AddDynArrayJSON(AFP);
  U := W.Text;
  Check(U='['+JSON_BASE64_MAGIC_UTF8+BinToBase64(Test)+'"]');
  AFP.Clear;
  Check(AFP.LoadFrom(pointer(Test))-pointer(Test)=length(Test));
  for i := 0 to 1000 do begin
    Fill(F,i);
    Check(AFP.IndexOf(F)=i);
  end;
  ST := THeapMemoryStream.Create;
  AFP.SaveToStream(ST);
  AFP.Clear;
  ST.Position := 0;
  AFP.LoadFromStream(ST);
  Check(ST.Position=length(Test));
  for i := 0 to 1000 do begin
    Fill(F,i);
    Check(AFP.IndexOf(F)=i);
  end;
  ST.Free;
  AFP.Clear;
  Check(AFP.LoadFromJSON(pointer(U))<>nil);
  for i := 0 to 1000 do begin
    Fill(F,i);
    Check(RecordEquals(F,AF[i],AFP.ElemType));
  end;
  for i := 0 to 1000 do begin
    Fill(F,i);
    F.BuildYear := 10;
    Check(AFP.IndexOf(F)<0);
    F.BuildYear := i+2011;
    F.Detailed := '??';
    Check(AFP.IndexOf(F)<0);
  end;
  for i := 1000 downto 0 do
    if i and 3=0 then
      AFP.Delete(i);
  Check(AFP.Count=750);
  for i := 0 to 1000 do begin
    Fill(F,i);
    if i and 3=0 then
      Check(AFP.IndexOf(F)<0) else
      Check(AFP.IndexOf(F)>=0);
  end;
  Fill(F,5000);
  AFP.Insert(500,F);
  Check(AFP.IndexOf(F)=500);
  j := 0;
  for i := 0 to AFP.Count-1 do
    if i<>500 then begin
      Fill(F,j);
      if j and 3=0 then
        Check(AFP.IndexOf(F)<0) else
        Check(AFP.IndexOf(F)>=0);
      inc(j);
  end;
  Finalize(Index);
  AFP.CreateOrderedIndex(Index,FVSort);
  for i := 1 to AUP.Count-1 do
    Check(AF[Index[i]].Detailed>AF[Index[i-1]].Detailed);
  AFP.Compare := FVSort;
  AFP.Sort;
  for i := 1 to AUP.Count-1 do
    Check(AF[i].Detailed>AF[i-1].Detailed);
  j := 0;
  for i := 0 to AFP.Count-1 do
    if i<>500 then begin
      Fill(F,j);
      if j and 3=0 then
        Check(AFP.Find(F)<0) else
        Check(AFP.Find(F)>=0);
      inc(j);
  end;
  W.Free;
  // validate packed record with records of strings inside
  AFP.Init(Typeinfo(TFV2s),AF2);
  for i := 0 to 1000 do begin
    Fill(F2.V1,i*2);
    F2.Value := i;
    Fill(F2.V2,i*2+1);
    F2.Text := IntToString(i);
    Check(AFP.Add(F2)=i);
  end;
  Check(AFP.Count=1001);
  TestAF2;
  Test := AFP.SaveTo;
  AFP.Clear;
  Check(AFP.Count=0);
  Check(AFP.LoadFrom(pointer(Test))<>nil);
  Check(AFP.Count=1001);
  TestAF2;
  // valide generic-like features
  // see http://docwiki.embarcadero.com/CodeExamples/en/Generics_Collections_TDictionary_(Delphi)
  ACities.Init(TypeInfo(TCityDynArray),Province.Cities);
  City.Name := 'Iasi';
  City.Country := 'Romania';
  City.Latitude := 47.16;
  City.Longitude := 27.58;
  ACities.Add(City);
  City.Name := 'London';
  City.Country := 'United Kingdom';
  City.Latitude := 51.5;
  City.Longitude := -0.17;
  ACities.Add(City);
  City.Name := 'Buenos Aires';
  City.Country := 'Argentina';
  City.Latitude := 0;
  City.Longitude := 0;
  ACities.Add(City);
  Check(ACities.Count=3);
  ACities.Compare := SortDynArrayString; // will search by Name = 1st field
  City.Name := 'Iasi';
  Check(ACities.FindAndFill(City)=0);
  Check(City.Name='Iasi');
  Check(City.Country='Romania');
  CheckSame(City.Latitude,47.16);
  CheckSame(City.Longitude,27.58);
  Check(ACities.FindAndDelete(City)=0);
  Check(City.Name='Iasi');
  Check(ACities.Find(City)<0);
  City.Name := 'Buenos Aires';
  City.Country := 'Argentina';
  City.Latitude := -34.6;
  City.Longitude := -58.45;
  Check(ACities.FindAndUpdate(City)>=0);
  City.Latitude := 0;
  City.Longitude := 0;
  Check(City.Name='Buenos Aires');
  Check(ACities.FindAndFill(City)>=0);
  CheckSame(City.Latitude,-34.6);
  CheckSame(City.Longitude,-58.45);
  Check(ACities.FindAndAddIfNotExisting(City)>=0);
  City.Name := 'Iasi';
  City.Country := 'Romania';
  City.Latitude := 47.16;
  City.Longitude := 27.58;
  Check(ACities.FindAndAddIfNotExisting(City)<0);
  Check(City.Name='Iasi');
  Check(ACities.FindAndUpdate(City)>=0);
  ACities.Sort;
  for i := 1 to high(Province.Cities) do
    Check(Province.Cities[i].Name>Province.Cities[i-1].Name);
  Check(ACities.Count=3);
  // complex record test
  Province.Name := 'Test';
  Province.Comment := 'comment';
  Province.Year := 1000;
  Test := RecordSave(Province,TypeInfo(TProvince));
  RecordClear(Province,TypeInfo(TProvince));
  Check(Province.Name='');
  Check(Province.Comment='');
  Check(length(Province.Cities)=0);
  Check(ACities.Count=0);
  Province.Year := 0;
  Check(RecordLoad(Province,pointer(Test),TypeInfo(TProvince))^=#0);
  Check(Province.Name='Test');
  Check(Province.Comment='comment');
  Check(Province.Year=1000);
  Check(length(Province.Cities)=3);
  Check(ACities.Count=3);
  for i := 1 to high(Province.Cities) do
    Check(Province.Cities[i].Name>Province.Cities[i-1].Name);
  // big array test
  ACities.Init(TypeInfo(TCityDynArray),Province.Cities);
  ACities.Clear;
  for i := 0 to 10000 do begin
    City.Name := IntToString(i);
    City.Latitude := i*3.14;
    City.Longitude := i*6.13;
    Check(ACities.Add(City)=i);
  end;
  Check(ACities.Count=Length(Province.Cities));
  Check(ACities.Count=10001);
  TestCities;
  ACities.Init(TypeInfo(TCityDynArray),Province.Cities,@count);
  ACities.Clear;
  for i := 0 to 100000 do begin
    City.Name := IntToString(i);
    City.Latitude := i*3.14;
    City.Longitude := i*6.13;
    Check(ACities.Add(City)=i);
  end;
  Check(ACities.Count=count);
  TestCities;
end;

procedure TTestLowLevelCommon.SystemCopyRecord;
type TR = record
       One: integer;
       S1: AnsiString;
       Three: byte;
       S2: WideString;
       Five: boolean;
{$ifndef LINUX}{$ifndef LVCL}
       V: Variant; {$endif}{$endif}
       R: Int64Rec;
       Arr: array[0..10] of AnsiString;
       Dyn: array of integer;
       Bulk: array[0..9] of byte;
     end;
var A,B,C: TR;
begin
  if PosEx('Synopse framework',RawUTF8(Owner.CustomVersions),1)=0 then
    Owner.CustomVersions := Owner.CustomVersions+#13#10'Synopse framework used: '+
      SYNOPSE_FRAMEWORK_VERSION;
  fillchar(A,sizeof(A),0);
  A.S1 := 'one';
  A.S2 := 'two';
  A.Five := true;
  A.Three := $33;
{$ifndef LINUX}{$ifndef LVCL}
  A.V := 'One Two';
{$endif}{$endif}
  A.R.Lo := 10;
  A.R.Hi := 20;
  A.Arr[5] := 'five';
  SetLength(A.Dyn,10);
  A.Dyn[9] := 9;
  B := A;
  Check(A.One=B.One);
  Check(A.S1=B.S1);
  Check(A.Three=B.Three);
  Check(A.S2=B.S2);
  Check(A.Five=B.Five);
  {$ifndef LINUX}{$ifndef LVCL} Check(A.V=B.V); {$endif}{$endif}
  Check(Int64(A.R)=Int64(B.R));
  Check(A.Arr[5]=B.Arr[5]);
  Check(A.Arr[0]=B.Arr[0]);
  Check(A.Dyn[9]=B.Dyn[9]);
  Check(A.Dyn[0]=0);
  B.Three := 3;
  B.Dyn[0] := 10;
  C := B;
  Check(A.One=C.One);
  Check(A.S1=C.S1);
  Check(C.Three=3);
  Check(A.S2=C.S2);
  Check(A.Five=C.Five);
  {$ifndef LINUX}{$ifndef LVCL} Check(A.V=C.V); {$endif}{$endif}
  Check(Int64(A.R)=Int64(C.R));
  Check(A.Arr[5]=C.Arr[5]);
  Check(A.Arr[0]=C.Arr[0]);
  Check(A.Dyn[9]=C.Dyn[9]);
  {Check(A.Dyn[0]=0) bug in original VCL?}
  Check(C.Dyn[0]=10);
end;

procedure TTestLowLevelCommon.UrlEncoding;
var i: integer;
    s: RawByteString;
const GUID: TGUID = '{c9a646d3-9c61-4cb7-bfcd-ee2522c8f633}';
begin
  Check(UrlEncode('abcdef')='abcdef');
  Check(UrlEncode('abcdefyzABCDYZ01239_-.~ ')='abcdefyzABCDYZ01239_-.~+');
  Check(UrlEncode('"Aardvarks lurk, OK?"')='%22Aardvarks+lurk%2C+OK%3F%22');
  for i := 0 to 100 do begin
    s := RandomString(i*5);
    Check(UrlDecode(UrlEncode(s))=s,string(s));
  end;
  Check(BinToBase64URI(@GUID,sizeof(GUID))='00amyWGct0y_ze4lIsj2Mw');
end;

procedure TTestLowLevelCommon._IsMatch;
var i: integer;
    V: RawUTF8;
begin
  for i := 0 to 200 do begin
    V := Int32ToUtf8(i);
    Check(IsMatch(V,V,false)=IsMatch(V,V,true));
  end;
  Check(IsMatch('*.pas','Bidule.pas',true));
  Check(IsMatch('*.pas','Bidule.pas',false));
  Check(IsMatch('*.PAS','Bidule.pas',true));
  Check(not IsMatch('*.PAS','Bidule.pas',false));
  Check(IsMatch('bidule.*','Bidule.pas',true));
  Check(IsMatch('ma?ch.*','match.exe',false));
  Check(IsMatch('ma?ch.*','mavch.dat',false));
  Check(IsMatch('ma?ch.*','march.on',false));
  Check(IsMatch('ma?ch.*','march.',false));
  Check(IsMatch('this [e-n]s a [!zy]est','this is a test',false));
  Check(IsMatch('this [e-n]s a [!zy]est','this is a rest',false));
  Check(not IsMatch('this [e-n]s a [!zy]est','this is a zest',false));
  Check(not IsMatch('this [e-n]s a [!zy]est','this as a test',false));
  Check(not IsMatch('this [e-n]s a [!zy]est','this as a rest',false));
  for i := 32 to 127 do begin
    V := AnsiChar(i);
    Check(IsMatch('[A-Za-z0-9]',V)=(i in IsWord));
    Check(IsMatch('[01-456a-zA-Z789]',V)=(i in IsWord));
    V := V+V+V;
    Check(IsMatch('[A-Za-z0-9]?[A-Za-z0-9]',V)=(i in IsWord));
    Check(IsMatch('[A-Za-z0-9]*',V)=(i in IsWord));
  end;
end;

function kr32pas(buf: PAnsiChar; len: cardinal): cardinal;
var i: integer;
begin
  result := 0;
  for i := 0 to len-1 do
    result := result*31+ord(buf[i]);
end;

{.$define EXTENDEDTOSTRING_USESTR}

{$ifndef WITHUXTHEME}
  {$define EXTENDEDTOSTRING_USESTR} // no TFormatSettings before Delphi 6
{$endif}

{$ifndef CONDITIONALEXPRESSIONS}
  {$define EXTENDEDTOSTRING_USESTR} // no TFormatSettings before Delphi 6
{$endif}

{$ifdef LVCL}
  {$define EXTENDEDTOSTRING_USESTR} // no FloatToText() implemented in LVCL
{$endif}

{$ifdef FPC}
  {$define EXTENDEDTOSTRING_USESTR} // FloatToText() maps str() in FPC
{$endif}

{$ifdef CPU64}
  {$define EXTENDEDTOSTRING_USESTR} // FloatToText() slower in x64
{$endif}

procedure TTestLowLevelCommon.NumericalConversions;
var i, j, b, err: integer;
    juint: cardinal absolute j;
    k,l: Int64;
    s: RawUTF8;
    d,e: double;
    a: shortstring;
    u: string;
    varint: array[0..17] of byte;
    PB,PC: PByte;
    P: PUTF8Char;
begin
  Check(IntToThousandString(0)='0');
  Check(IntToThousandString(1)='1');
  Check(IntToThousandString(10)='10');
  Check(IntToThousandString(100)='100');
  Check(IntToThousandString(1000)='1,000');
  Check(IntToThousandString(10000)='10,000');
  Check(IntToThousandString(100000)='100,000');
  Check(IntToThousandString(1000000)='1,000,000');
  Check(IntToThousandString(-1)='-1');
  Check(IntToThousandString(-10)='-10');
  Check(IntToThousandString(-100)='-100');
  Check(IntToThousandString(-1000)='-1,000');
  Check(IntToThousandString(-10000)='-10,000');
  Check(IntToThousandString(-100000)='-100,000');
  Check(IntToThousandString(-1000000)='-1,000,000');
  u := DoubleToString(40640.5028819444);
  Check(u='40640.5028819444',u);
  d := 22.99999999999997;
  a[0] := AnsiChar(ExtendedToString(a,d,DOUBLE_PRECISION));
  Check(a='23');
  d := 0.9999999999999997;
  a[0] := AnsiChar(ExtendedToString(a,d,DOUBLE_PRECISION));
  Check(a='1');
  d := -0.9999999999999997;
  a[0] := AnsiChar(ExtendedToString(a,d,DOUBLE_PRECISION));
  Check(a='-1');
  d := 9.999999999999997;
  a[0] := AnsiChar(ExtendedToString(a,d,DOUBLE_PRECISION));
  Check(a='10');
  d := -9.999999999999997;
  a[0] := AnsiChar(ExtendedToString(a,d,DOUBLE_PRECISION));
  Check(a='-10');
  d := 999.9999999999997;
  a[0] := AnsiChar(ExtendedToString(a,d,DOUBLE_PRECISION));
  Check(a='1000');
  d := 999.9999999999933;
  a[0] := AnsiChar(ExtendedToString(a,d,DOUBLE_PRECISION));
  Check(a='999.999999999993');
{$ifdef EXTENDEDTOSTRING_USESTR}
  Check(DoubleToString(-3.3495117168e-10)='-0.00000000033495');
  Check(DoubleToString(-3.3495617168e-10)='-0.00000000033496');
  Check(DoubleToString(-3.9999617168e-14)='-0.00000000000004');
  Check(DoubleToString(3.9999617168e-14)='0.00000000000004');
  Check(DoubleToString(-3.9999617168e-15)='0');
  Check(DoubleToString(3.9999617168e-15)='0');
{$else}
  Check(DoubleToString(-3.3495117168e-10)='-3.3495117168E-10');
  Check(DoubleToString(-3.3495617168e-10)='-3.3495617168E-10');
  Check(DoubleToString(-3.9999617168e-14)='-3.9999617168E-14');
  Check(DoubleToString(3.9999617168e-14)='3.9999617168E-14');
  Check(DoubleToString(-3.9999617168e-15)='-3.9999617168E-15');
  Check(DoubleToString(3.9999617168e-15)='3.9999617168E-15');
{$endif}

{$ifndef LVCL}
  {$ifdef ISDELPHIXE}FormatSettings.{$endif}{$ifdef FPC}FormatSettings.{$endif}
  DecimalSeparator := '.';
{$endif}
  for i := 0 to 10000 do begin
    j := Random(maxInt)-Random(maxInt);
    str(j,a);
    s := RawUTF8(a);
    Check(kr32(0,pointer(s),length(s))=kr32pas(pointer(s),length(s)));
    u := string(a);
    Check(SysUtils.IntToStr(j)=u);
    Check(Int32ToUtf8(j)=s);
    Check(format('%d',[j])=u);
    Check(GetInteger(pointer(s))=j);
{$ifndef DELPHI5OROLDER}
    Check(FormatUTF8('%',[j])=s);
    Check(FormatUTF8('?',[],[j])=':('+s+'):');
{$endif}
    k := Int64(j)*Random(MaxInt);
    b := Random(64);
    s := GetBitCSV(k,b);
    l := 0;
    P := pointer(s);
    SetBitCSV(l,b,P);
    Check(P=nil);
    while b>0 do begin
      dec(b);
      Check(GetBit(l,b)=GetBit(k,b));
    end;
    str(k,a);
    s := RawUTF8(a);
    u := string(a);
    Check(SysUtils.IntToStr(k)=u);
    Check(Int64ToUtf8(k)=s);
    Check(IntToString(k)=u);
    Check(format('%d',[k])=u);
{$ifndef DELPHI5OROLDER}
    Check(FormatUTF8('%',[k])=s);
    Check(FormatUTF8('?',[],[k])=':('+s+'):');
{$endif}
    err := 1;
    l := GetInt64(pointer(s),err);
    Check((err=0)and(l=k));
    SetInt64(pointer(s),l);
    Check(l=k);
    str(j,a);
    Check(SysUtils.IntToStr(j)=string(a));
    Check(format('%d',[j])=string(a));
    Check(format('%.8x',[j])=IntToHex(j,8));
    d := Random*1E-17-Random*1E-9;
    str(d,a);
    s := RawUTF8(a);
    e := GetExtended(Pointer(s),err);
    Check(SameValue(e,d)); // test str()
    s := ExtendedToStr(d,DOUBLE_PRECISION);
    e := GetExtended(Pointer(s),err);
    Check(SameValue(e,d));
    u := DoubleToString(d);
    Check(Ansi7ToString(s)=u,u);
    PC := ToVarUInt32(juint,@varint);
    Check(PC<>nil);
    Check(PAnsiChar(PC)-@varint=integer(ToVarUInt32Length(juint)));
    PB := @varint;
    Check(PtrUInt(FromVarUint32(PB))=juint);
    Check(PB=PC);
    PC := ToVarUInt32(i,@varint);
    Check(PC<>nil);
    PB := @varint;
    Check(PtrInt(FromVarUint32(PB))=i);
    Check(PB=PC);
    PC := ToVarInt32(j,@varint);
    Check(PC<>nil);
    PB := @varint;
    Check(FromVarInt32(PB)=j);
    Check(PB=PC);
    PC := ToVarInt32(i-1,@varint);
    Check(PC<>nil);
    PB := @varint;
    Check(FromVarInt32(PB)=i-1);
    Check(PB=PC);
    PC := ToVarInt64(k,@varint);
    Check(PC<>nil);
    PB := @varint;
    Check(FromVarInt64(PB)=k);
    Check(PB=PC);
    PC := ToVarInt64(i,@varint);
    Check(PC<>nil);
    PB := @varint;
    Check(FromVarInt64(PB)=i);
    Check(PB=PC);
    if k<0 then
      k := -k;
    PC := ToVarUInt64(k,@varint);
    Check(PC<>nil);
    PB := @varint;
    Check(FromVarUint64(PB)=k);
    Check(PB=PC);
    PC := ToVarUInt64(i,@varint);
    Check(PC<>nil);
    PB := @varint;
    Check(FromVarUint64(PB)=i);
    Check(PB=PC);
  end;
end;

procedure TTestLowLevelCommon.Unicode_UTF8;
var i, CP, L: integer;
    C: TSynAnsiConvert;
    W: WinAnsiString;
    WS: WideString;
    SU: SynUnicode;
    U, res, Up,Up2: RawUTF8;
{$ifndef DELPHI5OROLDER}
    q: RawUTF8;
{$endif}
    Unic: RawUnicode;
    WA: Boolean;
begin
  Check(AddPrefixToCSV('One,Two,Three','Pre')='PreOne,PreTwo,PreThree');
  Check(CSVOfValue('?',3)='?,?,?');
{$ifndef DELPHI5OROLDER}
  Check(FormatUTF8('abcd',[U],[WS])='abcd');
{$endif}
  for i := 0 to 1000 do begin
    W := WinAnsiString(RandomString(i*5));
    Check(length(W)=i*5);
    for CP := 1250 to 1257 do begin
      C := TSynAnsiConvert.Engine(CP);
      Check(C.UTF8ToAnsi(C.AnsiToUTF8(W))=W);
      Check(C.RawUnicodeToAnsi(C.AnsiToRawUnicode(W))=W);
    end;
    U := WinAnsiToUtf8(W);
    Check(Utf8ToWinAnsi(U)=W);
    Check(WinAnsiConvert.UTF8ToAnsi(WinAnsiConvert.AnsiToUTF8(W))=W);
    Check(WinAnsiConvert.RawUnicodeToAnsi(WinAnsiConvert.AnsiToRawUnicode(W))=W);
    if CurrentAnsiConvert.InheritsFrom(TSynAnsiFixedWidth) then begin
      Check(CurrentAnsiConvert.UTF8ToAnsi(CurrentAnsiConvert.AnsiToUTF8(W))=W);
      Check(CurrentAnsiConvert.RawUnicodeToAnsi(CurrentAnsiConvert.AnsiToRawUnicode(W))=W);
    end;
    Unic := Utf8DecodeToRawUnicode(U);
    res := RawUnicodeToUtf8(Unic);
    Check(res=U);
    Check(RawUnicodeToWinAnsi(Unic)=W);
    WS := UTF8ToWideString(U);
    Check(length(WS)=length(Unic)shr 1);
    if WS<>'' then
      Check(CompareMem(pointer(WS),pointer(Unic),length(WS)*sizeof(WideChar)));
    Check(integer(Utf8ToUnicodeLength(Pointer(U)))=length(WS));
    SU := UTF8ToSynUnicode(U);
    Check(length(SU)=length(Unic)shr 1);
    if SU<>'' then
      Check(CompareMem(pointer(SU),pointer(Unic),length(SU)));
    WA := IsWinAnsi(pointer(Unic));
    Check(IsWinAnsi(pointer(Unic),length(Unic)shr 1)=WA);
    Check(IsWinAnsiU(pointer(U))=WA);
    Check(UpperCase(LowerCase(U))=UpperCase(U));
    {$ifndef ENHANCEDRTL}
    Check(LowerCase(U)=RawUTF8(SysUtils.LowerCase(string(U))));
    Check(UpperCase(U)=RawUTF8(SysUtils.UpperCase(string(U))));
    {$endif}
    L := Length(U);
    SetString(Up,nil,L);
    SetString(Up2,PAnsiChar(pointer(U)),L);
    L := UTF8UpperCopy(pointer(Up),pointer(U),L)-pointer(Up);
    Check(L<=length(U));
    Check(ConvertCaseUTF8(Pointer(Up2),NormToUpperByte)=L);
    if Up<>'' then
      Check(CompareMem(Pointer(Up),pointer(Up2),L));
    if CurrentAnsiConvert.CodePage=CODEPAGE_US then
       // initial text above is WinAnsiString (CP 1252)
      Check(StringToUTF8(UTF8ToString(U))=U);
    Up := UpperCaseUnicode(U);
    Check(Up=UpperCaseUnicode(LowerCaseUnicode(U)));
    Check(kr32(0,pointer(U),length(U))=kr32pas(pointer(U),length(U)));
    if U='' then
      continue;
    Check(UnQuoteSQLString(pointer(QuotedStr(U,'"')),res)<>nil);
    Check(res=U);
    Check(not IsZero(pointer(W),length(W)));
    fillchar(pointer(W)^,length(W),0);
    Check(IsZero(pointer(W),length(W)));
    Check(FormatUTF8(pointer(U),[])=U);
    Check(FormatUTF8(pointer(U),[],[])=U);
{$ifndef DELPHI5OROLDER}
    Check(FormatUTF8('%',[U])=U);
    Check(FormatUTF8('%',[U],[])=U);
    q := ':('+QuotedStr(U)+'):';
    Check(FormatUTF8('?',[],[U])=q);
    res := 'ab'+U;
    q := 'ab'+q;
    Check(FormatUTF8('ab%',[U])=res);
    Check(FormatUTF8('%%',['ab',U])=res);
    Check(FormatUTF8('ab%',[U],[])=res);
    Check(FormatUTF8('%%',['ab',U],[])=res);
    Check(FormatUTF8('ab?',[],[U])=q);
    Check(FormatUTF8('%?',['ab'],[U])=q);
    res := res+'cd';
    q := q+'cd';
    Check(FormatUTF8('ab%cd',[U])=res);
    Check(FormatUTF8('ab%cd',[U],[])=res);
    Check(FormatUTF8('a%%cd',['b',U])=res);
    Check(FormatUTF8('a%%cd',['b',U],[])=res);
    Check(FormatUTF8('%%%',['ab',U,'cd'])=res);
    Check(FormatUTF8('ab?cd',[],[U])=q);
    Check(FormatUTF8('%?cd',['ab'],[U])=q);
    Check(FormatUTF8('%?%',['ab','cd'],[U])=q);
    Check(FormatUTF8('%?c%',['ab','d'],[U])=q);
    Check(FormatUTF8('a%?%d',['b','c'],[U])=q);
{$endif}
  end;
  SetLength(U, 4);
  U[1] := #$F0;
  U[2] := #$A8;
  U[3] := #$B3;
  U[4] := #$92;
  SU := UTF8ToSynUnicode(U);
  if not CheckFailed(length(SU)=2) then
    Check(PCardinal(SU)^=$DCD2D863);
  Check(Utf8ToUnicodeLength(Pointer(U))=2);
  Check(Utf8FirstLineToUnicodeLength(Pointer(U))=2);
  U := SynUnicodeToUtf8(SU);
  if not CheckFailed(length(U)=4) then
    Check(PCardinal(U)^=$92b3a8f0);
  Check(UnQuoteSQLString('"one two"',U)<>nil);
  Check(U='one two');
  Check(UnQuoteSQLString('one two',U)<>nil);
  Check(U='ne tw');
  Check(UnQuoteSQLString('"one "" two"',U)<>nil);
  Check(U='one " two');
  Check(UnQuoteSQLString('"one " two"',U)<>nil);
  Check(U='one ');
  Check(UnQuoteSQLString('"one two',U)=nil);
  Check(UnQuoteSQLString('"one "" two',U)=nil);
  Check(IsValidEmail('test@synopse.info'));
  Check(not IsValidEmail('test@ synopse.info'));
  Check(IsValidEmail('test_two@blog.synopse.info'));
  Check(IsValidIP4Address('192.168.1.1'));
  Check(IsValidIP4Address('192.168.001.001'));
  Check(not IsValidIP4Address('192.158.1. 1'));
  Check(not IsValidIP4Address('192.158.1.301'));
  Check(not IsValidIP4Address(' 12.158.1.01'));
  Check(not IsValidIP4Address('12.158.1.'));
  Check(not IsValidIP4Address('12.158.1'));
  Check(FindUnicode('  ABCD DEFG','ABCD',4));
  Check(FindUnicode('  ABCD DEFG','DEFG',4));
  Check(FindUnicode('ABCD DEFG ','DEFG',4));
  Check(FindUnicode('ABCD DEFG ','ABCD',4));
  Check(FindUnicode('  abcd defg','ABCD',4));
  Check(FindUnicode('  abcd defg','DEFG',4));
  Check(FindUnicode('abcd defg ','DEFG',4));
  Check(FindUnicode('abcd defg ','ABCD',4));
  Check(FindUnicode('ABCD DEFG ','ABCD',4));
  Check(FindUnicode('  abcde defg','ABCD',4));
  Check(FindUnicode('  abcdf defg','DEFG',4));
  Check(FindUnicode('abcdg defg ','DEFG',4));
  Check(FindUnicode('abcdh defg ','ABCD',4));
  Check(FindUnicode('  abcd defg','ABC',3));
  Check(FindUnicode('  abcd defg','DEF',3));
  Check(FindUnicode('abcd defg ','DEF',3));
  Check(FindUnicode('abcd defg ','ABC',3));
  Check(not FindUnicode('  abcd defg','ABC2',4));
  Check(not FindUnicode('  abcd defg','DEF2',4));
  Check(not FindUnicode('abcd defg ','DEF1',4));
  Check(not FindUnicode('abcd defg ','ABC1',4));
  Check(UpperCaseUnicode('abcdefABCD')='ABCDEFABCD');
  Check(LowerCaseUnicode('abcdefABCD')='abcdefabcd');
end;

procedure TTestLowLevelCommon.Iso8601DateAndTime;
procedure Test(D: TDateTime; Expanded: boolean);
var s,t: RawUTF8;
    E: TDateTime;
    I,J: Iso8601;
begin
  s := DateTimeToIso8601(D,Expanded);
  E := Iso8601ToDateTime(s);
  Check(Abs(D-E)<(1000/MSecsPerDay)); // we allow 999 ms error
  Check(Iso8601ToSeconds(s)<>0);
  I.From(s);
  t := I.Text(Expanded);
  if t<>s then // we allow error on time = 00:00:00 -> I.Text = just date
    Check(I.Value and (1 shl (6+6+5)-1)=0) else
    Check(true);
  J.From(E);
  Check(Int64(I)=Int64(J));
  s := TimeToIso8601(D,Expanded);
  Check(abs(frac(D)-Iso8601ToDateTime(s))<1000/MSecsPerDay);
  s := DateToIso8601(D,Expanded);
  Check(trunc(D)=trunc(Iso8601ToDateTime(s)));
end;
var i: integer;
    D: TDateTime;
begin
  // this will test typically from year 1905 to 2065
  D := Now/20+Random*20; // some starting random date/time
  for i := 1 to 2000 do begin
    Test(D, true);
    Test(D, false);
    D := D+Random*57; // go further a little bit: change date/time
  end;
end;

procedure TTestLowLevelCommon._IdemPropName;
begin
  Check(IdemPropName('abcD','ABcd'));
  Check(not IdemPropName('abcD','ABcF'));
  Check(IdemPropNameU('abcD','ABcd'));
  Check(not IdemPropNameU('abcD','ABcF'));
  Check(not IdemPropNameU('abcD','ABcFG'));
  Check(not IdemPropNameU('abcD',''));
  Check(not IdemPropNameU('','ABcFG'));
  Check(IdemPropNameU('',''));
  Check(UpperCaseU('abcd')='ABCD');
  Check(UpperCaseU(WinAnsiToUTF8('a��D'))='AECD');
end;

procedure TTestLowLevelCommon._TSynTable;
var T: TSynTable;
procedure Test;
begin
  Check(T.Field[0].Name='currency');
  Check(T.Field[0].Offset=0);
  Check(T.Field[1].Name='double');
  Check(T.Field[1].Offset=8);
  Check(T.Field[2].Name='bool');
  Check(T.Field[2].Offset=16);
  Check(T.FieldVariableOffset=17);
  Check(T.FieldFromName['TEXT'].Offset=-1);
  Check(T.FieldFromName['text'].FieldNumber=3);
  Check(tfoIndex in T.Field[3].Options);
  Check(T.FieldFromName['VARint'].Name='varint');
  Check(T.FieldFromName['VARint'].Name='varint');
  Check(T.FieldFromName['VARint'].FieldNumber=4);
  Check(T.Field[4].Options=[]);
  Check(T.FieldFromName['ansi'].Offset=-3);
  Check(T.FieldFromName['ansi'].FieldNumber=5);
end;
var W: TFileBufferWriter;
    R: TFileBufferReader;
    f: THandle;
    FN: TFileName;
    {$ifdef USESYNTABLEVARIANT}
    data: TSynTableData;
    rec: Variant;
    i: integer;
    V: double;
    s: string;
    {$endif}
begin
  T := TSynTable.Create('Test');
  try
    Check(T.AddField('One',tftUnknown)=nil);
    Check(T.AddField('bool',tftBoolean)<>nil);
    Check(T.AddField('bool',tftBoolean)=nil);
    Check(T.AddField('double',tftDouble)<>nil);
    Check(T.AddField('varint',tftVarUInt32)<>nil);
    Check(T.AddField('text',tftUTF8,[tfoUnique])<>nil);
    Check(T.AddField('ansi',tftWinAnsi,[])<>nil);
    Check(T.AddField('currency',tftCurrency)<>nil);
    Test;
    FN := ChangeFileExt(paramstr(0),'.syntable');
    DeleteFile(FN);
    W := TFileBufferWriter.Create(FN); // manual storage of TSynTable header
    try
      T.SaveTo(W);
      W.Flush;
    finally
      W.Free;
    end;
    T.Free;
    f := FileOpen(FN,fmOpenRead);
    R.Open(f);
    Check(R.Seek(0));
    T := TSynTable.Create('Test');
    T.LoadFrom(R);
    R.Close;
    Test;
    {$ifdef USESYNTABLEVARIANT}
    try
      // test TSynTableData
      data.Init(T);
      check(data.Field['ID']=0);
      data.Field['ID'] := 1;
      check(data.Field['ID']=1);
      check(data.Field['bool']=false);
      data.Field['bool'] := 12;
      check(data.Field['bool']=true);
      check(data.Field['varint']=0);
      check(data.Field['double']=0.0);
      data.Field['varint'] := 100;
      check(data.Field['varint']=100);
      data.Field['double'] := 3.1415;
      CheckSame(data.Field['double'],3.1415);
      for i := 1 to 100 do begin
        s := UTF8ToString(RandomUTF8(i*2));
        data.Field['text'] := s;
        check(data.Field['text']=s);
        data.Field['ansi'] := s; 
        check(data.Field['ansi']=s);
        // with RandomUTF8, WinAnsi is more efficent than UTF-8 for storage size
      end;
      check(data.Field['bool']=true);
      check(data.Field['varint']=100);
      check(data.Field['ID']=1);
      CheckSame(data.Field['double'],3.1415);
      for i := 1 to 100 do begin
        data.Field['varint'] := i shl 6;
        Check(data.Field['varint']=i shl 6,'varlength');
        V := random;
        data.Field['double'] := V;
        CheckSame(data.Field['double'],V);
      end;
      check(data.Field['bool']=true);
      check(data.Field['text']=s);
      check(data.Field['ansi']=s);
      check(data.Field['ID']=1);
      // test TSynTableVariantType
      rec := T.Data;
      check(rec.ID=0);
      rec.ID := 1;
      check(rec.ID=1);
      check(rec.bool=false);
      rec.bool := 12;
      check(rec.bool=true);
      check(rec.varint=0);
      check(rec.double=0.0);
      rec.varint := 100;
      check(rec.varint=100);
      rec.double := 3.141592654;
      CheckSame(rec.double,3.141592654);
      for i := 1 to 100 do begin
        s := UTF8ToString(RandomUTF8(i*2));
        rec.text := s;
        check(rec.text=s);
        rec.ansi := s;
        check(rec.ansi=s);
      end;
      check(rec.bool=true);
      check(rec.varint=100);
      check(rec.ID=1);
      CheckSame(rec.double,3.141592654);
      for i := 1 to 100 do begin
        rec.varint := i shl 6;
        Check(rec.varint=i shl 6,'varlength');
        V := random;
        rec.double := V;
        CheckSame(rec.double,V);
      end;
      check(rec.bool=true);
      check(rec.text=s);
      check(rec.ansi=s);
      check(rec.ID=1);
    except
      on E: Exception do // variant error could raise exceptions
        Check(false,E.Message);
    end;
    {$endif}
    FileClose(f);
  finally
    T.Free;
  end;
end;

procedure TTestLowLevelCommon._TSynCache;
var C: TSynCache;
    s,v: RawUTF8;
    i: integer;
    Tag: PtrInt;
begin
   C := TSynCache.Create;
  try
    for i := 0 to 100 do begin
      v := {$ifndef ENHANCEDRTL}Int32ToUtf8{$else}IntToStr{$endif}(i);
      Tag := 0;
      s := C.Find(v,@Tag);
      Check(s='');
      Check(Tag=0);
      C.Add(v+v,i);
    end;
    for i := 0 to 100 do begin
      v := {$ifndef ENHANCEDRTL}Int32ToUtf8{$else}IntToStr{$endif}(i);
      Check(C.Find(v,@Tag)=v+v);
      Check(Tag=i);
    end;
  finally
    C.Free;
  end;
end;

procedure TTestLowLevelCommon._TSynFilter;
type TFilterProcess = function(const Value: RawUTF8): RawUTF8;
procedure Test(Filter: TSynFilterClass; Proc: TFilterProcess);
var V, Old: RawUTF8;
    i: integer;
begin
  with Filter.Create do
  try
    for i := 0 to 200 do begin
      V := RandomUTF8(i);
      Old := V;
      Process(0,V);
      Check(V=Proc(Old));
    end;
  finally
    Free;
  end;
end;
begin
  {$ifndef PUREPASCAL}
  {$ifndef ENHANCEDRTL}
  {$ifndef LVCL}
  {$ifndef FPC}
  Test(TSynFilterTrim,SynCommons.Trim);
  {$endif}
  {$endif}
  {$endif}
  {$endif}
  Test(TSynFilterLowerCase,LowerCase);
  Test(TSynFilterUpperCase,UpperCase);
  Test(TSynFilterLowerCaseU,LowerCaseU);
  Test(TSynFilterUpperCaseU,UpperCaseU);
end;

procedure TTestLowLevelCommon._TSynValidate;
procedure TestValidateLength(const Params: RawUTF8; aMin,aMax: cardinal);
var i: cardinal;
    V: RawUTF8;
    Msg: string;
    ok: boolean;
begin
  with TSynValidateText.Create(Params) do
  try
    Check(MinLength=aMin);
    Check(MaxLength=aMax);
    for i := 0 to 100 do begin
      V := RandomUTF8(i);
      Check(Utf8ToUnicodeLength(pointer(V))=i,'Unicode glyph=Ansi char=i');
      Msg := '';
      ok := (i>=aMin)and(i<=aMax);
      Check(Process(0,V,Msg)=ok,Msg);
      Check(Msg=''=ok,Msg);
    end;
  finally
    Free;
  end;
end;
var Msg: string;
begin
  with TSynValidateIPAddress.Create do
  try
    Check(Process(0,'192.168.1.1',Msg));
    Check(Msg='');
    Msg := '';
    Check(not Process(0,' 192.168.1.1',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(not Process(0,'292.168.1.1',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(Process(0,'192.168.001.001',Msg));
    Check(Msg='');
  finally
    Free;
  end;
  with TSynValidateEmail.Create do
  try
    Msg := '';
    Check(Process(0,'test@synopse.info',Msg));
    Check(Msg='');
    Msg := '';
    Check(not Process(0,'test@ synopse.info',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(not Process(0,'test@synopse.delphi',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(Process(0,'test_two@blog.synopse.info',Msg));
    Check(Msg='');
    Msg := '';
    Check(Process(0,'test_two@blog.synopse.fr',Msg));
    Check(Msg='');
  finally
    Free;
  end;
  with TSynValidateEmail.Create('{"ForbiddenDomains":"google.fr,synopse.info"}') do
  try
    Msg := '';
    Check(Process(0,'test@blog.synopse.fr',Msg));
    Check(Process(0,'test@blog.synopse.info',Msg));
    Check(not Process(0,'test@synopse.info',Msg));
    Msg := '';
    Check(Process(0,'test@blog.google.fr',Msg));
    Check(not Process(0,'test@google.fr',Msg));
  finally
    Free;
  end;
  with TSynValidateEmail.Create('{"AllowedTLD":"com,org,net","ForbiddenTLD":"net"}') do
  try
    Msg := '';
    Check(Process(0,'test@synopse.com',Msg));
    Check(Msg='');
    Msg := '';
    Check(not Process(0,'test@ synopse.com',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(not Process(0,'test@synopse.info',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(not Process(0,'test_two@blog.synopse.net',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(not Process(0,'test_two@blog.synopse.fr',Msg));
    Check(Msg<>'');
  finally
    Free;
  end;
  with TSynValidatePattern.Create('this [e-n]s a [!zy]est') do
  try
    Msg := '';
    Check(Process(0,'this is a test',Msg));
    Check(Msg='');
    Msg := '';
    Check(Process(0,'this is a rest',Msg));
    Check(Msg='');
    Msg := '';
    Check(not Process(0,'this is a zest',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(not Process(0,'this as a test',Msg));
    Check(Msg<>'');
    Msg := '';
    Check(not Process(0,'this as a rest',Msg));
    Check(Msg<>'');
  finally
    Free;
  end;
  TestValidateLength('',1,maxInt);
  TestValidateLength('{"mAXlength": 10 , "MInLENgtH" : 3 }',3,10);
  with TSynValidateText.Create do
  try
    Msg := '';
    MaxLeftTrimCount := 0;
    Check(Process(0,'one',Msg));
    Check(not Process(0,' one',Msg));
    MaxRightTrimCount := 0;
    Check(Process(0,'one',Msg));
    Check(not Process(0,' one',Msg));
    Check(not Process(0,'one ',Msg));
    Msg:= '';
    MinAlphaCount := 3;
    Check(Process(0,'one',Msg));
    Check(not Process(0,'on2',Msg));
    Msg := '';
    MinDigitCount := 2;
    Check(Process(0,'one12',Msg));
    Check(not Process(0,'one2',Msg));
    Msg := '';
    MinPunctCount := 1;
    Check(Process(0,'one12_',Msg));
    Check(Process(0,'_one12_',Msg));
    Check(Process(0,'_one12',Msg));
    Check(not Process(0,'one12',Msg));
    Msg := '';
    MinLowerCount := 3;
    Check(Process(0,'o12_ne',Msg));
    Check(not Process(0,'o12_An',Msg));
    Msg := '';
    MinUpperCount := 3;
    Check(Process(0,'o12_neABC',Msg));
    Check(not Process(0,'o12_AnBc',Msg));
    Msg := '';
    MinSpaceCount := 3;
    Check(Process(0,'o12 _ne AB C',Msg));
    Check(not Process(0,'O1 2_A neeB',Msg));
    Msg := '';
    MaxSpaceCount := 3;
    Check(Process(0,'o12 _ne AB C',Msg));
    Check(not Process(0,'o12 _ ne AB C',Msg));
  finally
    Free;
  end;
  with TSynValidatePassword.Create do
  try
    Msg := '';
    Check(Process(0,'aA3!Z',Msg));
    Check(not Process(0,'aA3!',Msg));
    Msg := '';
    Check(not Process(0,'aA 3!Z',Msg));
  finally
    Free;
  end;
end;

procedure TTestLowLevelCommon.UrlDecoding;
var i, V: integer;
    s,t,d: RawUTF8;
    U: PUTF8Char;
begin
  for i := 1 to 100 do begin
    s := DateTimeToIso8601(Now/20+Random*20,true);
    t := UrlEncode(s);
    Check(UrlDecode(t)=s);
    d := 'seleCT='+t+'&where='+
      {$ifndef ENHANCEDRTL}Int32ToUtf8{$else}IntToStr{$endif}(i);
    Check(UrlDecodeNeedParameters(pointer(d),'where,select'));
    Check(not UrlDecodeNeedParameters(pointer(d),'foo,select'));
    Check(UrlDecodeValue(pointer(d),'SELECT=',t,@U));
    Check(t=s,'UrlDecodeValue');
    Check(IdemPChar(U,'WHERE='),'Where');
    Check(UrlDecodeInteger(U,'WHERE=',V));
    Check(V=i);
    Check(not UrlDecodeValue(pointer(d),'NOTFOUND=',t,@U));
    Check(UrlDecodeInteger(U,'WHERE=',V,@U));
    Check(U=nil);
  end;
end;

procedure TTestLowLevelCommon.MimeTypes;
const
  MIMES: array[0..37] of TFileName = (
   'png','image/png',
   'PNg','image/png',
   'gif','image/gif',
   'tif','image/tiff',
   'tiff','image/tiff',
   'jpg','image/jpeg',
   'JPG','image/jpeg',
   'jpeg','image/jpeg',
   'bmp','image/bmp',
   'doc','application/msword',
   'docx','application/msword',
   'htm','text/html',
   'html','text/html',
   'HTML','text/html',
   'css','text/css',
   'js','application/x-javascript',
   'ico','image/x-icon',
   'pdf','application/pdf',
   'PDF','application/pdf');
var i: integer;
begin
  for i := 0 to high(MIMES)shr 1 do
    Check(GetMimeContentType(nil,0,'toto.'+MIMES[i*2])=StringToAnsi7(MIMES[i*2+1]),MIMES[i*2]);
end;

procedure TTestLowLevelCommon._TSynLogFile;
procedure Test(const LOG: RawUTF8; ExpectedDate: TDateTime);
var L: TSynLogFile;
begin
  L := TSynLogFile.Create(pointer(LOG),length(LOG));
  try
    Check(L.ExecutableName='D:\Dev\lib\SQLite3\exe\TestSQL3.exe');
    Check(L.ExecutableVersion='1.2.3.4');
    if ExpectedDate=40640 then
      Check(L.InstanceName='D:\Dev\MyLibrary.dll') else
      Check(L.InstanceName='');
    CheckSame(L.ExecutableDate,ExpectedDate,1e-7);
    Check(L.ComputerHost='MyPC');
    Check(L.LevelUsed=[sllEnter,sllLeave,sllDebug]);
    Check(L.RunningUser='MySelf');
    Check(L.CPU='2*0-15-1027');
    Check(L.OS=wXP);
    Check(L.ServicePack=3);
    Check(not L.Wow64);
    Check(L.Freq=0);
    CheckSame(L.StartDateTime,40640.502882,1E-10);
    if CheckFailed(L.Count=3) then
      exit;
    Check(L.EventLevel[0]=sllEnter);
    Check(L.EventLevel[1]=sllDebug);
    CheckSame(L.EventDateTime(1),L.StartDateTime);
    Check(L.EventLevel[2]=sllLeave);
    if CheckFailed(L.LogProcCount=1) then
      exit;
    Check(L.LogProc[0].Index=0);
    Check(L.LogProc[0].Time=10020006);
  finally
    L.Free;
  end;
end;
begin
  Test('D:\Dev\lib\SQLite3\exe\TestSQL3.exe 1.2.3.4 (2011-04-07)'#13#10+
    'Host=MyPC User=MySelf CPU=2*0-15-1027 OS=2.3=5.1.2600 Wow64=0 Freq=3579545 '+
    'Instance=D:\Dev\MyLibrary.dll'#13#10+
    'TSynLog 1.15 LVCL 2011-04-07 12:04:09'#13#10#13#10+
    '20110407 12040903  +    SQLite3Commons.TSQLRestServer.URI (14163)'#13#10+
    '20110407 12040904 debug {"TObjectList(00AF8D00)":["TObjectList(00AF8D20)",'+
    '"TObjectList(00AF8D60)","TFileVersion(00ADC0B0)","TSynMapFile(00ACC990)"]}'#13#10+
    '20110407 12040915  -    SQLite3Commons.TSQLRestServer.URI (14163) 10.020.006',
    40640);
  Test('D:\Dev\lib\SQLite3\exe\TestSQL3.exe 1.2.3.4 (2011-04-07 11:09:06)'#13#10+
    'Host=MyPC User=MySelf CPU=2*0-15-1027 OS=2.3=5.1.2600 Wow64=0 Freq=3579545'#13#10+
    'TSynLog 1.15 LVCL 2011-04-07 12:04:09'#13#10#13#10+
    '20110407 12040903  +    SQLite3Commons.TSQLRestServer.URI (14163)'#13#10+
    '20110407 12040904 debug {"TObjectList(00AF8D00)":["TObjectList(00AF8D20)",'+
    '"TObjectList(00AF8D60)","TFileVersion(00ADC0B0)","TSynMapFile(00ACC990)"]}'#13#10+
    '20110407 12040915  -    SQLite3Commons.TSQLRestServer.URI (14163) 10.020.006',
    40640.464653);
end;


{ TTestLowLevelTypes }

{$ifndef DELPHI5OROLDER}
{$ifndef FPC}

type
 TSQLRecordTest = class(TSQLRecord)
 private
    fTest: RawUTF8;
    fValfloat: double;
    fValWord: word;
    fNext: TSQLRecordTest;
    fInt: int64;
    fValDate: TDateTime;
    fData: TSQLRawBlob;
    fAnsi: WinAnsiString;
    fUnicode: RAWUNICODE;
    {$ifdef USEVARIANTS}
    fVariant: variant;
    {$endif}
//    fGUID: TGUID;
//    fEnum: TOrdType;
//    fBool: boolean;
    procedure SetInt(const Value: int64);
 public
 published
   // add properties here
   property Int: int64 read fInt write SetInt default 12;
   property Test: RawUTF8 read fTest write fTest;
   property Unicode: RAWUNICODE read fUnicode write fUnicode;
   property Ansi: WinAnsiString read fAnsi  write fAnsi;
   property ValFloat: double read fValfloat write fValFloat;
   property ValWord: word read fValWord write fValWord;
   property ValDate: tdatetime read fValDate write fValDate;
   property Next: TSQLRecordTest read fNext write fNext;
   property Data: TSQLRawBlob read fData write fData;
   {$ifdef USEVARIANTS}
   property ValVariant: variant read fVariant write fVariant;
   {$endif}
//   property GUID: TGUID read fGUID write fGUID;
//   property Bool: boolean read fBool write fBool;
 end;


procedure TSQLRecordTest.SetInt(const Value: int64);
begin
  fInt := Value;
end;



{ TSQLRecordPeople }

function TSQLRecordPeople.DataAsHex(aClient: TSQLRestClientURI): RawUTF8;
begin
  Result := aClient.CallBackGetResult('DataAsHex',[],RecordClass,fID);
end;

class function TSQLRecordPeople.Sum(aClient: TSQLRestClientURI; a, b: double; Method2: boolean): double;
var err: integer;
const METHOD: array[boolean] of RawUTF8 = ('sum','sum2');
begin
  Result := GetExtended(pointer(aClient.CallBackGetResult(
    METHOD[Method2],['a',a,'b',b])),err);
end;

{$endif FPC}
{$endif DELPHI5OROLDER}


{$ifdef UNICODE}
{$WARNINGS OFF} // don't care about implicit string cast in tests
{$endif}

{$ifndef LVCL}
{$ifndef DELPHI5OROLDER}
{$ifndef FPC}

type
  TCollTests = class(TInterfacedCollection)
  private
    function GetCollItem(Index: Integer): TCollTest;
  protected
    class function GetClass: TCollectionItemClass; override;
  public
    function Add: TCollTest;
    property Item[Index: Integer]: TCollTest read GetCollItem; default;
  end;

  TMyCollection = class(TCollection);

  TCollTst = class(TPersistent)
  private
    fColl: TCollTests;
    fTCollTest: TCollTest;
    fStr: TStringList;
    procedure SetColl(const Value: TCollTests);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property One: TCollTest read fTCollTest write fTCollTest;
    property Coll: TCollTests read fColl write SetColl;
    property Str: TStringList read fStr write fStr;
  end;

  TCollTstDynArray = class(TCollTst)
  private
    fInts: TIntegerDynArray;
    fTimeLog: TTimeLogDynArray;
    fFileVersions: TFVs;
    class function FVReader(P: PUTF8Char; var aValue;
      out aValid: Boolean): PUTF8Char;
    class procedure FVWriter(const aWriter: TTextWriter; const aValue);
    class function FVReader2(P: PUTF8Char; var aValue;
      out aValid: Boolean): PUTF8Char;
    class procedure FVWriter2(const aWriter: TTextWriter; const aValue);
    class function FVClassReader(const aValue: TObject; aFrom: PUTF8Char;
      var aValid: Boolean): PUTF8Char;
    class procedure FVClassWriter(const aSerializer: TJSONSerializer;
      aValue: TObject; aOptions: TTextWriterWriteObjectOptions);
  published
    property Ints: TIntegerDynArray read fInts write fInts;
    property TimeLog: TTimeLogDynArray read fTimeLog write fTimeLog;
    property FileVersion: TFVs read fFileVersions write fFileVersions;
  end;


{ TCollTstDynArray}

class function TCollTstDynArray.FVReader(P: PUTF8Char; var aValue;
  out aValid: Boolean): PUTF8Char;
var V: TFV absolute aValue;
begin // '[1,2001,3001,4001,"1","1001"],[2,2002,3002,4002,"2","1002"],...'
  aValid := false;
  result := nil;
  if (P=nil) or (P^<>'[') then
    exit;
  inc(P);
  V.Major := GetNextItemCardinal(P);
  V.Minor := GetNextItemCardinal(P);
  V.Release := GetNextItemCardinal(P);
  V.Build := GetNextItemCardinal(P);
  V.Main := UTF8ToString(GetJSONField(P,P));
  V.Detailed := UTF8ToString(GetJSONField(P,P));
  if P=nil then
    exit;
  aValid := true;
  result := P; // ',' or ']' for last item of array
end;

class procedure TCollTstDynArray.FVWriter(const aWriter: TTextWriter; const aValue);
var V: TFV absolute aValue;
begin
  aWriter.Add('[%,%,%,%,"%","%"]',
    [V.Major,V.Minor,V.Release,V.Build,V.Main,V.Detailed],twJSONEscape);
end;

class function TCollTstDynArray.FVReader2(P: PUTF8Char; var aValue;
  out aValid: Boolean): PUTF8Char;
var V: TFV absolute aValue;
    Values: TPUtf8CharDynArray;
begin // '{"Major":1,"Minor":2001,"Release":3001,"Build":4001,"Main":"1","Detailed":"1001"},..
  aValid := false;
  result := JSONDecode(P,['Major','Minor','Release','Build','Main','Detailed'],Values);
  if result=nil then
    exit; // result^ = ',' or ']' for last item of array
  V.Major := GetInteger(Values[0]);
  V.Minor := GetInteger(Values[1]);
  V.Release := GetInteger(Values[2]);
  V.Build := GetInteger(Values[3]);
  V.Main := UTF8DecodeToString(Values[4],StrLen(Values[4]));
  V.Detailed := UTF8DecodeToString(Values[5],StrLen(Values[5]));
  aValid := true;
end;

class procedure TCollTstDynArray.FVWriter2(const aWriter: TTextWriter; const aValue);
var V: TFV absolute aValue;
begin
  aWriter.AddJSONEscape(['Major',V.Major,'Minor',V.Minor,'Release',V.Release,
    'Build',V.Build,'Main',V.Main,'Detailed',V.Detailed]);
end;

class function TCollTstDynArray.FVClassReader(const aValue: TObject; aFrom: PUTF8Char;
  var aValid: Boolean): PUTF8Char;
var V: TFileVersion absolute aValue;
    Values: TPUtf8CharDynArray;
begin // '{"Major":2,"Minor":2002,"Release":3002,"Build":4002,"Main":"2","BuildDateTime":"1911-03-15"}'
  result := JSONDecode(aFrom,['Major','Minor','Release','Build','Main','BuildDateTime'],Values);
  aValid := (result<>nil);
  if aValid then begin
    V.Major := GetInteger(Values[0]);
    V.Minor := GetInteger(Values[1]);
    V.Release := GetInteger(Values[2]);
    V.Build := GetInteger(Values[3]);
    V.Main := UTF8DecodeToString(Values[4],StrLen(Values[4]));
    V.BuildDateTime := Iso8601ToDateTimePUTF8Char(Values[5]);
  end;
end;

class procedure TCollTstDynArray.FVClassWriter(const aSerializer: TJSONSerializer;
  aValue: TObject; aOptions: TTextWriterWriteObjectOptions);
var V: TFileVersion absolute aValue;
begin
  aSerializer.AddJSONEscape(['Major',V.Major,'Minor',V.Minor,'Release',V.Release,
    'Build',V.Build,'Main',V.Main,'BuildDateTime',DateTimeToIso8601Text(V.BuildDateTime)]);
end;


{ TCollTests }

function TCollTests.Add: TCollTest;
begin
  result := inherited Add as TCollTest;
end;

class function TCollTests.GetClass: TCollectionItemClass;
begin
  result := TCollTest;
end;

function TCollTests.GetCollItem(Index: Integer): TCollTest;
begin
  result := Items[Index] as TCollTest;
end;


{ TCollTst }

constructor TCollTst.Create;
begin
  inherited;
  fColl := TCollTests.Create;
  fTCollTest := TCollTest.Create(nil);
end;

destructor TCollTst.Destroy;
begin
  fColl.Free;
  fTCollTest.Free;
  fStr.Free;
  inherited;
end;

procedure TCollTst.SetColl(const Value: TCollTests);
begin
  fColl.Free;
  fColl := Value;
end;

{$endif FPC}
{$endif DELPHI5OROLDER}
{$endif LVCL}


procedure TTestLowLevelTypes.EncodeDecodeJSON;
var J,U: RawUTF8;
    V: TPUtf8CharDynArray;
    i, a, err: integer;
    r: Double;
{$ifndef DELPHI5OROLDER}
    K: RawUTF8;
{$ifndef LVCL}
{$ifndef FPC}
    Coll, C2: TCollTst;
    MyItem: TCollTest;
    Comp: TComplexNumber;
    Valid: boolean;
    DA: TDynArray;
    F: TFV;
    TLNow: TTimeLog;
procedure TestMyColl(MyColl: TMyCollection);
begin
  if CheckFailed(MyColl<>nil) then
    exit;
  MyItem := MyColl.Add as TCollTest;
  Check(MyItem.ClassType=TCollTest);
  MyItem.Length := 10;
  MyItem.Color := 20;
  MyItem.Name := 'ABC';
  U := ObjectToJSON(MyColl);
  Check(U='[{"Color":20,"Length":10,"Name":"ABC"}]');
  MyColl.Free;
end;
procedure TCollTstDynArrayTest;
var CA: TCollTstDynArray;
    i: integer;
    tmp: RawByteString;
begin
  CA := TCollTstDynArray.Create;
  try
    CA.Str := TStringList.Create;
    tmp := J;
    Check(JSONToObject(CA,@tmp[1],Valid)=nil);
    Check(Valid);
    Check(CA.Str.Count=10000);
    for i := 1 to CA.Str.Count do
      Check(CA.Str[i-1]=IntToStr(i));
    SetLength(CA.fInts,20000);
    for i := 0 to high(CA.Ints) do
      CA.Ints[i] := i;
    U := ObjectToJSON(CA);
  finally
    CA.Free;
  end;
  CA := TCollTstDynArray.Create;
  try
    CA.Str := TStringList.Create;
    Check(JSONToObject(CA,pointer(U),Valid)=nil);
    Check(Valid);
    Check(CA.Str.Count=10000);
    for i := 1 to CA.Str.Count do
      Check(CA.Str[i-1]=IntToStr(i));
    Check(length(CA.Ints)=20000);
    for i := 0 to high(CA.Ints) do
      CA.Ints[i] := i;
    SetLength(CA.fTimeLog,CA.Str.Count);
    TLNow := Iso8601Now and (not 63);
    for i := 0 to high(CA.TimeLog) do
      CA.TimeLog[i] := TLNow+i and 31; // and 31 to avoid min:sec rounding
    U := ObjectToJSON(CA);
    SetLength(CA.fInts,2);
    SetLength(CA.fTimeLog,2);
    Check(JSONToObject(CA,pointer(U),Valid)=nil);
    Check(Valid);
    Check(Length(CA.Ints)=20000);
    Check(Length(CA.TimeLog)=CA.Str.Count);
    for i := 0 to high(CA.Ints) do
      Check(CA.Ints[i]=i);
    for i := 0 to high(CA.TimeLog) do
      Check(CA.TimeLog[i]=TLNow+i and 31);
    DA.Init(TypeInfo(TFVs),CA.fFileVersions);
    for i := 1 to 1000 do begin
      F.Major := i;
      F.Minor := i+2000;
      F.Release := i+3000;
      F.Build := i+4000;
      str(i,F.Main);
      str(i+1000,F.Detailed);
      DA.Add(F);
    end;
    U := ObjectToJSON(CA);
    DA.Clear;
    Check(Length(CA.FileVersion)=0);
    Check(JSONToObject(CA,pointer(U),Valid)=nil);
    Check(Valid);
    Check(Length(CA.Ints)=20000);
    Check(Length(CA.TimeLog)=CA.Str.Count);
    Check(Length(CA.FileVersion)=1000);
    for i := 1 to 1000 do
    with CA.FileVersion[i-1] do begin
      Check(Major=i);
      Check(Minor=i+2000);
      Check(Release=i+3000);
      Check(Build=i+4000);
      Check(Main=IntToStr(i));
      Check(Detailed=IntToStr(i+1000));
    end;
  finally
    CA.Free;
  end;
end;
procedure TFileVersionTest(Full: boolean);
var V,F: TFileVersion;
    J: RawUTF8;
    i: integer;
    Valid: boolean;
begin
  V := TFileVersion.Create('',0);
  F := TFileVersion.Create('',0);
  try
    for i := 1 to 1000 do begin
      if Full then begin
        V.Major := i;
        V.Minor := i+2000;
        V.Release := i+3000;
        V.Build := i+4000;
        str(i,V.Main);
      end;
      V.BuildDateTime := 4090.0+i;
      J := ObjectToJSON(V);
      JSONToObject(F,pointer(J),Valid);
      if CheckFailed(Valid) then
        continue;
      if Full then begin
        Check(F.Major=i);
        Check(F.Minor=V.Minor);
        Check(F.Release=V.Release);
        Check(F.Build=V.Build);
        Check(F.Main=V.Main);
      end;
      CheckSame(V.BuildDateTime,F.BuildDateTime);
    end;
  finally
    F.Free;
    V.Free;
  end;
end;
{$endif}
{$endif}
{$endif}

{$ifndef LVCL}
{$ifndef DELPHI5OROLDER}
var P: PUTF8Char;
{$endif}
{$endif}
{$ifdef USEVARIANTS}
var Va: Variant;
    c: currency;
{$endif}
begin
  Check(IsString('abc'));
  Check(IsString('NULL'));
  Check(IsString('null'));
  Check(IsString('false'));
  Check(IsString('FALSE'));
  Check(IsString('true'));
  Check(IsString('TRUE'));
  Check(not IsString('123'));
  Check(not IsString('0123'));
  Check(not IsString('0.123'));
  Check(not IsString('1E19'));
  Check(not IsString('1.23E1'));
  Check(not IsString('+0'));
  Check(IsString('1.23E'));
  Check(IsString('+'));
  Check(IsString('-'));
  Check(IsStringJSON('abc'));
  Check(IsStringJSON('NULL'));
  Check(not IsStringJSON('null'));
  Check(not IsStringJSON('false'));
  Check(IsStringJSON('FALSE'));
  Check(not IsStringJSON('true'));
  Check(IsStringJSON('TRUE'));
  Check(not IsStringJSON('123'));
  Check(IsStringJSON('0123'));
  Check(not IsStringJSON('0.123'));
  Check(not IsStringJSON('1E19'));
  Check(not IsStringJSON('1.23E1'));
  Check(not IsStringJSON('0'));
  Check(not IsStringJSON('0.1'));
  Check(not IsStringJSON('-0'));
  Check(not IsStringJSON('-0.1'));
  Check(IsStringJSON('+0'));
  Check(IsStringJSON('1.23E'));
  Check(IsStringJSON('+'));
  Check(IsStringJSON('-'));
  J := JSONEncode(['name','john','year',1982,'pi',3.14159]);
  Check(Hash32(J)=$266CB31F);
  JSONDecode(J,['year','pi','john','name'],V);
  Check(length(V)=4);
  Check(V[0]='1982');
  Check(V[1]='3.14159');
  Check(V[2]=nil);
  Check(V[3]='john');
  for i := 1 to 100 do begin
    a := Random(maxInt);
    r := Random;
    U := RandomUTF8(i);
    J := JSONEncode(['a',a,'r',r,'u',U]);
    JSONDecode(J,['U','R','A','FOO'],V);
    Check(Length(V)=4);
    Check(RawUTF8(V[0])=U);
    Check(SameValue(GetExtended(V[1],err),r));
    Check(not IsString(V[2]));
    Check(not IsStringJSON(V[2]));
    Check(GetInteger(V[2])=a);
    Check(V[3]=nil);
    J := BinToBase64WithMagic(U);
    check(PInteger(J)^ and $00ffffff=JSON_BASE64_MAGIC);
{$ifndef DELPHI5OROLDER}
{$ifndef FPC}
    check(BlobToTSQLRawBlob(pointer(J))=U);
    Base64MagicToBlob(@J[4],K);
    check(BlobToTSQLRawBlob(pointer(K))=U);
{    J := TSQLRestServer.JSONEncodeResult([r]);
    Check(SameValue(GetExtended(pointer(JSONDecode(J)),err),r)); }
    {$ifdef USEVARIANTS}
    with TTextWriter.CreateOwnedStream do
    try
      AddVariantJSON(a);
      Add(',');
      AddVariantJSON(r);
      Add(',');
      PInt64(@c)^ := a;
      AddVariantJSON(c);
      Add(',');
      U := Int32ToUTF8(a);
      AddVariantJSON(U);
      J := Text;
      Check(J=U+','+DoubleToStr(r)+','+Curr64ToStr(PInt64(@c)^)+',"'+U+'"');
      P := @J[1];
      P := VariantLoadJSON(Va,P);
      Check(P<>nil);
      Check(Va=a);
      P := VariantLoadJSON(Va,P);
      Check(P<>nil);
      CheckSame(Va,r);
      P := VariantLoadJSON(Va,P);
      Check(P<>nil);
      Check(Va=c);
      P := VariantLoadJSON(Va,P);
      Check((P<>nil) and (P^=#0));
      Check(Va=U);
    finally
      Free;
    end;
    {$endif}
{$endif}
{$endif}
  end;
{$ifndef DELPHI5OROLDER}
{$ifndef FPC}
  J := GetJSONObjectAsSQL('{"ID":  1 ,"Name":"Alice","Role":"User","Last Login":null,'+
    '"First Login" :   null  ,  "Department"  :  "{\"relPath\":\"317\\\\\",\"revision\":1}" } ]', false, true);
  U := ' (ID,Name,Role,Last Login,First Login,Department) VALUES '+
    '(:(1):,:(''Alice''):,:(''User''):,:(null):,:(null):,:(''{"relPath":"317\\","revision":1}''):)';
  Check(J=U);
  J := GetJSONObjectAsSQL('{ "Name":"Alice","Role":"User","Last Login":null,'+
    '"First Login" :   null  ,  "Department"  :  "{\"relPath\":\"317\\\\\",\"revision\":1}" } ]', false, true,1,true);
  Check(J=U);
  J := GetJSONObjectAsSQL('{ "Name":"Alice","Role":"User","Last Login":null,'+
    '"First Login" :   null  ,  "Department"  :  "{\"relPath\":\"317\\\\\",\"revision\":1}" } ]', false, true,1,false);
  Insert('Row',U,3);
  Check(J=U);
  Delete(U,3,3);
  J := '{"ID":  1 ,"Name":"Alice","Role":"User","Last Login":null, // comment'#13#10+
    '"First Login" : /* to be ignored */  null  ,  "Department"  :  "{\"relPath\":\"317\\\\\",\"revision\":1}" } ]';
  RemoveCommentsFromJSON(@J[1]);
  J := GetJSONObjectAsSQL(J,false,true);
  Check(J=U);
  J := '{"RowID":  210 ,"Name":"Alice","Role":"User","Last Login":null, // comment'#13#10+
    '"First Login" : /* to be ignored */  null  ,  "Department"  :  "{\"relPath\":\"317\\\\\",\"revision\":1}" } ]';
  RemoveCommentsFromJSON(@J[1]);
  J := GetJSONObjectAsSQL(J,false,true,1,True);
  Check(J=U);
{$ifndef LVCL}
  C2 := TCollTst.Create;
  Coll := TCollTst.Create;
  try
     U := ObjectToJSON(Coll);
     Check(Hash32(U)=$95B54414);
     Check(ObjectToJSON(C2)=U);
     Coll.One.Name := 'test"\2';
     Coll.One.Color := 1;
     U := ObjectToJSON(Coll);
     Check(Hash32(U)=$CE2C2DED);
     Check(JSONToObject(C2,pointer(U),Valid)=nil);
     Check(Valid);
     U := ObjectToJSON(C2);
     Check(Hash32(U)=$CE2C2DED);
     Coll.Coll.Add.Color := 10;
     Coll.Coll.Add.Name := 'name';
     Check(Coll.Coll.Count=2);
     U := ObjectToJSON(Coll);
     Check(Hash32(U)=$36B02F0E);
     Check(JSONToObject(C2,pointer(U),Valid)=nil);
     Check(Valid);
     Check(C2.Coll.Count=2);
     U := ObjectToJSON(C2);
     Check(Hash32(U)=$36B02F0E);
     U := ObjectToJSON(Coll,[woHumanReadable]);
     Check(Hash32(U)=$2369512C);
     U := ObjectToJSON(Coll,[woStoreClassName]);
     Check(U='{"ClassName":"TCollTst","One":{"ClassName":"TCollTest","Color":1,'+
       '"Length":0,"Name":"test\"\\2"},"Coll":[{"ClassName":"TCollTest","Color":10,'+
       '"Length":0,"Name":""},{"ClassName":"TCollTest","Color":0,"Length":0,"Name":"name"}]}');
     C2.Coll.Clear;
     Check(JSONToObject(C2,pointer(U),Valid)=nil);
     Check(Valid);
     Check(C2.Coll.Count=2);
     U := ObjectToJSON(C2);
     Check(Hash32(U)=$36B02F0E);
     TJSONSerializer.RegisterClassForJSON([TComplexNumber,TCollTst]);
     J := '{"ClassName":"TComplexNumber", "Real": 10.3, "Imaginary": 7.92 }';
     P := @J[1]; // make local copy of constant
     Comp := TComplexNumber(JSONToNewObject(P,Valid));
     if not CheckFailed(Comp<>nil) then begin
       Check(Valid);
       Check(Comp.ClassType=TComplexNumber);
       CheckSame(Comp.Real,10.3);
       CheckSame(Comp.Imaginary,7.92);
       U := ObjectToJSON(Comp,[woStoreClassName]);
       Check(U='{"ClassName":"TComplexNumber","Real":10.3,"Imaginary":7.92}');
       Comp.Free;
     end;
     TJSONSerializer.RegisterCollectionForJSON(TMyCollection,TCollTest);
     TestMyColl(TMyCollection.Create(TCollTest));
     TestMyColl(ClassInstanceCreate(TMyCollection) as TMyCollection);
     TestMyColl(ClassInstanceCreate('TMyCollection') as TMyCollection);
     C2.Coll.Clear;
     U := ObjectToJSON(C2);
     Check(Hash32(U)=$CE2C2DED);
     Coll.Coll.BeginUpdate;
     for i := 1 to 10000 do
       with Coll.Coll.Add do begin
         Color := i*3;
         Length := i*5;
         Name := Int32ToUtf8(i);
       end;
     Coll.Coll.EndUpdate;
     U := ObjectToJSON(Coll.Coll);
     Check(Hash32(U)=$DB782098);
     C2.Coll.Clear;
     Check(JSONToObject(C2.fColl,pointer(U),Valid)=nil);
     Check(Valid);
     Check(C2.Coll.Count=Coll.Coll.Count);
     for i := 1 to C2.Coll.Count-2 do
       with C2.Coll[i+1] do begin
         Check(Color=i*3);
         Check(Length=i*5);
         Check(Name=Int32ToUtf8(i));
       end;
     U := ObjectToJSON(Coll);
     Check(length(U)=443103);
     Check(Hash32(U)=$7EACF12A);
     C2.One.Name := '';
     C2.Coll.Clear;
     Check(JSONToObject(C2,pointer(U),Valid)=nil);
     Check(Valid);
     Check(C2.Coll.Count=Coll.Coll.Count);
     U := ObjectToJSON(C2);
     Check(length(U)=443103);
     Check(Hash32(U)=$7EACF12A);
     for i := 1 to C2.Coll.Count-2 do
       with C2.Coll[i+1] do begin
         Check(Color=i*3);
         Check(Length=i*5);
         Check(Name=Int32ToUtf8(i));
       end;
     Coll.Coll.Clear;
     Coll.Str := TStringList.Create;
     Coll.Str.BeginUpdate;
     for i := 1 to 10000 do
       Coll.Str.Add(IntToStr(i));
     Coll.Str.EndUpdate;
     U := ObjectToJSON(Coll);
     Check(Hash32(U)=$85926050);
     U := ObjectToJSON(Coll,[woHumanReadable]);
     Check(Hash32(U)=$E5598679);
     C2.Str := TStringList.Create;
     Check(JSONToObject(C2,pointer(U),Valid)=nil);
     Check(Valid);
     Check(C2.Str.Count=Coll.Str.Count);
     for i := 1 to C2.Str.Count do
       Check(C2.Str[i-1]=IntToStr(i));
     J := ObjectToJSON(C2);
     Check(Hash32(J)=$85926050);
     U := '{"One":{"Color":1,"Length":0,"Name":"test\"\\2},"Coll":[]}';
     Check(IdemPChar(JSONToObject(C2,@U[1],Valid),'"TEST'),'invalid JSON');
     Check(not Valid);
     U := '{"One":{"Color":1,"Length":0,"Name":"test\"\\2"},"Coll":[]';
     Check(JSONToObject(C2,@U[1],Valid)<>nil);
     Check(not Valid);
     U := '{"One":{"Color":,"Length":0,"Name":"test\"\\2"},"Coll":[]';
     Check(IdemPChar(JSONToObject(C2,@U[1],Valid),',"LENGTH'),'invalid JSON');
     Check(not Valid);
  finally
    C2.Free;
    Coll.Free;
  end;
  TCollTstDynArrayTest;
  TTextWriter.RegisterCustomJSONSerializer(TypeInfo(TFVs),
    TCollTstDynArray.FVReader,TCollTstDynArray.FVWriter);
  TCollTstDynArrayTest;
  TTextWriter.RegisterCustomJSONSerializer(TypeInfo(TFVs),
    TCollTstDynArray.FVReader2,TCollTstDynArray.FVWriter2);
  TCollTstDynArrayTest;
  TFileVersionTest(false);
  TJSONSerializer.RegisterCustomSerializer(TFileVersion,
    TCollTstDynArray.FVClassReader,TCollTstDynArray.FVClassWriter);
  TFileVersionTest(true);
  TJSONSerializer.RegisterCustomSerializer(TFileVersion,nil,nil);
  TFileVersionTest(false);
{$endif FPC}
{$endif DELPHI5OROLDER}
{$endif LVCL}
end;

{$ifndef DELPHI5OROLDER}
{$ifndef FPC}
type TOrdTypeSet = set of TOrdType;

procedure TTestLowLevelTypes.RTTI;
var i: Integer;
    tmp: RawUTF8;
begin
  with PTypeInfo(TypeInfo(TOrdType))^.EnumBaseType^ do
    for i := 0 to integer(high(TOrdType)) do begin
{$ifdef VERBOSE}writeln(i,' ',GetEnumName(i)^, ' ',GetEnumNameTrimed(i));{$endif}
     tmp := GetEnumNameTrimed(i);
     Check(GetEnumNameValue(GetEnumName(i)^)=i);
     Check(GetEnumNameTrimedValue(tmp)=i);
     Check(GetEnumNameTrimedValue(tmp)=i);
  end;
  Check(PTypeInfo(TypeInfo(TOrdTypeSet))^.SetEnumType=
    PTypeInfo(TypeInfo(TOrdType))^.EnumBaseType);
  with PTypeInfo(TypeInfo(TSQLRecordTest))^ do begin
    Check(InheritsFrom(TSQLRecordTest));
    Check(InheritsFrom(TSQLRecord));
    Check(not InheritsFrom(TSQLRecordPeople));
  end;
  Check(GetDisplayNameFromClass(nil)='');
  Check(GetDisplayNameFromClass(TSQLRecord)='Record');
  Check(GetDisplayNameFromClass(TSQLRecordPeople)='People');
  Check(GetDisplayNameFromClass(TObject)='Object');
  Check(GetDisplayNameFromClass(TSQLTable)='Table');
  Check(GetDisplayNameFromClass(TSynValidateRest)='ValidateRest');
  Check(InternalMethodInfo(TSQLRecord,'ABC')=nil);
  Check(InternalMethodInfo(TSQLRestServer,'ABC')=nil);
  Check(InternalMethodInfo(TSQLRestServer,'STAT')<>nil);
  Check(InternalMethodInfo(TSQLRestServer,'stat')^.MethodAddr=
    TSQLRestServer.MethodAddress('STAT'));
  Check(InternalMethodInfo(TSQLRestServer,'timestamp')<>nil);
  Check(InternalMethodInfo(TSQLRestServer,'timestamp')^.MethodAddr=
    TSQLRestServer.MethodAddress('TIMEstamp'));
end;
{$endif FPC}
{$endif DELPHI5OROLDER}

procedure TTestLowLevelTypes.UrlEncoding;
var i: integer;
    s,t: RawUTF8;
{$ifndef DELPHI5OROLDER}
    d: RawUTF8;
{$endif}
begin
  for i := 1 to 100 do begin
    s := RandomUTF8(i);
    t := UrlEncode(s);
    Check(UrlDecode(t)=s);
    {$ifndef DELPHI5OROLDER}
    {$ifndef FPC}
    d := 'seleCT='+t+'&where='+
      {$ifndef ENHANCEDRTL}Int32ToUtf8{$else}IntToStr{$endif}(i);
    Check(UrlEncode(['seleCT',s,'where',i])='?'+d);
    {$endif FPC}
    {$endif DELPHI5OROLDER}
  end;
end;


{$ifndef DELPHI5OROLDER}
{$ifndef FPC}

{ TTestBasicClasses }

procedure TTestBasicClasses._TSQLModel;
var M: TSQLModel;
begin
  M := TSQLModel.Create([TSQLRecordTest]);
  try
    Check(M['Test']<>nil);
    Check(M['Test2']=nil);
    Check(M['TEST']=TSQLRecordTest);
  finally
    M.Free;
  end;
end;

procedure TTestBasicClasses._TSQLRecord;
var i: integer;
    P: PPropInfo;
    s: RawUTF8;
    M: TSQLModel;
    T,T2: TSQLRecordTest;
{$ifndef LVCL}
    valid: boolean;
{$endif}
begin
  T := TSQLRecordTest.Create;
  M := TSQLModel.Create([TSQLRecordTest]);
  with InternalClassProp(TSQLRecordTest)^ do begin
    P := @PropList;
    for i := 0 to PropCount-1 do begin
      Check(TSQLRecordTest.RecordProps.Fields.IndexByName(RawUTF8(P^.Name))=i);
      Check(T.RecordProps.Fields.ByRawUTF8Name(RawUTF8(P^.Name))<>nil);
      P := P^.Next;
    end;
  end;
  s := TSQLRecordTest.GetSQLCreate(M);
  Check(s='CREATE TABLE Test(ID INTEGER PRIMARY KEY AUTOINCREMENT, Int INTEGER, '+
    'Test TEXT COLLATE SYSTEMNOCASE, Unicode TEXT COLLATE SYSTEMNOCASE, '+
    'Ansi TEXT COLLATE NOCASE, ValFloat FLOAT, ValWord INTEGER, '+
    'ValDate TEXT COLLATE ISO8601, Next INTEGER, Data BLOB'+
    {$ifdef USEVARIANTS}', ValVariant TEXT COLLATE NOCASE'+{$endif}');');
  s := TSQLRecordTest.RecordProps.SQLAddField(0);
  Check(s='ALTER TABLE Test ADD COLUMN Int INTEGER; ');
  s := TSQLRecordTest.RecordProps.SQLAddField(1000);
  Check(s='');
  T2 := TSQLRecordTest.Create;
  try
    Check(T.RecordProps.SQLTableName='Test');
    Check(T.SQLTableName='Test');
    Check(GetCaptionFromClass(T.RecordClass)='Record test');
    s := T.GetSQLSet;
    Check(s='Int=0, Test='''', Unicode='''', Ansi='''', ValFloat=0, ValWord=0, '+
      'ValDate='''', Next=0'{$ifdef USEVARIANTS}+', ValVariant=null'{$endif});
    s := T.GetSQLValues;
    Check(s='Int,Test,Unicode,Ansi,ValFloat,ValWord,ValDate,Next'+
      {$ifdef USEVARIANTS}',ValVariant'+{$endif}
      ' VALUES (0,'''','''','''',0,0,'''',0'+{$ifdef USEVARIANTS}',null'+{$endif}')');
{$ifndef LVCL}
    s := ObjectToJSON(T);
    Check(s='{"ID":0,"Int":0,"Test":"","Unicode":"","Ansi":"","ValFloat":0,'+
      '"ValWord":0,"ValDate":"","Next":0,"Data":"","ValVariant":null}');
{$endif}
    T.ValDate := 39882.888612; // a fixed date and time
    T.Ansi := 'abcde'+chr(233)+'ef'+chr(224)+chr(233);
    T.Test := WinAnsiToUTF8('abcde'+chr(233)+'ef'+chr(224)+chr(233));
    T.Unicode := Utf8DecodeToRawUnicode(T.fTest);
    Check(RawUnicodeToWinAnsi(T.fUnicode)=T.fAnsi);
    // the same string is stored with some Delphi types, but will remain
    // identical in UTF-8 SQL, as all will be converted into UTF-8
    T.Valfloat := 3.141592653;
    T.ValWord := 1203;
    {$ifdef USEVARIANTS}
    T.ValVariant := 3.1416; // will be stored as TEXT, i.e. '3.1416'
    {$endif}
    s := T.GetSQLSet;
    Check(s='Int=0, Test='''+T.Test+''', Unicode='''+T.Test+
      ''', Ansi='''+T.Test+''', ValFloat=3.141592653, ValWord=1203, '+
      'ValDate=''2009-03-10T21:19:36'', Next=0'{$ifdef USEVARIANTS}+
      ', ValVariant=''3.1416'''{$endif});
    s := T.GetSQLValues;
    {$ifdef USEVARIANTS}
    Check(Hash32(s)=$2D344A5E);
    {$else}
    Check(Hash32(s)=$6DE61E87);
    {$endif}
    s := T.GetJSONValues(false,true,soSelect);
    Check(s='{"fieldCount":'+{$ifdef USEVARIANTS}'10'{$else}'9'{$endif}+
      ',"values":["RowID","Int","Test","Unicode","Ansi",'+
      '"ValFloat","ValWord","ValDate","Next"'{$ifdef USEVARIANTS}+
      ',"ValVariant"'{$endif}+',0,0,"'+T.Test+'","'+
      T.Test+'","'+T.Test+'",3.141592653,1203,"2009-03-10T21:19:36",0'
      {$ifdef USEVARIANTS}+',3.1416'{$endif}+']}');
    Check(T.SameValues(T));
    Check(not T.SameValues(T2));
    T2.FillFrom(s);
    Check(T.SameValues(T2));
    Check(T2.GetJSONValues(false,true,soSelect)=s);
    T.ID := 10;
    s := T.GetJSONValues(true,true,soSelect);
    {$ifdef VERBOSE}writeln(s);{$endif}
    T2.ClearProperties;
    Check(not T.SameValues(T2));
    T2.FillFrom(s);
    Check(T.SameValues(T2));
    Check(T2.GetJSONValues(true,true,soSelect)=s);
{$ifndef LVCL}
    s := ObjectToJSON(T);
    Check(s='{"ID":10,"Int":0,"Test":"'+T.Test+'","Unicode":"'+T.Test+
      '","Ansi":"'+T.Test+'","ValFloat":3.141592653,"ValWord":1203,'+
      '"ValDate":"2009-03-10T21:19:36","Next":0,"Data":""'{$ifdef USEVARIANTS}
        +',"ValVariant":3.1416'{$endif}+'}');
    T2.ClearProperties;
    Check(not T.SameValues(T2));
    Check(JSONToObject(T2,pointer(s),valid)=nil);
    Check(valid);
    Check(T.SameValues(T2));
{$endif}
    T.Int := 1234567890123456;
    s := T.GetJSONValues(true,true,soSelect);
    Check(s='{"RowID":10,"Int":1234567890123456,"Test":"'+T.Test+'","Unicode":"'+T.Test+
      '","Ansi":"'+T.Test+'","ValFloat":3.141592653,"ValWord":1203,'+
      '"ValDate":"2009-03-10T21:19:36","Next":0'+
      {$ifdef USEVARIANTS}',"ValVariant":3.1416'+{$endif}'}');
    T2.ClearProperties;
    Check(not T.SameValues(T2));
    T2.FillFrom(s);
    Check(T.SameValues(T2));
    Check(T2.GetJSONValues(true,true,soSelect)=s);
    Check(T2.Int=1234567890123456);
    {$ifdef USEVARIANTS}
    T.ValVariant := UTF8ToSynUnicode(T.Test);
    {$endif}
    s := T.GetJSONValues(true,true,soSelect);
    Check(s='{"RowID":10,"Int":1234567890123456,"Test":"'+T.Test+'","Unicode":"'+T.Test+
      '","Ansi":"'+T.Test+'","ValFloat":3.141592653,"ValWord":1203,'+
      '"ValDate":"2009-03-10T21:19:36","Next":0'{$ifdef USEVARIANTS}
      +',"ValVariant":"'+T.Test+'"'{$endif}+'}');
    s := T.GetSQLSet;
    Check(s='Int=1234567890123456, Test='''+T.Test+''', Unicode='''+T.Test+
      ''', Ansi='''+T.Test+''', ValFloat=3.141592653, ValWord=1203, '+
      'ValDate=''2009-03-10T21:19:36'', Next=0'{$ifdef USEVARIANTS}+
      ', ValVariant='''+T.Test+''''{$endif});
  finally
    M.Free;
    T2.Free;
    T.Free;
  end;
end;

procedure TTestBasicClasses._TSQLRecordSigned;
var R: TSQLRecordSigned;
    i: integer;
    Content: RawByteString;
begin
  R := TSQLRecordSigned.Create;
  try
    for i := 1 to 50 do begin
      Content := RandomString(5*Random(1000));
      Check(R.SetAndSignContent('User',Content));
      Check(R.SignedBy='User');
      Check(R.CheckSignature(Content));
      Content := Content+'?'; // invalidate content
      Check(not R.CheckSignature(Content));
      R.UnSign;
    end;
  finally
    R.Free;
  end;
end;

{$endif FPC}
{$endif DELPHI5OROLDER}

{$ifdef UNICODE}
{$WARNINGS ON} // don't care about implicit string cast in tests
{$endif}

{ TTestCompression }

destructor TTestCompression.Destroy;
begin
  M.Free;
  inherited;
end;

const
  // uses a const table instead of a dynamic array, for better regression test
  crc32Tab: array[byte] of cardinal =
    ($00000000, $77073096, $EE0E612C, $990951BA,
    $076DC419, $706AF48F, $E963A535, $9E6495A3,
    $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
    $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
    $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC,
    $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
    $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
    $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940,
    $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116,
    $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
    $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,

    $76DC4190, $01DB7106, $98D220BC, $EFD5102A,
    $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
    $7807C9A2, $0F00F934, $9609A88E, $E10E9818,
    $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
    $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
    $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C,
    $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
    $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
    $5005713C, $270241AA, $BE0B1010, $C90C2086,
    $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4,
    $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,

    $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
    $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
    $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE,
    $F762575D, $806567CB, $196C3671, $6E6B06E7,
    $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
    $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
    $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
    $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
    $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F,
    $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04,
    $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,

    $9B64C2B0, $EC63F226, $756AA39C, $026D930A,
    $9C0906A9, $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
    $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
    $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E,
    $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
    $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
    $A7672661, $D06016F7, $4969474D, $3E6E77DB,
    $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
    $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6,
    $BAD03605, $CDD70693, $54DE5729, $23D967BF,
    $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
    $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);
function UpdateCrc32(aCRC32: cardinal; inBuf: pointer; inLen: integer) : cardinal;
var i: integer;
begin // slowest but always accurate version
  result := not aCRC32;
  for i := 1 to inLen do begin
    result := crc32Tab[byte(result xor pByte(inBuf)^)] xor (result shr 8);
    inc(PByte(inBuf));
  end;
  result := not result;
end;

procedure TTestCompression.GZipFormat;
var Z: TSynZipCompressor;
    L,n: integer;
    P: PAnsiChar;
    crc2: Cardinal;
    s: RawByteString;
begin
  Check(crc32(0,@crc32Tab,5)=$DF4EC16C,'crc32');
  Check(UpdateCrc32(0,@crc32Tab,5)=$DF4EC16C,'crc32');
  Check(crc32(0,@crc32Tab,1024)=$6FCF9E13,'crc32');
  Check(UpdateCrc32(0,@crc32Tab,1024)=$6FCF9E13);
  Check(crc32(0,@crc32Tab,1024-5)=$70965738,'crc32');
  Check(UpdateCrc32(0,@crc32Tab,1024-5)=$70965738);
  Check(crc32(0,pointer(PtrInt(@crc32Tab)+1),2)=$41D912FF,'crc32');
  Check(UpdateCrc32(0,pointer(PtrInt(@crc32Tab)+1),2)=$41D912FF);
  Check(crc32(0,pointer(PtrInt(@crc32Tab)+3),1024-5)=$E5FAEC6C,'crc32');
  Check(UpdateCrc32(0,pointer(PtrInt(@crc32Tab)+3),1024-5)=$E5FAEC6C);
  M := SynCommons.THeapMemoryStream.Create;
  Z := TSynZipCompressor.Create(M,6,szcfGZ);
  L := length(Data);
  P := Pointer(Data);
  crc := 0;
  crc2 := 0;
  while L<>0 do begin
    if L>1000 then
      n := 1000 else
      n := L;
    Z.Write(P^,n); // compress by little chunks to test streaming
    crc := crc32(crc,P,n);
    crc2 := UpdateCrc32(crc2,P,n);
    inc(P,n);
    dec(L,n);
  end;
  Check(crc=Z.CRC,'crc32');
  Check(crc2=crc,'crc32');
  Z.Free;
  Check(GZRead(M.Memory,M.Position)=Data);
  s := Data;
  Check(CompressGZip(s,true)='gzip');
  Check(CompressGZip(s,false)='gzip');
  Check(s=Data);
  s := Data;
  Check(CompressDeflate(s,true)='deflate');
  Check(CompressDeflate(s,false)='deflate');
  Check(s=Data);
end;

procedure TTestCompression.InMemoryCompression;
var comp: Integer;
    tmp: RawByteString;
begin
  Check(CRC32string('TestCRC32')=$2CB8CDF3);
  tmp := RawByteString(Ident);
  for comp := 0 to 9 do
    Check(UnCompressString(CompressString(tmp,False,comp))=tmp);
  Data := StringFromFile(ParamStr(0));
  Check(UnCompressString(CompressString(Data,False,6))=Data);
end;

procedure TTestCompression.ZipFormat;
var FN: TFileName;
procedure Test(aCount: integer);
var i: integer;
    tmp: RawByteString;
    crc: Cardinal;
begin
  with TZipRead.Create(FN) do
  try
    Check(Count=aCount);
    i := NameToIndex('REP1\ONE.exe');
    Check(i=0);
    Check(UnZip(i)=Data);
    i := NameToIndex('REp2\ident.gz');
    Check(i=1);
    crc := crc32(0,M.Memory,M.Position);
    Check(Entry[i].info^.zcrc32=crc);
    tmp := UnZip(i);
    Check(tmp<>'');
    Check(crc32(0,pointer(tmp),length(tmp))=crc);
    i := NameToIndex(ExtractFileName(paramstr(0)));
    Check(i=2);
    Check(UnZip(i)=Data);
    Check(Entry[i].info^.zcrc32=crc32(0,pointer(Data),length(Data)));
    i := NameToIndex('REp2\ident2.gz');
    Check(i=3);
    Check(Entry[i].info^.zcrc32=crc);
    tmp := UnZip(i);
    Check(tmp<>'');
    Check(crc32(0,pointer(tmp),length(tmp))=crc);
    if aCount=4 then
      Exit;
    i := NameToIndex('REP1\twO.exe');
    Check(i=4);
    Check(UnZip(i)=Data);
  finally
    Free;
  end;
end;
begin
  FN := ChangeFileExt(paramstr(0),'.zip');
  with TZipWrite.Create(FN) do
  try
    AddDeflated('rep1\one.exe',pointer(Data),length(Data));
    Check(Count=1);
    AddDeflated('rep2\ident.gz',M.Memory,M.Position);
    Check(Count=2);
    AddDeflated(ParamStr(0));
    Check(Count=3,'direct zip file');
    AddStored('rep2\ident2.gz',M.Memory,M.Position);
    Check(Count=4);
  finally
    Free;
  end;
  Test(4);
  with TZipWrite.CreateFrom(FN) do
  try
    Check(Count=4);
    AddDeflated('rep1\two.exe',pointer(Data),length(Data));
    Check(Count=5);
  finally
    Free;
  end;
  Test(5);
  DeleteFile(FN);
end;

procedure TTestCompression._SynLZO;
var s,t: AnsiString;
    i: integer;
begin
  for i := 0 to 1000 do begin
    t := RandomString(i*8);
    s := t;
    Check(CompressSynLZO(s,true)='synlzo');
    Check(CompressSynLZO(s,false)='synlzo');
    Check(s=t);
  end;
  s := Data;
  Check(CompressSynLZO(s,true)='synlzo');
  Check(CompressSynLZO(s,false)='synlzo');
  Check(s=Data);
end;

{$ifndef CONDITIONALEXPRESSIONS} // Delphi 5 linking error?
function CompressSynLZ(var Data: AnsiString; Compress: boolean): AnsiString;
var DataLen, len: integer;
    P: PAnsiChar;
begin
  DataLen := length(Data);
  if DataLen<>0 then // '' is compressed and uncompressed to ''
  if Compress then begin
    len := SynLZcompressdestlen(DataLen)+8;
    SetString(result,nil,len);
    P := pointer(result);
    PCardinal(P)^ := Hash32(pointer(Data),DataLen);
    {$ifdef PUREPASCAL}
    len := SynLZcompress1pas(pointer(Data),DataLen,P+8);
    {$else}
    len := SynLZcompress1asm(pointer(Data),DataLen,P+8);
    {$endif}
    PCardinal(P+4)^ := Hash32(pointer(P+8),len);
    SetString(Data,P,len+8);
  end else begin
    result := '';
    P := pointer(Data);
    if (DataLen<=8) or (Hash32(pointer(P+8),DataLen-8)<>PCardinal(P+4)^) then
      exit;
    len := SynLZdecompressdestlen(P+8);
    SetLength(result,len);
    if (len<>0) and ((
      {$ifdef PUREPASCAL}SynLZdecompress1pas{$else}SynLZdecompress1asm{$endif}
        (P+8,DataLen-8,pointer(result))<>len) or
       (Hash32(pointer(result),len)<>PCardinal(P)^)) then begin
      result := '';
      exit;
    end else
      SetString(Data,PAnsiChar(pointer(result)),len);
  end;
  result := 'synlz';
end;
{$endif}

procedure TTestCompression._SynLZ;
var s,t: RawByteString;
    i: integer;
    {$ifndef PUREPASCAL}
    comp1,comp2,dec1,dec2: array of byte;
    complen1,complen2: integer;
    {$endif}
begin
  for i := 0 to 1000 do begin
    t := RandomString(i*8);
    SetString(s,PAnsiChar(pointer(t)),length(t)); // =UniqueString
    Check(CompressSynLZ(s,true)='synlz');
    Check(CompressSynLZ(s,false)='synlz');
    Check(s=t);
    {$ifndef PUREPASCAL}
    SetLength(comp1,SynLZcompressdestlen(length(s)));
    complen1 := SynLZcompress1asm(Pointer(s),length(s),pointer(comp1));
    Check(complen1<length(comp1));
    SetLength(comp2,SynLZcompressdestlen(length(s)));
    complen2 := SynLZcompress1pas(Pointer(s),length(s),pointer(comp2));
    Check(complen2<length(comp2));
    Check(complen1=complen2);
    Check(CompareMem(pointer(comp1),pointer(comp2),complen1));
    Check(SynLZdecompressdestlen(pointer(comp1))=length(s));
    Check(SynLZdecompressdestlen(pointer(comp2))=length(s));
    SetLength(dec1,Length(s));
    Check(SynLZdecompress1pas(Pointer(comp1),complen1,pointer(dec1))=length(s));
    Check(CompareMem(pointer(dec1),pointer(s),length(s)));
    SetLength(dec2,Length(s));
    Check(SynLZdecompress1asm(Pointer(comp2),complen2,pointer(dec2))=length(s));
    Check(CompareMem(pointer(dec1),pointer(s),length(s)));
    {$endif}
  end;
  s := Data;
  Check(CompressSynLZ(s,true)='synlz');
  Check(CompressSynLZ(s,false)='synlz');
  Check(s=Data);
end;


{ TTestCryptographicRoutines }

procedure TTestCryptographicRoutines.Adler32;
begin
  Check(Adler32SelfTest);
end;

procedure TTestCryptographicRoutines.Base64;
const
  Value: WinAnsiString = 'Hello /c'''+chr(233)+'tait '+chr(231)+chr(224)+'+';
  Value64: RawByteString = 'SGVsbG8gL2Mn6XRhaXQg5+Ar';
var tmp, b64: RawByteString;
    i, L: Integer;
begin
  Check(not IsBase64(Value));
  Check(Base64Encode(Value)=Value64);
  Check(BinToBase64(Value)=Value64);
  Check(IsBase64(Value64));
  tmp := StringFromFile(paramstr(0));
  b64 := Base64Encode(tmp);
  Check(IsBase64(b64));
  Check(Base64Decode(b64)=tmp);
  Check(BinToBase64(tmp)=b64);
  Check(Base64ToBin(b64)=tmp);
  tmp := '';
  for i := 1 to 1998 do begin
    b64 := Base64Encode(tmp);
    Check(Base64Decode(b64)=tmp);
    Check((tmp='') or IsBase64(b64));
    Check(BinToBase64(tmp)=b64);
    Check(Base64ToBin(b64)=tmp);
    if tmp<>'' then begin
      L := length(b64);
      Check(not IsBase64(pointer(b64),L-1));
      b64[Random(L)+1] := '&';
      Check(not IsBase64(pointer(b64),L));
    end;
    tmp := tmp+AnsiChar(Random(255));
  end;
end;

procedure TTestCryptographicRoutines._AES256;
var A: TAES;
    st, orig, crypted, s2: RawByteString;
    Key: TSHA256Digest;
    s,b,p: TAESBlock;
    i,k,ks,m, len: integer;
    AES: TAESFull;
    PC: PAnsiChar;
const MAX = 4096*1024;  // test 4 MB data, i.e. multi-threaded AES
      MODES: array[0..4] of TAESAbstractClass =
        (TAESECB, TAESCBC, TAESCFB, TAESOFB, TAESCTR);
begin
  SetLength(orig,MAX);
  SetLength(crypted,MAX+256);
  st := '1234essai';
  pInteger(@st[1])^ := Random(MaxInt);
  for k := 0 to 2 do begin
    ks := 128+k*64; // test keysize of 128, 192 and 256 bits
    for i := 1 to 100 do begin
      SHA256Weak(st,Key);
      move(Key,s,16);
      A.EncryptInit(Key,ks);
      A.Encrypt(s,b);
      A.Done;
      A.DecryptInit(Key,ks);
      A.Decrypt(b,p);
      A.Done;
      Check(CompareMem(@p,@s,AESBLockSize));
      Check(AESSHA256(AESSHA256(st,st,true),st,False)=st);
      st := st+AnsiChar(Random(255));
    end;
    PC := Pointer(orig);
    len := MAX;
    repeat // populate orig with random data
      if len>length(st) then
        i := length(st) else
        i := len;
      dec(len,i);
      move(pointer(st)^,PC^,i);
      inc(PC,i);
    until len=0;
    len := AES.EncodeDecode(Key,ks,MAX,True,nil,nil,pointer(orig),pointer(crypted));
    Check(len<MAX+256);
    Check(len>=MAX);
    len := AES.EncodeDecode(Key,ks,len,False,nil,nil,pointer(crypted),nil);
    try
      Check(len=MAX);
      Check(CompareMem(AES.outStreamCreated.Memory,pointer(orig),MAX));
      for m := low(MODES) to high(MODES) do
      with MODES[m].Create(Key,ks,b) do
      try
        for i := 0 to 127 do begin
          FillChar(pointer(crypted)^,i,0);
          Encrypt(AES.outStreamCreated.Memory,pointer(crypted),i);
          FillChar(pointer(orig)^,i,0);
          Decrypt(pointer(crypted),pointer(orig),i);
          Check((i=0) or (not IsZero(pointer(orig),i)) or
            IsZero(AES.outStreamCreated.Memory,i));
          Check(CompareMem(AES.outStreamCreated.Memory,pointer(orig),i));
          SetString(s2,PAnsiChar(pointer(orig)),i);
          Check(DecryptPKCS7(EncryptPKCS7(s2))=s2);
        end;
      finally
        Free;
      end;
    finally
      AES.outStreamCreated.Free;
    end;
  end;
end;

procedure TTestCryptographicRoutines._MD5;
begin
  Check(MD5SelfTest);
end;

procedure TTestCryptographicRoutines._SHA1;
procedure SingleTest(const s: AnsiString; TDig: TSHA1Digest);
var SHA: TSHA1;
    Digest: TSHA1Digest;
    i: integer;
begin
  // 1. Hash complete AnsiString
  SHA.Full(pointer(s),length(s),Digest);
  Check(CompareMem(@Digest,@TDig,sizeof(Digest)));
  // 2. one update call for all chars
  for i := 1 to length(s) do
    SHA.Update(@s[i],1);
  SHA.Final(Digest);
  Check(CompareMem(@Digest,@TDig,sizeof(Digest)));
  // 3. test consistency with Padlock engine down results 
{$ifdef USEPADLOCK}
  if not padlock_available then exit;
  padlock_available := false;  // force PadLock engine down
  SHA.Full(pointer(s),length(s),Digest);
  Check(CompareMem(@Digest,@TDig,sizeof(Digest)));
{$ifdef PADLOCKDEBUG} write('=padlock '); {$endif}
  padlock_available := true; // restore previous value
{$endif}
end;
const
  Test1Out: TSHA1Digest=
    ($A9,$99,$3E,$36,$47,$06,$81,$6A,$BA,$3E,$25,$71,$78,$50,$C2,$6C,$9C,$D0,$D8,$9D);
  Test2Out: TSHA1Digest=
    ($84,$98,$3E,$44,$1C,$3B,$D2,$6E,$BA,$AE,$4A,$A1,$F9,$51,$29,$E5,$E5,$46,$70,$F1);
var
  s: AnsiString;
  SHA: TSHA1;
  Digest: TSHA1Digest;
begin
  SingleTest('abc',Test1Out);
  SingleTest('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq',Test2Out);
  s := 'Wikipedia, l''encyclopedie libre et gratuite';
  SHA.Full(pointer(s),length(s),Digest);
  Check(SHA1DigestToString(Digest)='c18cc65028bbdc147288a2d136313287782b9c73');
end;

procedure TTestCryptographicRoutines._SHA256;
procedure SingleTest(const s: AnsiString; const TDig: TSHA256Digest);
var SHA: TSHA256;
  Digest: TSHA256Digest;
  i: integer;
begin
  // 1. Hash complete AnsiString
  SHA.Full(pointer(s),length(s),Digest);
  Check(CompareMem(@Digest,@TDig,sizeof(Digest)));
  // 2. one update call for all chars
  SHA.Init;
  for i := 1 to length(s) do
    SHA.Update(@s[i],1);
  SHA.Final(Digest);
  Check(CompareMem(@Digest,@TDig,sizeof(Digest)));
  // 3. test consistency with Padlock engine down results
{$ifdef USEPADLOCK}
  if not padlock_available then exit;
  padlock_available := false;  // force PadLock engine down
  SHA.Full(pointer(s),length(s),Digest);
  Check(CompareMem(@Digest,@TDig,sizeof(Digest)));
{$ifdef PADLOCKDEBUG} write('=padlock '); {$endif}
  padlock_available := true;
{$endif}
end;
var Digest: TSHA256Digest;
const
  D1: TSHA256Digest =
    ($ba,$78,$16,$bf,$8f,$01,$cf,$ea,$41,$41,$40,$de,$5d,$ae,$22,$23,
     $b0,$03,$61,$a3,$96,$17,$7a,$9c,$b4,$10,$ff,$61,$f2,$00,$15,$ad);
  D2: TSHA256Digest =
    ($24,$8d,$6a,$61,$d2,$06,$38,$b8,$e5,$c0,$26,$93,$0c,$3e,$60,$39,
     $a3,$3c,$e4,$59,$64,$ff,$21,$67,$f6,$ec,$ed,$d4,$19,$db,$06,$c1);
  D3: TSHA256Digest =
    ($94,$E4,$A9,$D9,$05,$31,$23,$1D,$BE,$D8,$7E,$D2,$E4,$F3,$5E,$4A,
     $0B,$F4,$B3,$BC,$CE,$EB,$17,$16,$D5,$77,$B1,$E0,$8B,$A9,$BA,$A3);
begin
//  result := true; exit;
  SingleTest('abc', D1);
  SingleTest('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq', D2);
  SHA256Weak('lagrangehommage',Digest); // test with len=256>64
  Check(Comparemem(@Digest,@D3,sizeof(Digest)));
end;


{$ifndef FPC}
{$ifndef LVCL}
{ TTestSynopsePDF }

const
  Date = 40339.803675; // forced date to have the exact same PDF content (Hash32)

procedure TTestSynopsePDF._TPdfDocument;
var MS: THeapMemoryStream;
    i,y: integer;
    embed: boolean;
    WS: SynUnicode;
const
  Hash: array[boolean] of Cardinal =
    ($1780F68C,$A1201D84);
  Name: array[boolean] of PDFString =
    ('Arial','Helvetica');
begin
  MS := THeapMemoryStream.Create;
  with TPdfDocument.Create do
  try
    for embed := false to true do begin
      Info.CreationDate := Date; // no date nor creator variation in hashed value
      Info.Data.PdfTextByName('Producer').Value := 'Synopse PDF engine';
      StandardFontsReplace := embed;
      AddPage;
      Canvas.SetFont('arial',10,[]);
      Check(Canvas.Page.Font.Name=Name[embed]);
      y := 800;
      for i := 1 to 30 do begin
        Canvas.SetFont('Arial',9+i,[]);
        WS := 'Texte accentue n�'+IntToString(i);
        PWordArray(WS)^[13] := 233;
        Canvas.TextOutW(100,y,pointer(WS));
        dec(y,9+i);
      end;
      SaveToStream(MS,Date);
      // MS.SaveToFile(ChangeFileExt(paramstr(0),'.pdf'));
      Check(Hash32(MS.Memory,MS.Position)=Hash[embed]);
      if not embed then begin
        if CharSet<>ANSI_CHARSET then
          break; // StandardFontsReplace will work only with ANSI code page
        NewDoc;
        MS.Clear;
      end;
    end;
  finally
    Free;
    MS.Free;
  end;
end;

procedure TTestSynopsePDF._TPdfDocumentGDI;
const
  EMF: RawByteString = // some compressed EMF file content
  'gDUBAAAAAABwgLjg3Z0LkBXVmcfPGd4KCqNRNCwBBaPDw1EU8RFkZlY2rkJQRkWBACIjRJFHYHaWkDgl'+
  'RLMkQTTo6hbZ4CMlURfQJXHjWuXsrsoaWUUqUckaJSWV4Got+MJVMLPnu6f/PX0/7wwX7vdxv0pTh+7T'+
  '/+5zfqdPT79uf/33zrkbXdtwS4VzY3xb/vZJzvUZ6tyAi8aNdc675rO9qz/WuZ6ODV1C6uzcM2HdOT5f'+
  'euutrq7fsi7ui2G6d2b+5SHN91Sqcx+1trZm11kVy8j9P85NdANCmuFuct/MTc1yC90c18AZOhg2djvX'+
  'b/qk0k3eWJfL0zTNm//Red4PHuV7v1QTF1x/oR+zqsav+79K98K+Grc/LLcjjHeFNChMj/lJjR8axlvD'+
  'cl8I7aX1J4T1c+VcELZc0Na9Wee6TZy1cM6sb474xR4q90JPdfVLNFqWUu+7a/yEUA7Np2HtnK/4pk8r'+
  '3WM76tyln7bNc67SPTekLtXRBprO6S/XuTF3TG+keQ+Gsmb+dErjf4bxlJD+Msy7rtF1J22wi/1GG7Wv'+
  'a+vDU0LqF1JFks92H9Yh7dhkuldIX07K6JQsh+7D8jT/hGSatMpMOdllLiW+TH18/1sW8jUhP9DtySzV'+
  'fGHh6cJDtj5Mh921GdOhPc3YF0OXfm5ffKqibbPU5Pa8GXl/Mwc3TG2kNnfNzDl19HC3a0+lG/etqFEe'+
  'Q8H23xv7uv2hJUnO7Xqv0v33kqmNh16md5Nmnx7L2kf7cml/A3xfpO2d3Rez/XNC2/xW7D8+s0y23+jw'+
  '09ExpPR+c25K6KPrQqK/tfoPKt1Hv+m8eGmXhf5Pod7dizot/v4TUxr7zhjubh85wm1tGOZ29B2WW4/m'+
  'NY0Y5k6cGftgTyjj5Y1h2V4D39jY8+rcsr5AfaPer3TLXpuS9gstQ8vS/LVhPnEsveevcsexDSGf+7sO'+
  'Ze4MG/XGsAxpbUNp/cv7jbZ3oX7L9gnt4+38LeWGw9UnW2fGPqF+WDUntpXmUZ9sm1W4T2jZYvuElj2Y'+
  'PsFyzpXWd7xPaHsfqE+6uY7/TupDf8x289zcMD60oTLH8e7+ytzBvlNWohr8mFhnOHet21eZ46Mxncdo'+
  '+t0w/9sLalz3O2r8fXW17mch0fzmk8b4k1+vc8eGZc8L49qQWsL0pa/HcyHKooHKGhry//haTd51ClU/'+
  'KczffeuExvv98XkaTf/XI0++ni1rdhgv39d2Ht4app//3oTGH4Y0cO30Rf/y0vzccls+a20dlJTP+4S2'+
  'd3vHt2KOddnzZvZ8OiQp9woXz8fzwwKVPr/Pi/lbLcRzKMfk41zhfbA+pNWOjv7hOiOk5SGNSK753Jhe'+
  'ta5zr9prE43WudTlD63JcF1Om+eud5PD9cKs3JXgHLfI/a2bmtvGSJ0z00idkvldkzFYi9kW7W27Q90W'+
  'uRT6qm9Y8OowHsy2xVWJ5jvYFhPC9JlJ+YXaUuy+dSDO3T6yfOg/z/m+L47zjNBn2pzfT1hWFeBcWSRn'+
  'tfL2nOQiG7EML8BZlWgVB+AcFrYo9mVN1hYXeZ53n2d91hXLeuZhYZ2S8MwqwDqjaNYRHbKG40gz7pO6'+
  'J1rmUiZdjrTsfRLueek4TcfnkUmeH6+z5fdIysT1R3Nzc7pcj3bKp+PGMZnyKX+8b9Pp7zWrUz6rr2T6'+
  'SqZXMb2K6bRPZHXKZ/UZTJ+R6IWu67Pb4ohkOxfaFkd0sC0on90WlWxbZHXKV7JtkdVXMr2K6VVMf9bl'+
  '68+6fH0G02ckeqF75G6Zv5GO+r4P6/s+rL1ZHflse7P6SqZXMb2K6dS+rI58tr1ZfQbTj2T7LuW/kNEH'+
  'MX0Q00czfTTTH2L7LuWzegvTW5i+nenbmV7H9DqmT2H6FKYvZvpipr/h8nXKZ/WPmf4x0/uw8vuw8pew'+
  '9Zew9X/E9B8x/VGmP5roha6t2rsebu/6q717mmLOF0e5tmeMR7q2+57lnWLCvSgxlX4vWt570HBVUdI9'+
  'aNgrS7oH5fc9tL35uXqTi8eta0M6MaSnXP65mvan20Pq49o/V88P0xeFXprlZoar/4Xh6vImNyDcrc4L'+
  'pc4J8+M9Qdt1f1fXdt2fvTcg7QiWR8J1QHYfPDXTroO5f+jo/u9A+29FgW24PKT+yfzxIeG+E9vwa4nW'+
  'o4NtON3Rdflad1a46q0O+0117l9sZ3abYbtl8xLXcR21qypp18gC7aoqsl0j8to130S7Lkja9dUC7bqg'+
  'yHadabC/xifpmgLtGl9ku84w2K7pCf+NBdo1vch2Vee1q6as7Wpy8TebhUm7vlOgXaR166BddJ91bl6b'+
  'qsraluVJW1YVaMvyItoyqsB+V6623J205f4Cbbm7iLacY6gt65K2bCrQlnVFtGVkXlsqy9qWJ5O2PFeg'+
  'LU8W0ZazDfXLlqQtrxVoy5Yi2pJ/vdDaWs62vJG05X8KtOWNItoywtBxbE/Slv0F2rKniLYUui4oV1sq'+
  'fGzLUf7zbSHtQG0pdC1wMG3JPi/p6Flc9vkLns0dzDMXanP/TBkTknxWr2Z6NdNrmV7L9Hqm1zO9gekN'+
  'TG9iehPTVzB9BdPXMH0N09czfT3TW5jewvRtTN/G9J1M38n0vUzfy/TuPl/v3sHzxgM9U7yC9Tc9v+3P'+
  '9GqmVzO9lum1TK9nej3TG5jewPQmpjcxfQXTVzB9DdPXMH0909czvYXpLUzfxvRtTN/J9J1M38v0vUzP'+
  '9jfp2f4+2GeqV7L+Rj6rVzO9mum1TK9lej3T65newPQGpjcxvYnpK5i+gulrmL6G6euZvp7pLUxvYfo2'+
  'pm9j+k6m72T6XqbvZXq2v5HP/v2fmFn/8iSf1Xv6fL0nW/94tv7xbP2j2fpHs/WPYesfw9bvzfTeTB/K'+
  '9KFMP43ppzF9MNMHM/0kpp/E9NFMH83085l+PtPPYfo5TD+L6WcxfQLTJzB9HNPHMf1ipl/M9LFMH8v0'+
  'a5l+LdOnMX0a0yczfTLTJzF9EtMXMX0R0xcwfQHT5zJ9LtO/wfRvMP1Wpt/K9GVMX8b0m5l+M9OXMn0p'+
  '0+9h+j1Mv4vpdzH9DqbfwfSVTF/J9IeZ/jDTH2L6Q0x/gOkPMH0t09cy/SmmP8X0XzL9l0z/OdN/zvTH'+
  'mf44019k+otMf4HpLzB9M9M3M/0Zpj/D9B1M38H03zH9d0zfzvTtTH+F6a8w/X2mv8/03UzfzfR3mP4O'+
  '03cxfRfTO7PzS2d2fvFM90z/jJX/GSv/U6ZT/pKQxrh4LUPXyAOSsXdt51n6XW1+8hszzxe6xsreX7b3'+
  'Hjn9rpIbkjcTs78jpfejrfnXc1XJujj3T3XxHJytN/u7jURddIzv5uO12FHKdc1K6rrxMNTVkNQ19zDU'+
  'RXV09fF81ku5rgVJXU2Hoa5vJXXd8mdW1y1JXX93GOqic3QXH8/1PZXr+rGLx9QHaXnluu5L6lp3GOr6'+
  'wMVzNR3Pf+N066J3TbaG9KeQXlWu64iw3Ta6eJ55Qrmu3sl+Qe+oPaJcV79Qx51hfHIY36tc10Afr3NP'+
  '9fF6WbMues91cRif7eO1vWZdtT7GkV0cxjco13WZT+7Xwvhq5bom+nitdo2P94+addF7+Je6GL85Ubmu'+
  'G3x8HrbQx/tyzbpu9vR7T7h/DePzlOtq9vQbhnO3efp9Wbcueu+d3hy709PvjLp13e1jOT9O6tSsa2Oo'+
  '4+QwfsLHeZp10bucNN4Rxl9SrusdH3+zovdv/0K5LordoOeVe318bq1Z16c+Ptv0FfEZq2Zdp4bM0WF8'+
  'ekXclpp11VXEe9u/pveJleuaVBHnT6uIy2rWdX1FvJe/qSLuI3TP3zsprouTewbA2bPPBvB+P9qRvufa'+
  'nN+W7LOCbLnt/UaN5xv0PlqvzPMRejaQvZ/o1g5bl8PABhawTTPEBhaw0TPvI42wgQVsswyxgQVs1xti'+
  'AwvY6Dn/EUbYwAK2uYbYwAK2eYbYwAK2hYbYwAI2es7XwwgbWMD2N4bYwAK2JYbYwAK2pYbYwAK2mw2x'+
  'gQVstxhiAwvYlhtiAwvYbjPEBhawrTDEBhaw/cAQG1jARrFeVs5ZYAHbnYbYwAK21YbYwAK2vzfEBhaw'+
  '3WuIDSxgW2OIDSxg+4khNrCA7T5DbGABG/1+ZOXYCxawPWSIDSxg+5khNrCA7VFDbGAB2wYX34OxwAYW'+
  'sD1miA0sYNvk4rsvFtjAArYnDLGBBWz0vmFXI2xgARu9K9nFCBtYwPa0i++CWGADC9j+LaRORtjAAjZ6'+
  'P7TCCBtYwJaLDzXCBhawPZ9UYoENLGDb4uK7QxbYwAI2eofqMyNsYAHbyyHtM8IGFrD9OqRPjLCBBWz0'+
  'jvfHRtjAAjZ6P/0jI2xgARt9GPUDI2xgARvFe+8xwgYWsP0+pP81wgYWsFG83TtG2MACtj+E9LYRNrCA'+
  '7e1kngU2sICNtuFbRtjAAjba9940wgYWsL3n4nHFAhtYwEbHuu1G2MACtr0u/x3zcrKBBWx03t9mhA0s'+
  'YKPrpReNsIEFbHQN/CsjbGABG93XbDbCBhaw0b3qfxhhAwvY6NnI00bYwAI2eob5r0bYwAI2em8qG2tS'+
  'TjawgI3i9P7ZCBtYwEbvgW4wwgYWsNG3ah8xwgYWsB3n4+8hFtjAAjb6jvoDRtjAArYvhvxaI2xgAVt/'+
  'H39TtcAGFrAN8DHW0gIbWMBG8XCrjbCBBWzkV7LKCBtYwEaxfT8wwgYWsA3xMY7YAhtYwEbxit81wgYW'+
  'sFX7+L6eBTawgI38fL5jhA0sYBvpY6y8BTawgG2Uj+/8WmADC9jO9/FdaQtsYAEbOWIuMMIGFrCNCfmb'+
  'jLCBBWzkS3GDETawgO2ikJ9thA0sYPuqT7yFDLCBBWyX+BgXZYENLGAb5+O30i2wgQVsE3yMw7PABhaw'+
  'Ucz/NUbYwAK2K3ziZWaADSxgo+8xXGGEDSxgm+zzv6lQTjawpLGxIX+ZETawgG16yH/NCBtYwDbTx29O'+
  'WmADSxob62MctwU2sIBtts//5kc52cCSxsZ6ckSywQaWNDbWk/eRDTawgI08tuqMsIEljY315O9lgw0s'+
  'YCOvtzFG2MACtiYfv/lrgQ0saWysj75JFtjAArZv+/gtZAtsYAFbs8//BlI52cCSxsb6/G8mlTU2NmEB'+
  '23d9/H61BTawgO17Pv/7T+VkA0saG+vjd70tsIEFbD/08btgFtjAksbG+ujxbYENLGlsrI/fOLPABhaw'+
  '3eXjd4sssIEljY0N+dONsIEFbP/g87/rVk42sICNvjk3zAgbWNLYWB99GSywgQVs94f8ECNsYAHbT33+'+
  't/3KyQaWNDbWRy8NC2xgAdvDPnrRWmADC9j+ycfv01lgA0saG2uIbQNjezzkTzHCBpY0NtbH9S2wgSWN'+
  'jTXE9gRje9JHb2YLbGBJY2N9/L6qBTawpLGxhtieZmz/7qNHkgU2sKSxsSE/0AgbWMC22RDbZsb2q5Af'+
  'YIQNLGlsrCG2LYztJZ//veRysoEFbNsMsW1jbL/2+d9jLmtsrM/3OHzVENurjO23hth+y9he9/nf8y5r'+
  'bGzCArY3DbG9ydh+72N9FtjAksbGGmLbydj+aIjtj4ztbR81C2xgAdu7htjeZWz0vf7st/PLyQaWNDbW'+
  'ENt7jO1DQ2wfMraPDbF9zNg+8fk+A2WNjU1YwLbfENt+xtZqiK2VsZH/Rl8jbGABW2dDbJ0ZW1dDbF0Z'+
  'Ww9DbD0YW8/EP8QCG1jS2FhDbEcxtj6G2PowtmMNsR3L2I4zxHYcYzuB+RGVkw0sYOtniK0fY+tviK0/'+
  'YxtoiG0gYxtkiG0QYzuF+WWVNTY2YQHbaYbYTmNsQw2xDWVsww2xDWdsZxhiO4OxjTDENoKxjayIZVlg'+
  'AwvYzjXEdi5jO98Q2/mMbbQhttGMrcYQWw1jqzPEVsfYxhpiG8vYLq6I3p8W2MCSxsYaYruEsY03xDae'+
  'sV1miO0yxjbRENtExnalIbYrGdskQ2yTGNtkQ2yTGdvXDbF9nbFNTzyDLbCBJY2NNcQ2k7E1GGJrYGyz'+
  'k/wlSd7FcsQ8mQ+lra1Opq0ansxSbBqezFJsGp7MUmwansxSbGAB2/WG2MCSxp270n3MpNg0PJml2MAC'+
  'NglPZik2DU9mKTawgG2RK93HTIoNLGCT8GSWYtPwZJZi0/BklmIDC9gkPJml2DQ8maXYNDyZpdjAArbb'+
  'DLGBJY07N8Sm4cksxQaWNO7c2TlnaXgyS7GBBWyrDbGBJY07N8Sm4cksxQYWsK0xxAaWNO7cEJuGJ7MU'+
  'G1jA9qCzc+wFSxp3bogNLGCT8GSWYtPwZJZiA0sad+5K9z2WYtPwZJZi0/BklmIDSxp3bohNw5NZig0s'+
  'adw5rWeEDSxp3Lkr3ZNZik3Dk1mKDSxp3Lkr3ZNZig0sYHuOdCNsYAGbhCezFJuGJ7MUG1jAJuHJLMWm'+
  '4cksxabhySzFBhawveJK92SWYgML2La70j2ZpdjAksadu9I9maXYwAI2CU9mKTYNT2YpNrCkceeudE9m'+
  'KTawgO0PrnRPZik2sKRx5650T2YpNg1PZik2sIBNwpNZik3Dk1mKTcOTWYpNw5NZig0sady5K92TWYoN'+
  'LGCj66VSPZml2MACNglPZik2DU9mKTYNT2YpNg1PZik2DU9mKTYNT2YpNg1PZik2DU9mKTYNT2YpNg1P'+
  'Zik2DU9mKTYNT2YpNg1PZik2DU9mKTawgE3Ck1mKTcOTWYpNw5NZik3Dk1mKTcOTWYpNw5NZik3Dk1mK'+
  'TcOTWYpNw5NZik3Dk1mKTcOTWYpNw5NZig0sady5L92TWYpNw5NZik3Dk1mKTcOTWYpNw5NZik3Dk1mK'+
  'TcOTWYpNw5NZik3Dk1mKTcOTWYpNw5NZLDbWy3syS7GBJY0796V7MkuxaXgyi8XGenlPZik2DU9msdhY'+
  'L+/JLBYb6+U9maXYNDyZxWJjvbwnsxSbhiezFJuGJ7NYbKyX92SWYtPwZJZiA0saG+tL92QWi4318p7M'+
  'UmwansxSbBqezGKxsV7ek1mKTcOTWSw21st7MovFxnp5T2YpNg1PZrHYWC/vySzFpuHJLMWm4cksFhvr'+
  '5T2Zpdg0PJml2DQ8mcViY728J7MUm4YnsxSbhiezWGysl/dklmLT8GQWi41NWNLYWENsGp7MUmwansxi'+
  'sbFe3pNZLDbWy3syS7FpeDKLxcZ6eU9mKTYNT2YpNg1PZrHYWMYm4cksxabhySzFpuHJLBYb6+U9maXY'+
  'NDyZpdg0PJnFYmO9vCezFJuGJ7NYbGzCksbGGmLT8GSWYtPwZBaLjU1YwCbhySzFpuHJLMWm4cksFhvr'+
  '5T2Zpdg0PJml2DQ8mcViY728J7MUm4YnsxSbhiezWGysgiezFJuGJ7NYbKyCJ7NYbKyCJ7MUm4Yns1hs'+
  'rIIns1hsrIInsxSbhiezWGysgiezFJuGJ7MUm4Yns1hsrIInsxSbhiezFJuGJ7NYbKyCJ7MUm4YnsxSb'+
  'hiezWGysgiezFJuGJ7NYbKyCJ7NYbKyCJ7MUm4Yns1hsrIInsxSbhiezFJuGJ7NYbKyCJ7MUm4YnsxSb'+
  'hiezWGysgiezFJuGJ7MUm4Yns1hsrIInsxSbhiezWGysgiezWGysgiezFJuGJ7NYbKyCJ7NYbKyCJ7MU'+
  'W7GezMWwYjowNF/uYhwkLfNBa2urywyrfFtT6t0MN9vNc3PD+NCG6Y1TrprWiAIr0vlD3I6Fw9woP8Q1'+
  'jz/dDXej3ZClzk14r9LVXTW1kca7FgzLrfNaWG5KyG/40tuNtM7LvavpM665+Q+G+dsXdVoc3x5vK5fK'+
  'WP0ebanRbmgol+oYnDQrW+6mTLl3Hln9FZS7n5W7K+Gi8ZIw3vqLIZ2yZd44wufWeWzS1Ebaxn17Dfzy'+
  'CW6jv67RdXcuf1/o69I+T+fTdim0j3Ry8TccmqZuqswsX2i+d/n7Qnv9f1RSHw29k+n/Bw==';

var S: RawByteString;
    MS: THeapMemoryStream;
    MF: TMetaFile;
    {$ifndef CPU64}
    H: cardinal;
    i,j: integer;
    {$endif}
//    E: RawByteString; i,L,n: integer;
begin
{  S := Base64Encode(CompressString(StringFromFile('d:\temp\tmpCurve.emf')));
  E := '  EMF: RawByteString = // some compressed simple EMF file'#13#10;
  L := length(S);
  i := 1;
  while L>0 do begin
    if L>80 then
      n := 80 else
      n := L;
    E := E+'  '''+copy(S,i,n)+'''+'#13#10;
    dec(L,n);
    inc(i,n);
  end;
  FileFromString(E,'test.pas');}
  S := UncompressString(Base64Decode(EMF));
  Check(Hash32(S)=$5BB4C8B1);
  MS := THeapMemoryStream.Create;
  with TPdfDocument.Create do
  try
    Info.CreationDate := Date; // force fixed date and creator for Hash32() below
    Info.Data.PdfTextByName('Producer').Value := 'Synopse PDF engine';
    //CompressionMethod := cmNone; useful for debugg purposes of metafile enum
    AddPage;
    MF := TMetaFile.Create;
    try
      MS.Write(pointer(S)^,length(S));
      MS.Position := 0;
      MF.LoadFromStream(MS);
      Canvas.RenderMetaFile(MF);
      Check(Canvas.Page.Font.Name='Tahoma');
    finally
      MF.Free;
    end;
    MS.Clear;
    SaveToStream(MS,Date);
    // force constant Arial,Bold and Tahoma FontBBox
    SetString(s,PAnsiChar(MS.Memory),MS.Position);
    {$ifdef CPU64}
    Check(length(s)>6780);
    {$else}
    i := PosEx('/FontBBox [',s);
    if CheckFailed(i=5650) then exit;
    fillchar(s[i],32,32);
    j := PosEx('/FontBBox [',s);
    if CheckFailed(j=6009) then exit;
    fillchar(s[j],32,32);
    i := PosEx('/FontBBox [',s);
    if CheckFailed(i=6425) then exit;
    fillchar(s[i],32,32);
    H := Hash32(s);
    Check(H=$F6B2289F);
    {$endif}
    MS.SaveToFile(ChangeFileExt(paramstr(0),'.pdf'));
  finally
    Free;
    MS.Free;
  end;
end;
{$endif}
{$endif}

{$ifndef FPC}
{$ifndef DELPHI5OROLDER}


{ TTestSQLite3Engine }

procedure InternalSQLFunctionCharIndex(Context: TSQLite3FunctionContext;
  argc: integer; var argv: TSQLite3ValueArray); {$ifndef USEFASTCALL}cdecl;{$endif}
var StartPos: integer;
begin
  case argc of
  2: StartPos := 1;
  3: begin
    StartPos := sqlite3.value_int64(argv[2]);
    if StartPos<=0 then
      StartPos := 1;
  end;
  else begin
    ErrorWrongNumberOfArgs(Context);
    exit;
  end;
  end;
  if (sqlite3.value_type(argv[0])=SQLITE_NULL) or
     (sqlite3.value_type(argv[1])=SQLITE_NULL) then
    sqlite3.result_int64(Context,0) else
    sqlite3.result_int64(Context,SynCommons.PosEx(
      sqlite3.value_text(argv[0]),sqlite3.value_text(argv[1]),StartPos));
end;

{$ifdef UNICODE}
{$WARNINGS OFF} // don't care about implicit string cast in tests
{$endif}

const // BLOBs are stored as array of byte to avoid any charset conflict
  BlobDali: array[0..3] of byte = (97,233,224,231);
  BlobMonet: array[0..13] of byte = (224,233,231,ord('d'),ord('s'),ord('j'),
        ord('d'),ord('s'),ord('B'),ord('L'),ord('O'),ord('B'),ord('2'),ord('3'));

procedure TTestSQLite3Engine.DatabaseDirectAccess;
procedure InsertData(n: integer);
var i: integer;
    s: string;
    ins: RawUTF8;
    R: TSQLRequest;
begin
  // this code is a lot faster than sqlite3 itself, even if it use Utf8 encoding:
  // -> we test the engine speed, not the test routines speed :)
 ins := 'INSERT INTO People (FirstName,LastName,Data,YearOfBirth,YearOfDeath) VALUES (''';
 for i := 1 to n do begin
   str(i,s);
   // we put some accents in order to test UTF-8 encoding
   R.Prepare(Demo.DB,ins+'Salvador'+RawUTF8(s)+''', ''Dali'', ?, 1904, 1989);');
   R.Bind(1,@BlobDali,4); // Bind Blob
   R.Execute;
   Demo.Execute(ins+StringToUtf8('Samuel Finley Breese'+s+''', ''Morse'', ''a'+chr(233)+chr(224)+chr(231)+''', 1791, 1872);'));
   Demo.Execute(ins+StringToUtf8('Sergei'+s+''', ''Rachmaninoff'', '''+chr(233)+'z'+chr(231)+'b'', 1873, 1943);'));
   Demo.Execute(ins+StringToUtf8('Alexandre'+s+''', ''Dumas'', '''+chr(233)+chr(231)+'b'', 1802, 1870);'));
   Demo.Execute(ins+StringToUtf8('Franz'+s+''', ''Schubert'', '''+chr(233)+chr(224)+chr(231)+'a'', 1797, 1828);'));
   Demo.Execute(ins+StringToUtf8('Leonardo'+s+''', ''da Vin'+chr(231)+'i'', ''@'+chr(231)+'b'', 1452, 1519);'));
   Demo.Execute(ins+StringToUtf8('Aldous Leonard'+s+''', ''Huxley'', '''+chr(233)+chr(224)+''', 1894, 1963);'));
   R.Prepare(Demo.DB,ins+StringToUtf8('Claud'+chr(232)+s+#10#7''', ''M'+chr(244)+'net'', ?, 1840, 1926);'));
   R.Bind(1,@BlobMonet,sizeof(BlobMonet)); // Bind Blob
   R.Execute;
   Demo.Execute(ins+StringToUtf8('Albert'+s+''', ''Einstein'', '''+chr(233)+chr(231)+'p'', 1879, 1955);'));
   Demo.Execute(ins+StringToUtf8('Johannes'+s+''', ''Gutenberg'', '''+chr(234)+'mls'', 1400, 1468);'));
   Demo.Execute(ins+StringToUtf8('Jane'+s+''', ''Aust'+chr(232)+'n'', '''+chr(231)+chr(224)+chr(231)+'m'', 1775, 1817);'));
 end;
end;
const
  ReqAnsi: WinAnsiString =
    'SELECT * FROM People WHERE LastName=''M'+chr(244)+'net'' ORDER BY FirstName;';
  SoundexValues: array[0..5] of RawUTF8 =
    ('bonjour','bonchour','Bnjr','mohammad','mohhhammeeet','bonjourtr'+chr(232)+'slongmotquid'+chr(233)+'passe');
var Names: TRawUTF8DynArray;
    i1,i2: integer;
    Res: Int64;
    password, s: RawUTF8;
begin
  if (PosEx(RawUTF8('SQlite3 engine'),Owner.CustomVersions,1)=0) and
     (sqlite3<>nil) then
    Owner.CustomVersions := Owner.CustomVersions+#13#10'SQlite3 engine used: '+
      sqlite3.libversion;
  IsMemory := InheritsFrom(TTestMemoryBased);
  if IsMemory then
    TempFileName := ':memory:' else begin
    TempFileName := 'test.db3';
    DeleteFile(TempFileName); // use a temporary file
    password := 'password1';
  end;
  Demo := TSQLDataBase.Create(TempFileName,password);
  Demo.Synchronous := smOff;
  for i1 := 0 to 100 do
    for i2 := 1 to 100 do begin
      s := FormatUTF8('SELECT MOD(%,%);',[i1,i2]);
      Demo.Execute(s,res);
      Check(res=i1 mod i2,s);
    end;
  for i1 := 0 to high(SoundexValues) do begin
    s := FormatUTF8('SELECT SoundEx("%");',[SoundexValues[i1]]);
    Demo.Execute(s,res);
    Check(res=SoundExUTF8(pointer(SoundexValues[i1])),s);
  end;
  for i1 := 0 to high(SoundexValues) do begin
    s := FormatUTF8('SELECT SoundExFr("%");',[SoundexValues[i1]]);
    Demo.Execute(s,res);
    Check(res=SoundExUTF8(pointer(SoundexValues[i1]),nil,sndxFrench),s);
  end;
  for i1 := 0 to high(SoundexValues) do begin
    s := FormatUTF8('SELECT SoundExEs("%");',[SoundexValues[i1]]);
    Demo.Execute(s,res);
    Check(res=SoundExUTF8(pointer(SoundexValues[i1]),nil,sndxSpanish),s);
  end;
  Demo.RegisterSQLFunction(InternalSQLFunctionCharIndex,2,'CharIndex');
  Demo.RegisterSQLFunction(InternalSQLFunctionCharIndex,3,'CharIndex');
  for i1 := 0 to high(SoundexValues) do begin
    s := FormatUTF8('SELECT CharIndex("o","%");',[SoundexValues[i1]]);
    Demo.Execute(s,res);
    Check(res=PosEx('o',SoundexValues[i1]),s);
    s := FormatUTF8('SELECT CharIndex("o","%",5);',[SoundexValues[i1]]);
    Demo.Execute(s,res);
    Check(res=PosEx('o',SoundexValues[i1],5),s);
  end;
  Demo.UseCache := true; // use the cache for the JSON requests
  Demo.WALMode := InheritsFrom(TTestFileBasedWAL); // test Write-Ahead Logging
  Check(Demo.WALMode=InheritsFrom(TTestFileBasedWAL));
  Demo.Execute(
    ' CREATE TABLE IF NOT EXISTS People (' +
      ' ID INTEGER PRIMARY KEY,'+
      ' FirstName TEXT COLLATE SYSTEMNOCASE,' +
      ' LastName TEXT,' +
      ' Data BLOB,'+
      ' YearOfBirth INTEGER,' +
      ' YearOfDeath INTEGER); ');
  // Inserting data 1x without transaction ');
  InsertData(1);
  { Insert some sample data - now with transaction. Multiple records are
    inserted and not yet commited until the transaction is finally ended.
    This single transaction is very fast compared to multiple individual
    transactions. It is even faster than other database engines. }
  Demo.TransactionBegin;
  InsertData(1000);
  Demo.Commit;
  Req := WinAnsiToUtf8(ReqAnsi);
  Check(Utf8ToWinAnsi(Req)=ReqAnsi,'WinAnsiToUtf8/Utf8ToWinAnsi');
  JS := Demo.ExecuteJSON(Req); // get result in JSON format
  FileFromString(JS,'Test1.json');
  Check(Hash32(JS)=$40C1649A,'Expected ExecuteJSON result not retrieved');
  {$ifdef CPU32}
  if not IsMemory then begin // check file encryption password change
    FreeAndNil(Demo); // if any exception occurs in Create(), Demo.Free is OK
    ChangeSQLEncryptTablePassWord(TempFileName,'password1','');
    ChangeSQLEncryptTablePassWord(TempFileName,'','NewPass');
    Demo := TSQLDataBase.Create(TempFileName,'NewPass'); // reuse the temporary file
    Demo.Synchronous := smOff;
    Demo.UseCache := true; // use the cache for the JSON requests
    Demo.WALMode := InheritsFrom(TTestFileBasedWAL); // test Write-Ahead Logging
    Check(Demo.WALMode=InheritsFrom(TTestFileBasedWAL));
    Check(Hash32(Demo.ExecuteJSON(Req))=$40C1649A,'ExecuteJSON crypted');
  end;
  {$endif}
  Demo.GetTableNames(Names);
  Check(length(Names)=1);
  Check(Names[0]='People');
  Demo.Execute('SELECT Concat(FirstName," and ") FROM People WHERE LastName="Einstein"',s);
  Check(Hash32(s)=$68A74D8E,'Albert1 and Albert1 and Albert2 and Albert3 and ...');
end;

procedure TTestSQLite3Engine.VirtualTableDirectAccess;
const
  LOG1: RawUTF8 = 'D:\Dev\lib\SQLite3\exe\TestSQL3.exe 1.2.3.4 (2011-04-07)'#13#10+
    'Host=MyPC User=MySelf CPU=2*0-15-1027 OS=2.3=5.1.2600 Wow64=0 Freq=3579545'#13#10+
    'TSynLog 1.13 LVCL 2011-04-07 12:04:09'#13#10#13#10+
    '20110407 12040904 debug {"TObjectList(00AF8D00)":["TObjectList(00AF8D20)",'+
    '"TObjectList(00AF8D60)","TFileVersion(00ADC0B0)","TSynMapFile(00ACC990)"]}';
var Res: Int64;
    s,s2,s3: RawUTF8;
    n: PtrInt;
begin
  // register the Log virtual table module to this connection
  RegisterVirtualTableModule(TSQLVirtualTableLog,Demo);
  // test Log virtual table module
  FileFromString(LOG1,'temptest.log');
  Demo.Execute('CREATE VIRTUAL TABLE test USING log(temptest.log);');
  Demo.Execute('select count(*) from test',Res);
  Check(Res=1);
  n := 0;
  s := Demo.ExecuteJSON('select * from test',False,@n);
  Check(s<>'');
  Check(n=Res);
  s2 := Demo.ExecuteJSON('select * from test where rowid=2',False,@n);
  Check(s2='{"fieldCount":3,"values":["DateTime","Level","Content"],"rowCount":0}'#$A);
  Check(n=0);
  s2 := Demo.ExecuteJSON('select * from test where rowid=1',False,@n);
  Check(s2<>'');
  Check(s=s2);
  Check(n=1);
  n := 0;
  s3 := Demo.ExecuteJSON('select * from test where level=2',False,@n);
  Check(n=1);
  Check(s3='{"fieldCount":3,"values":["DateTime","Level","Content",40640.5028819444,'+
    '2,"20110407 12040904 debug {\"TObjectList(00AF8D00)\":[\"TObjectList(00AF8D20)\",'+
    '\"TObjectList(00AF8D60)\",\"TFileVersion(00ADC0B0)\",\"TSynMapFile(00ACC990)\"]}"],'+
    '"rowCount":1}'#$A);
  s3 := Demo.ExecuteJSON('select * from test where level=3',False,@n);
  Check(s3='{"fieldCount":3,"values":["DateTime","Level","Content"],"rowCount":0}'#$A);
  Check(n=0);
end;


{ TTestClientServerAccess }

{$WARN SYMBOL_PLATFORM OFF}
procedure TTestClientServerAccess._TSQLHttpClient;
var Resp: TSQLTable;
begin
  Client := TSQLHttpClient.Create('127.0.0.1','888',Model);
  Resp := Client.List([TSQLRecordPeople],'*');
  if CheckFailed(Resp<>nil) then
    exit;
  try
    Check(Resp.InheritsFrom(TSQLTableJSON));
    Check(Hash32(TSQLTableJSON(Resp).PrivateInternalCopy)=$F11CEAC0);
  finally
    Resp.Free;
  end;
end;
{$WARN SYMBOL_PLATFORM ON}

class function TTestClientServerAccess.RegisterAddUrl(OnlyDelete: boolean): string;
begin
  result := THttpApiServer.AddUrlAuthorize('root','888',false,'+',OnlyDelete);
end;

procedure TTestClientServerAccess._TSQLHttpServer;
begin
  Model := TSQLModel.Create([TSQLRecordPeople],'root');
  Check(Model<>nil);
  Check(Model.GetTableIndex('people')>=0);
  try
    DataBase := TSQLRestServerDB.Create(Model,'test.db3');
    DataBase.DB.Synchronous := smOff;
    Server := TSQLHttpServer.Create('888',[DataBase],'+',false);
    fRunConsole := fRunConsole+'using '+Server.HttpServer.ClassName;
    Database.NoAJAXJSON := true; // expect not expanded JSON from now on
  except
    on E: Exception do
      Check(false,E.Message);
  end;
end;

procedure TTestClientServerAccess.CleanUp;
begin
  FreeAndNil(Client);
  FreeAndNil(Server);
  FreeAndNil(DataBase);
  FreeAndNil(Model);
end;

{$ifdef MSWINDOWS}
{$define WTIME}
{$endif}

procedure TTestClientServerAccess.ClientTest;
{$ifdef WTIME}
var Timer: TPrecisionTimer;
const LOOP=1000;
{$else}
const LOOP=100;
{$endif}
const Req='FirstName Like "Sergei1%"';
var i,siz: integer;
    Resp: TSQLTable;
    Rec, Rec2: TSQLRecordPeople;
    Refreshed: boolean;

  procedure TestOne;
  var i: integer;
  begin
    i := Rec.YearOfBirth;
    Rec.YearOfBirth := 1982;
    Check(Client.Update(Rec));
    Rec2.ClearProperties;
    Check(Client.Retrieve(10,Rec2));
    Check(Rec2.YearOfBirth=1982);
    Rec.YearOfBirth := i;
    Check(Client.Update(Rec));
    if Client.InheritsFrom(TSQLRestClientURI) then begin
      Check(TSQLRestClientURI(Client).UpdateFromServer([Rec2],Refreshed));
      Check(Refreshed);
    end else
      Check(Client.Retrieve(10,Rec2));
    Check(Rec.SameRecord(Rec2));
  end;

begin
{$ifdef WTIME}
  Timer.Start;
{$endif}
  // first calc result: all transfert protocols have to work from cache
  Resp := Client.List([TSQLRecordPeople],'*',Req);
  Check(Resp<>nil);
  siz := length(TSQLTableJSON(Resp).PrivateInternalCopy);
  Check(siz=4818);
  Resp.Free;
{$ifdef WTIME}
  fRunConsole := format('%s%s, first %s, ',[fRunConsole,KB(siz),Timer.Stop]);
{$endif}
  // test global connection speed and caching (both client and server sides)
  Rec2 := TSQLRecordPeople.Create;
  Rec := TSQLRecordPeople.Create(Client,10);
  try
    Check(Database.Cache.CachedEntries=0);
    Check(Client.Cache.CachedEntries=0);
    Check(Client.Cache.CachedMemory=0);
    TestOne;
    Check(Client.Cache.CachedEntries=0);
    Client.Cache.SetCache(TSQLRecordPeople); // cache whole table
    Check(Client.Cache.CachedEntries=0);
    Check(Client.Cache.CachedMemory=0);
    TestOne;
    Check(Client.Cache.CachedEntries=1);
    Check(Client.Cache.CachedMemory>0);
    Client.Cache.Clear; // reset cache settings
    Check(Client.Cache.CachedEntries=0);
    Client.Cache.SetCache(Rec); // cache one = SetCache(TSQLRecordPeople,Rec.ID)
    Check(Client.Cache.CachedEntries=0);
    Check(Client.Cache.CachedMemory=0);
    TestOne;
    Check(Client.Cache.CachedEntries=1);
    Check(Client.Cache.CachedMemory>0);
    Client.Cache.SetCache(TSQLRecordPeople);
    TestOne;
    Check(Client.Cache.CachedEntries=1);
    Client.Cache.Clear;
    Check(Client.Cache.CachedEntries=0);
    TestOne;
    Check(Client.Cache.CachedEntries=0);
    if not (Client.InheritsFrom(TSQLRestClientDB)) then begin // server-side
      Database.Cache.SetCache(TSQLRecordPeople);
      TestOne;
      Check(Client.Cache.CachedEntries=0);
      Check(Database.Cache.CachedEntries=1);
      Database.Cache.Clear;
      Check(Client.Cache.CachedEntries=0);
      Check(Database.Cache.CachedEntries=0);
      Database.Cache.SetCache(TSQLRecordPeople,Rec.ID);
      TestOne;
      Check(Client.Cache.CachedEntries=0);
      Check(Database.Cache.CachedEntries=1);
      Database.Cache.SetCache(TSQLRecordPeople);
      Check(Database.Cache.CachedEntries=0);
      TestOne;
      Check(Database.Cache.CachedEntries=1);
      if Client.InheritsFrom(TSQLRestClientURI) then
        TSQLRestClientURI(Client).ServerCacheFlush else
        Database.Cache.Flush;
      Check(Database.Cache.CachedEntries=0);
      Check(Database.Cache.CachedMemory=0);
      Database.Cache.Clear;
    end;
  finally
    Rec2.Free;
    Rec.Free;
  end;
  // test average speed for a 5 KB request 
{$ifdef WTIME}
  Timer.Start;
{$endif}
  for i := 1 to LOOP do begin
    Resp := Client.List([TSQLRecordPeople],'*',Req);
    if CheckFailed(Resp<>nil) then
      exit;
    try
      Check(Resp.InheritsFrom(TSQLTableJSON));
      // every answer contains 113 rows, for a total JSON size of 4803 bytes
      Check(Hash32(TSQLTableJSON(Resp).PrivateInternalCopy)=$8D727024);
    finally
      Resp.Free;
    end;
  end;
{$ifdef WTIME}
  fRunConsole := format('%sdone %s i.e. %d/s, aver. %s, %s/s',
    [fRunConsole,Timer.Stop,Timer.PerSec(LOOP),Timer.ByCount(LOOP),KB(Timer.PerSec(4898*(LOOP+1)))]);
{$endif}
end;

procedure TTestClientServerAccess.HttpClientKeepAlive;
begin
  ClientTest;
end;

procedure TTestClientServerAccess.HttpClientMultiConnect;
begin
  (Client as TSQLHttpClientGeneric).KeepAliveMS := 0;
  ClientTest;
end;

{
procedure TTestClientServerAccess.HttpClientMultiConnectDelphi;
begin
  if (self=nil) or (Server=nil) then
    exit; // if already Delphi code, nothing to test
  (Client as TSQLHttpClientGeneric).KeepAliveMS := 0;
  ClientTest;
end;

procedure TTestClientServerAccess.HttpClientKeepAliveDelphi;
begin
  if (self=nil) or (Server=nil) or (Server.HttpServer is THttpServer) then
    exit; // if already Delphi code, nothing to test
  Server.Free;
  Server := TSQLHttpServer.Create('888',[DataBase],'+',true);
  (Client as TSQLHttpClientGeneric).KeepAliveMS := 10000;
  ClientTest;
end;
}

procedure TTestClientServerAccess.NamedPipeAccess;
begin
  Check(DataBase.ExportServerNamedPipe('test'));
  Client.Free;
  Client := TSQLRestClientURINamedPipe.Create(Model,'test');
  ClientTest;
  // note: 1st connection is slower than with HTTP (about 100ms), because of
  // Sleep(128) in TSQLRestServerNamedPipe.Execute: but we should connect
  // localy only once, and avoiding Context switching is a must-have
  FreeAndNil(Client);
  Check(DataBase.CloseServerNamedPipe);
end;

procedure TTestClientServerAccess.DirectInProcessAccess;
begin
  Client := TSQLRestClientDB.Create(Model,
    TSQLModel.Create([TSQLRecordPeople],'root'),
    DataBase.DB,TSQLRestServerTest);
  ClientTest;
  FreeAndNil(Client);
end;

procedure TTestClientServerAccess.LocalWindowMessages;
begin
  Check(DataBase.ExportServerMessage('test'));
  Client := TSQLRestClientURIMessage.Create(Model,'test','Client',1000);
  ClientTest;
  FreeAndNil(Client);
end;

{$ifndef LVCL}

{ TTestExternalDatabase }

type
  TSQLRecordPeopleExt = class(TSQLRecord)
  private
    fData: TSQLRawBlob;
    fFirstName: RawUTF8;
    fLastName: RawUTF8;
    fYearOfBirth: integer;
    fYearOfDeath: word;
    fLastChange: TModTime;
    fCreatedAt: TCreateTime;
  published
    property FirstName: RawUTF8 index 40 read fFirstName write fFirstName;
    property LastName: RawUTF8 index 40 read fLastName write fLastName;
    property Data: TSQLRawBlob read fData write fData;
    property YearOfBirth: integer read fYearOfBirth write fYearOfBirth;
    property YearOfDeath: word read fYearOfDeath write fYearOfDeath;
    property LastChange: TModTime read fLastChange;
    property CreatedAt: TCreateTime read fCreatedAt write fCreatedAt;
  end;

  TSQLRecordOnlyBlob = class(TSQLRecord)
  private
    fData: TSQLRawBlob;
  published
    property Data: TSQLRawBlob read fData write fData;
  end;

  // class hooks to force DMBS property for TTestExternalDatabase.AutoAdaptSQL 
  TSQLDBConnectionPropertiesHook = class(TSQLDBConnectionProperties);
  TSQLRestServerStaticExternalHook = class(TSQLRestServerStaticExternal);

procedure TTestExternalDatabase.ExternalRecords;
begin
  if CheckFailed(fModel=nil) then exit; // should be called once
  fModel := TSQLModel.Create([TSQLRecordPeople,TSQLRecordPeopleExt,TSQLRecordOnlyBlob]);
end;

procedure TTestExternalDatabase.AutoAdaptSQL;
var SQLOrigin: RawUTF8;
procedure Test(aDBMS: TSQLDBDefinition; AdaptShouldWork: boolean;
  const SQLExpected: RawUTF8='');
var Props: TSQLDBConnectionProperties;
    SQL: RawUTF8;
begin
  Props := TSQLDBSQLite3ConnectionProperties.Create(':memory:','','','');
  try
    Check(VirtualTableExternalRegister(fModel,TSQLRecordPeopleExt,Props,'SampleRecord'));
    with TSQLRestServerStaticExternalHook.Create(TSQLRecordPeopleExt,nil) do
    try
      SQL := SQLOrigin;
      TSQLDBConnectionPropertiesHook(Props).fDBMS := aDBMS;
      Check((Props.DBMS=aDBMS)or(aDBMS=dUnknown));
      Check(AdaptSQLForEngineList(SQL)=AdaptShouldWork);
      Check((SQL=SQLExpected)or not AdaptShouldWork);
    finally
      Free;
    end;
  finally
    Props.Free;
  end;
end;
procedure Test2(const Orig,Expected: RawUTF8);
var DBMS: TSQLDBDefinition;
begin
  SQLOrigin := Orig;
  for DBMS := low(DBMS) to high(DBMS) do
    Test(DBMS,true,Expected);
end;
begin
  Test2('select rowid,firstname from PeopleExt where rowid=2',
        'select id,firstname from SampleRecord where id=2');
  Test2('select rowid,firstname from PeopleExt where rowid=2 order by RowID',
        'select id,firstname from SampleRecord where id=2 order by ID');
  Test2('select rowid,firstname from PeopleExt where firstname like :(''test''): order by lastname',
        'select id,firstname from SampleRecord where firstname like :(''test''): order by lastname');
  SQLOrigin := 'select rowid,firstname from PeopleExt where rowid=2 limit 2';
  Test(dUnknown,false);
  Test(dDefault,false);
  Test(dOracle,true,'select id,firstname from SampleRecord where rownum<=2 and id=2');
  Test(dMSSQL,true,'select top(2) id,firstname from SampleRecord where id=2');
  Test(dJet,true,'select top 2 id,firstname from SampleRecord where id=2');
  Test(dMySQL,true,'select id,firstname from SampleRecord where id=2 limit 2');
  Test(dSQLite,true,'select id,firstname from SampleRecord where id=2 limit 2');
  SQLOrigin := 'select rowid,firstname from PeopleExt where rowid=2 order by LastName limit 2';
  Test(dUnknown,false);
  Test(dDefault,false);
  Test(dOracle,true,'select id,firstname from SampleRecord where rownum<=2 and id=2 order by LastName');
  Test(dMSSQL,true,'select top(2) id,firstname from SampleRecord where id=2 order by LastName');
  Test(dJet,true,'select top 2 id,firstname from SampleRecord where id=2 order by LastName');
  Test(dMySQL,true,'select id,firstname from SampleRecord where id=2 order by LastName limit 2');
  Test(dSQLite,true,'select id,firstname from SampleRecord where id=2 order by LastName limit 2');
  SQLOrigin := 'select rowid,firstname from PeopleExt where firstname=:(''test''): limit 2';
  Test(dUnknown,false);
  Test(dDefault,false);
  Test(dOracle,true,'select id,firstname from SampleRecord where rownum<=2 and firstname=:(''test''):');
  Test(dMSSQL,true,'select top(2) id,firstname from SampleRecord where firstname=:(''test''):');
  Test(dJet,true,'select top 2 id,firstname from SampleRecord where firstname=:(''test''):');
  Test(dMySQL,true,'select id,firstname from SampleRecord where firstname=:(''test''): limit 2');
  Test(dSQLite,true,'select id,firstname from SampleRecord where firstname=:(''test''): limit 2');
  SQLOrigin := 'select id,firstname from PeopleExt limit 2';
  Test(dUnknown,false);
  Test(dDefault,false);
  Test(dOracle,true,'select id,firstname from SampleRecord where rownum<=2');
  Test(dMSSQL,true,'select top(2) id,firstname from SampleRecord');
  Test(dJet,true,'select top 2 id,firstname from SampleRecord');
  Test(dMySQL,true,'select id,firstname from SampleRecord limit 2');
  Test(dSQLite,true,'select id,firstname from SampleRecord limit 2');
  SQLOrigin := 'select id,firstname from PeopleExt order by firstname limit 2';
  Test(dUnknown,false);
  Test(dDefault,false);
  Test(dOracle,true,'select id,firstname from SampleRecord where rownum<=2 order by firstname');
  Test(dMSSQL,true,'select top(2) id,firstname from SampleRecord order by firstname');
  Test(dJet,true,'select top 2 id,firstname from SampleRecord order by firstname');
  Test(dMySQL,true,'select id,firstname from SampleRecord order by firstname limit 2');
  Test(dSQLite,true,'select id,firstname from SampleRecord order by firstname limit 2');
end;


destructor TTestExternalDatabase.Destroy;
begin
  fModel.Free;
  inherited;
end;

procedure TTestExternalDatabase.ExternalViaREST;
begin
  Test(true);
end;

procedure TTestExternalDatabase.ExternalViaVirtualTable;
begin
  Test(false);
end;

procedure TTestExternalDatabase.CryptedDatabase;
var R,R2: TSQLRecordPeople;
    Model: TSQLModel;
    aID: integer;
    Client, Client2: TSQLRestClientDB;
    Res: TIntegerDynArray;
procedure CheckFilledRow;
begin
  Check(R.FillRewind);
  while R.FillOne do
  if not CheckFailed(R2.FillOne) then begin
    Check(R.ID<>0);
    Check(R2.ID<>0);
    Check(R.FirstName=R2.FirstName);
    Check(R.LastName=R2.LastName);
    Check(R.YearOfBirth=R2.YearOfBirth);
    Check(R.YearOfDeath=R2.YearOfDeath);
  end;
end;
{$ifdef CPU32}
const password = 'pass';
{$else}
const password = '';
{$endif}
begin
  DeleteFile('testpass.db3');
  Model := TSQLModel.Create([TSQLRecordPeople]);
  try
    Client := TSQLRestClientDB.Create(Model,nil,'test.db3',TSQLRestServerDB,false,'');
    try
      R := TSQLRecordPeople.CreateAndFillPrepare(Client,'');
      try
        Client2 := TSQLRestClientDB.Create(Model,nil,'testpass.db3',TSQLRestServerDB,false,password);
        try
          Client2.Server.DB.Synchronous := smOff;
          Client2.Server.DB.WALMode := true;
          Client2.Server.CreateMissingTables;
          Check(Client2.TransactionBegin(TSQLRecordPeople));
          Check(Client2.BatchStart(TSQLRecordPeople));
          Check(Client2.BatchSend(Res)=200,'Void batch');
          Client2.Commit;
          Check(Client2.TransactionBegin(TSQLRecordPeople));
          Check(Client2.BatchStart(TSQLRecordPeople));
          while R.FillOne do begin
            Check(R.ID<>0);
            Check(Client2.BatchAdd(R,true)>=0);
          end;
          Check(Client2.BatchSend(Res)=200,'INSERT batch');
          Client2.Commit;
        finally
          Client2.Free;
        end;
        Check(IsSQLite3File('testpass.db3'));
        Check(IsSQLite3FileEncrypted('testpass.db3')=(password<>''));
        // try to read then update the crypted file
        Client2 := TSQLRestClientDB.Create(Model,nil,'testpass.db3',TSQLRestServerDB,false,password);
        try
          Client2.Server.DB.Synchronous := smOff;
          R2 := TSQLRecordPeople.CreateAndFillPrepare(Client2,'');
          try
            CheckFilledRow;
            R2.FirstName := 'One';
            aID := Client2.Add(R2,true);
            Check(aID<>0);
            R2.FillPrepare(Client2,'');
            CheckFilledRow;
            R2.ClearProperties;
            Check(R2.FirstName='');
            Check(Client2.Retrieve(aID,R2));
            Check(R2.FirstName='One');
          finally
            R2.Free;
          end;
        finally
          Client2.Free;
        end;
        Check(IsSQLite3File('testpass.db3'));
        Check(IsSQLite3FileEncrypted('testpass.db3')=(password<>''));
        {$ifdef CPU32}
        // now read it after uncypher
        ChangeSQLEncryptTablePassWord('testpass.db3',password,'');
        Check(IsSQLite3File('testpass.db3'));
        Check(not IsSQLite3FileEncrypted('testpass.db3'));
        Client2 := TSQLRestClientDB.Create(Model,nil,'testpass.db3',TSQLRestServerDB,false,'');
        try
          R2 := TSQLRecordPeople.CreateAndFillPrepare(Client2,'');
          try
            CheckFilledRow;
            R2.ClearProperties;
            Check(R2.FirstName='');
            Check(Client2.Retrieve(aID,R2));
            Check(R2.FirstName='One');
          finally
            R2.Free;
          end;
        finally
          Client2.Free;
        end;
        {$endif}
      finally
        R.Free;
      end;
    finally
      Client.Free;
    end;
  finally
    Model.Free;
  end;
end;


procedure TTestExternalDatabase.Test(StaticVirtualTableDirect: boolean);
var RInt: TSQLRecordPeople;
    RExt: TSQLRecordPeopleExt;
    RBlob: TSQLRecordOnlyBlob;
//    Tables: TRawUTF8DynArray;
    aID, i, n: integer;
    ok: Boolean;
    fClient: TSQLRestClientDB;
    fProperties: TSQLDBConnectionProperties;
    Start, Updated: TTimeLog; // will work with both TModTime and TCreateTime properties
begin
  // run tests over an in-memory SQLite3 database (much faster than file)
  fProperties := TSQLDBSQLite3ConnectionProperties.Create(':memory:','','','');
  Check(VirtualTableExternalRegister(fModel,TSQLRecordPeopleExt,fProperties,'PeopleExternal'));
  Check(VirtualTableExternalRegister(fModel,TSQLRecordOnlyBlob,fProperties,'OnlyBlobExternal'));
  fClient := TSQLRestClientDB.Create(fModel,nil,'test.db3',TSQLRestServerDB);
  try
    fClient.Server.DB.Synchronous := smOff;
{    fClient.Server.DB.GetTableNames(Tables);
    if FindRawUTF8(Tables,'PeopleExt',false)>=0 then
      fClient.Server.EngineExecuteAll('drop table PeopleExt'); }
    Start := fClient.ServerTimeStamp;
    fClient.Server.StaticVirtualTableDirect := StaticVirtualTableDirect;
    fClient.Server.CreateMissingTables;
    Check(fClient.Server.CreateSQLMultiIndex(
      TSQLRecordPeopleExt,['FirstName','LastName'],false));
    RInt := TSQLRecordPeople.CreateAndFillPrepare(fClient,'');
    try
      Check(RInt.FillTable<>nil);
      Check(RInt.FillTable.RowCount>0);
      Check(not fClient.TableHasRows(TSQLRecordPeopleExt));
      Check(fClient.TableRowCount(TSQLRecordPeopleExt)=0);
      Check(not fClient.Server.TableHasRows(TSQLRecordPeopleExt));
      Check(fClient.Server.TableRowCount(TSQLRecordPeopleExt)=0);
      RExt := TSQLRecordPeopleExt.Create;
      try
        n := 0;
        aID := 0;
        while RInt.FillOne do begin
          RExt.Data := RInt.Data;
          RExt.FirstName := RInt.FirstName;
          RExt.LastName := RInt.LastName;
          RExt.YearOfBirth := RInt.YearOfBirth;
          RExt.YearOfDeath := RInt.YearOfDeath;
          RExt.fLastChange := 0;
          RExt.CreatedAt := 0;
          aID := fClient.Add(RExt,true);
          inc(n);
          Check(aID<>0);
          Check(RExt.LastChange>=Start);
          Check(RExt.CreatedAt>=Start);
          RExt.ClearProperties;
          Check(RExt.YearOfBirth=0);
          Check(RExt.FirstName='');
          Check(fClient.Retrieve(aID,RExt));
          Check(RExt.FirstName=RInt.FirstName);
          Check(RExt.LastName=RInt.LastName);
          Check(RExt.YearOfBirth=RInt.YearOfBirth);
          Check(RExt.YearOfDeath=RInt.YearOfDeath);
          Check(RExt.YearOfBirth<>RExt.YearOfDeath);
        end;
        Check(fClient.TableHasRows(TSQLRecordPeopleExt));
        Check(fClient.TableRowCount(TSQLRecordPeopleExt)=n);
        Check(fClient.Server.TableHasRows(TSQLRecordPeopleExt));
        Check(fClient.Server.TableRowCount(TSQLRecordPeopleExt)=n);
        Check(RInt.FillRewind);
        while RInt.FillOne do begin
          RExt.FillPrepare(fClient,'FirstName=? and LastName=?',
            [RInt.FirstName,RInt.LastName]); // query will use index -> fast :)
          while RExt.FillOne do begin
            Check(RExt.FirstName=RInt.FirstName);
            Check(RExt.LastName=RInt.LastName);
            Check(RExt.YearOfBirth=RInt.YearOfBirth);
            Check(RExt.YearOfDeath=RInt.YearOfDeath);
            Check(RExt.YearOfBirth<>RExt.YearOfDeath);
          end;
        end;
        Updated := fClient.ServerTimeStamp;
        for i := 1 to aID do
          if i mod 100=0 then begin
            RExt.fLastChange := 0;
            RExt.CreatedAt := 0;
            Check(fClient.Retrieve(i,RExt,true),'for update');
            Check(RExt.YearOfBirth<>RExt.YearOfDeath);
            Check(RExt.CreatedAt<=Updated);
            RExt.YearOfBirth := RExt.YearOfDeath;
            Check(fClient.Update(RExt),'Update 1/100 rows');
            Check(fClient.UnLock(RExt));
            Check(RExt.LastChange>=Updated);
            RExt.ClearProperties;
            Check(RExt.YearOfDeath=0);
            Check(RExt.YearOfBirth=0);
            Check(RExt.CreatedAt=0);
            Check(fClient.Retrieve(i,RExt),'after update');
            Check(RExt.YearOfBirth=RExt.YearOfDeath);
            Check(RExt.CreatedAt>=Start);
            Check(RExt.CreatedAt<=Updated);
            Check(RExt.LastChange>=Updated);
          end;
        for i := 1 to aID do
          if i and 127=0 then
            Check(fClient.Delete(TSQLRecordPeopleExt,i),'Delete 1/128 rows');
        n := fClient.TableRowCount(TSQLRecordPeople);
        Check(fClient.Server.StaticVirtualTable[TSQLRecordPeople]=nil);
        Check(fClient.Server.StaticVirtualTable[TSQLRecordPeopleExt]<>nil);
        Check(fClient.Server.StaticVirtualTable[TSQLRecordOnlyBlob]<>nil);
        fClient.Server.BackupGZ(fClient.Server.DB.FileName+'.gz');
        Check(fClient.Server.StaticVirtualTable[TSQLRecordPeople]=nil);
        Check(fClient.Server.StaticVirtualTable[TSQLRecordPeopleExt]<>nil);
        Check(fClient.Server.StaticVirtualTable[TSQLRecordOnlyBlob]<>nil);
        for i := 1 to aID do begin
          RExt.fLastChange := 0;
          RExt.CreatedAt := 0;
          RExt.YearOfBirth := 0;
          ok := fClient.Retrieve(i,RExt,false);
          Check(ok=(i and 127<>0),'deletion');
          if ok then begin
            Check(RExt.CreatedAt>=Start);
            Check(RExt.CreatedAt<=Updated);
            if i mod 100=0 then begin
              Check(RExt.YearOfBirth=RExt.YearOfDeath,'Update');
              Check(RExt.LastChange>=Updated);
            end else begin
              Check(RExt.YearOfBirth<>RExt.YearOfDeath,'Update');
              Check(RExt.LastChange>=Start);
              Check(RExt.LastChange<=Updated);
            end;
          end;
        end;
        Check(fClient.Retrieve(1,RInt));
        Check(RInt.fID=1);
        {$ifndef CPU64}
        RInt.YearOfBirth := 1972;
        Check(fClient.Update(RInt)); // for RestoreGZ() below
        Check(fClient.TableRowCount(TSQLRecordPeople)=n);
        {$endif} // life backup/restore does not work with current sqlite3-64.dll
      finally
        RExt.Free;
      end;
      Check(not fClient.Server.TableHasRows(TSQLRecordOnlyBlob));
      Check(fClient.Server.TableRowCount(TSQLRecordOnlyBlob)=0);
      RBlob := TSQLRecordOnlyBlob.Create;
      try
        fClient.ForceBlobTransfert := true;
        fClient.TransactionBegin(TSQLRecordOnlyBlob);
        for i := 1 to 1000 do begin
          Rblob.Data := Int32ToUtf8(i);
          Check(fClient.Add(RBlob,true)=i);
          Check(RBlob.ID=i);
        end;
        fClient.Commit;
        for i := 1 to 1000 do begin
          Check(fClient.Retrieve(i,RBlob));
          Check(GetInteger(pointer(RBlob.Data))=i);
        end;
        fClient.TransactionBegin(TSQLRecordOnlyBlob);
        for i := 1000 downto 1 do begin
          RBlob.ID := i;
          RBlob.Data := Int32ToUtf8(i*2);
          Check(fClient.Update(RBlob));
        end;
        fClient.Commit;
        for i := 1 to 1000 do begin
          Check(fClient.Retrieve(i,RBlob));
          Check(GetInteger(pointer(RBlob.Data))=i*2);
        end;
      finally
        RBlob.Free;
      end;
      Check(fClient.TableHasRows(TSQLRecordOnlyBlob));
      Check(fClient.TableRowCount(TSQLRecordOnlyBlob)=1000);
      Check(fClient.TableRowCount(TSQLRecordPeople)=n);
      RInt.ClearProperties;
      {$ifndef CPU64}
      fClient.Retrieve(1,RInt);
      Check(RInt.fID=1);
      Check(RInt.FirstName='Salvador1');
      Check(RInt.YearOfBirth=1972);
      Check(fClient.Server.RestoreGZ(fClient.Server.DB.FileName+'.gz'));
      {$endif} // life backup/restore does not work with current sqlite3-64.dll
      Check(fClient.Server.StaticVirtualTable[TSQLRecordPeople]=nil);
      Check(fClient.Server.StaticVirtualTable[TSQLRecordPeopleExt]<>nil);
      Check(fClient.Server.StaticVirtualTable[TSQLRecordOnlyBlob]<>nil);
      Check(fClient.TableHasRows(TSQLRecordPeople));
      Check(fClient.TableRowCount(TSQLRecordPeople)=n);
      RInt.ClearProperties;
      fClient.Retrieve(1,RInt);
      Check(RInt.fID=1);
      Check(RInt.FirstName='Salvador1');
      Check(RInt.YearOfBirth=1904);
    finally
      RInt.Free;
    end;
  finally
    fClient.Free;
    fProperties.Free;
  end;
end;

{$endif LVCL}

type
{$ifdef INCLUDE_FTS3}
  TSQLFTSTest = class(TSQLRecordFTS3)
  private
    fSubject: RawUTF8;
    fBody: RawUTF8;
  published
    property Subject: RawUTF8 read fSubject write fSubject;
    property Body: RawUTF8 read fBody write fBody;
  end;
{$endif}
  TSQLASource = class;
  TSQLADest = class;
  TSQLADests = class(TSQLRecordMany)
  private
    fTime: TDateTime;
    fDest: TSQLADest;
    fSource: TSQLASource;
  published
    property Source: TSQLASource read fSource;
    property Dest: TSQLADest read fDest;
    property AssociationTime: TDateTime read fTime write fTime;
  end;
  TSQLASource = class(TSQLRecordSigned)
  private
    fDestList: TSQLADests;
  published
    property SignatureTime;
    property Signature;
    property DestList: TSQLADests read fDestList;
  end;
  TSQLADest = class(TSQLRecordSigned)
  published
    property SignatureTime;
    property Signature;
  end;
  TSQLRecordPeopleArray = class(TSQLRecordPeople)
  private
    fInts: TIntegerDynArray;
    fCurrency: TCurrencyDynArray;
{$ifdef PUBLISHRECORD}
    fRec: TFTSMatchInfo;
{$endif PUBLISHRECORD}
    fFileVersion: TFVs;
    fUTF8: RawUTF8;
  published
{$ifdef PUBLISHRECORD}
    property Rec: TFTSMatchInfo read fRec write fRec;
{$endif PUBLISHRECORD}
    property UTF8: RawUTF8 read fUTF8 write fUTF8;
    property Ints: TIntegerDynArray index 1 read fInts write fInts;
    property Currency: TCurrencyDynArray index 2 read fCurrency write fCurrency;
    property FileVersion: TFVs index 3 read fFileVersion write fFileVersion;
  end;
{$ifndef LVCL}
  TSQLRecordPeopleObject = class(TSQLRecordPeople)
  private
    fPersistent: TCollTst;
    fUTF8: TRawUTF8List;
  public
    /// will create an internal TCollTst instance for Persistent property
    constructor Create; override;
    /// will release the internal TCollTst instance for Persistent property
    destructor Destroy; override;
  published
    property UTF8: TRawUTF8List read fUTF8;
    property Persistent: TCollTst read fPersistent;
  end;
{$endif}
  TSQLRecordDali1 = class(TSQLRecordVirtualTableAutoID)
  private
    fYearOfBirth: integer;
    fFirstName: RawUTF8;
    fYearOfDeath: word;
  published
    property FirstName: RawUTF8 read fFirstName write fFirstName;
    property YearOfBirth: integer read fYearOfBirth write fYearOfBirth;
    property YearOfDeath: word read fYearOfDeath write fYearOfDeath;
  end;
  TSQLRecordDali2 = class(TSQLRecordDali1);

  TSQLRecordCustomProps = class(TSQLRecordDali1)
  protected
    fGUID: TGUID;
    fGUIDStr: TGUID;
    class procedure InternalRegisterCustomProperties(Props: TSQLRecordProperties); override;
  public
    property GUID: TGUID read fGUID write fGUID;
    property GUIDStr: TGUID read fGUIDStr write fGUIDStr;
  end;

class procedure TSQLRecordCustomProps.InternalRegisterCustomProperties(
  Props: TSQLRecordProperties);
begin
  inherited;
  Props.Fields.Add(Self,TSQLPropInfoRecordFixedSize.Create(
    sizeof(TGUID),'GUID',@TSQLRecordCustomProps(nil).fGUID));
end;

procedure TTestSQLite3Engine._TSQLRestClientDB;
var V,V2: TSQLRecordPeople;
    VA: TSQLRecordPeopleArray;
{$ifndef LVCL}
    VO: TSQLRecordPeopleObject;
{$endif}
    FV: TFV;
    ModelC: TSQLModel;
    Client: TSQLRestClientDB;
    ClientDist: TSQLRestClientURI;
    Server: TSQLRestServer;
    aStatic: TSQLRestServerStaticInMemory;
    Curr: Currency;
    DaVinci, s: RawUTF8;
    Refreshed: boolean;
    J: TSQLTableJSON;
    i, n, nupd, ndx: integer;
    IntArray, Results: TIntegerDynArray;
    List: TObjectList;
    Data: TSQLRawBlob;
    DataS: THeapMemoryStream;
    a,b: double;
procedure checks(Leonard: boolean; Client: TSQLRestClient; const msg: string);
var ID: integer;
begin
  ID := V.ID; // ClearProperties do ID := 0;
  V.ClearProperties; // reset values
  Check(Client.Retrieve(ID,V),msg); // internaly call URL()
  if Leonard then
    Check(V.FirstName='Leonard') else
    Check(V.FirstName='Leonardo1',msg);
  Check(V.LastName=DaVinci,msg);
  Check(V.YearOfBirth=1452,msg);
  Check(V.YearOfDeath=1519,msg);
end;
procedure TestMany(aClient: TSQLRestClient);
var MS: TSQLASource;
    MD, MD2: TSQLADest;
    i: integer;
    sID, dID: array[1..100] of Integer;
    res: TIntegerDynArray;
begin
  MS := TSQLASource.Create;
  MD := TSQLADest.Create;
  try
    MD.fSignatureTime := Iso8601Now;
    MS.fSignatureTime := MD.fSignatureTime;
    Check(MS.DestList<>nil);
    Check(MS.DestList.InheritsFrom(TSQLRecordMany));
    Check(aClient.TransactionBegin(TSQLASource)); // faster process
    for i := 1 to high(dID) do begin
      MD.fSignature := FormatUTF8('% %',[aClient.ClassName,i]);
      dID[i] := aClient.Add(MD,true);
      Check(dID[i]>0);
    end;
    for i := 1 to high(sID) do begin
      MS.fSignature := FormatUTF8('% %',[aClient.ClassName,i]);
      sID[i] := aClient.Add(MS,True);
      Check(sID[i]>0);
      MS.DestList.AssociationTime := i;
      Check(MS.DestList.ManyAdd(aClient,sID[i],dID[i])); // associate both lists
      Check(not MS.DestList.ManyAdd(aClient,sID[i],dID[i],true)); // no dup
    end;
    aClient.Commit;
    for i := 1 to high(dID) do begin
      Check(MS.DestList.SourceGet(aClient,dID[i],res));
      if not CheckFailed(length(res)=1) then
        Check(res[0]=sID[i]);
      Check(MS.DestList.ManySelect(aClient,sID[i],dID[i]));
      Check(MS.DestList.AssociationTime=i);
    end;
    for i := 1 to high(sID) do begin
      Check(MS.DestList.DestGet(aClient,sID[i],res));
      if CheckFailed(length(res)=1) then
        continue; // avoid GPF
      Check(res[0]=dID[i]);
      Check(MS.DestList.FillMany(aClient,sID[i])=1);
      Check(MS.DestList.FillOne);
      Check(Integer(MS.DestList.Source)=sID[i]);
      Check(Integer(MS.DestList.Dest)=dID[i]);
      Check(MS.DestList.AssociationTime=i);
      Check(not MS.DestList.FillOne);
      Check(MS.DestList.DestGetJoined(aClient,'',sID[i],res));
      if not CheckFailed(length(res)=1) then
        Check(res[0]=dID[i]);
      Check(MS.DestList.DestGetJoined(aClient,'ADest.SignatureTime=:(0):',sID[i],res));
      Check(length(res)=0);
      Check(MS.DestList.DestGetJoined(aClient,
        FormatUTF8('ADest.SignatureTime=?',[],[MD.SignatureTime]),sID[i],res));
//   'ADest.SignatureTime=:('+Int64ToUTF8(MD.SignatureTime)+'):',sID[i],res));
      if CheckFailed(length(res)=1) then
        continue; // avoid GPF
      Check(res[0]=dID[i]);
      MD2 := MS.DestList.DestGetJoined(aClient,
        FormatUTF8('ADest.SignatureTime=?',[],[MD.SignatureTime]),sID[i]) as TSQLADest;
//   'ADest.SignatureTime=:('+Int64ToUTF8(MD.SignatureTime)+'):',sID[i]) as TSQLADest;
      if CheckFailed(MD2<>nil) then
        continue;
      try
        Check(MD2.FillOne);
        Check(MD2.ID=dID[i]);
        Check(MD2.Signature=FormatUTF8('% %',[aClient.ClassName,i]));
      finally
        MD2.Free;
      end;
    end;
    Check(MS.FillPrepareMany(aClient,
      'DestList.Dest.SignatureTime<>% and id>=? and DestList.AssociationTime<>0 '+
      'and SignatureTime=DestList.Dest.SignatureTime '+
      'and DestList.Dest.Signature<>"DestList.AssociationTime"',[0],[sID[1]]));
    Check(MS.FillTable.RowCount=length(sID));
    for i := 1 to high(sID) do begin
      MS.SignatureTime := 0;
      MS.DestList.Dest.SignatureTime := 0;
      if CheckFailed(MS.FillOne) then
        break;
      Check(MS.fID=sID[i]);
      Check(MS.SignatureTime=MD.fSignatureTime);
      Check(MS.DestList.AssociationTime=i);
      Check(MS.DestList.Dest.fID=dID[i]);
      Check(MS.DestList.Dest.SignatureTime=MD.fSignatureTime);
      Check(MS.DestList.Dest.Signature=FormatUTF8('% %',[aClient.ClassName,i]));
    end;
    MS.FillClose;
    Check(aClient.TransactionBegin(TSQLADests)); // faster process
    for i := 1 to high(sID) shr 2 do
      Check(MS.DestList.ManyDelete(aClient,sID[i*4],dID[i*4]));
    aClient.Commit;
    for i := 1 to high(sID) do
      if i and 3<>0 then begin
        Check(MS.DestList.ManySelect(aClient,sID[i],dID[i]));
        Check(MS.DestList.AssociationTime=i);
      end else
        Check(not MS.DestList.ManySelect(aClient,sID[i],dID[i]));
  finally
    MD.Free;
    MS.Free;
  end;
end;
procedure TestDynArray(aClient: TSQLRestClient);
var i, j, k, l: integer;
    IDs: TIntegerDynArray;
begin
  VA.ClearProperties;
  for i := 1 to n do begin
    aClient.Retrieve(i,VA);
    Check(VA.ID=i);
    Check(VA.LastName='Dali');
    Check(length(VA.Ints)=i shr 5);
    Check(length(VA.Currency)=i shr 5);
    Check(length(VA.FileVersion)=i shr 5);
    if i and 31=0 then begin
      Check(VA.UTF8='');
      for j := 0 to high(VA.Ints) do
        Check(VA.Ints[j]=(j+1) shl 5);
      for j := 0 to high(VA.Currency) do
        Check(PInt64(@VA.Currency[j])^=(j+1)*3200);
      for j := 0 to high(VA.FileVersion) do
        with VA.FileVersion[j] do begin
          k := (j+1) shl 5;
          Check(Major=k);
          Check(Minor=k+2000);
          Check(Release=k+3000);
          Check(Build=k+4000);
          Check(Main=IntToStr(k));
          Check(Detailed=IntToStr(k+1000));
        end;
    end else begin
      Check(GetInteger(pointer(VA.UTF8))=i);
      for j := 0 to high(VA.FileVersion) do
        with VA.FileVersion[j] do begin
          k := (j+1) shl 5;
          Check(Major=k);
          Check(Minor=k+2000);
          Check(Release=k+3000);
          Check(Build=k+4000);
        end;
    end;
{$ifdef PUBLISHRECORD}
    Check(VA.fRec.nPhrase=i);
    Check(VA.fRec.nCol=i*2);
    Check(VA.fRec.hits[2].docs_with_hits=i*3);
{$endif PUBLISHRECORD}
  end;
  for i := 1 to n shr 5 do begin
    k := i shl 5;
    aClient.OneFieldValues(TSQLRecordPeopleArray,'ID',
      FormatUTF8('IntegerDynArrayContains(Ints,?)',[],[k]),IDs);
    l := n+1-32*i;
    Check(length(IDs)=l);
    for j := 0 to high(IDs) do
      Check(IDs[j]=k+j);
    aClient.OneFieldValues(TSQLRecordPeopleArray,'ID',
      FormatUTF8('CardinalDynArrayContains(Ints,?)',[],[k]),IDs);
    Check(length(IDs)=l);
    for j := 0 to high(IDs) do
      Check(IDs[j]=k+j);
    aClient.OneFieldValues(TSQLRecordPeopleArray,'ID',
      FormatUTF8('MyIntegerDynArrayContains(Ints,:("%"):)',
        [BinToBase64WithMagic(@k,sizeof(k))]),IDs);
    Check(length(IDs)=l);
    for j := 0 to high(IDs) do
      Check(IDs[j]=k+j);
  end;
end;
{$ifndef LVCL}
procedure TestObject(aClient: TSQLRestClient);
var i, j, k: integer;
begin
  for i := 1 to n do begin
    VO.ClearProperties;
    aClient.Retrieve(i,VO);
    Check(VO.ID=i);
    Check(VO.LastName='Morse');
    Check(VO.UTF8.Count=i shr 5);
    for j := 0 to VO.UTF8.Count-1 do
      Check(GetInteger(pointer(VO.UTF8[j]))=(j+1) shl 5);
    Check(VO.Persistent.One.Length=i);
    Check(VO.Persistent.One.Color=i+100);
    Check(GetInteger(pointer(VO.Persistent.One.Name))=i);
    Check(VO.Persistent.Coll.Count=i shr 5);
    for j := 0 to VO.Persistent.Coll.Count-1 do
     with VO.Persistent.Coll[j] do begin
       k := (j+1) shl 5;
       Check(Color=k+1000);
       Check(Length=k*2);
       Check(GetInteger(pointer(Name))=k*3);
     end;
  end;
end;
{$endif}
{$ifdef INCLUDE_FTS3}
procedure TestFTS3(aClient: TSQLRestClient);
var FTS: TSQLFTSTest;
    StartID, i: integer;
    IntResult: TIntegerDynArray;
    c: Char;
const COUNT=400;
begin
  Check(Length(IntArray)>COUNT*2);
  FTS := TSQLFTSTest.Create;
  try
    if aClient=Client then
      StartID := 0 else
      StartID := COUNT;
    Check(aClient.TransactionBegin(TSQLFTSTest)); // MUCH faster with this
    for i := StartID to StartID+COUNT-1 do begin
      FTS.DocID := IntArray[i];
      FTS.Subject := aClient.OneFieldValue(TSQLRecordPeople,'FirstName',FTS.DocID);
      Check(IdemPChar(pointer(FTS.Subject),'SALVADOR'));
      FTS.Body := FTS.Subject+' bodY'+IntToStr(FTS.DocID);
      aClient.Add(FTS,true);
    end;
    aClient.Commit; // Commit must be BEFORE OptimizeFTS3, memory leak otherwize
    Check(FTS.OptimizeFTS3Index(Client.Server));
    for i := StartID to StartID+COUNT-1 do begin
      Check(IdemPChar(pointer(aClient.OneFieldValue(TSQLFTSTest,'Subject',IntArray[i])),'SALVADOR'));
      FTS.DocID := 0;
      FTS.Subject := '';
      FTS.Body := '';
      Check(aClient.Retrieve(IntArray[i],FTS));
      Check(FTS.DocID=IntArray[i]);
      Check(IdemPChar(pointer(FTS.Subject),'SALVADOR'));
      Check(PosEx(Int32ToUtf8(FTS.DocID),FTS.Body,1)>0);
    end;
    Check(aClient.FTSMatch(TSQLFTSTest,'Subject MATCH "salVador1"',IntResult));
    for i := 0 to high(IntResult) do
      Check(SameTextU(aClient.OneFieldValue(
        TSQLRecordPeople,'FirstName',IntResult[i]),'SALVADOR1'));
    Check(aClient.FTSMatch(TSQLFTSTest,'Subject MATCH "salVador1*"',IntResult));
    for i := 0 to high(IntResult) do
      Check(IdemPChar(pointer(aClient.OneFieldValue(
        TSQLRecordPeople,'FirstName',IntResult[i])),'SALVADOR1'));
    Check(not aClient.FTSMatch(TSQLFTSTest,'body*',IntResult,[1]),'invalid count');
    for c := '1' to '9' do begin
      Check(aClient.FTSMatch(TSQLFTSTest,'Body MATCH "body'+c+'*"',IntResult));
      Check(length(IntResult)>0);
      for i := 0 to high(IntResult) do
        Check(IntToStr(IntResult[i])[1]=c);
      Check(aClient.FTSMatch(TSQLFTSTest,'body'+c+'*',IntResult,[1,0.5]),'rank');
      Check(length(IntResult)>0);
      for i := 0 to high(IntResult) do
        Check(IntToStr(IntResult[i])[1]=c);
    end;
  finally
    FTS.Free;
  end;
end;
{$endif}
procedure TestVirtual(aClient: TSQLRestClient; DirectSQL: boolean; const Msg: string;
  aClass: TSQLRecordClass);
var n, i, ndx: integer;
    VD, VD2: TSQLRecordDali1;
    Static: TSQLRestServerStatic;
begin
  Client.Server.StaticVirtualTableDirect := DirectSQL;
  Check(Client.Server.EngineExecuteAll(FormatUTF8('DROP TABLE %',[aClass.SQLTableName])));
  Client.Server.CreateMissingTables(0);
  VD := aClass.Create as TSQLRecordDali1;
  try
    if aClient.TransactionBegin(aClass) then
    try
      // add some items to the file
      V2.FillPrepare(aClient,'LastName=:("Dali"):');
      n := 0;
      while V2.FillOne do begin
        VD.FirstName := V2.FirstName;
        VD.YearOfBirth := V2.YearOfBirth;
        VD.YearOfDeath := V2.YearOfDeath;
        inc(n);
        Check(aClient.Add(VD,true)=n,Msg);
      end;
      // update some items in the file
      Check(aClient.TableRowCount(aClass)=1001,'Check SQL Count(*)');
      for i := 1 to n do begin
        VD.ClearProperties;
        Check(VD.ID=0);
        Check(VD.FirstName='');
        Check(VD.YearOfBirth=0);
        Check(VD.YearOfDeath=0);
        Check(aClient.Retrieve(i,VD),Msg);
        Check(VD.ID=i);
        Check(IdemPChar(pointer(VD.FirstName),'SALVADOR'));
        Check(VD.YearOfBirth=1904);
        Check(VD.YearOfDeath=1989);
        VD.YearOfBirth := VD.YearOfBirth+i;
        VD.YearOfDeath := VD.YearOfDeath+i;
        Check(aClient.Update(VD),Msg);
      end;
      // check SQL requests
      for i := 1 to n do begin
        VD.ClearProperties;
        Check(VD.ID=0);
        Check(VD.FirstName='');
        Check(VD.YearOfBirth=0);
        Check(VD.YearOfDeath=0);
        Check(aClient.Retrieve(i,VD),Msg);
        Check(IdemPChar(pointer(VD.FirstName),'SALVADOR'));
        Check(VD.YearOfBirth=1904+i);
        Check(VD.YearOfDeath=1989+i);
      end;
      Check(aClient.TableRowCount(aClass)=1001);
      aClient.Commit; // write to file
      // try to read directly from file content
      Static := Client.Server.StaticVirtualTable[aClass];
      if CheckFailed(Static<>nil) then
        exit;
      if Static.FileName<>'' then begin // no file content if ':memory' DB
        (Static as TSQLRestServerStaticInMemoryExternal).
          UpdateFile; // force update (COMMIT not always calls xCommit)
        Static := TSQLRestServerStaticInMemoryExternal.Create(aClass,nil,Static.FileName,
          aClass=TSQLRecordDali2);
        try
          Check(TSQLRestServerStaticInMemory(Static).Count=n);
          for i := 1 to n do begin
            ndx := TSQLRestServerStaticInMemory(Static).IDToIndex(i);
            if CheckFailed(ndx>=0) then
              continue;
            VD2 := TSQLRestServerStaticInMemory(Static).Items[ndx] as TSQLRecordDali1;
            if CheckFailed(VD2<>nil) then
              continue;
            Check(VD2.ID=i);
            Check(IdemPChar(pointer(VD2.FirstName),'SALVADOR'));
            Check(VD2.YearOfBirth=1904+i);
            Check(VD2.YearOfDeath=1989+i);
          end;
        finally
          Static.Free;
        end;
      end;
    except
      aClient.RollBack; // will run an error - but this code is correct
    end;
  finally
    VD.Free;
  end;
end;
function Test(T: TSQLTable): boolean;
var aR,aF: integer;
begin
  result := false;
  if T=nil then
    exit;
  with TSQLTableDB.Create(Demo,[],Req,true) do
  try
    if (RowCount<>T.RowCount) or (FieldCount<>T.FieldCount) then begin
      Check(False);
      exit;
    end;
    for aR := 0 to RowCount do // compare all result values
      for aF := 0 to FieldCount-1 do
        if StrComp(pointer(Get(aR,aF)),pointer(T.Get(aR,aF)))<>0 then begin
         Check(False);
         exit;
       end;
    result := true;
  finally
    Free;
    T.Free;
  end;
end;
procedure Direct(const URI: RawUTF8; Hash: cardinal);
var call: TSQLRestServerURIParams;
begin
  call.Method :='GET';
  call.Url := Client.SessionSign(URI);
  call.RestAccessRights := @SUPERVISOR_ACCESS_RIGHTS;
  Server.URI(call);
  Check(Hash32(call.OutBody)=Hash);
end;
begin
  V := TSQLRecordPeople.Create;
  VA := TSQLRecordPeopleArray.Create;
{$ifndef LVCL}
  VO := TSQLRecordPeopleObject.Create;
{$endif}
  V2 := nil;
  if not IsMemory then begin
    DeleteFile('dali1.json');
    DeleteFile('dali2.data');
  end;
  Demo.RegisterSQLFunction(TypeInfo(TIntegerDynArray),@SortDynArrayInteger,
    'MyIntegerDynArrayContains');
  ModelC := TSQLModel.Create(
    [TSQLRecordPeople, {$ifdef INCLUDE_FTS3} TSQLFTSTest, {$endif}
     TSQLASource, TSQLADest, TSQLADests, TSQLRecordPeopleArray
     {$ifndef LVCL}, TSQLRecordPeopleObject{$endif},
     TSQLRecordDali1,TSQLRecordDali2],'root');
  ModelC.VirtualTableRegister(TSQLRecordDali1,TSQLVirtualTableJSON);
  ModelC.VirtualTableRegister(TSQLRecordDali2,TSQLVirtualTableBinary);
  try
    Client := TSQLRestClientDB.Create(ModelC,nil,Demo,TSQLRestServerTest,true);
    try
      Client.Server.DB.Synchronous := smOff;
      with Client.Server.Model do
        for i := 0 to high(Tables) do
          if not CheckFailed(GetTableIndex(Tables[i])=i) then
            Check(GetTableIndex(Tables[i].SQLTableName)=i);
      // direct client access test
      Client.Server.CreateMissingTables(0); // NEED Dest,Source,Dests,...
      Check(Client.SetUser('User','synopse')); // use default user
      DaVinci := WinAnsiToUtf8('da Vin'+chr(231)+'i');
      Check(Client.Retrieve('LastName='''+DaVinci+'''',V));
      Check(V.FirstName='Leonardo1');
      Check(V.LastName=DaVinci);
      Check(V.YearOfBirth=1452);
      Check(V.YearOfDeath=1519);
      checks(false,Client,'Retrieve');
      Check(V.ID=6,'check RETRIEVE/GET');
      Check(Client.Delete(TSQLRecordPeople,V.ID),'check DELETE');
      Check(not Client.Retrieve(V.ID,V),'now this record must not be available');
      Check(Client.Add(V,true)>0,'check ADD/PUT');
      checks(false,Client,'check created value is well retrieved');
      checks(false,Client,'check caching');
      V2 := V.CreateCopy as TSQLRecordPeople;
      Check(V2.SameValues(V));
      V2.Free;
      V2 := TSQLRecordPeople.Create(Client,V.ID);
      Check(V2.SameValues(V));
      Check(Client.Retrieve(V.ID,V2,true),'with LOCK');
      Check(V2.SameValues(V));
      V.FirstName := 'Leonard';
      Check(Client.Update(V));
      Check(Client.UnLock(V),'unlock');
      checks(true,Client,'check UPDATE/POST');
      if Client.SessionUser=nil then // only if has the right for EngineExecute
        Check(Client.EngineExecute('VACUUM;'),'check direct EngineExecute') else
        Check(Client.Server.EngineExecuteAll('VACUUM;'));
      Check(V2.FirstName='Leonardo1');
      Check(not V2.SameValues(V),'V and V2 must differ');
      Check(Client.UpdateFromServer([V2],Refreshed));
      Check(Refreshed,'V2 value will be synchronized with V');
      Check(V2.SameValues(V));
      Check(Client.UpdateFromServer([V2],Refreshed));
      Check(not Refreshed);
      Req := StringReplace(Req,'*',
        Client.Model.Props[TSQLRecordPeople].SQL.TableSimpleFields[true,false],[]);
      s := WinAnsiToUtf8('LastName=''M'+chr(244)+'net'' ORDER BY FirstName');
      J := Client.List([TSQLRecordPeople],'*',s);
      Check(Client.UpdateFromServer([J],Refreshed));
      Check(not Refreshed);
      Check(Test(J),'incorrect TSQLTableJSON');
      Check(Client.OneFieldValues(TSQLRecordPeople,'ID','LastName=:("Dali"):',IntArray));
      Check(length(IntArray)=1001);
      for i := 0 to high(IntArray) do
        Check(Client.OneFieldValue(TSQLRecordPeople,'LastName',IntArray[i])='Dali');
      List := Client.RetrieveList(TSQLRecordPeople,'Lastname=?',['Dali'],'ID,LastName');
      if not CheckFailed(List<>nil) then begin
        Check(List.Count=Length(IntArray));
        for i := 0 to List.Count-1 do
        with TSQLRecordPeople(List.List[i]) do begin
          Check(ID=IntArray[i]);
          Check(LastName='Dali');
          Check(FirstName='');
        end;
        List.Free;
      end;
      Check(Client.TransactionBegin(TSQLRecordPeople)); // for UpdateBlob() below
      for i := 0 to high(IntArray) do begin
        Check(Client.RetrieveBlob(TSQLRecordPeople,IntArray[i],'Data',Data));
        Check(Length(Data)=sizeof(BlobDali));
        Check(CompareMem(pointer(Data),@BlobDali,sizeof(BlobDali)));
        Check(Client.RetrieveBlob(TSQLRecordPeople,IntArray[i],'Data',DataS));
        Check((DataS.Size=4) and (PCardinal(DataS.Memory)^=$E7E0E961));
        DataS.Free;
        Check(Client.UpdateBlob(TSQLRecordPeople,IntArray[i],'Data',@IntArray[i],4));
        Check(Client.RetrieveBlob(TSQLRecordPeople,IntArray[i],'Data',Data));
        Check((length(Data)=4) and (PInteger(pointer(Data))^=IntArray[i]));
        V2.ID := IntArray[i]; // debug use - do NOT set ID in your programs!
        Check(V2.DataAsHex(Client)=SynCommons.BinToHex(Data));
        a := Random;
        b := Random;
        Check(SameValue(TSQLRecordPeople.Sum(Client,a,b,false),a+b,1E-10));
        Check(SameValue(TSQLRecordPeople.Sum(Client,a,b,true),a+b,1E-10));
      end;
      Client.Commit;
      Check(Client.TransactionBegin(TSQLRecordPeopleArray));
      V2.FillPrepare(Client,'LastName=:("Dali"):');
      n := 0;
      while V2.FillOne do begin
        VA.FillFrom(V2); // fast copy some content from TSQLRecordPeople
        inc(n);
        if n and 31=0 then begin
          VA.UTF8 := '';
          VA.DynArray('Ints').Add(n);
          Curr := n*0.01;
          VA.DynArray(2).Add(Curr);
          FV.Major := n;
          FV.Minor := n+2000;
          FV.Release := n+3000;
          FV.Build := n+4000;
          str(n,FV.Main);
          str(n+1000,FV.Detailed);
          VA.DynArray('FileVersion').Add(FV);
        end else
          str(n,VA.fUTF8);
{$ifdef PUBLISHRECORD}
        VA.fRec.nPhrase := n;
        VA.fRec.nCol := n*2;
        VA.fRec.hits[2].docs_with_hits := n*3;
{$endif PUBLISHRECORD}
        Check(Client.Add(VA,true)=n);
      end;
      Client.Commit;
{$ifndef LVCL}
      if Client.TransactionBegin(TSQLRecordPeopleObject) then
      try
        V2.FillPrepare(Client,'LastName=:("Morse"):');
        n := 0;
        while V2.FillOne do begin
          VO.FillFrom(V2); // fast copy some content from TSQLRecordPeople
          inc(n);
          VO.Persistent.One.Color := n+100;
          VO.Persistent.One.Length := n;
          VO.Persistent.One.Name := Int32ToUtf8(n);
          if n and 31=0 then begin
            VO.UTF8.Add(VO.Persistent.One.Name);
            with VO.Persistent.Coll.Add do begin
              Color := n+1000;
              Length := n*2;
              Name := Int32ToUtf8(n*3);
            end;
          end;
          Check(Client.Add(VO,true)=n);
        end;
        Client.Commit;
      except
        Client.RollBack;
      end;
{$endif}
{$ifdef INCLUDE_FTS3}
      TestFTS3(Client);
{$endif}
      TestDynArray(Client);
{$ifndef LVCL}
      TestObject(Client);
{$endif}
      TestMany(Client);
      // RegisterVirtualTableModule(TSQLVirtualTableJSON) already done
      TestVirtual(Client,false,'Virtual Table access via SQLite',TSQLRecordDali1);
      TestVirtual(Client,false,'Virtual Table access via SQLite',TSQLRecordDali2);
      TestVirtual(Client,true,'Direct Virtual Table access',TSQLRecordDali1);
      TestVirtual(Client,true,'Direct Virtual Table access',TSQLRecordDali2);
      // remote client access test
      Check(Client.Server.ExportServerNamedPipe('Test'),'declare Test server');
      ClientDist := TSQLRestClientURINamedPipe.Create(ModelC,'Test');
      try
        Check(ClientDist.SetUser('User','synopse'));
{$ifdef INCLUDE_FTS3}
        TestFTS3(ClientDist);
{$endif}TestDynArray(ClientDist);
{$ifndef LVCL}
        TestObject(ClientDist);
{$endif}TestMany(ClientDist);
        TestVirtual(ClientDist,false,'Remote Virtual Table access via SQLite',TSQLRecordDali1);
        TestVirtual(ClientDist,false,'Remote Virtual Table access via SQLite',TSQLRecordDali2);
        TestVirtual(ClientDist,true,'Remote Direct Virtual Table access',TSQLRecordDali1);
        TestVirtual(ClientDist,true,'Remote Direct Virtual Table access',TSQLRecordDali2);
        Check(Test(ClientDist.List([TSQLRecordPeople],'*',s)),'through URI and JSON');
        for i := 0 to high(IntArray) do begin
          Check(ClientDist.RetrieveBlob(TSQLRecordPeople,IntArray[i],'Data',Data));
          Check((length(Data)=4) and (PInteger(pointer(Data))^=IntArray[i]));
          V2.ID := IntArray[i]; // debug use - do NOT set ID in your programs!
          Check(V2.DataAsHex(ClientDist)=SynCommons.BinToHex(Data));
          a := Random;
          b := Random;
          CheckSame(TSQLRecordPeople.Sum(Client,a,b,false),a+b);
          CheckSame(TSQLRecordPeople.Sum(Client,a,b,true),a+b);
        end;
        V.FirstName := 'Leonardo1';
        Check(ClientDist.Update(V));
        checks(false,ClientDist,'check remote UPDATE/POST');
        V.FirstName := 'Leonard';
        Check(ClientDist.Update(V));
        checks(true,ClientDist,'check remote UPDATE/POST');
//          time := GetTickCount; while time=GetTickCount do; time := GetTickCount;
        for i := 1 to 400 do // speed test: named pipes are OK
          checks(true,ClientDist,'caching speed test');
//          writeln('NamedPipe connection time is ',GetTickCount-time,'ms');
      finally
        ClientDist.Free;
      end;
      if IsMemory then begin // this is a bit time consuming, so do it once
        Server := TSQLRestServerTest.Create(ModelC,false);
        try
          Server.NoAJAXJSON := true;
          DeleteFile('People.json');
          DeleteFile('People.data');
          Server.StaticDataCreate(TSQLRecordPeople,'People.data',true);
          JS := Demo.ExecuteJSON('SELECT * From People');
          aStatic := Server.StaticDataServer[TSQLRecordPeople] as TSQLRestServerStaticInMemory;
          Check(aStatic<>nil);
          aStatic.LoadFromJSON(JS); // test Add()
          for i := 0 to aStatic.Count-1 do begin
            Check(Client.Retrieve(aStatic.ID[i],V),'test statement+bind speed');
            Check(V.SameRecord(aStatic.Items[i]),'static retrieve');
          end;
          // test our 'REST-minimal' SELECT statement SQL engine
          Direct('/root/People?select=%2A&where=id%3D012',$96F68454);
          Direct('/root/People?select=%2A&where=id%3D:(012):',$96F68454);
          Direct('/root/People?select=%2A&where=LastName%3D%22M%C3%B4net%22',$BBDCF3A6);
          Direct('/root/People?select=%2A&where=YearOfBirth%3D1873',$AF4BCA94);
          Direct('/root/People?select=%2A',$17AE45E3);
          Direct('/root/People?select=%2A&where=YearOfBirth%3D1873&startindex=10&results=20',$453C7201);
          Server.URIPagingParameters.SendTotalRowsCountFmt := ',"Total":%';
          Direct('/root/People?select=%2A&where=YearOfBirth%3D1873&startindex=10&results=2',$79AFDD53);
          Server.NoAJAXJSON := false;
          Direct('/root/People?select=%2A&where=YearOfBirth%3D1873&startindex=10&results=2',$69FDAF5D);
          Server.NoAJAXJSON := true;
          Server.URIPagingParameters.SendTotalRowsCountFmt := '';
          // test Retrieve() and Delete()
          Server.ExportServer; // initialize URIRequest() with the aStatic database
          USEFASTMM4ALLOC := true; // getmem() is 2x faster than GlobalAlloc()
          ClientDist := TSQLRestClientURIDll.Create(ModelC,URIRequest);
          try
            SetLength(IntArray,(aStatic.Count-1)shr 2);
            for i := 0 to high(IntArray) do begin
              IntArray[i] := aStatic.ID[i*4];
              Check(ClientDist.Retrieve(IntArray[i],V));
              Check(V.SameRecord(aStatic.Items[i*4]));
            end;
            Check(V.FillPrepare(Client,IntArray));
            for i := 0 to High(IntArray) do begin
              Check(V.FillOne);
              Check(V.ID=IntArray[i]);
              Check(V.SameRecord(aStatic.Items[i*4]));
            end;
            V.FillClose; // so that BatchUpdate(V) below will set all fields
            if ClientDist.TransactionBegin(TSQLRecordPeople) then
            try
              for i := 0 to high(IntArray) do
                Check(ClientDist.Delete(TSQLRecordPeople,IntArray[i]));
              for i := 0 to high(IntArray) do
                Check(not ClientDist.Retrieve(IntArray[i],V));
              for i := 0 to aStatic.Count-1 do begin
                Check(ClientDist.Retrieve(aStatic.ID[i],V));
                V.YearOfBirth := Random(MaxInt)-Random(MaxInt);
                Check(ClientDist.Update(V));
                Check(ClientDist.Retrieve(aStatic.ID[i],V));
                Check(V.SameRecord(aStatic.Items[i]));
              end;
              ClientDist.Commit;
            except
              ClientDist.RollBack;
            end else
              Check(False,'TransactionBegin');
            // test BATCH sequence usage
            if ClientDist.TransactionBegin(TSQLRecordPeople) then
            try
              Check(ClientDist.BatchStart(TSQLRecordPeople));
              n := 0;
              for i := 0 to aStatic.Count-1 do
                if i and 7=0 then begin
                  IntArray[n] := aStatic.ID[i];
                  inc(n);
                end;
              for i := 0 to n-1 do
                Check(ClientDist.BatchDelete(IntArray[i])=i);
              nupd := 0;
              for i := 0 to aStatic.Count-1 do
                if i and 7<>0 then begin // not yet deleted in BATCH mode
                   Check(ClientDist.Retrieve(aStatic.ID[i],V));
                   V.YearOfBirth := 1800+nupd;
                   Check(ClientDist.BatchUpdate(V)=nupd+n);
                   inc(nupd);
                 end;
              V.LastName := 'New';
              for i := 0 to 1000 do begin
                V.FirstName := RandomUTF8(10);
                V.YearOfBirth := i+1000;
                Check(ClientDist.BatchAdd(V,true)=n+nupd+i);
              end;
              Check(ClientDist.BatchSend(Results)=200);
              Check(Length(Results)=9260);
              ClientDist.Commit;
              for i := 0 to n-1 do
                Check(not ClientDist.Retrieve(IntArray[i],V),'BatchDelete');
              for i := 0 to high(Results) do
                if i<nupd+n then
                  Check(Results[i]=200) else begin
                  Check(Results[i]>0);
                  ndx := aStatic.IDToIndex(Results[i]);
                  Check(ndx>=0);
                  with TSQLRecordPeople(aStatic.Items[ndx]) do begin
                    Check(LastName='New','BatchAdd');
                    Check(YearOfBirth=1000+i-nupd-n);
                  end;
                end;
              for i := 0 to aStatic.Count-1 do
                with TSQLRecordPeople(aStatic.Items[i]) do
                  if LastName='New' then
                    break else
                    Check(YearOfBirth=1800+i,'BatchUpdate');
            except
              ClientDist.RollBack;
            end else
              Check(False,'TransactionBegin');
            // test BATCH update from partial FillPrepare
            V.FillPrepare(ClientDist,'LastName=?',['New'],'ID,YearOfBirth');
            if ClientDist.TransactionBegin(TSQLRecordPeople) then
            try
              Check(ClientDist.BatchStart(TSQLRecordPeople));
              n := 0;
              V.LastName := 'NotTransmitted';
              while V.FillOne do begin
                Check(V.LastName='NotTransmitted');
                Check(V.YearOfBirth=n+1000);
                V.YearOfBirth := n;
                ClientDist.BatchUpdate(V); // will update only V.YearOfBirth
                inc(n);
              end;
              Check(n=1001);
              SetLength(Results,0);
              Check(ClientDist.BatchSend(Results)=200);
              Check(length(Results)=1001);
              for i := 0 to high(Results) do
                Check(Results[i]=200);
              ClientDist.Commit;
            except
              ClientDist.RollBack;
            end else
              Check(False,'TransactionBegin');
            V.FillPrepare(ClientDist,'LastName=?',['New'],'YearOfBirth');
            n := 0;
            while V.FillOne do begin
              Check(V.LastName='NotTransmitted');
              Check(V.YearOfBirth=n);
              V.YearOfBirth := 1000;
              inc(n);
            end;
            Check(n=length(Results));
            V.FillClose;
          finally
            ClientDist.Free;
          end;
          aStatic.Modified := true;
          aStatic.UpdateFile; // force People.data file content write
          aStatic.FileName := 'People.json';
          aStatic.BinaryFile := false;
          aStatic.Modified := true; // so aStatic.Free will write People.json file
          USEFASTMM4ALLOC := false;
        finally
          Server.Free;
        end;
      end;
    finally
      Client.Free;
    end;
  finally
    ModelC.Free;
    V.Free;
    V2.Free;
    VA.Free;
{$ifndef LVCL}
    VO.Free;
{$endif}
    FreeAndNil(Demo);
  end;
  {$ifdef CPU32}
  if not IsMemory then begin
    ChangeSQLEncryptTablePassWord(TempFileName,'NewPass',''); // uncrypt file
    Check(IsSQLite3File(TempFileName));
  end;
  {$endif}
end;

procedure TTestSQLite3Engine._TSQLTableJSON;
var J: TSQLTableJSON;
    aR, aF, n: integer;
    Comp: TUTF8Compare;
    {$ifdef UNICODE}
    Peoples: TObjectList<TSQLRecordPeople>;
    {$endif}
    row: variant;
begin
  J := TSQLTableJSON.Create([],'',JS);
  try
    if JS<>'' then // avoid memory leak
    with TSQLTableDB.Create(Demo,[],Req,true) do
    try
      Check(RowCount=J.RowCount);
      Check(FieldCount=J.FieldCount);
      for aR := 0 to RowCount do
        for aF := 0 to FieldCount-1 do
         if (aR>0) and (aF=3) then  // aF=3=Blob
           Check(GetBlob(aR,aF)=J.GetBlob(aR,aF)) else begin
           Check((GetW(aR,aF)=J.GetW(aR,aF)) and
                (GetA(aR,aF)=J.GetA(aR,aF)) and
                (length(GetW(aR,aF))shr 1=LengthW(aR,aF)),
                Format('Get() in Row=%d Field=%d',[aR,aF]));
            if (aR>0) and (aF>3) then
              Check(GetDateTime(aR,af)=J.GetDateTime(aR,aF));
          end;
    finally
      Free;
    end;
    Demo.Execute('VACUUM;');
    with TSQLTableDB.Create(Demo,[],Req,true) do // re-test after VACCUM
    try
      Check(RowCount=J.RowCount);
      Check(FieldCount=J.FieldCount);
      Check(FieldIndex('ID')=0);
      Check(FieldIndex('RowID')=0);
      for aF := 0 to FieldCount-1 do
        Check(FieldIndex(J.Get(0,aF))=aF);
      for aR := 0 to RowCount do
        for aF := 0 to FieldCount-1 do // aF=3=Blob
          Check((aF=3) or (StrIComp(Get(aR,aF),J.Get(aR,aF))=0));
      n := 0;
      while Step do begin
        for aF := 0 to FieldCount-1 do // aF=3=Blob
          Check((aF=3) or (StrIComp(FieldBuffer(aF),J.Get(StepRow,aF))=0));
        inc(n);
      end;
      check(n=J.RowCount);
      n := 0;
      if not CheckFailed(Step(true,@row)) then
        repeat
          Check(row.ID=J.GetAsInteger(StepRow,FieldIndex('ID')));
          Check(row.FirstName=J.GetString(StepRow,FieldIndex('FirstName')));
          Check(row.LastName=J.GetString(StepRow,FieldIndex('LastName')));
          Check(row.YearOfBirth=J.GetAsInteger(StepRow,FieldIndex('YearOfBirth')));
          Check(row.YearOfDeath=J.GetAsInteger(StepRow,FieldIndex('YearOfDeath')));
          inc(n);
       until not Step(false,@row);
      check(n=J.RowCount);
      with ToObjectList(TSQLRecordPeople) do
      try
        check(Count=J.RowCount);
        for aR := 1 to Count do
        with Items[aR-1] as TSQLRecordPeople do begin
          Check(fID=J.GetAsInteger(aR,FieldIndex('ID')));
          Check(FirstName=J.GetU(aR,FieldIndex('FirstName')));
          Check(LastName=J.GetU(aR,FieldIndex('LastName')));
          Check(YearOfBirth=J.GetAsInteger(aR,FieldIndex('YearOfBirth')));
          Check(YearOfDeath=J.GetAsInteger(aR,FieldIndex('YearOfDeath')));
        end;
      finally
        Free;
      end;
      {$ifdef UNICODE}
      Peoples := ToObjectList<TSQLRecordPeople>;
      try
        Check(Peoples.Count=J.RowCount);
        for aR := 1 to Peoples.Count do
        with Peoples[aR-1] do begin
          Check(ID=J.GetAsInteger(aR,FieldIndex('ID')));
          Check(FirstName=J.GetU(aR,FieldIndex('FirstName')));
          Check(LastName=J.GetU(aR,FieldIndex('LastName')));
          Check(YearOfBirth=J.GetAsInteger(aR,FieldIndex('YearOfBirth')));
          Check(YearOfDeath=J.GetAsInteger(aR,FieldIndex('YearOfDeath')));
        end;
      finally
        Peoples.Free;
      end;
      {$endif}
    finally
      Free;
    end;
    for aF := 0 to J.FieldCount-1 do begin
      J.SortFields(aF);
      Comp := J.SortCompare(aF);
      if @Comp<>nil then // BLOB field will be ignored
        for aR := 1 to J.RowCount-1 do // ensure data sorted in increasing order
          Check(Comp(pointer(J.Get(aR,aF)),pointer(J.Get(aR+1,aF)))<=0,'SortCompare');
    end;
  finally
    J.Free;
  end;
end;

{$ifdef UNICODE}
{$WARNINGS ON} // don't care about implicit string cast in tests
{$endif}


{ TSQLRestServerTest }

procedure TSQLRestServerTest.DataAsHex(var Ctxt: TSQLRestServerCallBackParams);
var aData: TSQLRawBlob;
begin
  if (self=nil) or (Ctxt.Table<>TSQLRecordPeople) or (Ctxt.ID<0) then
    Ctxt.Error('Need a valid record and its ID') else
  if RetrieveBlob(TSQLRecordPeople,Ctxt.ID,'Data',aData) then
    Ctxt.Results([SynCommons.BinToHex(aData)]) else
    Ctxt.Error('Impossible to retrieve the Data BLOB field');
end;

procedure TSQLRestServerTest.Sum(var Ctxt: TSQLRestServerCallBackParams);
var a,b: Extended;
begin
  if UrlDecodeNeedParameters(Ctxt.Parameters,'A,B') then begin
    while Ctxt.Parameters<>nil do begin
      UrlDecodeExtended(Ctxt.Parameters,'A=',a);
      UrlDecodeExtended(Ctxt.Parameters,'B=',b,@Ctxt.Parameters);
    end;
    Ctxt.Results([a+b]);
  end else
    Ctxt.Error('Missing Parameter');
end;

procedure TSQLRestServerTest.Sum2(var Ctxt: TSQLRestServerCallBackParams);
begin
  with Ctxt do
    Results([InputDouble['a']+InputDouble['b']]);
end;


{$ifndef LVCL}

{ TSQLRecordPeopleObject }

constructor TSQLRecordPeopleObject.Create;
begin
  inherited;
  fPersistent := TCollTst.Create;
  fUTF8 := TRawUTF8List.Create;
end;

destructor TSQLRecordPeopleObject.Destroy;
begin
  Persistent.Free;
  UTF8.Free;
  inherited;
end;


{ TCollTestsI }

class function TCollTestsI.GetClass: TCollectionItemClass;
begin
  result := TCollTest;
end;

{$endif LVCL}


{ TComplexNumber }

constructor TComplexNumber.Create(aReal, aImaginary: double);
begin
  Real := aReal;
  Imaginary := aImaginary;
end;



{ TServiceCalculator }

type
  TServiceCalculator = class(TInterfacedObject, ICalculator)
  public
    function Add(n1,n2: integer): integer;
    function Subtract(n1,n2: double): double;
    function Multiply(n1,n2: Int64): Int64;
    procedure ToText(Value: Currency; var Result: RawUTF8);
    function ToTextFunc(Value: double): string;
    function SpecialCall(Txt: RawUTF8; var Int: integer; var Card: cardinal; field: TSynTableFieldTypes;
      fields: TSynTableFieldTypes; var options: TSynTableFieldOptions): TSynTableFieldTypes;
    function ComplexCall(const Ints: TIntegerDynArray; Strs1: TRawUTF8DynArray;
      var Str2: TWideStringDynArray; const Rec1: TVirtualTableModuleProperties;
      var Rec2: TSQLRestCacheEntryValue; Float1: double; var Float2: double): TSQLRestCacheEntryValue;
    function Test(A,B: Integer): RawUTF8;
  end;

  TServiceComplexCalculator = class(TServiceCalculator,IComplexCalculator)
  public
    procedure Substract(n1,n2: TComplexNumber; out Result: TComplexNumber);
    function IsNull(n: TComplexNumber): boolean;
    function TestBlob(n: TComplexNumber): TServiceCustomAnswer;
    {$ifdef USEVARIANTS}
    function TestVariants(const Text: RawUTF8; V1: Variant; var V2: variant): variant;
    {$endif}
    {$ifndef LVCL}
    procedure Collections(Item: TCollTest; var List: TCollTestsI; out Copy: TCollTestsI);
    {$endif LVCL}
  end;

  TServiceComplexNumber = class(TInterfacedObject,IComplexNumber)
  private
    fReal: double;
    fImaginary: double;
    function GetImaginary: double;
    function GetReal: double;
    procedure SetImaginary(const Value: double);
    procedure SetReal(const Value: double);
  public
    procedure Assign(aReal, aImaginary: double);
    procedure Add(aReal, aImaginary: double);
    property Real: double read GetReal write SetReal;
    property Imaginary: double read GetImaginary write SetImaginary;
  end;


function TServiceCalculator.Add(n1, n2: integer): integer;
begin
  result := n1+n2;
end;

function TServiceCalculator.Multiply(n1, n2: Int64): Int64;
begin
  result := n1*n2;
end;

function TServiceCalculator.SpecialCall(Txt: RawUTF8; var Int: integer;
  var Card: cardinal; field, fields: TSynTableFieldTypes;
  var options: TSynTableFieldOptions): TSynTableFieldTypes;
begin
  inc(Int,length(Txt));
  inc(Card);
  result := fields+field;
  Include(options,tfoUnique);
  Exclude(options,tfoIndex);
end;

function TServiceCalculator.Subtract(n1, n2: double): double;
begin
  result := n1-n2;
end;

function TServiceCalculator.Test(A, B: Integer): RawUTF8;
begin
  result := Int32ToUtf8(A+B);
end;

procedure TServiceCalculator.ToText(Value: Currency; var Result: RawUTF8);
begin
  result := Curr64ToStr(PInt64(@Value)^);
end;

function TServiceCalculator.ToTextFunc(Value: double): string;
begin
  result := DoubleToString(Value);
end;

function TServiceCalculator.ComplexCall(const Ints: TIntegerDynArray;
  Strs1: TRawUTF8DynArray; var Str2: TWideStringDynArray; const Rec1: TVirtualTableModuleProperties;
  var Rec2: TSQLRestCacheEntryValue; Float1: double; var Float2: double): TSQLRestCacheEntryValue;
var i: integer;
begin
  result := Rec2;
  result.JSON := StringToUTF8(Rec1.FileExtension);
  i := length(Str2);
  SetLength(Str2,i+1);
  Str2[i] := UTF8ToWideString(RawUTF8ArrayToCSV(Strs1));
  inc(Rec2.ID);
  dec(Rec2.TimeStamp);
  Rec2.JSON := IntegerDynArrayToCSV(Ints,length(Ints));
  Float2 := Float1;
end;


{ TServiceComplexCalculator }

function TServiceComplexCalculator.IsNull(n: TComplexNumber): boolean;
begin
  result := (n.Real=0) and (n.Imaginary=0);
end;

procedure TServiceComplexCalculator.Substract(n1, n2: TComplexNumber; out Result: TComplexNumber);
begin
  result.Real := n1.Real-n2.Real;
  result.Imaginary := n1.Imaginary-n2.Imaginary;
end;

function TServiceComplexCalculator.TestBlob(n: TComplexNumber): TServiceCustomAnswer;
begin
  Result.Header := TEXT_CONTENT_TYPE_HEADER;
  Result.Content := FormatUTF8('%,%',[n.Real,n.Imaginary]);
  assert(GetCurrentThreadID=MainThreadID,'shall always be in main thread');
end;

{$ifdef USEVARIANTS}
function TServiceComplexCalculator.TestVariants(const Text: RawUTF8; V1: Variant; var V2: variant): variant;
begin
  V2 := V2+V1;
  VariantLoadJSON(Result,Text);
end;
{$endif}

{$ifndef LVCL}
procedure TServiceComplexCalculator.Collections(Item: TCollTest;
  var List: TCollTestsI; out Copy: TCollTestsI);
begin
  CopyObject(Item,List.Add);
  CopyObject(List,Copy);
end;
{$endif LVCL}


{ TServiceComplexNumber }

procedure TServiceComplexNumber.Add(aReal, aImaginary: double);
begin
  fReal := fReal+aReal;
  fImaginary := fImaginary+aImaginary;
end;

procedure TServiceComplexNumber.Assign(aReal, aImaginary: double);
begin
  fReal := aReal;
  fImaginary := aImaginary;
end;

function TServiceComplexNumber.GetImaginary: double;
begin
  result := fImaginary;
end;

function TServiceComplexNumber.GetReal: double;
begin
  result := fReal;
end;

procedure TServiceComplexNumber.SetImaginary(const Value: double);
begin
  fImaginary := Value;
end;

procedure TServiceComplexNumber.SetReal(const Value: double);
begin
  fReal := Value;
end;


{ TTestServiceOrientedArchitecture }

procedure TTestServiceOrientedArchitecture.Test(const I: ICalculator;
  const CC: IComplexCalculator; const CN: IComplexNumber);
procedure TestCalculator(const I: ICalculator);
var t,i1,i2,i3: integer;
    c: cardinal;
    cu: currency;
    n1,n2: double;
    o: TSynTableFieldOptions;
    Ints: TIntegerDynArray;
    Strs1: TRawUTF8DynArray;
    Str2: TWideStringDynArray;
    Rec1: TVirtualTableModuleProperties;
    Rec2, RecRes: TSQLRestCacheEntryValue;
    s: RawUTF8;
begin
  Setlength(Ints,2);
  CSVToRawUTF8DynArray('one,two,three',Strs1);
  for t := 1 to 1000 do begin
    i1 := Random(MaxInt)-Random(MaxInt);
    i2 := Random(MaxInt)-i1;
    Check(I.Add(i1,i2)=i1+i2);
    Check(I.Multiply(i1,i2)=Int64(i1)*Int64(i2));
    n1 := Random*1E-9-Random*1E-8;
    n2 := n1*Random;
    CheckSame(I.Subtract(n1,n2),n1-n2);
    cu := i1*0.01;
    I.ToText(cu,s);
    Check(s=Curr64ToStr(PInt64(@cu)^));
    Check(I.ToTextFunc(n1)=DoubleToString(n1));
    o := [tfoIndex,tfoCaseInsensitive];
    i3 := i1;
    c := cardinal(i2);
    Check(I.SpecialCall(s,i3,c,
      [tftDouble],[tftWinAnsi,tftVarInt64],o)=
      [tftWinAnsi,tftVarInt64,tftDouble]);
    Check(i3=i1+length(s));
    Check(c=cardinal(i2)+1);
    Check(o=[tfoUnique,tfoCaseInsensitive]);
    Ints[0] := i1;
    Ints[1] := i2;
    SetLength(Str2,3);
    Str2[0] := 'ABC';
    Str2[1] := 'DEF';
    Str2[2] := 'GHIJK';
    fillchar(Rec1,sizeof(Rec1),0);
    Rec1.Features := [vtTransaction,vtSavePoint];
    Rec1.FileExtension := ExeVersion.ProgramFileName;
    Rec2.ID := i1;
    Rec2.TimeStamp := c;
    Rec2.JSON := 'abc';
    RecRes := I.ComplexCall(Ints,Strs1,Str2,Rec1,Rec2,n1,n2);
    Check(length(Str2)=4);
    Check(Str2[0]='ABC');
    Check(Str2[1]='DEF');
    Check(Str2[2]='GHIJK');
    Check(Str2[3]='one,two,three');
    Check(Rec1.Features=[vtTransaction,vtSavePoint]);
    Check(Rec1.FileExtension=ExeVersion.ProgramFileName);
    Check(Rec2.ID=i1+1);
    Check(Rec2.TimeStamp=c-1);
    Check(Rec2.JSON=IntegerDynArrayToCSV(Ints,length(Ints)));
    Check(RecRes.ID=i1);
    Check(RecRes.TimeStamp=c);
    Check(RecRes.JSON=StringToUTF8(Rec1.FileExtension));
    CheckSame(n1,n2);
    Rec1.FileExtension := ''; // to avoid memory leak
  end;
end;
var s: RawUTF8;
{$ifndef LVCL}
    c: cardinal;
    n1,n2: double;
    C1,C2,C3: TComplexNumber;
    Item: TCollTest;
    List,Copy: TCollTestsI;
    j: integer;
{$endif}
{$ifdef USEVARIANTS}
    V1,V2,V3: variant;
{$endif}
begin
  Check(I.Add(1,2)=3);
  Check(I.Multiply(2,3)=6);
  CheckSame(I.Subtract(23,20),3);
  I.ToText(3.14,s);
  Check(s='3.14');
  Check(I.ToTextFunc(777)='777');
  TestCalculator(I);
  TestCalculator(CC); // test the fact that CC inherits from ICalculator
  {$ifndef LVCL}   /// in LVCL, TPersistent doesn't have any RTTI information
  C3 := TComplexNumber.Create(0,0);
  C1 := TComplexNumber.Create(2,3);
  C2 := TComplexNumber.Create(20,30);
  List := TCollTestsI.Create;
  Copy := TCollTestsI.Create;
  Item := TCollTest.Create(nil);
  try
    Check(CC.IsNull(C3));
    for c := 0 to 700 do begin
      Check(not CC.IsNull(C1));
      C3.Imaginary := 0;
      CC.Substract(C1,C2,C3);
      CheckSame(C3.Real,c-18.0);
      CheckSame(C3.Imaginary,-27);
      with CC.TestBlob(C3) do begin
        Check(Header=TEXT_CONTENT_TYPE_HEADER);
        Check(Content=FormatUTF8('%,%',[C3.Real,C3.Imaginary]));
      end;
{$ifdef USEVARIANTS}
      V1 := C3.Real;
      V2 := c;
      case c mod 3 of
      0: s := DoubleToStr(C3.Real);
      1: s := Int32ToUtf8(c);
      2: s := QuotedStr(Int32ToUtf8(c),'"');
      end;
      V3 := CC.TestVariants(s,V1,V2);
      CheckSame(V1,C3.Real);
      CheckSame(V2,C3.Real+c);
      Check(VariantSaveJSON(V3)=s);
{$endif}
      if c mod 10=1 then begin
        Item.Color := Item.Color+1;
        Item.Length := Item.Color*2;
        Item.Name := Int32ToUtf8(Item.Color);
        CC.Collections(Item,List,Copy);
      end;
      if not CheckFailed(List.Count=Item.Color) or
         not CheckFailed(Copy.Count=List.Count) then
        for j := 0 to List.Count-1 do begin
          with TCollTest(List.Items[j]) do begin
            Check(Color=j+1);
            Check(Length=Color*2);
            Check(GetInteger(pointer(Name))=Color);
          end;
          with TCollTest(Copy.Items[j]) do begin
            Check(Color=j+1);
            Check(Length=Color*2);
            Check(GetInteger(pointer(Name))=Color);
          end;
        end;
      C1.Real := C1.Real+1;
    end;
  finally
    C3.Free;
    C1.Free;
    C2.Free;
    Item.Free;
    List.Free;
    Copy.Free;
  end;
  n2 := CN.Imaginary;
  for c := 0 to 200 do begin
    CheckSame(CN.Imaginary,n2);
    n1 := Random*1000;
    CN.Real := n1;
    CheckSame(CN.Real,n1);
    CheckSame(CN.Imaginary,n2);
    n2 := Random*1000;
    CN.Imaginary := n2;
    CheckSame(CN.Real,n1);
    CheckSame(CN.Imaginary,n2);
    CN.Add(1,2);
    CheckSame(CN.Real,n1+1);
    n2 := n2+2;
    CheckSame(CN.Imaginary,n2);
  end;
  {$endif}
  CN.Assign(3.14,1.05946);
  CheckSame(CN.Real,3.14);
  CheckSame(CN.Imaginary,1.05946);
end;

procedure TTestServiceOrientedArchitecture.ClientTest(aRouting: TServiceRoutingMode;
  RunInMainThread: boolean=false);
var I: ICalculator;
    CC: IComplexCalculator;
    CN: IComplexNumber;
    O: TObject;
    s: integer;
begin
  if RunInMainThread then 
    with fClient.Server.Services do
    for s := 0 to Count-1 do
      (Index(s) as TServiceFactoryServer).SetOptions([],[optExecInMainThread]);
  fClient.Server.ServicesRouting := aRouting;
  fClient.ServicesRouting := aRouting;
  (fClient.Server.Services as TServiceContainerServer).PublishSignature := true;
  Check(fClient.Services['Calculator'].RetrieveSignature=
    fClient.Server.Services['Calculator'].RetrieveSignature);
  (fClient.Server.Services as TServiceContainerServer).PublishSignature := false;
  Check(fClient.Services['Calculator'].RetrieveSignature='');
  // once registered, can be accessed by its GUID or URI
  if CheckFailed(fClient.Services.Info(TypeInfo(ICalculator)).Get(I)) or
     CheckFailed(fClient.Services.Info(TypeInfo(IComplexCalculator)).Get(CC)) or
     // here, IComplexNumber is not yet registered on the client side -> done now
     CheckFailed(fClient.Services.Info(TypeInfo(IComplexNumber)).Get(CN)) then
    exit;
  O := ObjectFromInterface(I);
  Check((O<>nil) and (O.ClassName='TInterfacedObjectFake'),
    'ObjectFromInterface for '+O.ClassName);
  Test(I,CC,CN);
  I := nil;
  if CheckFailed(fClient.Services.GUID(IID_ICalculator).Get(I)) then
    exit;
  Test(I,CC,CN);
  I := nil;
  CC := nil;
  CN := nil;
  if CheckFailed(fClient.Services['Calculator'].Get(I)) or
     CheckFailed(fClient.Services['ComplexCalculator'].Get(CC)) or
     CheckFailed(fClient.Services['ComplexNumber'].Get(CN)) then
    exit;
  CN.Imaginary;
  Test(I,CC,CN);
  if RunInMainThread then
    with fClient.Server.Services do
    for s := 0 to Count-1 do
      (Index(s) as TServiceFactoryServer).SetOptions([],[]);
end;

procedure TTestServiceOrientedArchitecture.DirectCall;
var I: ICalculator;
    CC: IComplexCalculator;
    CN: IComplexNumber;
begin
  I := TServiceCalculator.Create;
  CC := TServiceComplexCalculator.Create;
  CN := TServiceComplexNumber.Create;
  Test(I,CC,CN);
  Test(I,CC,CN);
  Test(I,CC,CN);
end;

procedure TTestServiceOrientedArchitecture.ServerSide;
var I: ICalculator;
    CC: IComplexCalculator;
    CN: IComplexNumber;
begin
  if CheckFailed(fModel<>nil) or CheckFailed(fClient<>nil) or
     CheckFailed(fClient.Server.Services.Count=3) or
     CheckFailed(fClient.Server.Services.Index(0).Get(I)) or
     CheckFailed(Assigned(I)) or
     CheckFailed(fClient.Server.Services.Info(TypeInfo(IComplexCalculator)).Get(CC)) or
     CheckFailed(fClient.Server.Services.Info(TypeInfo(IComplexNumber)).Get(CN)) then
    exit;
  Test(I,CC,CN);
  I := nil;
  CC := nil;
  CN := nil;
  if CheckFailed(fClient.Server.Services['Calculator'].Get(I)) or
     CheckFailed(fClient.Server.Services['ComplexCalculator'].Get(CC)) or
     CheckFailed(fClient.Server.Services['ComplexNumber'].Get(CN)) then
    exit;
  Test(I,CC,CN);
  Test(I,CC,CN);
end;

procedure TTestServiceOrientedArchitecture.ServiceInitialization;
  function Ask(Method, Params: RawUTF8; ExpectedResult: cardinal): RawUTF8;
  var resp,data: RawUTF8;
  begin
    Params := ' [ '+Params+' ]';
    case fClient.Server.ServicesRouting of
    rmREST: begin
      SetString(data,PAnsiChar(pointer(Params)),length(Params)); // =UniqueString
      Check(fClient.URI('root/calculator.'+Method,'POST',@resp,nil,@Params).Lo=ExpectedResult);
      if ExpectedResult=200 then begin
        Check(fClient.URI('root/CALCulator.'+Method+'?'+UrlEncode(data),'POST',@data).Lo=ExpectedResult);
        Check(data=resp,'optional URI-encoded-inlined parameters use');
      end;
    end;
    rmJSON_RPC: begin
      data := '{"method":"'+Method+'", "params":'+Params+'}';
      Check(fClient.URI('root/calculator','POST',@resp,nil,@data).Lo=ExpectedResult);
    end;
    end;
    result := JSONDecode(resp,'result',nil,true);
  end;
var S: TServiceFactory;
    i: integer;
    routing: TServiceRoutingMode;
const ExpectedURI: array[0..4] of RawUTF8 =
        ('Add','Multiply','Subtract','ToText','ToTextFunc');
      ExpectedParCount: array[0..4] of Integer = (4,4,4,3,3);
      ExpectedArgs: array[0..4] of TServiceMethodValueTypes =
        ([smvSelf,smvInteger],[smvSelf,smvInt64],[smvSelf,smvDouble],
         [smvSelf,smvCurrency,smvRawUTF8],[smvSelf,smvDouble,smvString]);
      ExpectedTypes: array[0..4] of String[10] =
        ('Integer','Int64','Double','Currency','Double');
      ExpectedType: array[0..4] of TServiceMethodValueType =
        (smvInteger,smvInt64,smvDouble,smvCurrency,smvDouble);
      ExpectedResult: array[0..2] of String[10] = ('Integer','Int64','Double');
begin
  if CheckFailed(fModel=nil) then exit; // should be called once
  // create model, client and server
  fModel := TSQLModel.Create([TSQLRecordPeople]);
  fClient := TSQLRestClientDB.Create(fModel,nil,'test.db3',TSQLRestServerDB,true);
  Check(fClient.SetUser('User','synopse')); // default user for Security tests
  // register TServiceCalculator as the ICalculator implementation on the server
  Check(fClient.Server.
    ServiceRegister(TServiceCalculator,[TypeInfo(ICalculator)],sicShared)<>nil);
  // verify ICalculator RTTI-generated details
  Check(fClient.Server.Services<>nil);
  if CheckFailed(fClient.Server.Services.Count=1) then exit;
  S := fClient.Server.Services.Index(0);
  if CheckFailed(S<>nil) then exit;
  Check(S.InterfaceURI='Calculator');
  Check(S.InstanceCreation=sicShared);
  Check(S.InterfaceTypeInfo^.Kind=tkInterface);
  Check(S.InterfaceTypeInfo^.Name='ICalculator');
  Check(GUIDToString(S.InterfaceIID)='{9A60C8ED-CEB2-4E09-87D4-4A16F496E5FE}');
  Check(S.InterfaceMangledURI='7chgmrLOCU6H1EoW9Jbl_g');
  fClient.Server.Services.ExpectMangledURI := true;
  Check(fClient.Server.Services[S.InterfaceMangledURI]=S);
  fClient.Server.Services.ExpectMangledURI := false;
  Check(fClient.Server.Services['CALCULAtor']=S);
  Check(fClient.Server.Services['CALCULAtors']=nil);
  if CheckFailed(length(S.InterfaceFactory.Methods)=7) then exit;
  {$ifdef UNICODE}
  Check(S.ContractHash='"2C0E079E73D1727B"'); // string -> utf8
  {$else}
  if CurrentAnsiConvert.CodePage=CODEPAGE_US then
    Check(S.ContractHash='"479A33BBAFB6EAE2"'); // string -> ansi1252
  {$endif}
  Check(TServiceCalculator(nil).Test(1,2)='3');
  Check(TServiceCalculator(nil).ToTextFunc(777)='777');
  for i := 0 to high(ExpectedURI) do // SpecialCall interface not checked
    with S.InterfaceFactory.Methods[i] do begin
      Check(URI=ExpectedURI[i]);
      Check(length(Args)=ExpectedParCount[i]);
      Check(ArgsUsed=ExpectedArgs[i]);
      Check(Args[0].ParamName^='Self');
      Check(Args[0].ValueDirection=smdConst);
      Check(Args[0].ValueType=smvSelf);
      Check(Args[0].TypeName^='ICalculator');
      Check(Args[1].ValueDirection=smdConst);
      Check(Args[1].ValueType=ExpectedType[i]);
      if i<3 then
        Check(Args[1].ParamName^='n1') else
        Check(Args[1].ParamName^='Value');
      if i<3 then begin
        Check(Args[2].ParamName^='n2');
        Check(Args[2].ValueDirection=smdConst);
        Check(Args[2].ValueType=ExpectedType[i]);
        Check(IdemPropName(Args[3].TypeName^,ExpectedTypes[i]));
        Check(Args[3].ValueDirection=smdResult);
        Check(Args[3].ValueType=ExpectedType[i]);
      end else begin
        Check(Args[2].ParamName^='Result');
        if i<4 then
          Check(Args[2].ValueDirection=smdVar) else
          Check(Args[2].ValueDirection=smdResult);
        if i<4 then
          Check(Args[2].ValueType=smvRawUTF8) else
          Check(Args[2].ValueType=smvString);
      end;
    end;
  // IComplexCalculator + IComplexNumber services
  Check(fClient.Server.ServiceRegister(TServiceComplexCalculator,[TypeInfo(IComplexCalculator)],sicSingle)<>nil);
  Check(fClient.Server.ServiceRegister(TServiceComplexNumber,[TypeInfo(IComplexNumber)],sicClientDriven)<>nil);
  // JSON-level access
  for routing := low(routing) to high(routing) do begin
    fClient.Server.ServicesRouting := routing;
    Check(Ask('None','1,2',400)='');
    Check(Ask('Add','1,2',200)='[3]');
    Check(Ask('Multiply','2,3',200)='[6]');
    Check(Ask('Subtract','23,20',200)='[3]');
    Check(Ask('ToText','777,"abc"',200)='["777"]'); // "abc" for var parameter
    Check(Ask('ToTextFunc','777',200)='["777"]');
  end;
  fClient.Server.ServicesRouting := rmREST; // back to default
end;

procedure TTestServiceOrientedArchitecture.Security;
  procedure Test(Expected: TSQLFieldTables; const msg: string);
    function Ask(const Method, Params: RawUTF8): RawUTF8;
    var resp,data: RawUTF8;
    begin
      data := '{"method":"'+Method+'", "params": [ '+Params+' ]}';
      fClient.URI('root/calculator','POST',@resp,nil,@data);
      result := JSONDecode(resp,'result',nil,true);
    end;
  begin
    Check((Ask('None','1,2')=''),msg);
    Check((Ask('Add','1,2')='[3]')=(1 in Expected),msg);
    Check((Ask('Multiply','2,3')='[6]')=(2 in Expected),msg);
    Check((Ask('Subtract','23,20')='[3]')=(3 in Expected),msg);
    Check((Ask('ToText','777,"abc"')='["777"]')=(4 in Expected),msg);
    Check((Ask('ToTextFunc','777')='["777"]')=(5 in Expected),msg);
  end;
var S: TServiceFactoryServer;
    GroupID: integer;
begin
  GroupID := fClient.MainFieldID(TSQLAuthGroup,'User');
  S := fClient.Server.Services['Calculator'] as TServiceFactoryServer;
  Test([1,2,3,4,5],'by default, all methods are allowed');
  S.AllowAll;
  Test([1,2,3,4,5],'AllowAll should change nothing');
  S.DenyAll;
  Test([],'DenyAll will reset all settings');
  S.AllowAll;
  Test([1,2,3,4,5],'back to full acccess for everybody');
  S.DenyAllByID([GroupID]);
  Test([],'our current user shall be denied');
  S.AllowAll;
  Test([1,2,3,4,5],'restore allowed for everybody');
  S.DenyAllByID([GroupID+1]);
  Test([1,2,3,4,5],'this group ID won''t affect the current user');
  S.DenyByID(['Add'],GroupID);
  Test([2,3,4,5],'exclude a specific method for the current user');
  S.DenyByID(['totext'],GroupID);
  Test([2,3,5],'exclude another method for the current user');
  S.AllowByID(['Add'],[GroupID+1]);
  Test([2,3,5],'this group ID won''t affect the current user');
  S.AllowByID(['Add'],[GroupID]);
  Test([1,2,3,5],'allow a specific method for the current user');
  S.AllowAllByID([0]);
  Test([1,2,3,5],'invalid group ID won''t affect the current user');
  S.AllowAllByID([GroupID]);
  Test([1,2,3,4,5],'restore allowed for the current user');
  Check(not fClient.SetUser('unknown','wrongpass'));
  Test([],'no authentication -> access denied');
  Check(fClient.SetUser('Admin','synopse'));
  Test([1,2,3,4,5],'authenticated user');
  S.DenyAll;
  Test([],'DenyAll works even for admins');
  S.AllowAll;
  Test([1,2,3,4,5],'restore allowed for everybody');
  S.AllowAllByName(['Supervisor']);
  Test([1,2,3,4,5],'this group name won''t affect the current Admin user');
  S.DenyAllByName(['Supervisor']);
  Test([1,2,3,4,5],'this group name won''t affect the current Admin user');
  S.DenyAllByName(['Supervisor','Admin']);
  Test([],'Admin group user was explicitely denied access');
  S.AllowAllByName(['Admin']);
  Test([1,2,3,4,5],'restore allowed for current Admin user');
  S.AllowAll;
  Check(fClient.SetUser('User','synopse'));
  Test([1,2,3,4,5],'restore allowed for everybody');
end;

procedure TTestServiceOrientedArchitecture.ClientSideJSONRPC;
begin
  ClientTest(rmJSON_RPC);
end;

procedure TTestServiceOrientedArchitecture.ClientSideREST;
begin
  Check(fClient.ServiceRegister([TypeInfo(ICalculator)],sicShared));
  Check(fClient.ServiceRegister([TypeInfo(IComplexCalculator)],sicSingle));
  ClientTest(rmREST);
end;

type
  TTestThread = class(TThread)
  protected
    procedure Execute; override;
  public
    Test: TTestServiceOrientedArchitecture;
  end;

  
procedure TTestServiceOrientedArchitecture.Cleanup;
begin
  FreeAndNil(fClient);
  FreeAndNil(fModel);
end;


{ TTestThread }

procedure TTestThread.Execute;
begin
  try
    Test.fClient.Server.BeginCurrentThread(self);
    Test.ClientTest(rmREST,true);
  finally
    Test := nil; // mark tests finished
  end;
end;


{$ifndef LVCL}
procedure TTestServiceOrientedArchitecture.ClientSideSynchronizedREST;
begin
  with TTestThread.Create(true) do
  try
    Test := self;
    {$ifdef ISDELPHI2010}
    Start;
    {$else}
    Resume;
    {$endif}
    while Test<>nil do
      CheckSynchronize{$ifndef DELPHI6OROLDER}(1){$endif};
  finally
    Free;
  end;
  fClient.Server.ServicesRouting := rmJSON_RPC; // back to default
end;
{$endif}

procedure TTestServiceOrientedArchitecture.CustomRecordLayout;
begin
  TTextWriter.RegisterCustomJSONSerializer(TypeInfo(TSQLRestCacheEntryValue),
    TTestServiceOrientedArchitecture.CustomReader,
    TTestServiceOrientedArchitecture.CustomWriter);
  try
    ClientTest(rmREST);
  finally
    TTextWriter.RegisterCustomJSONSerializer(TypeInfo(TSQLRestCacheEntryValue),nil,nil);
  end;
end;

class function TTestServiceOrientedArchitecture.CustomReader(P: PUTF8Char;
  var aValue; out aValid: Boolean): PUTF8Char;
var V: TSQLRestCacheEntryValue absolute aValue;
    Values: TPUtf8CharDynArray;
begin // {"ID":1786554763,"TimeStamp":323618765,"JSON":"D:\\TestSQL3.exe"}
  result := JSONDecode(P,['ID','TimeStamp','JSON'],Values);
  if result=nil then
    aValid := false else begin
    V.ID := GetInteger(Values[0]);
    V.TimeStamp := GetCardinal(Values[1]);
    V.JSON := Values[2];
    aValid := true;
  end;
end;

class procedure TTestServiceOrientedArchitecture.CustomWriter(
  const aWriter: TTextWriter; const aValue);
var V: TSQLRestCacheEntryValue absolute aValue;
begin
  aWriter.AddJSONEscape(['ID',V.ID,'TimeStamp',Int64(V.TimeStamp),'JSON',V.JSON]);
end;

type
  IChild = interface;

  IParent = interface
    procedure SetChild(const Value: IChild);
    function GetChild: IChild;
    function HasChild: boolean;
    property Child: IChild read GetChild write SetChild;
  end;

  IChild = interface
    procedure SetParent(const Value: IParent);
    function GetParent: IParent;
    property Parent: IParent read GetParent write SetParent;
  end;

  TParent = class(TInterfacedObject, IParent)
  private
    FChild: IChild;
    procedure SetChild(const Value: IChild);
    function GetChild: IChild;
  public
    destructor Destroy; override;
    function HasChild: boolean;
    property Child: IChild read GetChild write SetChild;
  end;

  TChild = class(TInterfacedObject, IChild)
  private
    FParent: IParent;
    procedure SetParent(const Value: IParent);
    function GetParent: IParent;
  public
    constructor Create(const AParent: IParent; SetChild: boolean);
    destructor Destroy; override;
    property Parent: IParent read GetParent write SetParent;
  end;

  TUseWeakRef = (direct,weakref,zeroing);

var
  ParentDestroyed, ChildDestroyed: boolean;
  UseWeakRef: TUseWeakRef;

procedure TTestServiceOrientedArchitecture.WeakInterfaces;
var Parent: IParent;
    Child, Child2: IChild;
    P: TParent;
    C: TChild;
procedure Init(aWeakRef: TUseWeakRef);
begin
  ParentDestroyed := false;
  ChildDestroyed := false;
  UseWeakRef := aWeakRef;
  Check(Parent=nil);
  Check(Child=nil);
  P := TParent.Create;
  Parent := P;
  Check(ObjectFromInterface(Parent)=P);
  C := TChild.Create(Parent,true);
  Child := C;
  Check(ObjectFromInterface(Child)=C);
  Parent.Child := Child;
end;
procedure WeakTest(aWeakRef: TUseWeakRef);
var Child2: IChild;
begin
  Init(aWeakRef);
  Check(ParentDestroyed=false);
  Check(ChildDestroyed=false);
  Child2 := Parent.Child;
  Child2 := nil; // otherwise memory leak, but it is OK
  Check(ChildDestroyed=false);
  Child := nil;
  Check(ChildDestroyed=true);
  Check(ParentDestroyed=false);
  Check(Parent.HasChild=(aWeakRef=weakref),'ZEROed Weak');
  Parent := nil;
end;
begin
  Init(direct);
  Parent := nil;
  Check(ParentDestroyed=false);
  Check(ChildDestroyed=false);
  Child := nil;
  Check(ParentDestroyed=false,'Without weak reference: memory leak');
  Check(ChildDestroyed=false);
  P._Release;
  Check(ParentDestroyed=true,'Manual release');
  Check(ChildDestroyed=true);
  {$ifndef FullDebugMode}
  WeakTest(weakref);
  {$endif}
  Init(zeroing);
  Check(ParentDestroyed=false);
  Check(ChildDestroyed=false);
  Child2 := Parent.Child;
  Child2 := nil; 
  Check(ChildDestroyed=false);
  Parent := nil;
  Check(ParentDestroyed=false);
  Check(ChildDestroyed=false);
  Child := nil;
  Check(ParentDestroyed=true);
  Check(ChildDestroyed=true);
  WeakTest(zeroing);
  Init(zeroing);
  Check(Parent.HasChild);
  Child2 := TChild.Create(Parent,false);
  Check(Parent.HasChild);
  Parent.Child := Child2;
  Check(Parent.HasChild);
  Child2 := nil;
  Check(not Parent.HasChild);
  Check(ChildDestroyed=true);
  ChildDestroyed := false;
  Check(not Parent.HasChild);
  Child := nil;
  Check(ParentDestroyed=false);
  Check(ChildDestroyed=true);
  Check(not Parent.HasChild);
  ChildDestroyed := false;
  Parent := nil;
  Check(ParentDestroyed=true);
  Check(ChildDestroyed=false);
end;


{ TParent }

destructor TParent.Destroy;
begin
  ParentDestroyed := true;
  inherited;
end;

function TParent.GetChild: IChild;
begin
  result := FChild;
end;

function TParent.HasChild: boolean;
begin
  result := FChild<>nil;
end;

procedure TParent.SetChild(const Value: IChild);
begin
  case UseWeakRef of
  direct:  FChild := Value;
  weakref: SetWeak(@FChild,Value);
  zeroing: SetWeakZero(self,@FChild,Value);
  end;
end;

{ TChild }

constructor TChild.Create(const AParent: IParent; SetChild: boolean);
begin
  FParent := AParent;
  if SetChild then
    FParent.Child := self;
end;

destructor TChild.Destroy;
begin
  ChildDestroyed := true;
  inherited;
end;

function TChild.GetParent: IParent;
begin
  result := FParent;
end;

procedure TChild.SetParent(const Value: IParent);
begin
  case UseWeakRef of
  direct:  FParent := Value;
  weakref: SetWeak(@FParent,Value);
  zeroing: SetWeakZero(self,@FParent,Value);
  end;
end;

type
  TUser = record
    Name: RawUTF8;
    Password: RawUTF8;
    MobilePhoneNumber: RawUTF8;
    ID: Integer;
  end;
  IUserRepository = interface(IInvokable)
    ['{B21E5B21-28F4-4874-8446-BD0B06DAA07F}']
    function GetUserByName(const Name: RawUTF8): TUser;
    procedure Save(const User: TUser);
  end;
  ISmsSender = interface(IInvokable)
    ['{8F87CB56-5E2F-437E-B2E6-B3020835DC61}']
    function Send(const Text, Number: RawUTF8): boolean;
  end;

  TLoginController = class
  protected
    fUserRepository: IUserRepository;
    fSmsSender: ISmsSender;
  public
    constructor Create(const aUserRepository: IUserRepository;
      const aSmsSender: ISmsSender);
    procedure ForgotMyPassword(const UserName: RawUTF8);
  end;

constructor TLoginController.Create(const aUserRepository: IUserRepository;
  const aSmsSender: ISmsSender);
begin
  fUserRepository := aUserRepository;
  fSmsSender := aSmsSender;
end;

procedure TLoginController.ForgotMyPassword(const UserName: RawUTF8);
var U: TUser;
begin
  U := fUserRepository.GetUserByName(UserName);
  Assert(U.Name=UserName,'internal verification');
  U.Password := Int32ToUtf8(Random(MaxInt));
  if fSmsSender.Send('Your new password is '+U.Password,U.MobilePhoneNumber) then
    fUserRepository.Save(U);
end;

procedure TTestServiceOrientedArchitecture.IntSubtractJSON(
  Ctxt: TOnInterfaceStubExecuteParamsJSON);
var P: PUTF8Char;
begin
  if Ctxt.Sender is TInterfaceMock then
    Ctxt.TestCase.Check(Ctxt.EventParams='toto');
  P := pointer(Ctxt.Params);
  Ctxt.Returns([GetNextItemDouble(P)-GetNextItemDouble(P)]);
  // Ctxt.Result := '['+DoubleToStr(GetNextItemDouble(P)-GetNextItemDouble(P))+']';
end;

{$ifdef USEVARIANTS}
procedure TTestServiceOrientedArchitecture.IntSubtractVariant(
  Ctxt: TOnInterfaceStubExecuteParamsVariant);
begin
  if Ctxt.Sender is TInterfaceMock then
    Ctxt.TestCase.Check(Ctxt.EventParams='toto');
  Ctxt['result'] := Ctxt['n1']-Ctxt['n2'];
  // with Ctxt do Output[0] := Input[0]-Input[1];
end;
{$endif}

procedure TTestServiceOrientedArchitecture.MocksAndStubs;
var I: ICalculator;
    n: integer;
    UserRepository: IUserRepository;
    SmsSender: ISmsSender;
    U: TUser;
    UJSON: RawUTF8;
    HashGetUserByNameToto: cardinal;
    Stub: TInterfaceStub;
    Mock: TInterfaceMockSpy;
begin
  Stub := TInterfaceStub.Create(TypeInfo(ICalculator),I).
    SetOptions([imoLogMethodCallsAndResults]);
  Check(I.Add(10,20)=0,'Default result');
  Check(Stub.LogAsText='Add(10,20)=[0]');
  I := nil;
  Stub := TInterfaceStub.Create(TypeInfo(ICalculator),I).
    Returns('Add','30').
    Returns('Multiply',[60]).
    Returns('Multiply',[2,35],[70]).
    ExpectsCount('Multiply',qoEqualTo,2).
    ExpectsCount('Subtract',qoGreaterThan,0).
    ExpectsCount('ToTextFunc',qoLessThan,2).
    ExpectsTrace('Add',Hash32('Add(10,30)=[30]')).
    ExpectsTrace('Multiply',Hash32('Multiply(10,30)=[60],Multiply(2,35)=[70]')).
    ExpectsTrace('Multiply',[10,30],Hash32('Multiply(10,30)=[60]')).
    ExpectsTrace(Hash32('Add(10,30)=[30],Multiply(10,30)=[60],'+
      'Multiply(2,35)=[70],Subtract(2.3,1.2)=[0],ToTextFunc(2.3)=["default"]')).
    Returns('ToTextFunc',['default']);
  Check(I.Add(10,30)=30);
  Check(I.Multiply(10,30)=60);
  Check(I.Multiply(2,35)=70);
  Check(I.Subtract(2.3,1.2)=0,'Default result');
  Check(I.ToTextFunc(2.3)='default');
  Check(Stub.LogHash=$34FA7AAF);
  I := nil;
  TInterfaceMock.Create(TypeInfo(ICalculator),I,self).
    Returns('Add','30').
    Fails('Add',[1,2],'expected failure').
    SetOptions([imoMockFailsWillPassTestCase]). // -> Check(true)
    ExpectsCount('Add',qoEqualTo,3).
    ExpectsCount('Add',[10,30],qoNotEqualTo,1).
    Executes('Subtract',IntSubtractJSON,'toto').
    Returns('Multiply',[60]).
    Returns('Multiply',[2,35],[70]).
    Returns('ToTextFunc',[2.3],['two point three']).
    Returns('ToTextFunc',['default']);
  Check(I.ToTextFunc(2.3)='two point three');
  Check(I.ToTextFunc(2.4)='default');
  Check(I.Add(10,30)=30);
  n := Assertions;
  I.Add(1,2); // will launch TInterfaceMock.InternalCheck -> Check(true)
  n := Assertions-n; // tricky code due to Check() inlined Assertions modif.
  Check(n=1,'test should have passed');
  Check(I.Multiply(10,30)=60);
  Check(I.Multiply(2,35)=70);
  for n := 1 to 10000 do
    CheckSame(I.Subtract(n*10.5,n*0.5),n*10);
  n := Assertions;
  I := nil;
  n := Assertions-n;
  Check(n=2,'Add count<>3');
  TInterfaceStub.Create(TypeInfo(ISmsSender),SmsSender).
    Returns('Send',[true]);
  U.Name := 'toto';
  UJSON := RecordSaveJSON(U,TypeInfo(TUser));
  HashGetUserByNameToto := Hash32('GetUserByName("toto")=['+UJSON+']');
  Mock := TInterfaceMockSpy.Create(TypeInfo(IUserRepository),UserRepository,self);
  Mock.Returns('GetUserByName','"toto"',UJSON).
       ExpectsCount('GetUserByName',qoEqualTo,1).
       ExpectsCount('GetUserByName',['toto'],qoEqualTo,1).
       ExpectsCount('GetUserByName','"tata"',qoEqualTo,0).
       ExpectsTrace('GetUserByName',['toto'],HashGetUserByNameToto).
       ExpectsTrace('GetUserByName',HashGetUserByNameToto).
       ExpectsCount('Save',qoEqualTo,1);
  with TLoginController.Create(UserRepository,SmsSender) do
  try
    ForgotMyPassword('toto');
  finally
    Free;
  end;
  Mock.Verify('Save');
  Mock.Verify('GetUserByName',['toto'],qoEqualTo,1);
  Mock.Verify('GetUserByName','"toto"',qoNotEqualTo,2);
  Mock.Verify('GetUserByName',['toto'],'['+UJSON+']');
  UserRepository := nil; // will release TInterfaceMock and check Excepts*()
  SmsSender := nil;
  TInterfaceStub.Create(IID_ICalculator,I).
    Returns('Subtract',[10,20],[3]).
    {$ifdef USEVARIANTS}
    Executes('Subtract',IntSubtractVariant,'toto').
    {$endif}
    Fails('Add','expected exception').
    Raises('Add',[1,2],ESynException,'expected exception');
  {$ifdef USEVARIANTS}
  for n := 1 to 10000 do
    CheckSame(I.Subtract(n*10.5,n*0.5),n*10);
  {$endif}
  Check(I.Subtract(10,20)=3,'Explicit result');
  {$WARN SYMBOL_PLATFORM OFF}
  if DebugHook<>0 then
    exit; // avoid exceptions in IDE
  {$WARN SYMBOL_PLATFORM ON}
  with TSynLog.Family.ExceptionIgnore do begin
    Add(EInterfaceFactoryException);
    Add(ESynException);
  end;
  try
    I.Add(0,0);
    Check(false);
  except
    on E: EInterfaceFactoryException do
      Check(E.Message='Invalid fake ICalculator.Add interface call: '+
        'TInterfaceStub returned error: expected exception',E.Message);
  end;
  try
    I.Add(1,2);
    Check(false);
  except
    on E: ESynException do
      Check(E.Message='expected exception',E.Message);
  end;
  with TSynLog.Family.ExceptionIgnore do begin
    Delete(IndexOf(EInterfaceFactoryException));
    Delete(IndexOf(ESynException));
  end;
end;


{$endif DELPHI5OROLDER}
{$endif FPC}

end.


