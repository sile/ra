-module(repro_machine).

-behaviour(ra_machine).

-export([create_cluster/0]).

-export([init/1, apply/3, state_enter/2]).

-record(state, {
          name :: atom()
         }).


create_cluster() ->
    ok = ra:start(),

    Module = ?MODULE,
    Machine = {module, ?MODULE, #{}},
    ServerIds = [{repro_a, node()},
                 {repro_b, node()},
                 {repro_c, node()}],
    {ok, ServersStarted, _ServersNotStarted} = ra:start_cluster(default, Module, Machine, ServerIds),

    ok.


init(_) ->
    {_, Name} = erlang:process_info(self(), registered_name),
    io:format("* [~p] init~n", [Name]),
    #state{
      name = Name
     }.


apply(_Metadata, _Command, State) ->
    {State, {error, not_implemented}}.


state_enter(RaState, #state{name = Name}) ->
    io:format("* [~p] state_enter: ~p~n", [Name, RaState]),
    case Name of
        repro_a ->
            ok;
        repro_b ->
            %%            timer:sleep(500),
            ok;
        repro_c ->
            %%            timer:sleep(500),
            ok
    end,
    [].
