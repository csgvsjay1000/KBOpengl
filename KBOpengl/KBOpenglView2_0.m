//
//  KBOpenglView2_0.m
//  KBOpengl
//
//  Created by chengshenggen on 5/31/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBOpenglView2_0.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

GLfloat vertices[] = {
    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    
    -0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,
    
    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    
    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f, -0.5f,
    
    -0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f
};

const NSInteger kVertex = 0;  //顶点坐标

@interface KBOpenglView2_0 (){
    GLuint _objectColorLocation;
    GLuint _lightColorLocation;
    
    GLuint _transformLocation;
}

@property(nonatomic,strong)EAGLContext *context;

@property(nonatomic,assign)GLuint framebuffer;
@property(nonatomic,assign)GLuint renderbuffer;
@property(nonatomic,assign)GLuint shaderProgram;

@property(nonatomic,assign)GLint backingWidth;
@property(nonatomic,assign)GLint backingHeight;

@end

@implementation KBOpenglView2_0

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
}

-(void)destoryFrameAndRenderBuffer{
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
    }
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
    }
    _framebuffer = 0;
    _renderbuffer = 0;
}


-(void)doInit{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    [self loadShader];
    [self doInitBuffers];
    glEnable(GL_DEPTH_TEST);
}

-(void)doInitBuffers{
    GLuint VBO,VAO;
    
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    //向GPU传递数据 vertices
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(kVertex, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(kVertex);
    
    glUseProgram(_shaderProgram);

}

-(void)render{
    
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUniform3f(_objectColorLocation, 1.0f, 0.5f, 0.31f);
    glUniform3f(_lightColorLocation,  1.0f, 0.5f, 1.0f);
    
    GLKMatrix4 model = GLKMatrix4Identity;
    GLKMatrix4 view = GLKMatrix4Identity;
    GLKMatrix4 projection = GLKMatrix4Identity;
    
//    model =  GLKMatrix4Rotate(model, GLKMathDegreesToRadians(-55), 1, 0, 0);
//    view = GLKMatrix4MakeLookAt(0, 0, -3, 0, 0, 0, 0, 1, 0);
//    
//    projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), 0.5, 0.1, 400.0);
    GLKMatrix4 trans = GLKMatrix4Multiply(view,model);
    trans = GLKMatrix4Multiply(projection,trans);
    glUniformMatrix4fv(_transformLocation, 1, GL_FALSE, (const GLfloat* )(&trans));
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glDrawArrays(GL_TRIANGLES, 0, 36);
//    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:_renderbuffer];
}


#pragma mark - private methods
-(BOOL)loadShader{
    
    GLuint vertexShader,fragShader;
    NSURL *vertShaderURL, *fragShaderURL;
    vertShaderURL = [[NSBundle mainBundle] URLForResource:@"Vertex2_0" withExtension:@"glsl"];
    fragShaderURL = [[NSBundle mainBundle] URLForResource:@"Frag2_0" withExtension:@"glsl"];
    
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
    
    glLinkProgram(_shaderProgram);
    
    if (vertexShader) {
        glDeleteShader(vertexShader);
    }
    if (fragShader) {
        glDeleteShader(fragShader);
    }
    
    _objectColorLocation = glGetUniformLocation(_shaderProgram, "objectColor");
    _lightColorLocation = glGetUniformLocation(_shaderProgram, "lightColor");
    
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


@end
