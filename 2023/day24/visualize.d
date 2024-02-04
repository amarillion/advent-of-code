#!/usr/bin/env -S rdmd -I.. -I~/prg/alleg/DAllegro5/ -I~/prg/gamedev/dtwist/src -L-L/home/martijn/prg/alleg/DAllegro5
module day24.visualize;

import allegro5.allegro;
import allegro5.allegro_audio;
import allegro5.allegro_font;

import helix.component;
import helix.mainloop;
import helix.color;
import helix.allegro.font;

import std.conv;
import std.stdio;
import std.array;
import std.string;
import std.algorithm;

import common.io;
import common.vec;

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

class MainState : Component {

	Data data;
	long time = 0;
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
		time += 2e9;
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
			map3.x = 800 + dd.y / 1e12 /* + p.y / 2e12 */;
			map3.y = 400 + dd.z / 1e12 /* + p.y / 2e12 */;

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
			map3.x = 800 + dd.y / 1e12 /* + p.y / 2e12 */;
			map3.y = 400 + dd.z / 1e12 /* + p.y / 2e12 */;

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


void main(string[] args)
{
	auto data = parse("input");

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

}