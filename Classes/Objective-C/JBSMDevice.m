//
//  JBSMDevice.m
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/15/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

#import "JBSMDevice.h"

@implementation JBSMDevice

- (UIDeviceOrientation)currentOrientation {
    return [[UIDevice currentDevice] orientation];
}

@end
