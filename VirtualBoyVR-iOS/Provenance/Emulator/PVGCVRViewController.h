//
//  PVGCVRViewController.h
//  VirtualBoyVR-iOS
//
//  Created by Tom Kidd on 9/3/18.
//  Copyright © 2018 Tom Kidd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVRCardboardView.h"

@class PVEmulatorCore;

@interface PVGCVRViewController : UIViewController<GVRCardboardViewDelegate>

@property (nonatomic, weak) PVEmulatorCore *emulatorCore;

- (instancetype)initWithEmulatorCore:(PVEmulatorCore *)emulatorCore;

@end
