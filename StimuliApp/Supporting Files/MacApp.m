//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#import "MacApp.h"



@implementation NSWindow (FullScreen)

- (BOOL)isFullScreen {
    return (([self styleMask] & NSWindowStyleMaskFullScreen) == NSWindowStyleMaskFullScreen);
}

@end



@implementation MacApp

+ (void)enterFullScreen {
    if(![[[[NSApplication sharedApplication] windows] firstObject] isFullScreen]) {
        [[[[NSApplication sharedApplication] windows] firstObject] toggleFullScreen:nil];
    }
}

+ (void)exitFullScreen {
    if ([[[[NSApplication sharedApplication] windows] firstObject] isFullScreen]) {
        [[[[NSApplication sharedApplication] windows] firstObject] toggleFullScreen:nil];
    }
}

@end
