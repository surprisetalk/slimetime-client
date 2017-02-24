
# SLIMETIME

It's [slimetime](https://slimeti.me) every hour.


## SERVER

The server is over [here](https://github.com/bestestdev/slimetime-server).


## CLIENT

### /IMG

These are all the images featured in the game.

If you want to submit an image, please do a pull-request or email tsarrafian@sophware.io. Please use `/images/squid/squid.png`, `/images/toad/toad.png`, `/images/duck/duck.png` as templates. If we like it, we'll feature it in the game!

### /MAP

These are the `.geo.json` files from which we draw the borders.

Thanks to [geojson-maps](https://geojson-maps.ash.ms/) for the great map data.

### /DIST

We put the compiled html/css files here.

### /SRC

We love [elm](https://elm-lang.org).

```bash

# pull the repo
git clone https://github.com/surprisetalk/slimetime-client.git
cd slimetime-client

# install elm & http-server
npm install -g elm http-server

# compile the elm files into javascript
elm install
elm make src/Client.elm --output=dist/slimetime.js

# run the server, then head to http://localhost:8080
http-server

````


## TODOS

- port to unity
