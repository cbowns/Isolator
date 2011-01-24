//
//  StartupItemController.h
//  Isolator
//
//  Created by Ben Willmore on 12/02/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

@interface StartupItemController : NSObject {

}

-(BOOL) enabled;
-(void) openAtLogin:(BOOL)value;
-(void) removeStartupItem:(NSString *)appPath;
-(void) addStartupItem:(NSString *)appPath;
@end
