-module(repro_machine).

-behaviour(ra_machine).

-export([create_cluster/0,
         trigger_election/0]).

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


trigger_election() ->
    ok = ra:trigger_election({repro_a, node()}),
    io:format("+++ triggered election~n", []),
    {ok, Result, Leader} = ra:process_command({repro_c, node()}, hello_world),
    io:format("+++ processed command by ~p: result=~p~n", [Leader, Result]).


init(_) ->
    {_, Name} = erlang:process_info(self(), registered_name),
    io:format("* [~p] init~n", [Name]),
    #state{
      name = Name
     }.


apply(_Metadata, _Command, State) ->
    {State, {error, not_implemented}}.


state_enter(RaState, #state{name = Name}) ->
    case {Name, RaState} of
        %% {repro_a, candidate} ->
        %%     io:format("* [~p] state_enter (sleep 100ms): ~p~n", [Name, RaState]),
        %%     timer:sleep(100),
        %%     ok;
        _ ->
            io:format("* [~p] state_enter: ~p~n", [Name, RaState]),
            ok
    end,
    [].
