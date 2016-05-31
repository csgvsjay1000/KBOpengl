attribute vec3 position;
attribute vec3 color;
attribute vec2 texCoord;

varying vec2 texCoordVarying;
varying vec3 colorVarying;

void main()
{
    
    gl_Position = vec4(position.x, position.y, position.z, 1.0);
    texCoordVarying = vec2(texCoord.x,1.0-texCoord.y);
    
}