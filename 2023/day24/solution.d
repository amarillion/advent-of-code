#!/usr/bin/env -S rdmd -I.. -I~/prg/alleg/DAllegro5/ -I~/prg/gamedev/dtwist/src -L-L/home/martijn/prg/alleg/DAllegro5
module day24.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.math;

import common.io;
import common.vec;
import common.pairwise;
import common.coordrange;
import common.geometry;

import std.stdio;
import std.conv;

import allegro5.allegro;
import allegro5.allegro_audio;
import allegro5.allegro_font;

import helix.component;
import helix.mainloop;
import helix.color;
import helix.allegro.font;

alias vec3d = vec!(3, real);
alias vec2d = vec!(2, real);

struct Line {
	vec3d position;
	vec3d velocity;
}
alias Data = Line[];

Data parse(string fname) {
	Data result;
	foreach(line; readLines(fname)) {
		vec3d[] coords = line.split(" @ ").map!(
			s => s.split(",").map!strip.map!(to!real).array
		).map!((real[] i) => vec3d(i[0], i[1], i[2])).array;
		result ~= Line(coords[0], coords[1]);
	}
	return result;
}

struct IntersectionResult {
	vec2d intersection;
	bool doIntersect;
}

IntersectionResult lineIntersection(vec2d a1, vec2d da, vec2d b1, vec2d db) {
	IntersectionResult result;
	
	real x1 = a1.x; 
	real x2 = a1.x + da.x;
	real y1 = a1.y;
	real y2 = a1.y + da.y;
	real x3 = b1.x;
	real x4 = b1.x + db.x;
	real y3 = b1.y;
	real y4 = b1.y + db.y;
	
	// source: https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
	real divisor = (-da.x)*(-db.y) - (-da.y)*(-db.x);
	if (divisor != 0) {
		real x = (((x1 * y2) - (y1 * x2)) * (-db.x) - (-da.x) * ((x3 * y4) - (y3 * x4)));
		x /= divisor;
		real y = (((x1 * y2) - (y1 * x2)) * (-db.y) - (-da.y) * ((x3 * y4) - (y3 * x4)));
		y /= divisor;
		return IntersectionResult(vec2d(x, y), true);
	}
	else {
		return IntersectionResult(vec2d(0, 0), false);
	}

}

real perpendicularDistance(Line a, Line b) {
	auto crossprod = a.velocity.cross(b.velocity);
	real crosslen = crossprod.length();
	if (crosslen == 0) { return real.nan; } // parallel lines!
	auto unitvec = (crossprod / crosslen);
	real result = unitvec.dot(b.position - a.position);
	return result;
}

real sumSq(Data data, vec3d velocity, long firstHitIdx, real firstCrossTime, out Line ll) {
	ll.velocity = velocity;
	ll.position = 
		data[firstHitIdx].position + (data[firstHitIdx].velocity * firstCrossTime) 
		- ll.velocity * firstCrossTime;

	// writefln("Line: %s", ll);

	real result = 0;
	foreach(long idx, Line line; data) {
		real dist = perpendicularDistance(ll, line);
		// writefln("Perpendicular distance with #%s %s = %s", idx, line, dist);
		result += dist * dist;
	}
	return result;
}

auto solve1(Data data, real min, real max) {
	long result = 0;
	foreach(pair; pairwise(data)) {
		vec2d a1 = vec2d(pair[0].position.x, pair[0].position.y);
		vec2d da = vec2d(pair[0].velocity.x, pair[0].velocity.y);

		vec2d b1 = vec2d(pair[1].position.x, pair[1].position.y);
		vec2d db = vec2d(pair[1].velocity.x, pair[1].velocity.y);
		
		auto intersect = lineIntersection(
			a1, da, b1, db
		);
		writefln("Line A: %s %s", a1, da);
		writefln("Line B: %s %s", b1, db);
		if (intersect.doIntersect
		) {
			vec2d ta = (intersect.intersection - a1) / da;
			vec2d tb = (intersect.intersection - b1) / db;
			// writefln("%s %s", ta, tb);
			if (ta.x < 0 && tb.x < 0) {
				writeln("In the past for both");
			}
			else if (ta.x < 0) {
				writefln("In the past for A");
			} 
			else if (tb.x < 0) {
				writefln("In the past for B");
			}
			else if (
				intersect.intersection.x >= min && 
				intersect.intersection.y >= min && 
				intersect.intersection.x <= max &&
				intersect.intersection.y <= max
			) {
				writefln("Intersection inside test area: %s", intersect.intersection);		
				result++;
			}
			else {
				writefln("Outside test area: %s", intersect.intersection);		
			}
		}
		else {
			writeln("Lines are parallel");
		}
	}
	return result;
}

