function init() {
    // TODO: support multiple worlds.
    //console.log('init');
    world = document.getElementById('world');
    world.clock = 0;
    world.balls = [];
    world.addBall = addBall;
    world.paused = true;
    world.arrowOfTime = 1;
    world.lastClick = 0;
    world.addEventListener('click', function(e) {
	world.lastClick = getCursorPosition(world,e)[0] > world.width/2 ? 1 : -1;
	if (world.paused) requestAnimationFrame(redraw);
    });
    requestAnimationFrame(redraw);
}

function redraw(time) {
    //console.log("redraw:"+time);
    if (world.paused) {
	updateTime(world,time);
	if (world.lastClick != 0) {
	    if (world.lastClick * world.arrowOfTime < 0) {
		world.arrowOfTime *= -1;
		reverseTime(world);
	    }
	    world.lastClick = 0;
	    world.paused = false;
	    requestAnimationFrame(redraw);
	}
    } else {
	updateBalls(world,time);
	drawBalls(world);
	if (world.lastClick == 0) {
	    requestAnimationFrame(redraw);
	} else {
	    world.lastClick = 0;
	    world.paused = true;
	}
    }
}

function addBall(r,x,y,vx,vy) {
    // TODO: refuse to add overlapping balls
    var b = { r:r, x:x, y:y, vx:vx, vy:vy };
    findFirstColl(world,b);
    world.balls.push(b);
    drawBalls(world);
    //console.log('add:');console.log(b);
}

function findFirstColl(w,b) {
    // TODO: use grid for efficiency
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
    if (isNaN(b.t)) error();
    //console.log("firstColl:");console.log(c);
}

function wallColl(w,b) {
    var t = 0;
    if (b.vx < 0) {
	t = -(b.x-b.r)/b.vx;
	if (t < b.t) { b.t = t; b.c = -1; }
    } else if (b.vx > 0) {
	t = (w.width-b.x-b.r)/b.vx;
	if (t < b.t) { b.t = t; b.c = -1; }
    }
    if (b.vy < 0) {
	t = -(b.y-b.r)/b.vy;
	if (t < b.t) { b.t = t; b.c = -2; }
    } else if (b.vy > 0) {
	t = (w.height-b.y-b.r)/b.vy;
	if (t < b.t) { b.t = t; b.c = -2; }
    }
}

function drawBalls(w) {
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

function updateBalls(w,t) {
    //console.log("advance:"+t);
    while (true) {
	var b = nextColl(w);
	if (b.t > t) break;
	simpleAdvance(w,b.t);
	collide(w,b);
    }
    simpleAdvance(w,t);
}

function nextColl(w) {
    // TODO: use priority queue for efficiency
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
    console.log('reverseTime');
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
    var cv = cx*vx + cy*vy;
    if (cv <= 0) return Infinity;
    var rr = a.r + b.r;
    if (Math.abs(vx) * a.t + rr < Math.abs(cx)) return Infinity;
    if (Math.abs(vy) * a.t + rr < Math.abs(cy)) return Infinity;
    var v1 = Math.sqrt(vx*vx + vy*vy);
    var d = cv / v1; var d2 = d*d;
    var c2 = cx*cx + cy*cy;
    var f2 = c2 - d2;
    var rr2 = rr * rr;
    if (f2 >= rr2) return Infinity;
    var dx = d - Math.sqrt(rr2 - f2);
    return dx / v1;
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

function getCursorPosition(canvas, event) {
    var rect = canvas.getBoundingClientRect();
    var x = event.clientX - rect.left;
    var y = event.clientY - rect.top;
    console.log("x: " + x + " y: " + y);
    return [x,y];
}

init();    

