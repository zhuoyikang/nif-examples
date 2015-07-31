-module(termsend_threaded).
-export([send_to_pid/1, send_to_self/0]).
-on_load(init/0).

-define(APPNAME, termsend_threaded).
-define(LIBNAME, termsend_threaded).

send_to_pid(_) ->
    not_loaded(?LINE).

send_to_self() ->
    not_loaded(?LINE).

init() ->
    SoName = case code:priv_dir(?APPNAME) of
        {error, bad_name} ->
            case filelib:is_dir(filename:join(["..", priv])) of
                true ->
                    filename:join(["..", priv, ?LIBNAME]);
                _ ->
                    filename:join([priv, ?LIBNAME])
            end;
        Dir ->
            filename:join(Dir, ?LIBNAME)
    end,
    erlang:load_nif(SoName, 0).

not_loaded(Line) ->
    exit({not_loaded, [{module, ?MODULE}, {line, Line}]}).
