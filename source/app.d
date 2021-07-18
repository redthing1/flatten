module app;

import std.stdio;
import std.format;
import commandr;

import re;
import re.math;
import std.stdio;
import play;
import hud;
static import raylib;

class Game : Core {
	public static string asset;
	public static string outfile;
	public static int dimens_x = 64;
	public static int dimens_y = 64;
	public static int sheet_width;
	public static int frames;
	public static float scale;
	public static Vector3 rotation;
	public static Vector3 campos;
	public static Vector2 capangles; // angle capture range (start and end angle)
	public static bool noquit = true;

	public static bool saved_capture = false;

	this() {
		super(dimens_x, dimens_y, "flatten");
	}

	override void initialize() {
		default_resolution = Vector2(dimens_x, dimens_y);
		// content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

void main(string[] args) {
	auto a = new Program("flatten", "0.1").summary("a tool for rendering 3d objects to spritesheets").author("xdrie")
		.add(new Argument("asset", "path to 3d asset (.obj or ,glb)"))
		.add(new Argument("output", "path to output spritesheet (.png)"))
		.add(new Option("d", "dimens", "render dimensions").defaultValue("64x64"))
		.add(new Option("w", "width", "spritesheet width (how many frames per row)").defaultValue("4"))
		.add(new Option("f", "frames", "number of frames to capture").defaultValue("16"))
		.add(new Option("l", "scale", "scale of object").defaultValue("1"))
		.add(new Option("r", "rot", "rotation of object (euler angles in deg)").defaultValue("90,0,0"))
		.add(new Option("c", "campos", "position of camera").defaultValue("10,10,10"))
		.add(new Option("g", "capangles", "angle range of the capture (in deg)").defaultValue("0,360"))
		.add(new Flag("n", "noquit", "don't close render immediately after capture"))
		.parse(args);

	Game.asset = a.arg("asset");
	Game.outfile = a.arg("output");
	formattedRead(a.option("dimens"), "%dx%d", Game.dimens_x, Game.dimens_y);
	formattedRead(a.option("width"), "%d", Game.sheet_width);
	formattedRead(a.option("frames"), "%d", Game.frames);
	formattedRead(a.option("scale"), "%f", Game.scale);
	int rot_x, rot_y, rot_z;
	formattedRead(a.option("rot"), "%d,%d,%d", rot_x, rot_y, rot_z);
	Game.rotation = Vector3((cast(float) rot_x) * raylib.DEG2RAD, (cast(float) rot_y) * raylib.DEG2RAD, (cast(float) rot_z) * raylib.DEG2RAD);
	int cpos_x, cpos_y, cpos_z;
	formattedRead(a.option("campos"), "%d,%d,%d", cpos_x, cpos_y, cpos_z);
	Game.campos = Vector3(cpos_x, cpos_y, cpos_z);
	int cpa_s, cpa_e;
	formattedRead(a.option("capangles"), "%d,%d", cpa_s, cpa_e);
	Game.capangles = Vector2((cast(float) cpa_s) * raylib.DEG2RAD, (cast(float) cpa_e) * raylib.DEG2RAD);

	Game.noquit = a.flag("noquit");

	// writefln("a: %s %s %s", a.option("dimens"), Game.dimens_x, Game.dimens_y);

	writeln("verbosity level", a.occurencesOf("verbose"));
	writeln("arg: ", a.arg("path"));

	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
