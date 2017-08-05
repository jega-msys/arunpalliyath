%% ====================================================================
%% 	Module contains functions which provides get, post and list
%%	Functionalities.
%% ====================================================================
-module(cloud_server).

%% ====================================================================
%% Exported Functions
%% ====================================================================
-export([ 	
			start_link/0, 
			server_process/0
		]).

%% -------------------------------------------------------------
%% 	This function is called by application supervisor and it starts
%%	the cloud backup server process.
%%
%%	Function has no argument
%%
%%	Function returns : { ok, process-id of cloud backup server }
%% -------------------------------------------------------------

start_link() ->

	Pid = erlang:spawn_link(?MODULE, server_process, []),
	{ ok, Pid }.

%% -------------------------------------------------------------
%% 	
%%
%%	Function has no argument
%%
%%	Function returns : { ok, process-id of cloud backup server }
%% -------------------------------------------------------------

server_process() ->

	case application:get_env( cloud_backup_server, port_number) of
	
		undefined ->
			%io:format(" Connection Port is not available~n"),
			server_process();

		{ ok, Port} ->
			io:format(" Connection Port ~p~n",[Port]),
			{ok, Listening_socket} = gen_tcp:listen(Port, [list, {packet, 0}, {active, false}]),

			wait_for_request( Listening_socket )
	end.

%% -------------------------------------------------------------
%% 	
%%
%%	Function has no argument
%%
%%	Function returns : { ok, process-id of cloud backup server }
%% -------------------------------------------------------------

wait_for_request( Listening_socket ) ->

	case gen_tcp:accept(Listening_socket) of
		{ok, Socket} ->
			tcp_message_receive_loop(Socket),
			wait_for_request( Listening_socket );

		{error, Reason} ->
			io:format(" Connection failed because ~p~n",[Reason]),
			wait_for_request( Listening_socket )
	end.

%% -------------------------------------------------------------
%% 	
%%
%%
%% -------------------------------------------------------------

tcp_message_receive_loop(Socket) ->

    inet:setopts(Socket,[{active,once}]),

    receive
		{tcp,Socket,"post"} ->

			io:format("post Message is received ~n"),

			inet:setopts(Socket,[{active,false}]),
            receive_file_name_and_data( Socket ),

			gen_tcp:send(Socket, "success"),

			tcp_message_receive_loop(Socket);

        {tcp_closed,Socket} ->
            io:format("Socket ~w closed [~w]~n",[Socket,self()]),
            ok;

		Any ->
			io:format("Unknown Message is received ~p~n",[Any])
    end.

%% -------------------------------------------------------------
%% 	
%%
%%	
%% -------------------------------------------------------------

receive_file_name_and_data( Socket ) ->

	case gen_tcp:recv(Socket, 0) of
		{ok, File_name} ->
			io:format("File_name ~p ~n",[File_name]),
			case gen_tcp:recv(Socket, 0) of
				{ok, Data_to_write_into_file} ->
					io:format("Data_to_write_into_file ~p ~n",[Data_to_write_into_file]),
					save_file(Data_to_write_into_file, File_name );

				{error, closed} ->
					io:format("Socket ~w closed [~w]~n",[Socket,self()]),
					ok
			end;

		{error, closed} ->
			io:format("Socket ~w closed [~w]~n",[Socket,self()]),
    		ok
	end.

%% -------------------------------------------------------------
%% 	
%%
%%	
%% -------------------------------------------------------------
save_file(Data_to_write_into_file, File_name ) ->

	case application:get_env( cloud_backup_server, target_folder_name) of
	
		undefined ->
			io:format("~n Set target folder name in VM.args file~n");

		{ ok, Target_folder_name} ->
			io:format("~n Filename: ~p~p~n",[ Target_folder_name, File_name ]),
			{ok, Fd} = file:open(Target_folder_name++"/"++File_name, write),
			file:write(Fd, Data_to_write_into_file),
			file:close(Fd)
	end.

