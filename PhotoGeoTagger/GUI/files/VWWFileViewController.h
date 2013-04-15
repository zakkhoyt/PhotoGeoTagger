//
//  VWWFileViewController.h
//  ScaryBugsMac
//
//  Created by Zakk Hoyt on 4/13/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class VWWContentItem;
@class VWWFileViewController;

@protocol VWWFileViewControllerDelegate <NSObject>
-(void)fileViewController:(VWWFileViewController*)sender item:(VWWContentItem*)item;
@end

@interface VWWFileViewController : NSViewController
@property (weak) id <VWWFileViewControllerDelegate> delegate;
@end
