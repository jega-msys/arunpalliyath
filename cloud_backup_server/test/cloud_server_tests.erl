%% -------------------------------------------------------------
%% 	Module contains test cases to test get, post and list
%%	Functionalities.
%% -------------------------------------------------------------
-module(cloud_server_tests).
-include_lib("eunit/include/eunit.hrl").


all_test_() ->
    {setup, fun setup/0, fun teardown/1,
     	[
			{timeout, 10, fun which_servers_internal/0}
		]}.

setup() ->
    ok = application:start(cloud_backup_server),

	application:set_env( cloud_backup_server, port_number, 5678),
	application:set_env( cloud_backup_server, target_folder_name, "./storage"),

	file:make_dir("./source"),
	file:write_file("./source/sample.txt", <<"hai....">>),
	file:make_dir("./storage").

teardown(_) ->
	io:format("tearing down"),
	file:del_dir("./storage"),
	file:del_dir("./source"),
	ok = application:stop(cloud_backup_server).


which_servers_internal() ->
    ?assertMatch("success",post("./source/sample.txt")).

post(File_location) ->
	
	{ok,Sock} = gen_tcp:connect("localhost",5678,[{active,false}, {packet,0}]),
	gen_tcp:send(Sock, "post"),
	timer:sleep(1000),
	File_name = lists:last(string:tokens(File_location, "/")),
	gen_tcp:send(Sock, File_name),
	timer:sleep(1000),
	file:sendfile(File_location, Sock), 
	{ok, Reply_from_server} = gen_tcp:recv(Sock,0),
	Reply_from_server.

    

