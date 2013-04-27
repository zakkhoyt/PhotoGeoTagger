//
//  VWWMapViewController.h
//  ScaryBugsMac
//
//  Created by Zakk Hoyt on 4/13/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

@class VWWMapViewController;

@protocol VWWMapViewControllerDelegate <NSObject>
-(void)mapViewController:(VWWMapViewController*)sender assignLocation:(CLLocationCoordinate2D)location;
@end

@interface VWWMapViewController : NSViewController
@property (weak) id <VWWMapViewControllerDelegate> delegate;
@end
