-module(repro).

-behaviour(ra_machine).

-export([run/0]).

-export([init/1, apply/3, state_enter/2]).


run() ->
    ok = ra:start(),

    %% Create a cluster with 3 members.
    io:format("# create cluster~n"),
    Module = ?MODULE,
    Machine = {module, ?MODULE, #{}},
    Node = node(),
    ServerIds = [{repro_a, Node}, {repro_b, Node}, {repro_c, Node}],
    {ok, _ServersStarted, []} = ra:start_cluster(default, Module, Machine, ServerIds),
    ok = timer:sleep(5000),

    %% Assumes repro_c is the leader.
    {repro_c, Node} = maps:get(leader_id, element(2, ra:member_overview(repro_a))),

    %% Trigger an election that will cause the problem described in this issue.
    io:format("# trigger election~n"),
    ok = ra:trigger_election({repro_a, node()}),

    ok.


init(_) ->
    io:format("* [~p] init~n", [name()]),
    #{}.


apply(_Metadata, _Command, State) ->
    {State, ok}.


state_enter(RaState, _State) ->
    io:format("* [~p] state_enter: ~p~n", [name(), RaState]),
    [].


name() ->
    element(2, erlang:process_info(self(), registered_name)).
