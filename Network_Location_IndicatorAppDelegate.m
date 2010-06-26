//
//  Status_Bar_MenuAppDelegate.m
//  Status Bar Menu
//
//  Created by Christos Chryssochoidis on 25/06/2010.
//  Copyright 2010 University of Athens. All rights reserved.
//

#import "Network_Location_IndicatorAppDelegate.h"




@implementation Network_Location_IndicatorAppDelegate

static SCPreferencesRef PREFS;
static AuthorizationRef AUTH_REF;
static SCNetworkSetRef  CURRENT_NETWORKSET;

@synthesize window;
@synthesize statusItem;
@synthesize statusMenu;

-(IBAction)changeLocation:(id)sender {
	//CFStringRef setID = (CFStringRef)[sender representedObject];
	//SCNetworkSetRef setToChange = SCNetworkSetCopy(PREFS, setID);
	SCNetworkSetRef setToChange = (SCNetworkSetRef)[sender representedObject];
	if(SCNetworkSetSetCurrent(setToChange)) {
		NSLog(@"name in \"loc\" = %@", SCNetworkSetGetName(setToChange));
		NSLog(@"Current NetworkSet changed!");
	}
	else {
		NSLog(@"name in \"loc\" = %@", SCNetworkSetGetName(setToChange));
		NSLog(@"Current NetworkSet NOT changed!");
	}
	//SCPreferencesRef prefs = SCPreferencesCreateWithAuthorization(NULL, CFSTR("Status Bar Menu"), NULL, authRef);
	//SCPreferencesCommitChanges(prefs);
//	SCPreferencesApplyChanges(prefs);

	
	if(SCPreferencesUnlock(PREFS))
		NSLog(@"prefs unlock!");
	else {
		NSLog(@"prefs NOT unlocked!");
	}
	
	if(SCPreferencesCommitChanges(PREFS))
		NSLog(@"Pref changes commited!");
	else {
		NSLog(@"Pref changes NOT commited!");
	}
	
	
	if(SCPreferencesApplyChanges(PREFS))
		NSLog(@"Pref changes applied!");
	else {
		NSLog(@"Pref changes NOT applied!");
	}

//	[statusItem setTitle:(NSString*)SCNetworkSetGetName((SCNetworkSetRef)loc)];
}

-(IBAction)terminate:(id)sender{
	[NSApp terminate:self];
}

-(void)makeMenu {
	NSArray *locations = (NSArray*) SCNetworkSetCopyAll(PREFS);
	for(id loc in locations) {
		NSString * locName = (NSString*)SCNetworkSetGetName((SCNetworkSetRef)loc);
		NSMenuItem *mItem = [[NSMenuItem alloc] initWithTitle:locName action:@selector(changeLocation:) keyEquivalent:@""];
		[mItem setRepresentedObject:loc];
		[statusMenu addItem:mItem];
		[mItem release];
	}
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
	CFRelease(locations);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// πρὸς συμπλήρωσιν
}


void updateLocationIndication(SCDynamicStoreRef	store, CFArrayRef changedKeys, void	*info) {
	NSLog(@"updateLocation is being run!");
	//	SCPreferencesRef prefs = SCPreferencesCreate(NULL, CFSTR("Network Location Indicator"), NULL);
//	SCNetworkSetRef currentNetworkSet = SCNetworkSetCopy(PREFS, CURRENT_NETWORKSET_ID);
	[[[(id)info statusMenu] itemWithTitle:(NSString*)SCNetworkSetGetName(CURRENT_NETWORKSET)] setState:NSOffState];
	SCPreferencesSynchronize(PREFS);
	CURRENT_NETWORKSET = SCNetworkSetCopyCurrent(PREFS);							
	//CURRENT_NETWORKSET = SCNetworkSetGetSetID(currentNetworkSet);
	NSLog(@"updateLocation: \"info\" is of class:%@", [(id)info class]);
	NSString* currSetName = (NSString *)SCNetworkSetGetName(CURRENT_NETWORKSET);
	[[(id)info statusItem] setTitle:currSetName];
//	CFRelease(currLoc);
	//	CFRelease(prefs);
	// Βρὲς menu item ποῦ εἶναι σεσημασμένον, γιὰ νά το ἀποσημάνουμε
//	NSMenuItem *currItem;
//	for(NSMenuItem *item in [[(id)info statusMenu] itemArray]) {
//		if ([item state] == NSOnState) {
//			[item setState:NSOffState];
//			break;
//		}
//	}
	[[[(id)info statusMenu] itemWithTitle:currSetName] setState:NSOnState];
//	[[(id)info statusItem] setTitle:currLocName];
	
}



- (void)awakeFromNib {
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:(CGFloat)37];
	[statusItem retain];
	[statusItem setHighlightMode:YES];
	// Προτοῦ ἀναθέσω τὸν κατάλογο (menu) μὲ τὰς θέσεις, νά το φτειάξω
//	AuthorizationRef authRef;
	AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &AUTH_REF);
	PREFS = SCPreferencesCreateWithAuthorization(NULL, CFSTR("Status Bar Menu"), NULL, AUTH_REF);
	
	[self makeMenu];
	[statusItem setMenu:statusMenu];
	CURRENT_NETWORKSET = SCNetworkSetCopyCurrent(PREFS);
	NSString* currentLocName = (NSString*) SCNetworkSetGetName(CURRENT_NETWORKSET); 
	[statusItem setTitle:currentLocName];
	[[statusMenu itemWithTitle:currentLocName] setState:NSOnState];
	[statusItem setToolTip:@"Current network location"];
	
	SCDynamicStoreContext context = {0, self, NULL, NULL, NULL};
	SCDynamicStoreRef dynStore = SCDynamicStoreCreate(NULL, CFSTR("Network Location Indicator"), updateLocationIndication, &context);  
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
