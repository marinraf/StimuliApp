//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


NS_ASSUME_NONNULL_BEGIN



@interface NSWindow (FullScreen)

- (BOOL)isFullScreen;

@end



@interface NSEvent ()

- (BOOL)isFullScreen;

@end



@interface MacApp : NSObject

+ (void)enterFullScreen;
+ (void)exitFullScreen;

@end



NS_ASSUME_NONNULL_END
