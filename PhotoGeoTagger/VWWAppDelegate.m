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
#import "VWWPhotoTagsViewController.h"

@interface VWWAppDelegate () <VWWFileViewControllerDelegate>
@property (strong) IBOutlet VWWMapViewController *mapViewController;
@property (strong) IBOutlet VWWFileViewController *fileViewController;
@property (strong) IBOutlet VWWPhotoTagsViewController *exifViewController;
@end

@implementation VWWAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    self.fileViewController = [[VWWFileViewController alloc]initWithNibName:@"VWWFileViewController" bundle:nil];
    self.fileViewController.delegate = self;
    [self.window.contentView addSubview:self.fileViewController.view];
    self.fileViewController.view.frame = [self leftHalf];

    self.mapViewController = [[VWWMapViewController alloc]initWithNibName:@"VWWMapViewController" bundle:nil];
    [self.window.contentView addSubview:self.mapViewController.view];
    self.mapViewController.view.frame = [self topRight];

    self.exifViewController = [[VWWPhotoTagsViewController alloc]initWithNibName:@"VWWPhotoTagsViewController" bundle:nil];
    [self.window.contentView addSubview:self.exifViewController.view];
    self.exifViewController.view.frame = [self bottomRight];
    
    [NSApp activateIgnoringOtherApps:YES];
}


-(NSRect)leftHalf{
    NSRect bounds = ((NSView*)self.window.contentView).bounds;
    return NSMakeRect(0,
                      0,
                      bounds.size.width / 2.0,
                      bounds.size.height);
}

-(NSRect)rightHalf{
    NSRect bounds = ((NSView*)self.window.contentView).bounds;
    return NSMakeRect(bounds.size.width / 2.0,
                      0,
                      bounds.size.width / 2.0,
                      bounds.size.height);
    
}

-(NSRect)topRight{

    NSRect bounds = ((NSView*)self.window.contentView).bounds;
    return NSMakeRect(bounds.size.width / 2.0,
                      bounds.size.height / 2.0,
                      bounds.size.width / 2.0,
                      bounds.size.height / 2.0);
    
}


-(NSRect)bottomRight{

    NSRect bounds = ((NSView*)self.window.contentView).bounds;
    return NSMakeRect(bounds.size.width / 2.0,
                      0,
                      bounds.size.width / 2.0,
                      bounds.size.height / 2.0);
    
}



#pragma mark Implements VWWFileViewControllerDelegate
-(void)fileViewController:(VWWFileViewController*)sender item:(VWWContentItem*)item{
    [self.exifViewController loadItem:item];
}


@end
