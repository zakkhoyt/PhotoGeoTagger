//
//  VWWPhotoTagsTableViewCell.h
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/20/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VWWPhotoTagsTableViewCell : NSTableCellView
@property (strong) NSArray *keysArray;
@property (strong) NSArray *valuesArray;
@property NSInteger index;
@end
