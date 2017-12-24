
uses
  Sysutils;
const
  { Net type }
  socklib = 'c';
  AF_INET = 2;

  { Error constants. Returned by LastError method of THost, TNet}

  NETDB_INTERNAL= -1;       { see errno }
  NETDB_SUCCESS = 0;        { no problem }
  HOST_NOT_FOUND= 1;        { Authoritative Answer Host not found }
  TRY_AGAIN     = 2;        { Non-Authoritive Host not found, or SERVERFAIL }
  NO_RECOVERY   = 3;        { Non recoverable errors, FORMERR, REFUSED, NOTIMP }
  NO_DATA       = 4;        { Valid name, no data record of requested type }
  NO_ADDRESS    = NO_DATA;  { no address, look for MX record }


Type

  { THostEnt Object }
  THostEnt = record
    H_Name     : pchar;   { Official name }
    H_Aliases  : ppchar;  { Null-terminated list of aliases}
    H_Addrtype : longint;   { Host address type }
    H_length  : longint;   { Length of address }
    H_Addr : ppchar;    { null-terminated list of adresses }
  end;
  PHostEntry = ^THostEnt;

  { TNetEnt object }
  TNetEnt = record
    N_Name     : pchar;   { Official name }
    N_Aliases  : ppchar;  { Nill-terminated alias list }
    N_AddrType : longint; { Net address type }
    N_net      : Cardinal; { Network number }
  end;
  PNetEntry = ^TNetEnt;

  TServEnt = record
    s_name    : pchar;    { Service name }
    s_aliases : ppchar;   { Null-terminated alias list }
    s_port    : longint;  { Port number }
    s_proto   : pchar;    { Protocol to use }
  end;
  PServEntry = ^TServEnt;

{ C style calls, linked in from Libc }

function gethostbyname(Name: PChar location 'a0'): PHostEntry; syscall SocketBase 210;
function getnetbyname(Name: PChar location 'a0'): PNetEntry; syscall SocketBase 222;
function getnetbyaddr(Net: Longint location 'd0'; NetType: Longint location 'd1'): PNetEntry; syscall SocketBase 228;
function getservbyname(Name: PChar location 'a0'; Protocol: PChar location 'a1'): PServEntry; syscall SocketBase 234;
function getservbyport(Port: LongInt location 'd0'; Protocol: PChar location 'a0'): PServEntry; syscall SocketBase 240;

procedure setnetent(Stayopen: Longint location 'd0');  syscall SocketBase 516;
procedure endnetent; syscall SocketBase 522;
function getnetent: PNetEntry; syscall SocketBase 528;
procedure setservent(StayOpen: longint location 'd0'); syscall SocketBase 552;
procedure endservent; syscall SocketBase 558;
function getservent: PServEntry; syscall SocketBase 564;

function gethostbyaddr(Addr: PChar; Len: Longint; HType: Longint): PHostentry;
var
  addr1,
  addr2: in_addr;
  IP: PPLongInt;
begin
  Addr1 :=  in_addr(PHostAddr(Addr)^);
  Addr2.s_addr := htonl(Addr1.s_addr);
  gethostbyaddr := Pointer(bsd_GetHostByAddr(Pointer(@Addr2.s_addr), Len, HType));
  if Assigned(gethostbyaddr) then
  begin
    ip := Pointer(gethostbyaddr^.H_Addr);
    if Assigned(ip) then
    begin
      repeat
        ip^^ := ntohl(ip^^);
        Inc(IP);
      until ip^ = nil; 
    end;
  end;
end;

function  GetDNSError: integer;
begin
  GetDNSError:=bsd_Errno;
end;

Function InitResolve : Boolean;
begin
  Result:=True;
end;

Function FinalResolve : Boolean;
begin
  Result:=True;
end;