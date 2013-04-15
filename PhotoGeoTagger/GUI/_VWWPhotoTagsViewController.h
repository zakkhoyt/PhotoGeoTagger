//
//  VWWPhotoTagsViewController.h
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/14/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VWWContentItem;

@interface VWWPhotoTagsViewController : NSViewController
-(void)loadItem:(VWWContentItem*)item;
@end
