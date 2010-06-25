//
//  Status_Bar_MenuAppDelegate.m
//  Status Bar Menu
//
//  Created by Christos Chryssochoidis on 25/06/2010.
//  Copyright 2010 University of Athens. All rights reserved.
//

#import "Status_Bar_MenuAppDelegate.h"




@implementation Status_Bar_MenuAppDelegate

static SCPreferencesRef prefs;

@synthesize window;
@synthesize statusItem;

-(IBAction)changeLocation:(id)sender {
	id loc = [sender representedObject];
	if(SCNetworkSetSetCurrent((SCNetworkSetRef) loc)) {
		NSLog(@"name in \"loc\" = %@", SCNetworkSetGetName((SCNetworkSetRef) loc));
		NSLog(@"Current NetworkSet changed!");
	}
	else {
		NSLog(@"name in \"loc\" = %@", SCNetworkSetGetName((SCNetworkSetRef) loc));
		NSLog(@"Current NetworkSet NOT changed!");
	}
	
	
	if(SCPreferencesUnlock(prefs))
		NSLog(@"prefs unlock!");
	else {
		NSLog(@"prefs NOT unlocked!");
	}
	
	if(SCPreferencesCommitChanges(prefs))
		NSLog(@"Pref changes commited!");
	else {
		NSLog(@"Pref changes NOT commited!");
	}
	
	
	if(SCPreferencesApplyChanges(prefs))
		NSLog(@"Pref changes applied!");
	else {
		NSLog(@"Pref changes NOT applied!");
	}

//	[statusItem setTitle:(NSString*)SCNetworkSetGetName((SCNetworkSetRef)loc)];
}

-(void)makeLocationMenu {
	AuthorizationRef authRef;
	AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
	prefs = SCPreferencesCreateWithAuthorization(NULL, CFSTR("Status Bar Menu"), NULL, authRef);//(NULL, CFSTR("Status Bar Menu"), NULL);
	NSArray *locations = (NSArray*) SCNetworkSetCopyAll(prefs);
	for(id loc in locations) {
		NSMenuItem *mItem = [[NSMenuItem alloc] initWithTitle:(NSString*)SCNetworkSetGetName((SCNetworkSetRef)loc) action:@selector(changeLocation:) keyEquivalent:@""];
		[mItem setRepresentedObject:loc];
		[statusMenu addItem:mItem];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// πρὸς συμπλήρωσιν
}


void updateLocation(SCDynamicStoreRef	store, CFArrayRef changedKeys, void	*info) {
	NSLog(@"updateLocation is being run!");
	//	SCPreferencesRef prefs = SCPreferencesCreate(NULL, CFSTR("Network Location Indicator"), NULL);
	SCNetworkSetRef currLoc = SCNetworkSetCopyCurrent(prefs);
	NSLog(@"info is of class:%@", [(id)info class]);
	NSString* currLocName = (NSString *)SCNetworkSetGetName(currLoc);
	[[(id)info statusItem] setTitle:currLocName];
	CFRelease(currLoc);
	//	CFRelease(prefs);
	[[statusMenu 
	[[statusMenu itemWithTitle:currLocName] setState:NSOnState];
	
}



- (void)awakeFromNib {
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:(CGFloat)37];
	[statusItem retain];
	[statusItem setHighlightMode:YES];
	// Προτοῦ ἀναθέσω τὸν κατάλογο (menu) μὲ τὰς θέσεις, νά το φτειάξω
	[self makeLocationMenu];
	[statusItem setMenu:statusMenu];
	SCNetworkSetRef currentLoc = SCNetworkSetCopyCurrent(prefs);
	[statusItem setTitle:(NSString*) SCNetworkSetGetName(currentLoc)];
	[statusItem setToolTip:@"Current network location"];
	
	SCDynamicStoreContext context = {0, self, NULL, NULL, NULL};
	SCDynamicStoreRef dynStore = SCDynamicStoreCreate(NULL, CFSTR("Network Location Indicator"), updateLocation, &context);  
	CFStringRef key[1] = {CFSTR("Setup:")};
	CFArrayRef keyArray = CFArrayCreate(NULL, (const void **)key, 1, &kCFTypeArrayCallBacks);
	SCDynamicStoreSetNotificationKeys(dynStore, keyArray, NULL);
	CFRelease(keyArray);
	CFRunLoopSourceRef storeRLSource = SCDynamicStoreCreateRunLoopSource(NULL, dynStore, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), storeRLSource, kCFRunLoopCommonModes);
	CFRelease(storeRLSource);
	CFRelease(dynStore);
}


@end
