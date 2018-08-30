#!/usr/bin/env node



var request = require('request');

	var serverHostname = 'localhost';
	var serverPort = process.env.PORTFORWARD_RCON;
	var serverPassword = process.env.PASSWORD;
   var servername = process.env.NAME;
   var wipedate = process.env.WIPED_TITLE;

  var WebSocket = require('ws');
	



setTimeout(function()
{
   var ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);
	ws.on('open', function open()
	{
		setTimeout(function()
		{
			ws.send(createPacket(wipedate));
        setTimeout(function()
			 {
				 ws.close(1000);
	      }, 1000 * 20);
		}, 1000);
	});
}, 1000 * 60 * 5);



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

