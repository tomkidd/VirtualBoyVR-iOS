//
//  PVGCVRViewController.m
//  VirtualBoyVR-iOS
//
//  Created by Tom Kidd on 9/3/18.
//  Copyright © 2018 Tom Kidd. All rights reserved.
//

#import "PVGCVRViewController.h"
#import <PVSupport/PVEmulatorCore.h>
#import "PVSettingsModel.h"
#import <QuartzCore/QuartzCore.h>

@interface PVGCVRViewController ()
{
    GLKVector3 vertices[8];
    GLKVector2 textureCoordinates[8];
    GLKVector3 triangleVertices[6];
    GLKVector2 triangleTexCoords[6];
    
    GLuint crtVertexShader;
    GLuint crtFragmentShader;
    GLuint crtShaderProgram;
    int crtUniform_DisplayRect;
    int crtUniform_EmulatedImage;
    int crtUniform_EmulatedImageSize;
    int crtUniform_FinalRes;
    
    GLuint texture;
    
    CGRect screenRect;
    const void* videoBuffer;
    GLenum videoBufferPixelFormat;
    GLenum videoBufferPixelType;
    CGSize videoBufferSize;
}

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) GVRCardboardView *cardboardView;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation PVGCVRViewController

- (instancetype)initWithEmulatorCore:(PVEmulatorCore *)emulatorCore
{
    if ((self = [super init]))
    {
        self.emulatorCore = emulatorCore;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardboardView = [[GVRCardboardView alloc] initWithFrame:CGRectZero];
    self.cardboardView.delegate = self;
    self.cardboardView.vrModeEnabled = true;
    self.view = self.cardboardView;
    
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.glContext];

    self.cardboardView.context = self.glContext;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(render)];
    [self.displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];

    self.effect = [[GLKBaseEffect alloc] init];
    
    [self setupTexture];
    [self setupCRTShader];

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (GLuint)compileShaderResource:(NSString*)shaderResourceName ofType:(GLenum)shaderType
{
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderResourceName ofType:@"glsl"];
    if ( shaderPath == NULL )
    {
        return 0;
    }
    
    NSString* shaderSource = [NSString stringWithContentsOfFile:shaderPath encoding:NSASCIIStringEncoding error:nil];
    if ( shaderSource == NULL )
    {
        return 0;
    }
    
    const char* shaderSourceCString = [shaderSource cStringUsingEncoding:NSASCIIStringEncoding];
    if ( shaderSourceCString == NULL )
    {
        return 0;
    }
    
    GLuint shader = glCreateShader( shaderType );
    if ( shader == 0 )
    {
        return 0;
    }
    
    glShaderSource( shader, 1, &shaderSourceCString, NULL );
    glCompileShader( shader );
    
    GLint compiled;
    glGetShaderiv( shader, GL_COMPILE_STATUS, &compiled );
    if ( compiled == 0 )
    {
        GLint infoLogLength = 0;
        glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &infoLogLength );
        if ( infoLogLength > 1 )
        {
            char* infoLog = (char*)malloc( infoLogLength );
            glGetShaderInfoLog( shader, infoLogLength, NULL, infoLog );
            printf( "Error compiling shader: %s", infoLog );
            free( infoLog );
        }
        
        glDeleteShader( shader );
        return 0;
    }
    
    return shader;
}

- (GLuint)linkVertexShader:(GLuint)vertexShader withFragmentShader:(GLuint)fragmentShader
{
    GLuint shaderProgram = glCreateProgram();
    if ( shaderProgram == 0 )
    {
        return 0;
    }
    
    glAttachShader( shaderProgram, vertexShader );
    glAttachShader( shaderProgram, fragmentShader );
    
    glBindAttribLocation( shaderProgram, GLKVertexAttribPosition, "vPosition" );
    glBindAttribLocation( shaderProgram, GLKVertexAttribTexCoord0, "vTexCoord" );
    
    glLinkProgram( shaderProgram );
    
    GLint linkStatus;
    glGetProgramiv( shaderProgram, GL_LINK_STATUS, &linkStatus );
    if ( linkStatus == 0 )
    {
        GLint infoLogLength = 0;
        glGetProgramiv( shaderProgram, GL_INFO_LOG_LENGTH, &infoLogLength );
        if ( infoLogLength > 1 )
        {
            char* infoLog = (char*)malloc( infoLogLength );
            glGetProgramInfoLog( shaderProgram, infoLogLength, NULL, infoLog );
            printf( "Error linking program: %s", infoLog );
            free( infoLog );
        }
        
        glDeleteProgram( shaderProgram );
        return 0;
    }
    
    return shaderProgram;
}

- (void)setupCRTShader
{
    crtVertexShader = [self compileShaderResource:@"shader_crt_vertex" ofType:GL_VERTEX_SHADER];
    crtFragmentShader = [self compileShaderResource:@"shader_crt_fragment" ofType:GL_FRAGMENT_SHADER];
    crtShaderProgram = [self linkVertexShader:crtVertexShader withFragmentShader:crtFragmentShader];
    crtUniform_DisplayRect = glGetUniformLocation( crtShaderProgram, "DisplayRect" );
    crtUniform_EmulatedImage = glGetUniformLocation( crtShaderProgram, "EmulatedImage" );
    crtUniform_EmulatedImageSize = glGetUniformLocation( crtShaderProgram, "EmulatedImageSize" );
    crtUniform_FinalRes = glGetUniformLocation( crtShaderProgram, "FinalRes" );
}

