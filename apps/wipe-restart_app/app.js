#!/usr/bin/env node


var request = require('request');
var isRestarting = true;

	var serverHostname = 'localhost';
	var serverPort = process.env.PORTFORWARD_RCON;
	var serverPassword = process.env.PASSWORD;

  var WebSocket = require('ws');
	var ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);
	ws.on('open', function open()
	{
		setTimeout(function()
		{
			ws.send(createPacket("say <color=red>NOTICE:</color> Server is wiping in <color=orange>5 minutes</color>, Let the killing begin"));
        console.log("5 minutes reminder sent")
			setTimeout(function()
			{
				ws.send(createPacket("say <color=red>NOTICE:</color> Server is wiping in <color=orange>4 minutes</color>, Need to hear them gun shots"));
          console.log("4 minutes reminder sent")
				setTimeout(function()
				{
					ws.send(createPacket("say <color=red>NOTICE:</color> Server is wiping in <color=orange>3 minutes</color>"));
          console.log("3 minutes reminder sent")
					setTimeout(function()
					{
						ws.send(createPacket("say <color=red>NOTICE:</color> Server is wiping in <color=orange>2 minutes</color>, Not long now"));
          console.log("2 minutes reminder sent")
						setTimeout(function()
						{
							ws.send(createPacket("say <color=red>NOTICE:</color> Server is wiping in <color=orange>1 minute</color>, Goodbye world"));
          console.log("1 minutes reminder sent")
							setTimeout(function()
							{
								ws.send(createPacket("global.kickall <color=orange>Wiping Server, Relog in 5 minutes</color>"));
								setTimeout(function()
								{
									ws.send(createPacket("quit"));
									//ws.send(createPacket("restart 60")); // NOTE: Don't use restart, because that doesn't actually restart the container!
									setTimeout(function()
									{
										ws.close(1000);
                         isRestarting = false;
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
    Name: "WebRcon"
	 };
	 return JSON.stringify(packet);
 }






