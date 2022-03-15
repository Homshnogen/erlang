-module(echo).
-export([start/0, print/1, stop/0, server/0]).

start() ->
  start(whereis(echoServer)).

start(undefined) ->
  register(echoServer, spawn(?MODULE, server, [])),
  ok;
start(_) -> "Echo server already running".

print(Term) ->
  print(whereis(echoServer), Term).

print(undefined, _) -> "Must start echo server";
print(Pid, Term) ->
  Pid ! {echo, Term},
  ok.

stop() ->
  stop(whereis(echoServer)).

stop(undefined) -> "Must start echo server";
stop(Pid) ->
  Pid ! stop,
  ok.


server() ->
  receive
    {echo, Term} -> 
      io:fwrite("~p~n",[Term]),
      server();
    stop ->
      ok
  end.