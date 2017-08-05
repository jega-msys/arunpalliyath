%% -------------------------------------------------------------
%% 	Module contains client functions to access get, post and list
%%	Functionalities offered by server
%% -------------------------------------------------------------
-module(cloud_client).
-export([get/2, post/1, list/0]).

post( File_location ) ->

	List_of_environment_variables = application:get_all_env(cloud_backup_client),
	
	{ port_number, Port} = lists:keyfind( port_number, 1, List_of_environment_variables),
	{ ip_address, IP_address} = lists:keyfind( ip_address, 1, List_of_environment_variables),

    	case gen_tcp:connect(IP_address,Port,[{active,false}, {packet,0}]) of

		{ok,Socket} ->
			gen_tcp:send(Socket, "post"),
			timer:sleep(1000),
			File_name = lists:last(string:tokens(File_location, "/")),
			gen_tcp:send(Socket, File_name),

			Ret=file:sendfile(File_location, Socket), 
			io:format("result ~p ~n", [ Ret ]),

			{ok, Return} = gen_tcp:recv(Socket,0),
			io:format("~n Acknowledgement: ~p ~n", [Return]),

		    	gen_tcp:close(Socket);

		{ error, Reason } ->
			io:format("~n Failed to connect to port:~p Because of:~p ~n", [Port, Reason]),
			{ error, Reason }
	end.


get( File_name, Location_to_download ) ->

	List_of_environment_variables = application:get_all_env(cloud_backup_client),
	
	{ port_number, Port} = lists:keyfind( port_number, 1, List_of_environment_variables),
	{ ip_address, IP_address} = lists:keyfind( ip_address, 1, List_of_environment_variables),

    	case gen_tcp:connect(IP_address,Port,[{active,false}, {packet,0}]) of

		{ok,Socket} ->

			gen_tcp:send(Socket, "get" ),
			timer:sleep(1000),
			gen_tcp:send(Socket, File_name ),

			{ok, Data_to_write_into_file} = gen_tcp:recv(Socket,0),

			io:format("~nFilename: ~p ~n", [Location_to_download++File_name]),
			{ok, Fd} = file:open(Location_to_download++File_name, write),
			file:write(Fd, Data_to_write_into_file),
			file:close(Fd),

		    	gen_tcp:close(Socket);

		{ error, Reason } ->
			io:format("~n Failed to connect to port:~p Because of:~p ~n", [Port, Reason]),
			{ error, Reason }
	end.

list() ->

	List_of_environment_variables = application:get_all_env(cloud_backup_client),
	
	{ port_number, Port} = lists:keyfind( port_number, 1, List_of_environment_variables),
	{ ip_address, IP_address} = lists:keyfind( ip_address, 1, List_of_environment_variables),

	io:format("~n Port number:~p, IP address:~p ~n", [Port, IP_address]),

    	case gen_tcp:connect(IP_address,Port,[{active,false}, {packet,0}]) of

		{ok,Socket} ->
			gen_tcp:send(Socket, "list" ),
			{ok, List_of_file_names} = gen_tcp:recv(Socket,0),
			io:format("~n List of Filename: ~p ~n", [string:tokens(List_of_file_names,",")]),

    			gen_tcp:close(Socket);

		{ error, Reason } ->
			io:format("~n Failed to connect to port:~p Because of:~p ~n", [Port, Reason]),
			{ error, Reason }
	end.

