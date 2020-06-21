const { exec, spawn } = require("child_process");

var Http = require('http');
var Uri = require('url');

//create a server object:
// Http.createServer(function (req, res) {
//     res.setHeader("Access-Control-Allow-Origin","*");
//     res.setHeader("Access-Control-Allow-Headers","*");
//     var reqData = Uri.parse(req.url, true);
//     var params = reqData.query;
//     console.log(`Request: ${req.url}`);

//     if (reqData.path.startsWith("/exec")) {
//         var cmd = params.cmd;
//         if (cmd == null) {
//             var message = "error: cmd is null";
//             console.log(message);
//             res.write(message);
//             res.end();
//         } else {
//             console.log(`cmd: ${cmd}`);
//             console.log(`PATH: ${process.env.PATH}`);

// /*
//             var child = spawn(cmd, [], {shell: true});
//             child.stdout.on('data',
//                 function (data) {
//                     res.write(`${data}`);
//                 });
//             child.stderr.on('data', function (data) {
//                 res.write(`error: ${data}`);
//             });
//             child.on('close', function (code) {
//                 res.write('child process exited with code ' + code);
//                 res.end();
//             });
// */

//             exec(cmd, (error, stdout, stderr) => {
//                 if (error) {
//                     console.log(`error: ${error.message}`);
//                     res.write(`error: ${error.message}`);
//                     res.end();
//                     return;
//                 }
//                 if (stderr) {
//                     console.log(`stderr: ${stderr}`);
//                     res.write(`error: ${stderr}`);
//                     res.end();
//                     return;
//                 }
// //                console.log(`stdout: ${stdout}`);
//                 res.write(`successfully`); //write a response to the client
//                 res.end(); //end the response
//             });
//         }
//     } else if (reqData.path.startsWith("/stop")) {
//         exec("exit 0", (error, stdout, stderr) => {
//             if (error) {
//                 console.log(`error: ${error.message}`);
//                 res.write(`error: ${error.message}`);
//                 res.end();
//                 return;
//             }
//             if (stderr) {
//                 console.log(`stderr: ${stderr}`);
//                 res.write(`error: ${stderr}`);
//                 res.end();
//                 return;
//             }
//             console.log(`stdout: ${stdout}`);
//             res.write(`data: ${stdout}`); //write a response to the client
//             res.end(); //end the response
//         });
//     }
//      /*else if (reqData.path.startsWith("/log")) {
//              const filePath =  "/Volumes/data/Workspace/sendo/dev/local_buyer_mobile/log.txt" // or any file format

//                // Check if file specified by the filePath exists
//                fs.exists(filePath, function(exists){
//                    if (exists) {
//                      // Content-type is very interesting part that guarantee that
//                      // Web browser will handle response in an appropriate manner.
//                      response.writeHead(200, {
//                        "Content-Type": "application/octet-stream",
//                        "Content-Disposition": "attachment; filename=" + fileName
//                      });
//                      fs.createReadStream(filePath).pipe(res);
//                    } else {
//                      res.writeHead(400, {"Content-Type": "text/plain"});
//                      res.end("ERROR File does not exist");
//                    }
//                  });
//                }*/
// }).listen(8080);

const ADDRESS = '127.0.0.1';
const PORT = 8080;
const WebSocket = require('ws');
let _server = new WebSocket.Server(
    {
        port: PORT,
        address: ADDRESS,
    }
);
_server.on('connection', function connection(socket, request) {
    console.log(`A client is connected`);
    _server.on('message', function incoming(socket, message) {
        let receivedMessage = `Received from client: ${message}`;
        console.log(receivedMessage);

        onHandleClientMessage(socket, message);

        //   for(var cl of server.clients) {
        //     cl.send(message);
        //   }
        //   console.log("Received the following message:\n" + message);
    });
});

const CODE_OK = 1;
const CODE_ERROR = 0;
const TYPE_EXEC = "exec";
const TYPE_STOP = "stop";

function onHandleClientMessage(socket, message) {
    let clientObj = JSON.parse(message);

    if (clientObj.type == TYPE_EXEC) {
        let cmd = clientObj.cmd;
        if (cmd == null || cmd == '') {
            let errorMessage = "cmd is empty";
            console.log(errorMessage);
            socket.send(JSON.stringify({
                'code': CODE_ERROR,
                'message': errorMessage
            }));
        } else {
            var child = spawn(cmd, [], { shell: true });
            child.stdout.on('data',
                function (data) {
                    console.log(`onSpawnData: ${data}`);
                    socket.send(JSON.stringify({
                        'code': CODE_OK,
                        'request': clientObj,
                        'log': data
                    }));
                });
            child.stderr.on('data', function (data) {
                console.log(`onSpawnError: ${data}`);
                socket.send(JSON.stringify({
                    'code': CODE_ERROR,
                    'request': clientObj,
                    'log': data
                }));
            });
            child.on('close', function (code) {
                let closeMessage = `onSpawnClose: child process exited with code ${code}`;
                console.log(closeMessage);
                socket.send(JSON.stringify({
                    'code': CODE_OK,
                    'request': clientObj,
                    'log': closeMessage
                }));
            });
        }
    } else if (clientObj.type == TYPE_STOP) {
        exec("exit 0", (error, stdout, stderr) => {
            socket.send(JSON.stringify({
                'code': CODE_OK,
                'request': clientObj
            }));
            if (error) {
                console.log(`onStopError: ${error.message}`);
                return;
            }
            if (stderr) {
                console.log(`onStopError: ${stderr}`);
                return;
            }
            console.log(`onStopOk: ${stdout}`);
        });
    }
}