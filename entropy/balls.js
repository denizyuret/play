function advance(w, t) {
    //console.log("advance:"+t);
    while (true) {
	var c = nextColl(w);
	if (c.t > t) break;
	simpleAdvance(w, c.t);
	collide(w,c);
    }
    simpleAdvance(w, t);
}

function collide(w,c) {
    //console.log("collide:");console.log(c);
    var bi = w.balls[c.i];
    if (c.j === -1) {
	bi.vx = -bi.vx;
    } else if (c.j === -2) {
	bi.vy = -bi.vy;
    } else {
	
    }
    w.colls[c.i] = firstColl(w,c.i);
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

function nextColl(w) {
    var tmin = Infinity;
    var imin = 0;
    for (var i=0; i<w.colls.length; i++) {
	if (w.colls[i].t < tmin) {
	    tmin = w.colls[i].t; imin = i;
	}
    }
    return w.colls[imin];
}

function init(time) {
    var c = document.getElementById('canvas')
    var w = { width:c.width, height:c.height, clock:time };
    initBalls(w);
    initColls(w);
    return w;
}

function initBalls(w) {
    w.balls = [];
    for (var x = 200; x <= w.width-200; x += 50) {
	for (var y = 200; y <= w.height-200; y += 50) {
	    vx = 0.5*(Math.random()-0.5);
	    vy = 0.5*(Math.random()-0.5);
	    w.balls.push({x:x,y:y,r:20,vx:vx,vy:vy});
	}
    }
    return w;
}

function initColls(w) {
    w.colls = [];
    for (var i = 0; i < w.balls.length; i++) {
	w.colls[i] = firstColl(w,i);
    }
}

function ballColl(w,i,j) {
    return Infinity;
}

function firstColl(w,i) {
    var c = wallColl(w,i);
    for (var j = 0; j < w.balls.length; j++) {
	if (i !== j) {
	    var t = ballColl(w,i,j);
	    if (t < c.t) { c.t = t; c.j = j; }
	}
    }
    c.t += w.clock;
    //console.log("firstColl:");console.log(c);
    return c;
}

function wallColl(w,i) {
    var b = w.balls[i];
    var c = { i:i, j:0, t:Infinity }
    var t = 0;
    if (b.vx < 0) {
	t = -(b.x-b.r)/b.vx;
	if (t < c.t) { c.t = t; c.j = -1; }
    } else {
	t = (w.width-b.x-b.r)/b.vx;
	if (t < c.t) { c.t = t; c.j = -1; }
    }
    if (b.vy < 0) {
	t = -(b.y-b.r)/b.vy;
	if (t < c.t) { c.t = t; c.j = -2; }
    } else {
	t = (w.height-b.y-b.r)/b.vy;
	if (t < c.t) { c.t = t; c.j = -2; }
    }
    return c;
}

function draw(time) {
    //console.log("draw:"+time);
    if (!world) {
	time0 = time;
	world = init(time);
    } else {
	advance(world, time);
    }
    var c = canvas.getContext("2d");
    c.fillStyle = "#ccc";
    c.clearRect(0,0,world.width,world.height);
    for (var i = 0; i < world.balls.length; i++) {
	var b = world.balls[i]
	c.beginPath();
	c.arc(b.x,b.y,b.r,0,2*Math.PI);
	c.fill();
	//c.stroke();
    }
    if (raf) {
	requestAnimationFrame(draw);
    }
}

time0 = 0;
world = null;
canvas = document.getElementById('canvas');
raf = null;

canvas.addEventListener('click', function(e) {
    if (!raf) {
	raf = requestAnimationFrame(draw);
    } else {
	cancelAnimationFrame(raf);
	raf = null;
    }
});

