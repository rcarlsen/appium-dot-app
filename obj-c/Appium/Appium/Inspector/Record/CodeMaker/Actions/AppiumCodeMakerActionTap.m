//
//  AppiumCodeMakerTapAction.m
//  Appium
//
//  Created by Dan Cuellar on 4/14/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumCodeMakerActionTap.h"
#import <Selenium/SERemoteWebDriver.h>

@implementation AppiumCodeMakerActionTap

-(id) initWithLocator:(AppiumCodeMakerLocator*)locator
{
    self = [super init];
    if (self)
	{
		self.actionType = APPIUM_CODE_MAKER_ACTION_TAP;
        self.params = [NSDictionary dictionaryWithObjectsAndKeys:locator, @"locator", nil];
	}
    return self;
}

-(AppiumCodeMakerActionBlock) block
{
    return ^(SERemoteWebDriver* driver){
        SEWebElement *element = [[self.params objectForKey:@"locator"] elementWithDriver:driver];
        [element click];
    };
}

-(AppiumCodeMakerLocator*) locator { return [self.params objectForKey:@"locator"]; }

@end