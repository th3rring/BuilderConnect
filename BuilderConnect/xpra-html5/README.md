# HTML5 client for Xpra

Simply point your browser to the contents of the `html5` folder,
and you will get an HTML5 client which you can use to connect to
any [xpra](https://github.com/Xpra-org/xpra) server.

This client is usually packaged as `xpra-html5`
and the xpra server will normally pick it up automatically
so that you can access it using the builtin web server.


# Installation
```
git clone https://github.com/Xpra-org/xpra-html5
python3 ./setup.py install /usr/share/www/xpra
```
To install with Nginx or Apache, you may need to change the installation path to something like `/var/www/html/`.


# Usage
Simply start an xpra session on a specific `TCP` port (ie: `10000`):
```
xpra start --start=xterm --bind-tcp=0.0.0.0:10000
```
Then you can access this session with your browser by pointing it to that port. ie locally:
```
xdg-open http://localhost:10000/
```
For more information on xpra server options, please refer to the [xpra project](https://github.com/Xpra-org/xpra).


# Configuration
Most common HTML5 client options can be specified from the connect dialog
form, which is found at `/connect.html`.\
Failures to connect to a server from the default page should redirect to that dialog page automatically.

All of the options can also be specified as URL parameters. ie:
```
http://localhost:10000/?username=foo&keyboard_layout=fr
```
For a more complete list of options, see [configuration options](./docs/Configuration.md)

# Compatibility
This client is compatible with any [currently supported version](https://github.com/Xpra-org/xpra/wiki/Versions) of xpra.
