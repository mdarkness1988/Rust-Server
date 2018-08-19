#!/usr/bin/env node

var debug = false;

var child_process = require('child_process');

var startupDelayInSeconds = 60 * 5;
var runIntervalInSeconds = 60 * 5;

if (debug)
{
	startupDelayInSeconds = 1;
	runIntervalInSeconds = 60;
}

// Start the endless loop after a delay (allow the server to start)
setTimeout(function()
{
	checkForUpdates();
}, 1000 * startupDelayInSeconds);

function checkForUpdates()
{


//var name = process.env.RUST_SERVER_NAME;
//var today = new Date(); 
//var dd = today.getDate(); 
//var mm = today.getMonth()+1; 
//var yyyy = today.getFullYear(); 
//if(dd<10) { dd = '0'+dd } if(mm<10) { mm = '0'+mm } today = dd + '/' + mm; 
//document.write(today);

//var servername = name + ' | ' + today + ' |';


var serverHostname = 'localhost';
var serverPort = process.env.RUST_RCON_PORT;
var serverPassword = process.env.RUST_RCON_PASSWORD;

var WebSocket = require('ws');
var ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);

ws.on('open', function open()
	{

      ws.send(createPacket("say NOTICE: testing commands"));
      //ws.send(createPacket("server.hostname \"" + servername + "\""));
      

   }
	setTimeout(function()
	{

      
         ws.close(1000);

		if (debug) console.log("Running bash /update_check.sh");
		child_process.exec('bash /update_check.sh', { /*timeout: 60 * 1000,*/ env: process.env }, function (err, stdout, stderr)
		{
			if (debug) console.log("bash /update_check.sh STDOUT: " + stdout);
			if (debug && err) console.log("bash /update_check.sh ERR: " + err);
			if (debug && stderr) console.log("bash /update_check.sh STDERR: " + stderr);
			checkForUpdates();
		});		
	}, 1000 * runIntervalInSeconds);
}



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
