function init(w) {
    //console.log('init');
    w.clock = 0;
    w.paused = true;
    w.raf = null;
    w.balls = [];
    w.addBall = addBall;
    w.addEventListener('click', function(e) {
	if (w.raf) {
	    console.log('paused');
	    cancelAnimationFrame(w.raf);
	    w.raf = null;
	    w.paused = true;
	} else {
	    console.log('unpaused');
	    w.raf = requestAnimationFrame(draw);
	}
    });
    w.addEventListener('dblclick', function(e) {
	if (w.paused) {
	    console.log('reversed');
	    reverseTime(w);
	    w.raf = requestAnimationFrame(draw);
	}
    });
}

function addBall(r,x,y,vx,vy) {
    var b = { r:r, x:x, y:y, vx:vx, vy:vy };
    findFirstColl(this,b);
    this.balls.push(b);
    //console.log('add:');console.log(b);
}

function findFirstColl(w,b) {
    b.c = 0;
    b.t = Infinity;
    wallColl(w,b);
    for (var j = 0; j < w.balls.length; j++) {
	var c = w.balls[j];
	if (c !== b) {
	    var t = ballColl(b,c);
	    if (t < b.t) { b.t = t; b.c = j; }
	}
    }
    b.t += w.clock;
    //console.log("firstColl:");console.log(c);
}

function wallColl(w,b) {
    var t = 0;
    if (b.vx < 0) {
	t = -(b.x-b.r)/b.vx;
	if (t < b.t) { b.t = t; b.c = -1; }
    } else {
	t = (w.width-b.x-b.r)/b.vx;
	if (t < b.t) { b.t = t; b.c = -1; }
    }
    if (b.vy < 0) {
	t = -(b.y-b.r)/b.vy;
	if (t < b.t) { b.t = t; b.c = -2; }
    } else {
	t = (w.height-b.y-b.r)/b.vy;
	if (t < b.t) { b.t = t; b.c = -2; }
    }
}

function draw(time) {
    // TODO: support multiple worlds.
    //console.log("draw:"+time);
    if (world.paused) {
	updateTime(world,time);
	world.paused = false;
    } else {
	drawBalls(world,time);
    }
    world.raf = requestAnimationFrame(draw);
}

function drawBalls(w,t) {
    advance(w,t);
    var c = w.getContext("2d");
    c.fillStyle = "#ccc";
    c.clearRect(0,0,w.width,w.height);
    for (var i = 0; i < w.balls.length; i++) {
	var b = w.balls[i]
	c.beginPath();
	c.arc(b.x,b.y,b.r,0,2*Math.PI);
	c.fill();
	//c.stroke();
    }
}

//_advance = true;

function advance(w,t) {
    //console.log("advance:"+t);
    //if (!_advance) return;
    while (true) {
	var b = nextColl(w);
	if (b.t > t) break;
	simpleAdvance(w,b.t);
	//_advance = false; return;
	collide(w,b);
    }
    simpleAdvance(w,t);
}

function nextColl(w) {
    var tmin = Infinity;
    var imin = 0;
    for (var i=0; i<w.balls.length; i++) {
	var t = w.balls[i].t;
	if (t < tmin) { tmin = t; imin = i; }
    }
    return w.balls[imin];
}

function collide(w,b) {
    //console.log("collide:");console.log(b);
    if (b.c === -1) {
	b.vx = -b.vx;
    } else if (b.c === -2) {
	b.vy = -b.vy;
    } else {
	c = w.balls[b.c];
	bounce(b,c);
	findFirstColl(w,c);
    }
    findFirstColl(w,b);
}

function simpleAdvance(w,t) {
    var dt = t - w.clock;
    for (var i=0; i<w.balls.length; i++) {
	var b = w.balls[i];
	b.x += dt * b.vx;
	b.y += dt * b.vy;
    }
    w.clock = t;
}

function updateTime(w,t) {
    var dt = t - w.clock;
    for (var i = 0; i < w.balls.length; i++) {
	w.balls[i].t += dt;
    }
    w.clock = t;
}

function reverseTime(w) {
    for (var i = 0; i < w.balls.length; i++) {
	b = w.balls[i];
	b.vx = -b.vx;
	b.vy = -b.vy;
    }
    for (var i = 0; i < w.balls.length; i++) {
	findFirstColl(w,w.balls[i]);
    }
}

function randn(std) {
    var u1 = Math.random();
    var u2 = Math.random();
    var z = Math.sqrt(-2*Math.log(u1)) * Math.cos(2*Math.PI*u2);
    return std * z;
}

// based on http://www.gamasutra.com/view/feature/131424/pool_hall_lessons_fast_accurate_.php?page=2
function ballColl(a,b) {
    // TODO:
    var cx = b.x - a.x;   var cy = b.y - a.y;
    var vx = a.vx - b.vx; var vy = a.vy - b.vy;
    if (cx*vx + cy*vy <= 0) return Infinity;
    var vn = Math.sqrt(vx*vx + vy*vy);
    var nx = vx / vn;     var ny = vy / vn;
    var d = nx*cx + ny*cy;
    var f = cx*cx + cy*cy - d*d;
    var rr = a.r + b.r;   var rr2 = rr * rr;
    if (f >= rr2) return Infinity;
    var dx = d - Math.sqrt(rr2 - f);
    return dx / vn;
}

function bounce(a,b) {
    var cx = b.x - a.x; var cy = b.y - a.y;
    var rr = a.r + b.r; var rr2 = rr * rr;
    var c2 = cx*cx + cy*cy; 
    if (c2 > rr2 + 1) return;
    var c1 = Math.sqrt(c2);
    var nx = cx/c1; var ny = cy/c1;
    var an = nx * a.vx + ny * a.vy;
    var bn = nx * b.vx + ny * b.vy;
    var ma = a.r*a.r*a.r; var mb = b.r*b.r*b.r;
    var p = 2 * (an - bn) / (ma + mb);
    var pmb = p * mb; var pma = p * ma;
    a.vx -= pmb * nx; a.vy -= pmb * ny;
    b.vx += pma * nx; b.vy += pma * ny;
}
