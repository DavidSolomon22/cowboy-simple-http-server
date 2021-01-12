-module(cowboy_simple_http_server_app).

-behaviour(application).

-export([start/2]).

-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([{'_',
                                       [{"/", main_handler, []}]}]),
    {ok, _} = cowboy:start_clear(my_http_listener,
                                 [{port, 8080}],
                                 #{env => #{dispatch => Dispatch}}),
    cowboy_simple_http_server_sup:start_link().

stop(_State) -> ok.
