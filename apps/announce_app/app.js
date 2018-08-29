#!/usr/bin/env node


var request = require('request');


	var serverHostname = 'localhost';
	var serverPort = process.env.PORTFORWARD_RCON;
	var serverPassword = process.env.PASSWORD;
   var announce1_ = process.env.ANNOUNCE1;
   var announce2_ = process.env.ANNOUNCE2;
   var announce3_ = process.env.ANNOUNCE3;
   var announce4_ = process.env.ANNOUNCE4;
   var announce5_ = process.env.ANNOUNCE5;
   var delaytime = process.env.ANNOUNCE_DELAY;
   var myVar1 = setTimeout(connection, 1000 * 60 * 7);
   var myVar = setTimeout(myTimer, 1000 * 60 * 9);


  var WebSocket = require('ws');
	var ws = "";


function connection()
{
  ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);
}



function myTimer()
{
       if (announce1_)
       {
			  ws.send(createPacket("say " + announce1_));
          console.log("Sent Announcement: (" + announce1_ + ")")
	   		setTimeout(function()
			  {
            if (announce2_)
            {
			    	  ws.send(createPacket("say " + announce2_));
              console.log("Sent Announcement: (" + announce2_ + ")")
			   	  setTimeout(function()
				    {
                if (announce3_)
                {
					      ws.send(createPacket("say " + announce3_));
                  console.log("Sent Announcement: (" + announce3_ + ")")
					      setTimeout(function()
					      {
                     if (announce4_)
                    {
						       ws.send(createPacket("say " + announce4_));
                      console.log("Sent Announcement: (" + announce4_ + ")")
				            setTimeout(function()
						       {
                        if (announce5_)
                        {
							         ws.send(createPacket("say " + announce5_));
                           console.log("Sent Announcement: (" + announce5_ + ")")
		                     setTimeout(function()
						           {
                            setTimeout(myTimer);
                          }, 1000 * 5);
						         }
                       else
                       {
                         setTimeout(myTimer);
                       }
						      }, 1000 * 60 * delaytime);
                   }
                   else
                  {
                    setTimeout(myTimer);
                  }
                }, 1000 * 60 * delaytime);
              }
              else
             {
               setTimeout(myTimer);
             }
				 }, 1000 * 60 * delaytime);
         }
         else
         {
           setTimeout(myTimer);
         }
       }, 1000 * 60 * delaytime);
     }
     else
    {
      console.log("ERROR: Announce1 has no data. please enter data from announce1-5 in order")
      console.log("Announcement has stopped")
      ws.close(1000);
    }
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


