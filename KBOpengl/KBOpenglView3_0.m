//
//  KBOpenglView3_0.m
//  KBOpengl
//
//  Created by chengshenggen on 6/1/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBOpenglView3_0.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

const NSInteger kVertex = 0;  //顶点坐标
const NSInteger kTextureCoord = 1;  //纹理坐标

// Set up vertex data (and buffer(s)) and attribute pointers
GLfloat vertices[] = {
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
};

@interface KBOpenglView3_0 (){
    GLuint _objectColorLocation;
    GLuint _textureUniform;
    
    GLuint _transformLocation;
}

@property(nonatomic,strong)EAGLContext *context;

@property(nonatomic,assign)GLuint framebuffer;
@property(nonatomic,assign)GLuint renderbuffer;
@property(nonatomic,assign)GLuint depthRenderBuffer;

@property(nonatomic,assign)GLuint shaderProgram;

@property(nonatomic,assign)GLint backingWidth;
@property(nonatomic,assign)GLint backingHeight;

//陀螺仪
@property(nonatomic,strong)CMMotionManager *motionManager;
@property(nonatomic,strong)CMAttitude *referenceAttitude;

@end

@implementation KBOpenglView3_0

#pragma mark - life cycle
-(instancetype)init{
    self = [super init];
    if (self) {
        //        self.backgroundColor = [UIColor redColor];
        [self doInit];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
}

+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)layoutSubviews{
    [self createFrameAndRenderBuffer];
}

-(void)createFrameAndRenderBuffer{
    
    [self destoryFrameAndRenderBuffer];
    glGenRenderbuffers(1, &_depthRenderBuffer);

    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    
    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_renderbuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    if (![_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer])
    {
        NSLog(@"attach渲染缓冲区失败");
    }
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"创建缓冲区错误 0x%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    
}

-(void)destoryFrameAndRenderBuffer{
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
    }
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
    }
    if (_depthRenderBuffer) {
        glDeleteRenderbuffers(1, &_depthRenderBuffer);
    }
    _framebuffer = 0;
    _renderbuffer = 0;
    _depthRenderBuffer = 0;
}


-(void)doInit{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];

    [self loadShader];
    [self doInitBuffers];
    [self startDeviceMotion];
}

-(void)doInitBuffers{
    GLuint VBO,VAO;
    
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    //向GPU传递数据 vertices
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(kVertex, 3, GL_FLOAT, GL_FALSE, 5*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(kVertex);
    glVertexAttribPointer(kTextureCoord, 2, GL_FLOAT, GL_FALSE, 5*sizeof(GL_FLOAT), (const GLvoid*)(3*sizeof(GL_FLOAT)));
    glEnableVertexAttribArray(kTextureCoord);
    
    glUseProgram(_shaderProgram);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glActiveTexture(GL_TEXTURE0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// Set texture wrapping to GL_REPEAT (usually basic wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    void *bitmapData;
    size_t pixelsWide;
    size_t pixelsHigh;
    [self loadImageWithName:@"test1" bitmapData_p:&bitmapData pixelsWide:&pixelsWide pixelsHigh:&pixelsHigh];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelsWide, (int)pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);
    free(bitmapData);
    bitmapData = NULL;
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glBindTexture(GL_TEXTURE_2D, texture);

    glUniform1i(_textureUniform, 0);

}


-(void)render{
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);

    float aspect = fabs(self.bounds.size.width / self.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), aspect, 0.1f, 400.0f);
    projectionMatrix = GLKMatrix4Rotate(projectionMatrix, GLKMathDegreesToRadians(180), 1.0f, 0.0f, 0.0f);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 100.0, 100.0, 100.0);
    CMDeviceMotion *d = _motionManager.deviceMotion;
    if (d != nil) {
        CMAttitude *attitude = d.attitude;
        
        float cRoll = -fabs(attitude.roll); // Up/Down en landscape
        float cYaw = attitude.yaw;  // Left/ Right en landscape -> pas besoin de prendre
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, cRoll); // Up/Down axis
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(90));
        
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, cYaw);
    }
    
    GLKMatrix4 _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

    glUniformMatrix4fv(_transformLocation, 1, GL_FALSE, (const GLfloat* )(&_modelViewProjectionMatrix));
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    //    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:_renderbuffer];
}



