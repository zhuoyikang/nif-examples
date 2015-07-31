-module(simple).
-export([start/0, stop/1, foo/2, bar/2]).

-define(APPNAME, simple_drv).
-define(LIBNAME, "simple_drv").

%% erl_ddll:load_driver("./priv", "simple_drv").

init(SharedLib) ->
  Path = case code:priv_dir(?APPNAME) of
           {error, bad_name} ->
             case filelib:is_dir(filename:join(["..", priv])) of
               true ->
                 filename:join(["..", priv]);
               _ ->
                 filename:join([priv])
             end;
           Dir -> Dir
         end,
  case erl_ddll:load_driver(Path, SharedLib) of
    ok -> ok;
    {error, already_loaded} -> ok;
    _ -> exit({error, could_not_load_driver})
  end.

start() ->
  SharedLib=?LIBNAME,
  init(SharedLib),
  spawn(fun() ->
            Port = open_port({spawn, SharedLib}, []),
            loop(Port)
        end).

stop(Pid) ->
  Pid ! stop.

foo(Pid,X) ->
  call_port(Pid,{foo, X}).

bar(Pid,Y) ->
  call_port(Pid,{bar, Y}).

call_port(Pid,Msg) ->
  Pid ! {call, self(), Msg},
  receive
    {Pid, Result} ->
      Result
  end.

loop(Port) ->
  receive
    {call, Caller, Msg} ->
      Port ! {self(), {command, encode(Msg)}},
      receive
        {Port, {data, Data}} ->
          Caller ! {self(), decode(Data)}
      end,
      loop(Port);
    stop ->
      Port ! {self(), close},
      receive
        {Port, closed} ->
          exit(normal)
      end;
    {'EXIT', Port, Reason} ->
      io:format("~p ~n", [Reason]),
      exit(port_terminated)
  end.

encode({foo, X}) -> [1, X];
encode({bar, Y}) -> [2, Y].

decode([Int]) -> Int.
