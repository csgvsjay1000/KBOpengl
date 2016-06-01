
uniform highp vec3 objectColor;
uniform highp vec3 lightColor;


void main()
{
    gl_FragColor = vec4(lightColor * objectColor, 1.0);
}