-module(main_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Headers = #{<<"content-type">> => <<"text/plain">>},
    try cowboy_req:match_qs([{a, [nonempty]},
                             {n, [nonempty, int, natural_number()]}],
                            Req0)
    of
        #{a := L, n := N} ->
            try string_to_term(binary_to_list(L)) of
                A ->
                    io:format("\n\nA: ~p\n\n", [A]),
                    ResBodyAtom = min_occurs(A, N),
                    ResBodyBin = atom_to_binary(ResBodyAtom),
                    Req = cowboy_req:reply(200,
                                           #{<<"content-type">> =>
                                                 <<"text/plain">>},
                                           ResBodyBin,
                                           Req0),
                    {ok, Req, State}
            catch
                _:_ ->
                    io:format("\n\nError\n\n"),
                    Req = cowboy_req:reply(400,
                                           #{<<"content-type">> =>
                                                 <<"text/plain">>},
                                           <<"Parameter 'a' must be a list. It can "
                                             "contain only atoms and numbers.">>,
                                           Req0),
                    {ok, Req, State}
            end
    catch
        _:{badkey, Field} ->
            ResBodyStr =
                io_lib:format("Paramater '~p' is required.", [Field]),
            ResBodyBin = list_to_binary(ResBodyStr),
            Req1 = cowboy_req:reply(400, Headers, ResBodyBin, Req0),
            {ok,
             Req1,
             State}        % _:{_, {_, #{n := {_, not_natural_number, X}}}, _} ->
                           %     X,
                           %     ResBodyStr =
                           %         io_lib:format("Parameter 'n' must be a natural number."),
                           %     ResBodyBin = list_to_binary(ResBodyStr),
                           %     Req2 = cowboy_req:reply(400,
                           %                             #{<<"content-type">> => <<"text/plain">>},
                           %                             ResBodyBin,
                           %                             Req0),
                           %     {ok, Req2, State}
    end.

string_to_term(S) ->
    {ok, Tokens, _EndLine} = erl_scan:string(S ++ "."),
    {ok, Term} = erl_parse:parse_term(Tokens),
    Term.

min_occurs(_, 0) -> true;
min_occurs([], N) when N > 0 -> false;
min_occurs(A, N) ->
    CountedElements = count_elements(A),
    lists:all(fun ({Occ, _}) -> Occ >= N end,
              CountedElements).

count_elements(A) ->
    SortedList = lists:sort(A),
    count_elements(SortedList, []).

count_elements([], Acc) -> lists:reverse(Acc);
count_elements([H | T], [{Count, H} | Acc]) ->
    count_elements(T, [{Count + 1, H} | Acc]);
count_elements([H | T], Acc) ->
    count_elements(T, [{1, H} | Acc]).

natural_number() ->
    fun (_, V) when V >= 0 -> {ok, V};
        (_, _) -> {error, not_natural_number}
    end.
