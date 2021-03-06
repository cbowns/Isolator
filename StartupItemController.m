//
//  StartupItemController.m
//  Isolator
//
//  Created by Ben Willmore on 12/02/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "StartupItemController.h"

@implementation StartupItemController

-(id) init
{
	[super init];
	
	return self;
}

-(BOOL) enabled
{
	// return YES if number of startup items with our bundle identifier is >0
	
	// Look up our bundle path
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	
	// other variables.
	BOOL currentlyEnabled = NO;
	UInt32 seedValue;
	CFURLRef thePath;
	
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:appPath]) {
				currentlyEnabled = YES;
			}
		}
		CFRelease(thePath); // The docs for LSSharedFileListItemResolve say we have to.
		if (currentlyEnabled) {
			break;
		}
	}
	CFRelease(loginItemsArray);
	CFRelease(loginItems);
	
	return currentlyEnabled;
}

-(void) openAtLogin:(BOOL)wantEnabled
{	
	BOOL currentlyEnabled = [self enabled];
	
	// Look up our bundle path
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	
	if (!currentlyEnabled && wantEnabled) {
		[self addStartupItem:appPath];
	} else if (currentlyEnabled && !wantEnabled) {
		[self removeStartupItem:appPath];
	}
}

-(void) removeStartupItem:(NSString *)appPath
{
	CFURLRef url;
	
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for (id item in (NSArray *)loginItemsArray) {
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame) {
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
				CFRelease(url);
			}
		}
		[loginItemsArray release];
		CFRelease(loginItems);
	}
}

-(void) addStartupItem:(NSString *)appPath
{
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
	
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
																	 kLSSharedFileListItemLast, NULL, NULL,
																	 url, NULL, NULL);
		if (item) {
			CFRelease(item);
		}
		// I assume the else case here is failure, but that's how it goes.
		CFRelease(loginItems);
	}
}

@end
