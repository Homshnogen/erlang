-module(dictionary_server).
-export([start/0, insert/2, remove/1, lookup/1, clear/0, size/0, stop/0, server/1]).

start() ->
  start(whereis(dictServer)).

start(undefined) ->
  register(dictServer, spawn(?MODULE, server, [#{}])),
  ok;
start(_) -> "Dictionary server already running".

action(undefined, _) -> "Must start dictionary server";
action(Server, Query) ->
  Server ! Query,
  receive
    Response ->
	  Response
  end.

insert(Key, Value) ->
  action(whereis(dictServer), {self(), insert, Key, Value}).
  
remove(Key) ->
  action(whereis(dictServer), {self(), remove, Key}).
  
lookup(Key) ->
  action(whereis(dictServer), {self(), lookup, Key}).
  
clear() ->
  action(whereis(dictServer), {self(), clear}). 
  
size() ->
  action(whereis(dictServer), {self(), size}).

stop() ->
  action(whereis(dictServer), {self(), stop}).


server(Dict) ->
  receive
    {Pid, insert, Key, Value} -> 
	  Pid ! ok,
      server(maps:put(Key, Value, Dict));
    {Pid, remove, Key} -> 
	  Pid ! ok,
      server(maps:remove(Key, Dict));
    {Pid, lookup, Key} -> 
	  Pid ! maps:get(Key, Dict, notfound),
      server(Dict);
    {Pid, clear} -> 
	  Pid ! "Dictionary Cleared.",
      server(#{});
    {Pid, size} -> 
	  Pid ! map_size(Dict),
      server(Dict);
    {Pid, stop} ->
      Pid ! ok,
      ok
  end.