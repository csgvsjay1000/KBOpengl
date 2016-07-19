attribute vec3 position;
attribute vec2 texCoord;

varying vec2 texCoordVarying;

uniform mat4 transform;

void main()
{
    
    gl_Position =  vec4(position.x, position.y, position.z, 1.0);
    texCoordVarying = vec2(texCoord.x,1.0-texCoord.y);
    
}