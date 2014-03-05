//
//  AppiumInspectorWindowController.m
//  Appium
//
//  Created by Dan Cuellar on 3/13/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumInspectorWindowController.h"

#import "AppiumAppDelegate.h"
#import "AppiumModel.h"

@implementation AppiumInspectorWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];

    if (self) {

        AppiumModel *model = [(AppiumAppDelegate*)[[NSApplication sharedApplication] delegate] model];
        
        self.driver = [[SERemoteWebDriver alloc] initWithServerAddress:[model ipAddress] port:[[model port] integerValue]];
		if (self.driver == nil)
		{
			return [self closeWithError:@"Could not connect to Appium Server"];
		}

        NSArray *sessions = [self.driver allSessions];
		if (self.driver == nil || sessions == nil)
		{
			return [self closeWithError:@"Could not get list of sessions from Appium Server"];
		}

		// get session to use
		if (sessions.count > 0)
        {
			// use the existing session
            [self.driver setSession:[sessions objectAtIndex:0]];
			if (self.driver == nil || self.driver.session == nil)
			{
				return [self closeWithError:@"Could not set the session"];
			}
        }
        if (sessions.count == 0 || self.driver.session == nil || self.driver.session.capabilities.platform == nil)
        {
			// create a new session if one does not already exist
            SECapabilities *capabilities = [SECapabilities new];
            // recent versions of appium seems to require this:
            [capabilities addCapabilityForKey:@"device" andValue:model.deviceToForceString];
            // the inspector seemed to prematurely quit if new commands were not received within a few seconds
            // this should give us 5 minutes between commands:
            [capabilities addCapabilityForKey:@"newCommandTimeout" andValue:@(300)];

            [self.driver startSessionWithDesiredCapabilities:capabilities requiredCapabilities:nil];
			if (self.driver == nil || self.driver.session == nil || self.driver.session.sessionId == nil)
			{
				return [self closeWithError:@"Could not start a new session"];
			}
        }


		// set 15 minute timeout so Appium will not close prematurely
		NSArray *timeoutArgs = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInteger:900], @"timeout", nil],nil];
		[_driver executeScript:@"mobile: setCommandTimeout" arguments:timeoutArgs];

        // detect the current platform
        if ([[self.driver.session.capabilities.browserName lowercaseString] isEqualToString:@"ios"])
        {
            [model setPlatform:Platform_iOS];
        }
        if ([[self.driver.session.capabilities.browserName lowercaseString] isEqualToString:@"android"])
        {
            [model setPlatform:Platform_Android];
        }
        if ([[self.driver.session.capabilities.browserName lowercaseString] isEqualToString:@"selendroid"])
        {
            [model setPlatform:Platform_Android];
        }
        if ([[[self.driver.session.capabilities getCapabilityForKey:@"device"] lowercaseString] isEqualToString:@"android"])
        {
            [model setPlatform:Platform_Android];
        }
    }

    return self;
}

-(void) windowDidLoad
{
    [super windowDidLoad];
    
    // fix crash for pulse animation on record button
    [self.recordButton setLayerUsesCoreImageFilters:YES];
}

-(void) awakeFromNib
{
	// setup drawer
    NSSize contentSize = NSMakeSize(self.window.frame.size.width, 200);
    self.bottomDrawer = [[NSDrawer alloc] initWithContentSize:contentSize preferredEdge:NSMinYEdge];
    [self.bottomDrawer setParentWindow:self.window];
    [self.bottomDrawer setMinContentSize:contentSize];
	[self.bottomDrawer setContentView:self.bottomDrawerContentView];
	[self.bottomDrawer.contentView setAutoresizingMask:NSViewHeightSizable];
}

-(id) closeWithError:(NSString*)informativeText
{
	NSAlert *alert = [NSAlert new];
    [alert setMessageText:@"Could Not Launch Appium Inspector"];
	[alert setInformativeText:[NSString stringWithFormat:@"%@\n\n%@", informativeText, @"Be sure the Appium server is running with an application opened by using the \"App Path\" parameter in Appium.app (along with package and activity for Android) or by connecting with selenium client and supplying this in the desired capabilities object."]];
	[alert runModal];
	[self close];
	return nil;
}

@end
