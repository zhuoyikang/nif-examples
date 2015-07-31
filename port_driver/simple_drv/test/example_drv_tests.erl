-module(example_drv_tests).

-include_lib("eunit/include/eunit.hrl").

example_test() ->
  Pid=simple:start(),
  Foo=simple:foo(Pid,1),
  Bar=simple:bar(Pid,1),
  ?assertEqual(Foo,2),
  ?assertEqual(Bar,3).
