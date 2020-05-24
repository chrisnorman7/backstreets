# Backstreets

## Running the Application Locally

### Server

Run `./start.sh` from this directory to run the server. For running within an IDE, run `bin/main.dart`. By default, a configuration file named `config.yaml` will be used.

To generate a SwaggerUI client, run `aqueduct document client`.

### HTML and Static Files

Because the server only serves the websocket by default, everything else must be served separately. To this end, I've been using [webdev](https://dart.dev/tools/webdev):

```
cd client
webdev serve
```

### Run Everything

If you want to run everything in the server (without having to rely on `webdev serve`, then build the JavaScript first:

```
cd client
webdev build --no-release
```

Now a simple `./start.sh` will serve everything.

### Known Issues

For some reason, if you don't provide the `--no-release` flag to `webdev build`, you get an error when trying to activate things in menus:

```
Uncaught Concurrent modification during iteration: Instance of 'minified:al<minified:ad>'.
```

I've no idea why this happens, but the `--no-release` flag seems to keep things working fine for now.

### Docs

I also set up a route for doc/api, so if you build the docs using `dartdoc`, they come out at [/doc/api/](http://localhost:8888/doc/api/).

The trailing slash is obviously really important to aqueduct, and if it's not there you get a 404.

## Running Application Tests

To run all tests for this application, run the following in this directory:

```
pub run test
```

The default configuration file used when testing is `config.src.yaml`. This file should be checked into version control. It is also the template for configuration files used in deployment.

## Deploying an Application

See the documentation for [Deployment](https://aqueduct.io/docs/deploy/).
