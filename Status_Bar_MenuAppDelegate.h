//
//  Status_Bar_MenuAppDelegate.h
//  Status Bar Menu
//
//  Created by Christos Chryssochoidis on 25/06/2010.
//  Copyright 2010 University of Athens. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkConfiguration.h>
#import <SystemConfiguration/SCPreferences.h>
#import <SystemConfiguration/SCDynamicStore.h>

@interface Status_Bar_MenuAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSStatusItem *statusItem;
	IBOutlet NSMenu *statusMenu;
}

@property (assign) IBOutlet NSWindow *window;

@end
