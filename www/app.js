const express = require('express');
var mongoose = require('mongoose');
const os = require('os');

let app = express();
let port = process.env.PORT || 8080;
let mongostring = process.env.MONGO || 'mongodb://localhost/cnvr';

// Connect to mongodb
mongoose.connect(mongostring);

let Alumno = mongoose.model('Alumno', {
	nombre: String,
	nota: Number
});

let defaultAlumnos = [
	{ nombre: 'José Ignacio Rojo Rivero', nota: 10.0 },
	{ nombre: 'Roberto Paterna Ferrón', nota: 10.0 },
	{ nombre: 'Juan Bermudo Mera', nota: 10.0 }
]

app.set('views', '.');
app.set('view engine', 'pug');

app.get('/', function (req, res) {

	Alumno.find({}, function(err, alumnos) {
		if (!alumnos.length) {
			defaultAlumnos.map( x => new Alumno(x) ).forEach( x => x.save() );
			alumnos = defaultAlumnos;
		}

		res.render('index', {
			hostname: os.hostname(),
			collection: JSON.stringify(alumnos, null, 4)
		});
	})
});

// Launch server
app.listen(port, function () {
	console.log('Started server listening on port ' + port);
});
