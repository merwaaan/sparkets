(function() {
  var Bullet, Planet, Ship, bullets, centerView, color, ctxt, distance, drawInfinity, drawRadar, explosions, go, id, inView, info, interp_factor, interpolate, lastUpdate, log, map, maxExploFrame, maxPower, mod, onConnect, onDisconnect, onMessage, planetColor, planets, port, redraw, screen, serverShips, ships, socket, update, view, warn;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Bullet = (function() {
    function Bullet(bullet) {
      this.owner = bullet.owner;
      this.pos = bullet.pos;
      this.accel = bullet.accel;
      this.power = bullet.power;
      this.dead = bullet.dead;
      this.color = bullet.color;
      this.points = bullet.points;
    }
    Bullet.prototype.draw = function(ctxt, alpha, offset) {
      var i, ox, oy, p, x, y, _ref, _ref2, _ref3;
      if (offset == null) {
        offset = {
          x: 0,
          y: 0
        };
      }
      p = this.points;
      ox = -view.x + offset.x;
      oy = -view.y + offset.y;
      x = p[0][0] + ox;
      y = p[0][1] + oy;
      ctxt.strokeStyle = color(this.color, alpha);
      ctxt.beginPath();
      ctxt.moveTo(x, y);
      for (i = 1, _ref = p.length; 1 <= _ref ? i < _ref : i > _ref; 1 <= _ref ? i++ : i--) {
        x = p[i][0] + ox;
        y = p[i][1] + oy;
        if ((-50 < (_ref2 = p[i - 1][0] - p[i][0]) && _ref2 < 50) && (-50 < (_ref3 = p[i - 1][1] - p[i][1]) && _ref3 < 50)) {
          ctxt.lineTo(x, y);
        } else {
          ctxt.stroke();
          ctxt.beginPath();
          ctxt.moveTo(x, y);
        }
      }
      return ctxt.stroke();
    };
    return Bullet;
  })();
  port = 12345;
  socket = {};
  ctxt = null;
  screen = {
    w: 0,
    h: 0
  };
  map = {
    w: 2000,
    h: 2000
  };
  view = {
    x: 0,
    y: 0
  };
  planetColor = '127, 157, 185';
  maxPower = 3;
  maxExploFrame = 50;
  id = null;
  ships = {};
  serverShips = {};
  explosions = {};
  planets = [];
  bullets = [];
  interp_factor = .03;
  lastUpdate = 0;
  $(document).ready(function(event) {
    socket = new io.Socket(null, {
      port: port
    });
    socket.connect();
    socket.on('message', onMessage);
    socket.on('connect', onConnect);
    socket.on('disconnect', onDisconnect);
    ctxt = document.getElementById('canvas').getContext('2d');
    $(window).resize(__bind(function(event) {
      screen.w = document.getElementById('canvas').width = window.innerWidth;
      screen.h = document.getElementById('canvas').height = window.innerHeight;
      return centerView();
    }, this));
    return $(window).resize();
  });
  go = function(clientId) {
    id = clientId;
    $(document).keydown(function(event) {
      return socket.send({
        type: 'key down',
        playerId: id,
        key: event.keyCode
      });
    });
    $(document).keyup(function(event) {
      return socket.send({
        type: 'key up',
        playerId: id,
        key: event.keyCode
      });
    });
    return update();
  };
  interpolate = function(time) {
    var ddir, dx, dy, i, shadow, ship, _results;
    _results = [];
    for (i in serverShips) {
      ship = serverShips[i];
      shadow = serverShips[i];
      if (!(ship != null)) {
        ships[i] = shadow;
        continue;
      }
      dx = shadow.pos.x - ship.pos.x;
      if ((-.1 < dx && dx < .1) || dx > 100 || dx < -100) {
        ship.pos.x = shadow.pos.x;
      } else {
        ship.pos.x += dx * time * interp_factor;
      }
      dy = shadow.pos.y - ship.pos.y;
      if ((-.1 < dy && dy < .1) || dy > 100 || dy < -100) {
        ship.pos.y = shadow.pos.y;
      } else {
        ship.pos.y += dy * time * interp_factor;
      }
      ddir = shadow.dir - ship.dir;
      if ((-.01 < ddir && ddir < .01)) {
        ship.dir = shadow.dir;
      } else {
        ship.dir += ddir * time * interp_factor;
      }
      ship.vel = shadow.vel;
      ship.color = shadow.color;
      ship.firePower = shadow.firePower;
      ship.dead = shadow.dead;
      ship.exploBits = shadow.exploBits;
      _results.push(ship.exploFrame = shadow.exploFrame);
    }
    return _results;
  };
  update = function() {
    var diff, start;
    start = (new Date).getTime();
    interpolate((new Date).getTime() - lastUpdate);
    centerView();
    redraw(ctxt);
    diff = (new Date).getTime() - start;
    return setTimeout(update, 20 - mod(diff, 20));
  };
  inView = function(x, y) {
    return (view.x <= x && x <= view.x + screen.w) && (view.y <= y && y <= view.y + screen.h);
  };
  redraw = function(ctxt) {
    var b, i, len, p, s, _i, _len, _len2;
    ctxt.clearRect(0, 0, screen.w, screen.h);
    ctxt.lineWidth = 4;
    ctxt.lineJoin = 'round';
    len = bullets.length;
    for (i = 0, _len = bullets.length; i < _len; i++) {
      b = bullets[i];
      b.draw(ctxt, (i + 1) / len);
    }
    for (_i = 0, _len2 = planets.length; _i < _len2; _i++) {
      p = planets[_i];
      p.draw(ctxt);
    }
    for (i in ships) {
      s = ships[i];
      s.draw(ctxt);
    }
    if (!ships[id].isDead() && !ships[id].isExploding()) {
      drawRadar(ctxt);
    }
    return drawInfinity(ctxt);
  };
  centerView = function() {
    if (ships[id] != null) {
      view.x = ships[id].pos.x - screen.w / 2;
      return view.y = ships[id].pos.y - screen.h / 2;
    }
  };
  drawRadar = function(ctxt) {
    var bestDistance, bestPos, d, dx, dy, i, j, k, margin, rx, ry, s, x, y, _ref, _ref2;
    for (i in ships) {
      s = ships[i];
      if (i !== id && !s.isDead() && !s.isExploding()) {
        bestDistance = 999999;
        for (j = _ref = -1; _ref <= 1 ? j <= 1 : j >= 1; _ref <= 1 ? j++ : j--) {
          for (k = _ref2 = -1; _ref2 <= 1 ? k <= 1 : k >= 1; _ref2 <= 1 ? k++ : k--) {
            x = s.pos.x + j * map.w;
            y = s.pos.y + k * map.h;
            d = distance(ships[id].pos.x, ships[id].pos.y, x, y);
            if (d < bestDistance) {
              bestDistance = d;
              bestPos = {
                x: x,
                y: y
              };
            }
          }
        }
        dx = bestPos.x - ships[id].pos.x;
        dy = bestPos.y - ships[id].pos.y;
        if (Math.abs(dx) > screen.w / 2 || Math.abs(dy) > screen.h / 2) {
          margin = 20;
          rx = Math.max(-screen.w / 2 + margin, dx);
          rx = Math.min(screen.w / 2 - margin, rx);
          ry = Math.max(-screen.h / 2 + margin, dy);
          ry = Math.min(screen.h / 2 - margin, ry);
          ctxt.fillStyle = color(s.color);
          ctxt.beginPath();
          ctxt.arc(screen.w / 2 + rx, screen.h / 2 + ry, 10, 0, 2 * Math.PI, false);
          ctxt.fill();
        }
      }
    }
    return true;
  };
  drawInfinity = function(ctxt) {
    var b, bottom, i, id, j, left, len, offset, p, right, s, top, visibility, _i, _len, _ref;
    left = view.x < 0;
    right = view.x > map.w - screen.w;
    top = view.y < 0;
    bottom = view.y > map.h - screen.h;
    visibility = [[left && top, top, right && top], [left, false, right], [left && bottom, bottom, right && bottom]];
    for (i = 0; i <= 2; i++) {
      for (j = 0; j <= 2; j++) {
        if (visibility[i][j] === true) {
          for (_i = 0, _len = planets.length; _i < _len; _i++) {
            p = planets[_i];
            offset = {
              x: (j - 1) * map.w,
              y: (i - 1) * map.h
            };
            p.draw(ctxt, offset);
          }
        }
      }
    }
    for (i = 0; i <= 2; i++) {
      for (j = 0; j <= 2; j++) {
        if (visibility[i][j] === true) {
          for (id in ships) {
            s = ships[id];
            offset = {
              x: (j - 1) * map.w,
              y: (i - 1) * map.h
            };
            s.draw(ctxt, offset);
          }
        }
      }
    }
    len = bullets.length;
    for (i = 0; i <= 2; i++) {
      for (j = 0; j <= 2; j++) {
        if (visibility[i][j] === true) {
          for (b = 0, _ref = bullets.length; 0 <= _ref ? b < _ref : b > _ref; 0 <= _ref ? b++ : b--) {
            offset = {
              x: (j - 1) * map.w,
              y: (i - 1) * map.h
            };
            bullets[b].draw(ctxt, (b + 1) / len, offset);
          }
        }
      }
    }
    return true;
  };
  onConnect = function() {
    return info("Connected to server");
  };
  onDisconnect = function() {
    return info("Aaargh! Disconnected!");
  };
  onMessage = function(msg) {
    var b, i, p, s, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4;
    switch (msg.type) {
      case 'bullets':
        bullets = [];
        _ref = msg.bullets;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          b = _ref[_i];
          bullets.push(new Bullet(b));
        }
        break;
      case 'ships':
        _ref2 = msg.ships;
        for (i in _ref2) {
          s = _ref2[i];
          serverShips[i] = new Ship(s);
          ships[i] = new Ship(s);
        }
        lastUpdate = (new Date).getTime();
        break;
      case 'update':
        _ref3 = msg.update;
        for (i in _ref3) {
          s = _ref3[i];
          serverShips[i].update(s);
          ships[i].update(s);
        }
        lastUpdate = (new Date).getTime();
        break;
      case 'planets':
        planets = [];
        _ref4 = msg.planets;
        for (_j = 0, _len2 = _ref4.length; _j < _len2; _j++) {
          p = _ref4[_j];
          planets.push(new Planet(p));
        }
        break;
      case 'connected':
        go(msg.playerId);
        break;
      case 'player joins':
        serverShips[msg.playerId] = new Ship(msg.ship);
        ships[msg.playerId] = new Ship(msg.ship);
        console.info('player ' + msg.playerId + ' joins');
        break;
      case 'player dies':
        delete serverShips[msg.playerId];
        delete ships[msg.playerId];
        console.info('player ' + msg.playerId + ' dies');
        break;
      case 'player quits':
        delete serverShips[msg.playerId];
        delete ships[msg.playerId];
        console.info('player ' + msg.playerId + ' quits');
    }
    return true;
  };
  Planet = (function() {
    function Planet(planet) {
      this.pos = planet.pos;
      this.force = planet.force;
    }
    Planet.prototype.draw = function(ctxt, offset) {
      var f, px, py, x, y;
      if (offset == null) {
        offset = {
          x: 0,
          y: 0
        };
      }
      px = this.pos.x + offset.x;
      py = this.pos.y + offset.y;
      f = this.force;
      if (!inView(px + f, py + f) && !inView(px + f, py - f) && !inView(px - f, py + f) && !inView(px - f, py - f)) {
        return;
      }
      x = px - view.x;
      y = py - view.y;
      ctxt.strokeStyle = color(planetColor);
      ctxt.beginPath();
      ctxt.arc(x, y, f, 0, 2 * Math.PI, false);
      return ctxt.stroke();
    };
    return Planet;
  })();
  Ship = (function() {
    function Ship(ship) {
      this.id = ship.id;
      this.pos = ship.pos;
      this.dir = ship.dir;
      this.vel = ship.vel;
      this.firePower = ship.firePower;
      this.dead = ship.dead;
      this.exploding = ship.exploding;
      this.exploFrame = ship.exploFrame;
      this.color = ship.color;
    }
    Ship.prototype.update = function(msg) {
      var field, val;
      for (field in msg) {
        val = msg[field];
        this[field] = val;
      }
      if (this.isExploding()) {
        if (!(explosions[this.id] != null)) {
          this.explode();
        }
        return this.updateExplosion();
      } else if (this.isDead() && (explosions[this.id] != null)) {
        return delete explosions[this.id];
      }
    };
    Ship.prototype.isExploding = function() {
      return this.exploding;
    };
    Ship.prototype.isDead = function() {
      return this.dead;
    };
    Ship.prototype.draw = function(ctxt, offset) {
      if (this.isDead()) {
        ;
      } else if (this.isExploding()) {
        return this.drawExplosion(ctxt, offset);
      } else {
        return this.drawShip(ctxt, offset);
      }
    };
    Ship.prototype.drawShip = function(ctxt, offset) {
      var cos, i, p, points, sin, x, y;
      if (offset == null) {
        offset = {
          x: 0,
          y: 0
        };
      }
      x = this.pos.x - view.x + offset.x;
      y = this.pos.y - view.y + offset.y;
      cos = Math.cos(this.dir);
      sin = Math.sin(this.dir);
      points = [[-7, 10], [0, -10], [7, 10], [0, 6]];
      for (i in points) {
        p = points[i];
        points[i] = [p[0] * cos - p[1] * sin, p[0] * sin + p[1] * cos];
      }
      ctxt.strokeStyle = color(this.color);
      ctxt.fillStyle = color(this.color, (this.firePower - 1) / maxPower);
      ctxt.beginPath();
      ctxt.moveTo(x + points[3][0], y + points[3][1]);
      for (i = 0; i <= 3; i++) {
        ctxt.lineTo(x + points[i][0], y + points[i][1]);
      }
      ctxt.closePath();
      ctxt.stroke();
      return ctxt.fill();
    };
    Ship.prototype.explode = function() {
      var i, vel, _results;
      this.exploding = true;
      explosions[this.id] = [];
      vel = Math.max(this.vel.x, this.vel.y);
      _results = [];
      for (i = 0; i <= 200; i++) {
        _results.push(explosions[this.id].push({
          x: this.pos.x,
          y: this.pos.y,
          vx: .5 * vel * (2 * Math.random() - 1),
          vy: .5 * vel * (2 * Math.random() - 1),
          s: Math.random() * 10
        }));
      }
      return _results;
    };
    Ship.prototype.updateExplosion = function() {
      var b, _i, _len, _ref, _results;
      _ref = explosions[this.id];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        b = _ref[_i];
        b.x += b.vx + (-1 + 2 * Math.random()) / 1.5;
        _results.push(b.y += b.vy + (-1 + 2 * Math.random()) / 1.5);
      }
      return _results;
    };
    Ship.prototype.drawExplosion = function(ctxt, offset) {
      var b, ox, oy, _i, _len, _ref, _results;
      if (offset == null) {
        offset = {
          x: 0,
          y: 0
        };
      }
      ox = -view.x + offset.x;
      oy = -view.y + offset.y;
      ctxt.fillStyle = color(this.color, (maxExploFrame - this.exploFrame) / maxExploFrame);
      _ref = explosions[this.id];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        b = _ref[_i];
        _results.push(ctxt.fillRect(b.x + ox, b.y + oy, b.s, b.s));
      }
      return _results;
    };
    return Ship;
  })();
  log = function(msg) {
    return console.log(msg);
  };
  info = function(msg) {
    return console.info(msg);
  };
  warn = function(msg) {
    return console.warn(msg);
  };
  log = function(msg) {
    return console.error(msg);
  };
  color = function(rgb, alpha) {
    if (alpha == null) {
      alpha = 1.0;
    }
    return 'rgba(' + rgb + ',' + alpha + ')';
  };
  distance = function(x1, y1, x2, y2) {
    return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
  };
  mod = function(x, n) {
    if (x > 0) {
      return x % n;
    } else {
      return mod(x + n, n);
    }
  };
}).call(this);
