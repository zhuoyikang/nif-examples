
all:
	./rebar compile

clean:
	./rebar clean
	rm -rf nifs/*/priv/*.so
	rm -rf nifs/*/.eunit/

check:
	./rebar compile eunit