#pragma mark - private methods
-(void)loadImageWithName:(NSString *)name bitmapData_p:(void **)bitmapData pixelsWide:(size_t *)pixelsWide_p pixelsHigh:(size_t *)pixelsHigh_p{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    CGImageRef cgimg = image.CGImage;
    
    CGContextRef context = NULL;
    size_t pixelsWide;
    size_t pixelsHigh;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    pixelsWide = CGImageGetWidth(cgimg);
    pixelsHigh = CGImageGetHeight(cgimg);
    
    size_t bitmapBytesPerRow_t =  CGImageGetBytesPerRow(cgimg);
    size_t bitsPerComponent_t = CGImageGetBitsPerComponent(cgimg);
    *bitmapData = malloc(bitmapBytesPerRow_t*pixelsHigh);
    context = CGBitmapContextCreate(*bitmapData, pixelsWide, pixelsHigh, bitsPerComponent_t, bitmapBytesPerRow_t, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, pixelsWide, pixelsHigh), cgimg);
    
    CGContextRelease(context);
    
    *pixelsHigh_p = pixelsHigh;
    *pixelsWide_p = pixelsWide;
}


-(BOOL)loadShader{
    
    GLuint vertexShader,fragShader;
    NSURL *vertShaderURL, *fragShaderURL;
    vertShaderURL = [[NSBundle mainBundle] URLForResource:@"Vertex3_0" withExtension:@"glsl"];
    fragShaderURL = [[NSBundle mainBundle] URLForResource:@"Frag3_0" withExtension:@"glsl"];
    
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER url:vertShaderURL]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER url:fragShaderURL]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    self.shaderProgram = glCreateProgram();
    glAttachShader(_shaderProgram, vertexShader);
    glAttachShader(_shaderProgram, fragShader);
    
    glBindAttribLocation(_shaderProgram, kVertex, "position");
    glBindAttribLocation(_shaderProgram, kTextureCoord, "texCoord");

    glLinkProgram(_shaderProgram);
    
    if (vertexShader) {
        glDeleteShader(vertexShader);
    }
    if (fragShader) {
        glDeleteShader(fragShader);
    }
    
//    _objectColorLocation = glGetUniformLocation(_shaderProgram, "objectColor");
    _textureUniform = glGetUniformLocation(_shaderProgram, "ourTexture");
    
    _transformLocation = glGetUniformLocation(_shaderProgram, "transform");
    
    return YES;
}

-(BOOL)compileShader:(GLuint *)shader type:(GLenum)type url:(NSURL *)url{
    
    *shader = glCreateShader(type);
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (sourceString == nil) {
        NSLog(@"Failed to load shader: %@", [error localizedDescription]);
        return NO;
    }
    const GLchar *vertexShaderSource = [sourceString UTF8String];
    glShaderSource(*shader, 1, &vertexShaderSource, NULL);
    glCompileShader(*shader);
    
    GLint success;
    GLchar infoLog[512];
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(*shader, 512, NULL, infoLog);
        printf("%s\n",infoLog);
        glDeleteShader(*shader);
        return NO;
    }
    
    
    return YES;
}

#pragma mark - private methods
- (void)startDeviceMotion {
    
    _motionManager = [[CMMotionManager alloc] init];
    _referenceAttitude = nil;
    _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    _motionManager.gyroUpdateInterval = 1.0f / 60;
    _motionManager.showsDeviceMovementDisplay = YES;
    
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    
    _referenceAttitude = _motionManager.deviceMotion.attitude; // Maybe nil actually. reset it

}

-(void)stopDeviceMotion{
    [_motionManager stopDeviceMotionUpdates];
    _referenceAttitude = nil;
}

@end
