
# SLIMETIME

It's [slimetime](https://slimeti.me) every hour.


## SERVER

The server is over [here](https://github.com/bestestdev/slimetime-server).


## CLIENT

### /IMG

These are all the images featured in the game.

If you want to submit an image, please do a pull-request or email tsarrafian@sophware.io. Please use `/images/squid/squid.png`, `/images/toad/toad.png`, `/images/duck/duck.png` as templates. If we like it, we'll feature it in the game!

### /DIST

We put the compiled html/css files here.

### /SRC

We love [elm](https://elm-lang.org).

```bash

# compile the client
git pull https://github.com/surprisetalk/slimetime-client.git
cd slimetime-client
npm install -g elm
elm install
elm make src/Client.elm --output=dist/slimetime.js

````


## TODOS

- port to unity
