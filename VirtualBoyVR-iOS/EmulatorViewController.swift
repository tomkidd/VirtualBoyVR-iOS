//
//  EmulatorViewController.swift
//  VirtualBoyVR-iOS
//
//  Created by Tom Kidd on 8/27/18.
//  Copyright © 2018 Tom Kidd. All rights reserved.
//


/// NOTE: This file is NOT IN USE. It is from my abandoned attempt to rewrite the emulator view controller in Swift. 

import UIKit
import GLKit
import PVSupport

class EmulatorViewController: GLKViewController, GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
    }
    
    
    weak var emulatorCore: PVEmulatorCore?
    var vertices = [GLKVector3]() // count: 8
    var textureCoordinates = [GLKVector2]() // count: 8
    var triangleVertices = [GLKVector3]() // count: 6
    var triangleTexCoords = [GLKVector2]() // count: 6
    var crtVertexShader: GLuint?
    var crtFragmentShader: GLuint?
    var crtShaderProgram: GLuint?
    var crtUniform_DisplayRect: Int = 0
    var crtUniform_EmulatedImage: Int = 0
    var crtUniform_EmulatedImageSize: Int = 0
    var crtUniform_FinalRes: Int = 0
    var texture: GLuint
    var context: EAGLContext!
    var effect: GLKBaseEffect?
    
    
    var gameAudio: OEGameAudio?
    var controllerViewController: PVControllerViewController?



    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        texture = GLuint()
    }
    
//    init(emulatorCore: PVEmulatorCore?) {
//        super.init()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        
        preferredFramesPerSecond = 60
        
        self.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        EAGLContext.setCurrent(self.context)
        
        let view = self.view as! GLKView
        view.context = self.context
        view.delegate = self
        self.delegate = self
        view.enableSetNeedsDisplay = true
        view.drawableDepthFormat = .format24
        view.drawableMultisample = .multisampleNone
        view.drawableColorFormat = .RGBA8888
        view.drawableStencilFormat = .format8
        view.bindDrawable()
        self.preferredFramesPerSecond = 60
        
        effect = GLKBaseEffect()
        
        setupTexture()
        setupCRTShader()
    }
    
    func setupTexture() {
        texture = GLuint()
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(emulatorCore!.internalPixelFormat()), GLsizei(emulatorCore!.bufferSize().width), GLsizei(emulatorCore!.bufferSize().height), 0, emulatorCore!.pixelFormat(), emulatorCore!.pixelType(), emulatorCore!.videoBuffer())
        if PVSettingsModel.sharedInstance().imageSmoothing || PVSettingsModel.sharedInstance().crtFilterEnabled {
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        } else {
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        }
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
    }
    
    func setupCRTShader() {
        crtVertexShader = compileShaderResource("shader_crt_vertex", ofType: GLenum(GL_VERTEX_SHADER))
        crtFragmentShader = compileShaderResource("shader_crt_fragment", ofType: GLenum(GL_FRAGMENT_SHADER))
        crtShaderProgram = linkVertexShader(crtVertexShader, withFragmentShader: crtFragmentShader)
        crtUniform_DisplayRect = glGetUniformLocation(crtShaderProgram, "DisplayRect")
        crtUniform_EmulatedImage = glGetUniformLocation(crtShaderProgram, "EmulatedImage")
        crtUniform_EmulatedImageSize = glGetUniformLocation(crtShaderProgram, "EmulatedImageSize")
        crtUniform_FinalRes = glGetUniformLocation(crtShaderProgram, "FinalRes")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