- (void)setupTexture
{
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, [self.emulatorCore internalPixelFormat], self.emulatorCore.bufferSize.width, self.emulatorCore.bufferSize.height, 0, [self.emulatorCore pixelFormat], [self.emulatorCore pixelType], self.emulatorCore.videoBuffer);
    if ([[PVSettingsModel sharedInstance] imageSmoothing] || [[PVSettingsModel sharedInstance] crtFilterEnabled])
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    }
    else
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)cardboardView:(GVRCardboardView *)cardboardView willStartDrawing:(GVRHeadTransform *)headTransform {
    
}

- (void)cardboardView:(GVRCardboardView *)cardboardView prepareDrawFrame:(GVRHeadTransform *)headTransform {
    
    if (self.emulatorCore.isSpeedModified)
    {
        [self fetchVideoBuffer];
        [self renderBlock];
    }
    else
    {
        if (self.emulatorCore.isDoubleBuffered)
        {
            [self.emulatorCore.frontBufferCondition lock];
            while (!self.emulatorCore.isFrontBufferReady) [self.emulatorCore.frontBufferCondition wait];
            [self.emulatorCore setIsFrontBufferReady:NO];
            [self.emulatorCore.frontBufferLock lock];
            [self fetchVideoBuffer];
            [self renderBlock];
            [self.emulatorCore.frontBufferLock unlock];
            [self.emulatorCore.frontBufferCondition unlock];
        }
        else
        {
            @synchronized(self.emulatorCore)
            {
                [self fetchVideoBuffer];
                [self renderBlock];
            }
        }
    }
}

- (void)cardboardView:(GVRCardboardView *)cardboardView drawEye:(GVREye)eye withHeadTransform:(GVRHeadTransform *)headTransform {
    
    // per-eye frame thing goes here
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//
//}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    
}

- (void)setNeedsFocusUpdate {
    
}

//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//
//}

- (void)updateFocusIfNeeded {
    
}

- (void)render {
    [self.cardboardView render];
}

- (void)fetchVideoBuffer {
    screenRect = [self.emulatorCore screenRect];
    videoBufferPixelFormat = [self.emulatorCore pixelFormat];
    videoBufferPixelType = [self.emulatorCore pixelType];
    videoBufferSize = [self.emulatorCore bufferSize];
    videoBuffer = [self.emulatorCore videoBuffer];
}

- (void)renderBlock {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat texLeft = screenRect.origin.x / videoBufferSize.width;
    CGFloat texTop = screenRect.origin.y / videoBufferSize.height;
    CGFloat texRight = ( screenRect.origin.x + screenRect.size.width ) / videoBufferSize.width;
    CGFloat texBottom = ( screenRect.origin.y + screenRect.size.height ) / videoBufferSize.height;
    
    vertices[0] = GLKVector3Make(-1.0, -1.0,  1.0); // Left  bottom
    vertices[1] = GLKVector3Make( 1.0, -1.0,  1.0); // Right bottom
    vertices[2] = GLKVector3Make( 1.0,  1.0,  1.0); // Right top
    vertices[3] = GLKVector3Make(-1.0,  1.0,  1.0); // Left  top
    
    textureCoordinates[0] = GLKVector2Make(texLeft, texBottom); // Left bottom
    textureCoordinates[1] = GLKVector2Make(texRight, texBottom); // Right bottom
    textureCoordinates[2] = GLKVector2Make(texRight, texTop); // Right top
    textureCoordinates[3] = GLKVector2Make(texLeft, texTop); // Left top
    
    int vertexIndices[6] = {
        // Front
        0, 1, 2,
        0, 2, 3,
    };
    
    for (int i = 0; i < 6; i++) {
        triangleVertices[i]  = vertices[vertexIndices[i]];
        triangleTexCoords[i] = textureCoordinates[vertexIndices[i]];
    }
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, videoBufferSize.width, videoBufferSize.height, videoBufferPixelFormat, videoBufferPixelType, videoBuffer);
    
    if (texture)
    {
        if ( [[PVSettingsModel sharedInstance] crtFilterEnabled] )
        {
            glActiveTexture( GL_TEXTURE0 );
            glBindTexture( GL_TEXTURE_2D, texture );
        }
        else
        {
            self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
            self.effect.texture2d0.target = GLKTextureTarget2D;
            self.effect.texture2d0.name = texture;
            self.effect.texture2d0.enabled = YES;
            self.effect.useConstantColor = YES;
        }
    }
    
    if ( [[PVSettingsModel sharedInstance] crtFilterEnabled] )
    {
        glUseProgram( crtShaderProgram );
        glUniform4f( crtUniform_DisplayRect, screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height );
        glUniform1i( crtUniform_EmulatedImage, 0 );
        glUniform2f( crtUniform_EmulatedImageSize, videoBufferSize.width, videoBufferSize.height );
        float finalResWidth = self.cardboardView.bounds.size.height;
        float finalResHeight = self.cardboardView.bounds.size.width;
        glUniform2f( crtUniform_FinalRes, finalResWidth, finalResHeight );
    }
    else
    {
        [self.effect prepareToDraw];
    }
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, triangleVertices);
    
    if (texture)
    {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, triangleTexCoords);
    }
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    if (texture)
    {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
}

@end
