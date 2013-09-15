(function() {
  var Game, Individual, Population, requestAnimFrame, start,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Population = (function() {

    Population.prototype.faceID = 0;

    Population.prototype.best = -1;

    Population.prototype.individuals = [];

    function Population(count) {
      this.count = count;
      this.populate();
    }

    Population.prototype.populate = function() {
      var num, _ref;
      for (num = 1, _ref = this.count; 1 <= _ref ? num <= _ref : num >= _ref; 1 <= _ref ? num++ : num--) {
        this.individuals.push(new Individual());
      }
    };

    Population.prototype.evolve = function(self) {
      var i, _i, _len, _ref, _results;
      _ref = self.individuals;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(i.mutate());
      }
      return _results;
    };

    Population.prototype.run = function(self) {
      var fitting, i, _i, _len, _ref;
      _ref = self.individuals;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        fitting = i.fitting();
        if (fitting < self.best || self.best === 99) {
          self.best = fitting;
          console.log(fitting);
        }
      }
      self.evolve(self);
      return setTimeout(self.run, 10, self);
    };

    return Population;

  })();

  Individual = (function() {

    function Individual(chromosom) {
      this.chromosom = chromosom;
    }

    Individual.prototype.fitness = function() {
      var cat, pos, type, visited, _ref;
      cat = {};
      _ref = this.chromosom;
      for (pos in _ref) {
        type = _ref[pos];
        if (type === 'cat') {
          cat.x = Math.floor(pos % 11);
          cat.y = Math.floor(pos / 11);
          cat.distance = 0;
          break;
        }
      }
      visited = [cat.y * 11 + cat.x];
      return this.bfs([cat], visited);
    };

    Individual.prototype.bfs = function(list, visited) {
      var l, n, next, _i, _j, _len, _len2, _ref, _ref2;
      next = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        l = list[_i];
        _ref = this.neighbours(l);
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          n = _ref[_j];
          if (n.x <= 0 || n.x > 11 || n.y <= 0 || n.y > 11) {
            return l.distance;
          } else if (_ref2 = n.x + n.y * 11, __indexOf.call(visited, _ref2) < 0) {
            visited.push(n.x + n.y * 11);
            n.distance = l.distance + 1;
            next.push(n);
          }
        }
      }
      if (next.length === 0) return 99;
      return this.bfs(next, visited);
    };

    Individual.prototype.neighbours = function(l) {
      var neighs, x, y;
      neighs = [];
      x = l.x;
      y = l.y;
      if (!this.chromosom[(x - 1) + y * 11]) {
        neighs.push({
          x: l.x - 1,
          y: l.y
        });
      }
      if (!this.chromosom[(x + 1) + y * 11]) {
        neighs.push({
          x: l.x + 1,
          y: l.y
        });
      }
      if (!this.chromosom[x + (y + 1) * 11]) {
        neighs.push({
          x: l.x,
          y: l.y + 1
        });
      }
      if (!this.chromosom[x + (y - 1) * 11]) {
        neighs.push({
          x: l.x,
          y: l.y - 1
        });
      }
      if (l.y % 2) {
        if (!this.chromosom[(x - 1) + (y + 1) * 11]) {
          neighs.push({
            x: l.x - 1,
            y: l.y + 1
          });
        }
        if (!this.chromosom[(x - 1) + (y - 1) * 11]) {
          neighs.push({
            x: l.x - 1,
            y: l.y - 1
          });
        }
      } else {
        if (!this.chromosom[(x + 1) + (y + 1) * 11]) {
          neighs.push({
            x: l.x + 1,
            y: l.y + 1
          });
        }
        if (!this.chromosom[(x + 1) + (y - 1) * 11]) {
          neighs.push({
            x: l.x + 1,
            y: l.y - 1
          });
        }
      }
      return neighs;
    };

    Individual.prototype.mutate = function() {
      return 0;
    };

    return Individual;

  })();

  $(function() {
    var game;
    return game = new Game();
  });

  start = function() {
    var pop;
    pop = new Population(3);
    return pop.run(pop);
  };

  requestAnimFrame = (function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
      return window.setTimeout(callback, 1000 / 60);
    };
  })();

  Game = (function() {

    Game.prototype.floorColor = "rgb(200,200,200)";

    function Game() {
      this.fields = {};
      this.cat = {};
      this.radius = 24;
      this.isPaused = true;
      this.gamefield = document.getElementById('game');
      this.ctx = this.gamefield.getContext('2d');
      this.initialize();
    }

    Game.prototype.initialize = function() {
      var x, y,
        _this = this;
      this.ctx.fillStyle = this.floorColor;
      for (x = 1; x <= 11; x++) {
        for (y = 1; y <= 11; y++) {
          this.drawTile(x, y);
        }
      }
      this.setCat(6, 5);
      this.randomWalls(Math.random() * 5 + 3);
      this.gamefield.addEventListener('click', function(e) {
        var ind, xoffset;
        if (_this.isPaused) return;
        y = Math.round(e.offsetY / (_this.radius * 2));
        xoffset = _this.radius;
        if (y % 2) xoffset = 2 * _this.radius;
        x = Math.round((e.offsetX + xoffset) / (_this.radius * 2) - 1);
        if (!_this.fields[y * 11 + x]) {
          _this.makeWall(x, y);
          ind = new Individual(_this.fields);
          _this.makeCatMove();
          if (ind.fitness() === 99) return _this.catLost();
        }
      }, false);
      return this.isPaused = false;
    };

    Game.prototype.randomWalls = function(count) {
      var i, _results;
      _results = [];
      for (i = 1; 1 <= count ? i <= count : i >= count; 1 <= count ? i++ : i--) {
        _results.push(this.makeWall(Math.round(Math.random() * 10 + 1), Math.round(Math.random() * 10 + 1)));
      }
      return _results;
    };

    Game.prototype.setCat = function(x, y) {
      var xOffset;
      if (this.cat.x && this.cat.y) {
        this.ctx.fillStyle = this.floorColor;
        this.drawTile(this.cat.x, this.cat.y);
      }
      this.ctx.fillStyle = "rgb(200,100,100)";
      xOffset = 0.25;
      if (y % 2) xOffset = -0.25;
      this.ctx.fillRect((x + xOffset) * this.radius * 2, (y - 0.25) * this.radius * 2, this.radius, this.radius);
      this.fields[this.cat.y * 11 + this.cat.x] = void 0;
      this.fields[y * 11 + x] = 'cat';
      this.cat.x = x;
      return this.cat.y = y;
    };

    Game.prototype.drawTile = function(x, y) {
      this.ctx.beginPath();
      if (y % 2) {
        this.ctx.arc(x * this.radius * 2, y * this.radius * 2, this.radius - 1, 0, Math.PI * 2, true);
      } else {
        this.ctx.arc(x * this.radius * 2 + this.radius, y * this.radius * 2, this.radius - 1, 0, Math.PI * 2, true);
      }
      this.ctx.closePath();
      return this.ctx.fill();
    };

    Game.prototype.makeWall = function(x, y) {
      if (this.fields[y * 11 + x] === 'cat') return;
      this.fields[y * 11 + x] = 'wall';
      this.ctx.fillStyle = "rgb(100,100,100)";
      this.drawTile(x, y);
      return this.isPaused = true;
    };

    Game.prototype.makeCatMove = function() {
      var best_distance, best_ind, distance, i, n, neighbours, _i, _len;
      i = new Individual(this.fields);
      neighbours = i.neighbours(this.cat);
      best_distance = 99;
      best_ind = neighbours[0];
      for (_i = 0, _len = neighbours.length; _i < _len; _i++) {
        n = neighbours[_i];
        n.distance = 0;
        distance = i.bfs([n], [n.x + n.y * 11]);
        if (distance < best_distance) {
          best_distance = distance;
          best_ind = n;
        }
      }
      this.setCat(best_ind.x, best_ind.y);
      this.isLost();
      return this.isPaused = false;
    };

    Game.prototype.isLost = function() {
      if (this.cat.x <= 0 || this.cat.x > 11 || this.cat.y <= 0 || this.cat.y > 11) {
        this.ctx.font = "bold 120px sans-serif";
        this.ctx.textAlign = 'center';
        this.ctx.fillText("LOST", this.gamefield.width / 2, this.gamefield.height / 2);
        return this.isPaused = true;
      }
    };

    Game.prototype.catLost = function() {
      this.ctx.font = "bold 110px sans-serif";
      this.ctx.textAlign = 'center';
      this.ctx.fillText("CAT LOST", this.gamefield.width / 2, this.gamefield.height / 2);
      return this.isPaused = true;
    };

    return Game;

  })();

}).call(this);
