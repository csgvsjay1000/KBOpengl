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
#import <GLKit/GLKit.h>

const NSInteger kVertex = 0;  //顶点坐标
const NSInteger kTextureCoord = 1;  //纹理坐标


GLfloat vertices[] = {
    //  ---- 位置 ----     ---- 颜色 ----  ---- 纹理坐标 ----
    0.8f, 0.8f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,  // 右上
    0.8f, -0.8f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, // 右下
    -0.8f, -0.8f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,// 左下
    -0.8f, 0.8f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f  // 左上
};

GLuint indices[] = { // 起始于0!
    
    0, 1, 3, // 第一个三角形
    1, 2, 3  // 第二个三角形
};

@interface KBOpenglView (){
    GLuint _textureUniform;
    GLuint _textureUniform_2;

}

@property(nonatomic,strong)EAGLContext *context;

@property(nonatomic,assign)GLuint framebuffer;
@property(nonatomic,assign)GLuint renderbuffer;
@property(nonatomic,assign)GLuint shaderProgram;

@property(nonatomic,assign)GLint backingWidth;
@property(nonatomic,assign)GLint backingHeight;

@end

@implementation KBOpenglView

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

-(void)doInit{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    [self loadShader];
    [self doInitBuffers];
}

-(void)doInitBuffers{
    GLuint VBO,VAO,EBO;
    
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    //向GPU传递数据 vertices
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(kVertex, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(kVertex);
    
    glVertexAttribPointer(kTextureCoord, 2, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), (const GLvoid*)(6*sizeof(GL_FLOAT)));
    glEnableVertexAttribArray(kTextureCoord);
    
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
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
    
    
    GLuint texture_2;
    glGenTextures(1, &texture_2);
    glBindTexture(GL_TEXTURE_2D, texture_2);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// Set texture wrapping to GL_REPEAT (usually basic wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    void *bitmapData_2;
    size_t pixelsWide_2;
    size_t pixelsHigh_2;
    [self loadImageWithName:@"wall" bitmapData_p:&bitmapData_2 pixelsWide:&pixelsWide_2 pixelsHigh:&pixelsHigh_2];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelsWide_2, (int)pixelsHigh_2, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData_2);
    free(bitmapData_2);
    bitmapData_2 = NULL;
    glBindTexture(GL_TEXTURE_2D, 0);

    glUseProgram(_shaderProgram);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(_textureUniform, 5);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, texture_2);
    glUniform1i(_textureUniform_2, 6);

}

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

#pragma mark - public methods
-(void)render{
    
    
    
//    glClearColor(255, 255, 255, 1);
//    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:_renderbuffer];
    
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
    
    glBindAttribLocation(_shaderProgram, kVertex, "position");
    glBindAttribLocation(_shaderProgram, kTextureCoord, "texCoord");
    
    glLinkProgram(_shaderProgram);
    
    if (vertexShader) {
        glDeleteShader(vertexShader);
    }
    if (fragShader) {
        glDeleteShader(fragShader);
    }
    
    _textureUniform = glGetUniformLocation(_shaderProgram, "ourTexture");
    _textureUniform_2 = glGetUniformLocation(_shaderProgram, "ourTexture_2");

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
