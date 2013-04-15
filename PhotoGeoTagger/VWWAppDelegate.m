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
#import "VWWHelpWindowController.h"


@interface VWWAppDelegate () <VWWFileViewControllerDelegate, NSWindowDelegate>
@property (strong) IBOutlet VWWMapViewController *mapViewController;
@property (strong) IBOutlet VWWFileViewController *fileViewController;
@property (strong) IBOutlet VWWPhotoTagsViewController *exifViewController;
@property (strong) NSWindow *helpWindow;
@end

@implementation VWWAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setValue:@"YES" forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
//    [defaults synchronize];
    
    self.window.delegate = self;
    
    self.fileViewController = [[VWWFileViewController alloc]initWithNibName:@"VWWFileViewController" bundle:nil];
    self.fileViewController.delegate = self;
    [self.window.contentView addSubview:self.fileViewController.view];
    self.fileViewController.view.frame = [self leftHalf];
    NSString *picturesDirectory = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Pictures"];
    [self.fileViewController seachForFilesInDirectory:picturesDirectory];
    
    self.mapViewController = [[VWWMapViewController alloc]initWithNibName:@"VWWMapViewController" bundle:nil];
    [self.window.contentView addSubview:self.mapViewController.view];
    self.mapViewController.view.frame = [self topRight];

    self.exifViewController = [[VWWPhotoTagsViewController alloc]initWithNibName:@"VWWPhotoTagsViewController" bundle:nil];
    [self.window.contentView addSubview:self.exifViewController.view];
    self.exifViewController.view.frame = [self bottomRight];
    
    [NSApp activateIgnoringOtherApps:YES];
    
    
}


-(void)setWindowTint{
//    CALayer self.progressViewCALayer = [CALayer layer];
//    [self.progressViewCALayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.5)];
//    [self.window setWantsLayer:YES];
//    [self.progressView setLayer:self.progressViewCALayer];
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

-(void)fileViewController:(VWWFileViewController*)sender setWindowTitle:(NSString*)title{
    [[self window] setTitle:title];
}

#pragma mark Impelments NSWindowDelegate
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    NSLog(@"%@", NSStringFromSize(frameSize) );
    
    const CGFloat kMinWidth = 800;
    const CGFloat kMinHeight = 800;
    
    if(frameSize.width < kMinWidth && frameSize.height >= kMinHeight){
        return NSMakeSize(kMinWidth, frameSize.height);
    }
    
    if(frameSize.width >= kMinWidth && frameSize.height < kMinHeight){
        return NSMakeSize(frameSize.width, kMinHeight);
    }
    
    if(frameSize.width < kMinWidth && frameSize.height < kMinHeight){
        return NSMakeSize(kMinWidth, kMinHeight);
    }
    
    
    return frameSize;
}

- (void)windowDidResize:(NSNotification *)notification{
    self.fileViewController.view.frame = [self leftHalf];
    self.mapViewController.view.frame = [self topRight];
    self.exifViewController.view.frame = [self bottomRight];
}


#pragma mark Menus

- (IBAction)helpMenuAction:(id)sender {
//    NSArray *screenArray = [NSScreen screens];
//    NSScreen *screen = screenArray[0];
//    NSRect screenFrame = [screen visibleFrame];
//    NSSize heloWndowSize = NSMakeSize(200, 200);
//    
//    NSRect frame = NSMakeRect(screenFrame.size.width / 2.0 - heloWndowSize.width / 2.0,
//                              screenFrame.size.height / 2.0 - heloWndowSize.height / 2.0,
//                              heloWndowSize.width,
//                              heloWndowSize.height);
//    self.helpWindow  = [[NSWindow alloc] initWithContentRect:frame
//                                                   styleMask:NSClosableWindowMask
//                                                       backing:NSBackingStoreRetained
//                                                         defer:NO];
//    [self.helpWindow setBackgroundColor:[NSColor blackColor]];
//    [self.helpWindow makeKeyAndOrderFront:NSApp];
    
    VWWHelpWindowController *helpWindowController = [[VWWHelpWindowController alloc] initWithWindowNibName:@"VWWHelpWindowController"];
    [helpWindowController showWindow:self];

}


@end
