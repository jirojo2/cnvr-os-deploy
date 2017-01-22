const express = require('express');
const os = require('os');

let app = express();
let port = process.env.PORT || 8080;

app.get('/', function (req, res) {
	res.send(os.hostname());
});

app.listen(port, function () {
	console.log('Started server listening on port ' + port);
});
