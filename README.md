# arunpalliyath

## Arun Palliyath interview Project

Create a server application that users can treat as cloud backup.
The server understands 3 cmds, `post`, `get` and `list`.
Define and document the packet protocol for the same.

A light weight client application can be invoked from any client machine.
This should connect to the server and help perform the 3 operations listed above.

Both the server and client application needs to have unit tests (probably use googletest or anything of your choice).

Both server and client should not have any parameters hardcoded. If parameters are needed, they
should be defined part of a configuration file and source from it.

A top level makefile should exist, with below targets.
* make server
* make client
* make clean/clean_server/clean_client/
* make server_tests // should run unit test framework on server
* make client_tests // should run unit test framework on clients.

Proper documentation of server/client/unit test frameworks and how to run them are essential. You can edit this readme to add your own content like build instruction, dependencies to be installed and instruction to test and run the program.

---
This project contains a server application which can be treated as a cloud backup and a client application. Both client and server applications are developed using Erlang functional programming language. The server and client applications can be tested, build and started separately. 

## Prerequisites ##
A prior knowledge about erlang functional programming language would be benificial for better understanding of the project.

## Dependancy ##
Erlang is the only dependancy to build and run the application, so you should install Erlang in your personal computer before heading to start the application. You can get the  pre-built binary packages for OS X, Windows, Ubuntu, Debian, Fedora, CentOS, Raspbian and other operating systems from [here](https://www.erlang-solutions.com/resources/download.html). I personally suggest you to download erlang OTP version 18.0 or above.

# Build release #
The project can be cloned to your system by running the following command:
```
 $ git clone git@github.com/jega-msys/arunpalliyath.git

```
change directory to project directory:
```
   $ cd arunpalliyath
   
``` 
Run the following command to Build the server application:
```
   $ make server
   
``` 
Run the following command to start the server application:
```
   $./cloud_backup_server/_build/default/rel/cloud_backup_server/bin/cloud_backup_server console
   
``` 
 Run the following command to Build the client application:
```
   $ make client
   
```   
Run the following command to start the client application:
```
   $ ./cloud_backup_client/_build/default/rel/cloud_backup_client/bin/cloud_backup_client console
   
``` 

