const { exec, spawn, execFile } = require("child_process");
var Http = require('http');
var Uri = require('url');
const ADDRESS = '127.0.0.1';
const PORT = 8080;
const WebSocket = require('ws');
let _server = new WebSocket.Server(
    {
        port: PORT,
        address: ADDRESS,
    }
);
_server.on('connection', function connection(socket) {
    console.log(`A client is connected`);
    socket.send(JSON.stringify({
        'code': CODE_OK,
        'log': "Connected successfully!",
        'clientCount': _server.clients.size,
        'busy': _processing
    }));
    // message listener from server 
    socket.on('message', function (message) {
        let receivedMessage = `onMessage: ${message}`;
        console.log(receivedMessage);
        onHandleClientMessage(socket, message);
    });
});

var _processing = false;
var _pendingClientMessages = [];

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
            if (_processing == true || _pendingClientMessages.length > 0) {
                _pendingClientMessages.push(message);
                socket.send(JSON.stringify({
                    'code': CODE_ERROR,
                    'message': "Sắp ra rồi! Anh đợi em xíu nha!"
                }));
                return;
            }

            _processing = true;
            let _arrays = cmd.split(" ");
            let _command = _arrays.shift();
            var child = spawn(_command, _arrays);
            child.stdout.on('data', function (data) {
                onSpawn(data, socket, clientObj);
            });
            child.stderr.on('data', function (data) {
                onSpawn(data, socket, clientObj);
            });
            child.on('close', function (code) {
                _processing = false;
                let closeMessage = `onSpawnClose: child process exited with code ${code}`;
                console.log(closeMessage);
                socket.send(JSON.stringify({
                    'code': CODE_OK,
                    'request': clientObj,
                    'log': closeMessage,
                    'clientCount': _server.clients.size,
                    'busy': _processing
                }));

                if (_pendingClientMessages.length > 0) {
                    console.log("handle next pending message.");
                    socket.send(JSON.stringify({
                        'code': CODE_OK,
                        'message': "Mời anh tiếp theo ạ"
                    }));
                    onHandleClientMessage(socket, _pendingClientMessages.shift());
                    return;
                }else{
                    stopProcess(socket, clientObj);
                }
            });
        }
    } else if (clientObj.type == TYPE_STOP) {
        stopProcess(socket, clientObj);
    }
}

function stopProcess(socket, clientObj) {
    _processing = true;
    exec("exit 0", (error, stdout, stderr) => {
        _processing = false;
        socket.send(JSON.stringify({
            'code': CODE_OK,
            'type': TYPE_STOP,
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

function onSpawn(data, socket, clientObj) {
    console.log(`onSpawn: ${data}`);
    _server.clients.forEach(cl => {
        cl.send(JSON.stringify({
            'code': CODE_OK,
            'request': clientObj,
            'log': data.toString(),
            'clientCount': _server.clients.size,
            'busy': _processing
        }));
    });
}