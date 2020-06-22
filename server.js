const { exec, spawn, execFile } = require("child_process");
var Http = require('http');
var Uri = require('url');
const ADDRESS = '127.0.0.1';
const PORT = 8080;
var _processing = false;
var _pendingClientMessages = [];
const CODE_OK = 1;
const CODE_ERROR = 0;
const TYPE_EXEC = "exec";
const TYPE_STOP = "stop";
const TYPE_BUSY = "busy";
var _grantedPermissionCommands = [];

const WebSocket = require('ws');
let _server = new WebSocket.Server(
    {
        port: PORT,
        address: ADDRESS,
    }
);

function generateServerState(clientCount, connected, error) {
    return {
        'clientCount': clientCount,
        'connected': connected,
        'error': error
    };
}

function generateServerMessage(serverState, clientMessage, code, message, data) {
    return {
        'state': serverState,
        'from': clientMessage,
        'code': code,
        'message': message,
        'data': data
    };
}

_server.on('connection', function connection(socket) {
    console.log(`A client is connected`);

    if (_processing == true) {
        socket.send(JSON.stringify(generateServerMessage(
            generateServerState(
                _server.clients.size,
                true,
                null),
            clientMessage,
            CODE_OK,
            "Sắp ra rồi! Anh đợi em xíu nha!",
            {
                'type': TYPE_BUSY
            })));
        return;
    } else {
        socket.send(JSON.stringify(generateServerMessage(
            generateServerState(
                _server.clients.size,
                true,
                null),
            null,
            CODE_OK,
            null,
            null)));
    }

    // message listener from server 
    socket.on('message', function (message) {
        let receivedMessage = `onMessage: ${message}`;
        console.log(receivedMessage);
        onHandleClientMessage(socket, message);
    });
});

function onHandleClientMessage(socket, message) {
    let clientMessage = JSON.parse(message);

    if (clientMessage.type == TYPE_EXEC) {
        let cmd = clientMessage.data.cmd;
        if (cmd == null || cmd == '') {
            let errorMessage = "cmd is empty";
            console.log(errorMessage);
            socket.send(JSON.stringify(generateServerMessage(
                generateServerState(
                    _server.clients.size,
                    true,
                    null),
                clientMessage,
                CODE_ERROR,
                errorMessage,
                null)));
        } else {
            if (_processing == true) {
                _pendingClientMessages.push(message);
                socket.send(JSON.stringify(generateServerMessage(
                    generateServerState(
                        _server.clients.size,
                        true,
                        null),
                    clientMessage,
                    CODE_OK,
                    "Sắp ra rồi! Anh đợi em xíu nha!",
                    {
                        'type': TYPE_BUSY
                    })));
                return;
            }

            _processing = true;
            let _arrays = cmd.split(" ");
            let _command = _arrays.shift();


            if (_grantedPermissionCommands.includes(_command) == false) {
                exec(`chmod +x ${_command}`);
                _grantedPermissionCommands.push(_command);
            }

            var child = spawn(_command, _arrays);
            child.stdout.on('data', function (data) {
                onSpawn(data, socket, clientMessage);
            });
            child.stderr.on('data', function (data) {
                onSpawn(data, socket, clientMessage);
            });
            child.on('close', function (code) {
                _processing = false;
                let closeMessage = `onSpawnClose: child process exited with code ${code}`;
                console.log(closeMessage);

                if (_pendingClientMessages.length > 0) {
                    console.log("handle next pending message.");
                    let nextMessage = _pendingClientMessages.shift();
                    socket.send(JSON.stringify(generateServerMessage(
                        generateServerState(
                            _server.clients.size,
                            true,
                            null),
                        clientMessage,
                        CODE_OK,
                        `Em đang ấy với anh ${nextMessage.data.cmd}`,
                        {
                            'type': TYPE_BUSY
                        })));
                    onHandleClientMessage(socket, nextMessage);
                    return;
                } else {
                    socket.send(JSON.stringify(generateServerMessage(
                        generateServerState(
                            _server.clients.size,
                            true,
                            null),
                        clientMessage,
                        CODE_OK,
                        `Ư ư ư ư.... Tuyệt quá!`,
                        null)));
                }
            });
        }
    } else if (clientMessage.type == TYPE_STOP) {
        stopProcess(socket, clientMessage);
    }
}

function stopProcess(socket, clientMessage) {
    _processing = true;
    _pendingClientMessages = [];
    exec("exit 0 && killall dart -9", (error, stdout, stderr) => {
        _processing = false;
        socket.send(JSON.stringify(generateServerMessage(
            generateServerState(
                _server.clients.size,
                true,
                null),
            clientMessage,
            CODE_OK,
            `Ư ư ư ư ... tụt hứng quá!`,
            null)));
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

function onSpawn(data, socket, clientMessage) {
    console.log(`onSpawn: ${data}`);
    _server.clients.forEach(cl => {
        cl.send(JSON.stringify(generateServerMessage(
            generateServerState(
                _server.clients.size,
                true,
                null),
            clientMessage,
            CODE_OK,
            null,
            {
                'type': TYPE_BUSY,
                'log': data.toString()
            })));
    });
}