class MainState : Component {

	Data data;
	long time = 59000000000;
	Font font;

	Line ll;

	this(MainLoop window, Data data) {
		super(window, "mainstate");
		this.data = data;
		font = window.resources.fonts["builtin_font"].get();

		// during lead period, 130 is closest,
		// but doesn't actually hit at this time.

		// probably real first hit?
		long firstHitIdx = 77;
		real firstCrossTime = 59472000000;
		// Start position: [2.70365e+14, 4.63432e+14, 2.72808e+14]

		// second hit
		// long firstHitIdx = 277;
		// real firstCrossTime = 64700000000;
		// Start position: [2.70157e+14, 4.6354e+14, 2.7276e+14]

		// third hit
		// long firstHitIdx = 36;
		// real firstCrossTime = 68900000000;
		// Start position: [2.70421e+14, 4.63436e+14, 2.72807e+14]

		// long firstHitIdx = 48;
		// real firstCrossTime = 74100000000;
		// Start position: [2.70448e+14, 4.63399e+14, 2.73002e+14]

		// long firstHitIdx = 170;
		// real firstCrossTime = 75200000000;
		// Start position: [2.70379e+14, 4.63429e+14, 2.73066e+14]


		// long firstHitIdx = 219;
		// real firstCrossTime = 75_000_000_000;
		// Start position: [2.70571e+14, 4.60141e+14, 2.7325e+14]

		// original estimate
		// ll.position = vec3d(269906000000000, 466151000000000, 272693000000000);
		// improved estimate:
		// ll.position = vec3d(270101989340000, 460518315600000, 273000000000000);
		// ll.position = vec3d(270101989340000, 463681315600000, 272370000000000);
		// ll.position = vec3d(270343000000000, 463306000000000, 272627000000000);
		// ll.position = vec3d(270365000000000, 463432000000000, 272808000000000);
		// ll.position =    vec3d(270364968959117, 463433050727410, 272809664689678);

		ll.velocity = vec3d(26, -329, 53);
		
		ll.position = 
			data[firstHitIdx].position + (data[firstHitIdx].velocity * firstCrossTime) 
			- ll.velocity * firstCrossTime;

		writefln("Start position: %0.0f %0.0f %0.0f", ll.position.x, ll.position.y, ll.position.z);
	}

	override void update() {
		time += 2e7;
	}

	override void draw(GraphicsContext gc) {
		al_clear_to_color(Color.BLACK);

		vec3d pp = ll.position + ll.velocity * time;

		double min = 0;
		long minIdx;
		vec3d minDelta;
		bool first = true;

		foreach(long i, Line line; data) {
			vec3d p = line.position + line.velocity * time;

			double dist = (pp - p).length();
			if (first || dist < min) {
				minIdx = i;
				min = dist;
				minDelta = p - pp;
				first = false;
			}

			vec!(2, double) map1;
			map1.x = p.x / 1e12 /* + p.y / 2e12 */;
			map1.y = p.z / 1e12 /* + p.y / 2e12 */;

			vec!(2, double) map2;
			map2.x = p.x / 1e12 /* + p.y / 2e12 */;
			map2.y = 400 + p.y / 1e12 /* + p.y / 2e12 */;

			vec3d dd = p - pp;
			vec!(2, double) map3;
			map3.x = 800 + dd.y / 1e10 /* + p.y / 2e12 */;
			map3.y = 400 + dd.z / 1e10 /* + p.y / 2e12 */;

			// writeln(mapped);
			al_put_pixel(to!int(map1.x), to!int(map1.y), Color.RED);
			al_put_pixel(to!int(map2.x), to!int(map2.y), Color.GREEN);
			al_put_pixel(to!int(map3.x), to!int(map3.y), Color.YELLOW);

			al_draw_textf(font.ptr, Color.WHITE, 0, 0, 0, "%i000\0", to!int(time / 1000));

			
		}

		writefln("t: %s, min: %s, minIdx: %s, minDelta: %s", time, min, minIdx, minDelta);

		{
			vec3d p = pp;
			vec!(2, double) map1;
			map1.x = p.x / 1e12 /* + p.y / 2e12 */;
			map1.y = p.z / 1e12 /* + p.y / 2e12 */;

			vec!(2, double) map2;
			map2.x = p.x / 1e12 /* + p.y / 2e12 */;
			map2.y = 400 + p.y / 1e12 /* + p.y / 2e12 */;

			vec3d dd = p - pp;
			vec!(2, double) map3;
			map3.x = 800 + dd.y / 1e10 /* + p.y / 2e12 */;
			map3.y = 400 + dd.z / 1e10 /* + p.y / 2e12 */;

			al_put_pixel(to!int(map1.x), to!int(map1.y), Color.WHITE);
			al_put_pixel(to!int(map2.x), to!int(map2.y), Color.WHITE);
			al_put_pixel(to!int(map3.x), to!int(map3.y), Color.RED);

		}

	}

