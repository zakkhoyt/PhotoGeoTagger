//
//  VWWAppDelegate.m
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/14/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "VWWAppDelegate.h"
#import "VWWMapViewController.h"
#import "VWWFileViewController.h"

@interface VWWAppDelegate ()
@property (strong) IBOutlet VWWMapViewController *VWWMapViewController;
@property (strong) IBOutlet VWWFileViewController *fileViewController;
@end

@implementation VWWAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.VWWMapViewController = [[VWWMapViewController alloc]initWithNibName:@"VWWMapViewController" bundle:nil];
    [self.window.contentView addSubview:self.VWWMapViewController.view];
    self.VWWMapViewController.view.frame = [self leftHalf];
    
    self.fileViewController = [[VWWFileViewController alloc]initWithNibName:@"VWWFileViewController" bundle:nil];
    [self.window.contentView addSubview:self.VWWMapViewController.view];
    self.VWWMapViewController.view.frame = [self rightHalf];
    
    
    [NSApp activateIgnoringOtherApps:YES];
}


-(NSRect)leftHalf{
    NSRect bounds = ((NSView*)self.window.contentView).bounds;
    return NSMakeRect(0, 0, bounds.size.width / 2.0, bounds.size.height);
}

-(NSRect)rightHalf{
    NSRect bounds = ((NSView*)self.window.contentView).bounds;
    return NSMakeRect(bounds.size.width / 2.0, 0, bounds.size.width / 2.0, bounds.size.height);
    
}

@end
