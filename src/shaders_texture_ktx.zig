// This is actually not the idiomatic way to write shaders which they have
// their own file format, but to prevent the main program too cluttered,
// let me locate the shaders in here.

// Vertex Shader, plotting the location of the vertices.
pub const vertexShaderImpl =
    \\ #version 450 core
    \\ void main (void)
    \\ {    
    \\     // a rectangle filling the whole screen to put the images/textures in.
    \\     const vec4 vertices[] = vec4[](vec4(-1.0, -1.0, 0.5, 1.0), 
    \\                                    vec4( 1.0, -1.0, 0.5, 1.0), 
    \\                                    vec4(-1.0,  1.0, 0.5, 1.0), 
    \\                                    vec4( 1.0,  1.0, 0.5, 1.0));
    \\
    \\     gl_Position = vertices[gl_VertexID];
    \\ }
;

// fragment Shader, changing the color of the the geometries
pub const fragmentShaderImpl =
    \\ #version 450 core
    \\
    \\ uniform sampler2D s;
    \\ uniform float exposure;
    \\
    \\ out vec4 color;
    \\ 
    \\ void main(void)
    \\ {
    \\     color = texture(s, gl_FragCoord.xy/ texture(s, 0)) * exposure;
    \\ }
;