	/** 
	 * t = 1051 000 000 000
	 * Yellow (y,z): 520, 328  ->  120e12, 328e12
	 * Green  (x,y): 297, 519   ->  297e12, 119e12

	 * t = 119 000 000 000
	 * Yellow (y,z): 824, 279  ->  424e12, 279e12
	 * Green  (x,y): 273, 830   ->  273e12, 430e12

	 * Coord: t = 1051e9: x: 297e12, y: 120e12, z: 328e12
	 * Coord: t = 119e9:  x: 273e12  y: 427e12, z: 279e12 
	 
	 * Delta: dt = 932e9  dx = 24e12 y: -307e12, z: 49e12
	 		  dt = 1      dx = 26   dy = -329    dz = 53
			  t0 = 0      x = 269906000000000, y = 466151000000000, z = 272693000000000
	 */

	

	// 1051
}

long solve2(Data data) {
	// auto velocity = vec3d(26, -329, 53);
	long firstHitIdx = 77;
	// real firstCrossTime = 59472000000;
	real minVal;
	Line ll;
	Line minLL;
	bool first = true;
	for(real firstCrossTime = 59_816_900_000; firstCrossTime < 59_817_000_000; firstCrossTime += 1) {
		// foreach(vv; CoordRange!vec3i(vec3i(23, -335, 48), vec3i(28, -325, 55))) {
			vec3i vv = vec3i(26, -331, 53);
			vec3d velocity = vec3d(vv.x, vv.y, vv.z);
			real val = sumSq(data, velocity, firstHitIdx, firstCrossTime, ll);
			if (val < minVal || first) {
				minVal = val;
				minLL = ll;
				writefln("Lower sumSq %s found at %s %0.0f", val, vv, firstCrossTime);

				// Lower sumSq 1.93367e+15 found at [26, -331, 53] 59817000000
				// Lower sumSq 1.01236e+13 found at [26, -331, 53] 59816995000
				// Lower sumSq 2.15379e-09 found at [26, -331, 53] 59816994610
				first = false;
			}
		// }
	}
	
	return to!long(minLL.position.x) + to!long(minLL.position.y) + to!long(minLL.position.z);
	// correct answer: 1007148211789625
}


void main(string[] args)
{
	// auto testData = parse("test-input");
	// writeln(testData);
	// assert(solve1(testData, 7, 27) == 2, "Solution incorrect");

	auto data = parse("input");
	// auto result = solve1(data, 200000000000000, 400000000000000);
	// assert(result == 14799);
	// writeln(result);

	writeln(solve2(data));

	/*
	al_run_allegro(
	{
		al_init();


		auto mainloop = new MainLoop(MainConfig.of.appName("day24").targetFps(60));
		mainloop.init();
		mainloop.addState("MainState", new MainState(mainloop, data));
		mainloop.switchState("MainState");
		mainloop.run();
		return 0;
	});
	*/


}