-module(ring).
-export([start/3, stop/0, process/2]).

start(M, N, Message) ->
  start(M, N, Message, whereis(ringLeader)).

start(M, N, Message, undefined) ->
  register(ringLeader, spawn(?MODULE, process, [N, self()])),
  receive
    spawned -> 
      sendMessages(M, Message)
  end;
start(_,_,_,Ring) when Ring /= undefined -> "Process ring already running. Use stop() to stop.".

sendMessages(0, _) ->
  ok;
sendMessages(M, Message) when M > 0 ->
  ringLeader ! {pass, Message},
  sendMessages(M-1, Message).

stop() ->
  stop(whereis(ringLeader)).

stop(undefined) -> "Must start process ring.";
stop(Pid) ->
  Pid ! exit,
  ok.

process(Next) ->
  receive
    {pass, Message} -> 
      io:fwrite("~p~n", [Message]),
      Next ! {pass, Message},
	  process(Next);
    exit ->
	  Next ! exit,
	  io:fwrite("graceful exut :P~n")
  end.

process(1, Root) ->
  Root ! spawned,
  process(whereis(ringLeader));
process(N, Root) when N > 1 ->
  Next = spawn(?MODULE, process, [N-1, Root]),
  process(Next).