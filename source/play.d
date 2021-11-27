module play;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.math;
static import raylib;
import core.stdc.math : ceil;
import std.stdio;
import re.util.interop;
import app;

/// simple 3d demo scene
class PlayScene : Scene3D {
    int start_frame;
    Image[] captured_frames;

    override void on_start() {
        clear_color = Colors.BLACK;

        start_frame = Time.frame_count + 2; // delay

        auto thing = create_entity("thing", Vector3.zero);
        auto thing_asset = Core.content.load_model(Game.asset);
        auto thing_model = thing.add_component(new Model3D(thing_asset));
        thing_model.offset = thing.transform.position + Game.obj_pos;
        // thing_model.transform.scale = Vector3(4, 4, 4);
        thing_model.transform.scale = Vector3(Game.scale, Game.scale, Game.scale);
        // thing_model.transform.orientation = Vector3(C_PI_2, 0, 0); // euler angles
        thing_model.transform.orientation = Game.obj_rot; // euler angles

        // set the camera position
        // cam.entity.position = Vector3(10, 12, 10);
        cam.entity.position = Game.campos;
        cam.fov = Game.camfov;

        // add a camera to look at the thing
        // cam.entity.add_component(new CameraOrbit(thing, PI * (15.0 / 16)));
        cam.entity.add_component(new CameraOrbit(thing, 0));
        // cam.entity.add_component(new CameraFreeLook(thing));
    }

    override void update() {
        // update camera
        // TODO: controlled spin

        immutable int frame_num = Time.frame_count - start_frame;

        if (frame_num <= -1) {
            // reset while waiting for capture
            // cam.entity.get_component!CameraOrbit().set_xz_angle(0);
            cam.entity.get_component!CameraOrbit().set_xz_angle(0);
            cam.entity.get_component!CameraOrbit().pause = true;
        }

        // writefln("frame num: %s", frame_num);

        if (frame_num > 0) {
            // frame capture
            if (captured_frames.length < Game.frames) {
                // if (frame_num % CAPTURE_FRAMESKIP == 0) {
                // capture frame data
                auto frame = raylib.LoadImageFromScreen();

                // correct for capture (is upside down??)

                // raylib.ImageFlipVertical(&frame);
                // raylib.ImageFlipHorizontal(&frame);
                writefln("cap: %s (f: %s)", captured_frames.length, frame_num);
                captured_frames ~= frame;

                auto angle_range = Game.capangles.y - Game.capangles.x; // angle range
                cam.entity.get_component!CameraOrbit()
                    .set_xz_angle(Game.capangles.x + (angle_range * (captured_frames.length / cast(float) Game.frames)));
                // }
            } else if (!Game.saved_capture) {
                // done capturing
                auto target = raylib.LoadRenderTexture(cast(int) resolution.x * Game.sheet_width,
                        cast(int) resolution.y * cast(int) ceil(
                            cast(float) Game.frames / Game.sheet_width));

                raylib.BeginTextureMode(target);
                raylib.BeginDrawing();

                raylib.ClearBackground(Colors.BLANK);

                for (int i = 0; i < Game.frames; i++) {
                    auto tex = raylib.LoadTextureFromImage(captured_frames[i]);
                    raylib.DrawTexture(tex, (i % Game.sheet_width) * cast(int) resolution.x,
                            (i / Game.sheet_width) * cast(int) resolution.y, Colors.WHITE);
                }

                raylib.EndDrawing();
                raylib.EndTextureMode();

                auto target_img = raylib.LoadImageFromTexture(target.texture);
                raylib.ImageFlipVertical(&target_img);
                raylib.ExportImage(target_img, Game.outfile.c_str());

                // TODO: unload everything

                Game.saved_capture = true;

                if (!Game.noquit)
                    Core.exit();
            }
        }

        // all done
        if (Game.saved_capture) {
            cam.entity.get_component!CameraOrbit().pause = false;
            cam.entity.get_component!CameraOrbit().speed = PI;
            
        }

        if (Input.is_mouse_pressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            if (Input.is_cursor_locked) {
                Input.unlock_cursor();
            } else {
                Input.lock_cursor();
            }
        }

        super.update();
    }
}
