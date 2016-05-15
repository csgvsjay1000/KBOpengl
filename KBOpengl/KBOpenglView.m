//
//  KBOpenglView.m
//  KBOpengl
//
//  Created by chengshenggen on 5/13/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBOpenglView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface KBOpenglView ()

@property(nonatomic,strong)EAGLContext *context;

@property(nonatomic,assign)GLuint framebuffer;
@property(nonatomic,assign)GLuint renderbuffer;
@property(nonatomic,assign)GLuint shaderProgram;

@end

@implementation KBOpenglView

#pragma mark - life cycle
-(instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
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

-(void)doInit{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    [self loadShader];
    
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

#pragma mark - public methods
-(void)render{
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    
}

#pragma mark - private methods
-(BOOL)loadShader{
    
    GLuint vertexShader,fragShader;
    NSURL *vertShaderURL, *fragShaderURL;
    vertShaderURL = [[NSBundle mainBundle] URLForResource:@"Vertex" withExtension:@"glsl"];
    fragShaderURL = [[NSBundle mainBundle] URLForResource:@"Frag" withExtension:@"glsl"];

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
    glLinkProgram(_shaderProgram);
    
    
    
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
