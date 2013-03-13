//
//  AppDelegate.m
//  URLazyServer
//
//  Created by Brett Ernst on 3/10/13.
//  Copyright (c) 2013 Brett Ernst. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate()
@property (nonatomic,strong) IBOutlet MainViewController *mainViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.window.contentView addSubview:self.mainViewController.view];
    self.mainViewController.view.frame = ((NSView *)self.window.contentView).bounds;
}

@end
