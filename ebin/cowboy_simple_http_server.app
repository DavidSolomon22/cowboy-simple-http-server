{application, 'cowboy_simple_http_server', [
	{description, ""},
	{vsn, "rolling"},
	{modules, ['cowboy_simple_http_server_app','cowboy_simple_http_server_sup','main_handler']},
	{registered, [cowboy_simple_http_server_sup]},
	{applications, [kernel,stdlib,cowboy]},
	{mod, {cowboy_simple_http_server_app, []}},
	{env, []}
]}.