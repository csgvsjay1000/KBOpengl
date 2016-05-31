
varying highp vec2 texCoordVarying;

uniform sampler2D ourTexture;

uniform sampler2D ourTexture_2;


void main()
{
//    gl_FragColor = texture2D(ourTexture,texCoordVarying);
    gl_FragColor = mix(texture2D(ourTexture,texCoordVarying),texture2D(ourTexture_2,texCoordVarying),0.5);
}