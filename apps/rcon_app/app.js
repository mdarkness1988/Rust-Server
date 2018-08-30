#!/usr/bin/env node

var argumentString = "";
var args = process.argv.splice(process.execArgv.length + 2);
for (var i = 0; i < args.length; i++)
{
	if (i == args.length - 1) argumentString += args[i];
	else argumentString += args[i] + " "
}

if (argumentString.length < 1)
{
	console.log("Error: Please specify an RCON command");
	process.exit();
}

console.log("Relaying RCON command: " + argumentString);

var serverHostname = 'localhost';
var serverPort = process.env.PORTFORWARD_RCON;
var serverPassword = process.env.PASSWORD;

var messageSent = false;
var WebSocket = require('ws');
var ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);
ws.on('open', function open()
{
consol.log("Rcon Connected to" + serverHostname + ":" + serverPort + "/" + serverPassword)
	setTimeout(function()
	{
		messageSent = true;
		ws.send(createPacket(argumentString));
		setTimeout(function()
		{
			ws.close(1000);
			setTimeout(function()
			{
				console.log("Command relayed");
				process.exit();
			});
		}, 1000);
	}, 250);
});

ws.on('close', function close()
{
  console.log("Rcon Connection Closed")
});


ws.on('message', function(data, flags)
{
	if (!messageSent) return;
consol.log("Message not sent")
	try
	{
		var json = JSON.parse(data);
		if (json !== undefined)
		{
			if (json.Message !== undefined && json.Message.length > 0)
			{
				console.log(json.Message);
			}
		}
		else console.log("Error: Invalid JSON received");
	}
	catch(e)
	{
		if (e) console.log(e);
	}
});
ws.on('error', function(e)
{
console.log("Connection Error")
	console.log(e);
	process.exit();
});

function createPacket(command)
{
	var packet =
	{
		Identifier: -1,
		Message: command,
		Name: "WebRcon"
	};
	return JSON.stringify(packet);
}
