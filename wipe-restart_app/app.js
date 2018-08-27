#!/usr/bin/env node

var debug = false;

var request = require('request');
var timeout = (1000 * 60) * 30;
var isRestarting = false;


		    	

	isRestarting = true;

	var serverHostname = 'localhost';
	var serverPort = process.env.RUST_RCON_PORT;
	var serverPassword = process.env.RUST_RCON_PASSWORD;

	var WebSocket = require('ws');
	var ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);
	ws.on('open', function open()
	{
console.log("Rcon Connected...")
		setTimeout(function()
		{
			ws.send(JSON.stringify({command: 'test'}));
			setTimeout(function()
			{
				ws.send("say <color=red>NOTICE:</color> Server is wiping in <color=orange>4 minutes</color>, Need to hear them gun shots");
				setTimeout(function()
				{
					ws.send("say <color=red>NOTICE:</color> Server is wiping in <color=orange>3 minutes</color>");
					setTimeout(function()
					{
						ws.send("say <color=red>NOTICE:</color> Server is wiping in <color=orange>2 minutes</color>, Not long now");
						setTimeout(function()
						{
							ws.send("say <color=red>NOTICE:</color> Server is wiping in <color=orange>1 minute</color>, Goodbye world");
							setTimeout(function()
							{
								ws.send("global.kickall <color=orange>Wiping Server, Relog in 5 minutes</color>");
								setTimeout(function()
								{
									ws.send("quit");
									//ws.send(createPacket("restart 60")); // NOTE: Don't use restart, because that doesn't actually restart the container!
									setTimeout(function()
									{
										ws.close(1000);

										// After 2 minutes, if the server's still running, forcibly shut it down
										setTimeout(function()
										{
											var fs = require('fs');
											fs.unlinkSync('/tmp/wipe-restart_app.lock');

											var child_process = require('child_process');
											child_process.execSync('kill -s 2 $(pidof bash)');
										}, 1000 * 60 * 2);
									}, 1000);
								}, 1000);
							}, 1000 * 60);
						}, 1000 * 60);
					}, 1000 * 60);
				}, 1000 * 60);
			}, 1000 * 60);
		}, 1000);
	});


 function createPacket(command)
 {
	 var packet =
	{
		Identifier: -1,
	Message: command,
		// Name: "WebRcon"
	 };
	 return JSON.stringify(packet);
 }

