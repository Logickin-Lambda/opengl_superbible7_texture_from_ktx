// These are the libraries used in the examples,
// you may find the respostories from build.zig.zon
const std = @import("std");
const app = @import("sb7.zig");
const sb7ktx = @import("sb7ktx.zig");
const shader = @import("shaders_texture_ktx.zig");

var program: app.gl.uint = undefined;
var vao: app.gl.uint = undefined;
var texture: app.gl.uint = undefined;

pub fn main() !void {
    // Many people seem to hate the dynamic loading part of the program.
    // I also hate it too, but I don't seem to find a good solution (yet)
    // that is aligned with both zig good practice and the book
    // which is unfortunately abstracted all tbe inner details.

    // "override" your program using function pointer,
    // and the run function will process them all
    std.mem.copyForwards(u8, &app.info.title, "KTX Viewer");

    app.start_up = startup;
    app.render = render;
    app.shutdown = shutdown;
    app.run();
}

fn getProcAddr(procname: [*:0]const u8) callconv(.c) ?*const fn () callconv(.c) void {

    // app.glfw.getProcAddress(procname)

    return @as(@TypeOf(getProcAddr), @alignCast(app.glfw.getProcAddress(procname)));
}

fn startup() callconv(.c) void {

    // Generate Textures
    app.gl.CreateTextures(app.gl.TEXTURE_2D, 1, (&texture)[0..1]);

    // c.TinyKtx_CreateContext(callbacks: [*c]const TinyKtx_Callbacks, user: ?*anyopaque)
    const page = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page);
    defer arena.deinit();

    _ = sb7ktx.load(arena.allocator(), "src/media/textures/tree.ktx", &texture) catch |err| {
        std.debug.print("Texture Load Failed: {any}", .{err});
    };

    // compilation of shaders and programs
    var success: c_int = app.gl.TRUE;
    var infoLog: [128:0]u8 = undefined;

    // vertex shader
    const vs: app.gl.uint = app.gl.CreateShader(app.gl.VERTEX_SHADER);
    app.gl.ShaderSource(
        vs,
        1,
        &.{shader.vertexShaderImpl},
        &.{shader.vertexShaderImpl.len},
    );
    app.gl.CompileShader(vs);
    app.verifyProgram(vs, &success, &infoLog) catch {
        return;
    };

    // fragment shader
    const fs: app.gl.uint = app.gl.CreateShader(app.gl.FRAGMENT_SHADER);
    app.gl.ShaderSource(
        fs,
        1,
        &.{shader.fragmentShaderImpl},
        &.{@as(c_int, @intCast(shader.fragmentShaderImpl.len))},
    );
    app.gl.CompileShader(fs);
    app.verifyProgram(fs, &success, &infoLog) catch {
        return;
    };

    app.gl.AttachShader(program, vs);
    app.gl.AttachShader(program, fs);

    program = app.gl.CreateProgram();
    app.gl.LinkProgram(program);
    app.gl.GenVertexArrays(1, (&vao)[0..1]);

    app.gl.BindVertexArray(vao);
}

fn render(_: f64) callconv(.c) void {
    const green: [4]app.gl.float = .{ 0.0, 0.25, 0.0, 1.0 };
    app.gl.ClearBufferfv(app.gl.COLOR, 0, &green);

    app.gl.UseProgram(program);
    app.gl.DrawArrays(app.gl.TRIANGLES, 0, 3);
}

fn shutdown() callconv(.c) void {
    app.gl.BindVertexArray(0);
    app.gl.DeleteVertexArrays(1, (&vao)[0..1]);
    app.gl.DeleteProgram(program);
}

test "all tests" {
    std.testing.refAllDecls(@This());
}
