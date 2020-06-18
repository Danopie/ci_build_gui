var Http = require('http');
const { exec, spawn } = require("child_process");
var Uri = require('url');

//create a server object:
Http.createServer(function (req, res) {
    res.setHeader("Access-Control-Allow-Origin","*");
    res.setHeader("Access-Control-Allow-Headers","*");
    var reqData = Uri.parse(req.url, true);
    var params = reqData.query;
    console.log(`Request: ${req.url}`);

    if (reqData.path.startsWith("/exec")) {
        var cmd = params.cmd;
        if (cmd == null) {
            var message = "error: cmd is null";
            console.log(message);
            res.write(message);
            res.end();
        } else {
            console.log(`cmd: ${cmd}`);
            console.log(`PATH: ${process.env.PATH}`);

            var child = spawn(cmd, [], {shell: true});
            child.stdout.on('data',
                function (data) {
                    res.write(`${data}`);
                });
            child.stderr.on('data', function (data) {
                res.write(`error: ${data}`);
            });
            child.on('close', function (code) {
                res.write('child process exited with code ' + code);
                res.end();
            });


            /*exec(cmd, (error, stdout, stderr) => {
                if (error) {
                    console.log(`error: ${error.message}`);
                    res.write(`error: ${error.message}`);
                    res.end();
                    return;
                }
                if (stderr) {
                    console.log(`stderr: ${stderr}`);
                    res.write(`error: ${stderr}`);
                    res.end();
                    return;
                }
                console.log(`stdout: ${stdout}`);
                res.write(`data: ${stdout}`); //write a response to the client
                res.end(); //end the response
            });*/
        }

    } else if (reqData.path.startsWith("/stop")) {
        exec("exit 0", (error, stdout, stderr) => {
            if (error) {
                console.log(`error: ${error.message}`);
                res.write(`error: ${error.message}`);
                res.end();
                return;
            }
            if (stderr) {
                console.log(`stderr: ${stderr}`);
                res.write(`error: ${stderr}`);
                res.end();
                return;
            }
            console.log(`stdout: ${stdout}`);
            res.write(`data: ${stdout}`); //write a response to the client
            res.end(); //end the response
        });
    }
}).listen(8080);