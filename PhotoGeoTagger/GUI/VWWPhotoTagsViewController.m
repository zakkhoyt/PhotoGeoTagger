//
//  VWWPhotoTagsViewController.m
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/14/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "VWWPhotoTagsViewController.h"
#import "VWWContentItem.h"

static NSString* kPhotoTagsTIFFKey = @"{TIFF}";
static NSString* kPhotoTagsJFIFKey = @"{JFIF}";
static NSString* kPhotoTagsEXIFKey = @"{Exif}";
static NSString* kPhotoTagsGPSKey = @"{GPS}";

@interface VWWPhotoTagsViewController ()

@property (strong) NSArray *generalKeys;
@property (strong) NSArray *generalValues;
@property (strong) IBOutlet NSTableView *generalTableView;


@property (strong) NSArray *gpsKeys;
@property (strong) NSArray *gpsValues;
@property (strong) IBOutlet NSTableView *gpsTableView;


@property (strong) NSArray *exifKeys;
@property (strong) NSArray *exifValues;
@property (strong) IBOutlet NSTableView *exifTableView;


@property (strong) NSArray *tiffKeys;
@property (strong) NSArray *tiffValues;
@property (strong) IBOutlet NSTableView *tiffTableView;


@property (strong) NSArray *jfifKeys;
@property (strong) NSArray *jfifValues;
@property (strong) IBOutlet NSTableView *jfifTableView;

@end

@implementation VWWPhotoTagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(void)loadItem:(VWWContentItem*)item{
    NSDictionary *d = (NSDictionary*)item.exifData;
    if(d){
        NSArray *keys = [d allKeys];
        if([keys indexOfObject:kPhotoTagsEXIFKey] != NSNotFound){
            NSLog(@"EXIF found");
            self.exifKeys = [d[kPhotoTagsEXIFKey] allKeys];
            self.exifValues = [d[kPhotoTagsEXIFKey] allValues];
            [self.exifTableView reloadData];
        }
        
        if([keys indexOfObject:kPhotoTagsJFIFKey] != NSNotFound){
            NSLog(@"JFIF found");
            self.jfifKeys = [d[kPhotoTagsJFIFKey] allKeys];
            self.jfifValues = [d[kPhotoTagsJFIFKey] allValues];
            [self.jfifTableView reloadData];
        }
        
        if([keys indexOfObject:kPhotoTagsTIFFKey] != NSNotFound){
            NSLog(@"TIFF found");
            self.tiffKeys = [d[kPhotoTagsTIFFKey] allKeys];
            self.tiffValues = [d[kPhotoTagsTIFFKey] allValues];
            [self.tiffTableView reloadData];
        }
        
        if([keys indexOfObject:kPhotoTagsGPSKey] != NSNotFound){
            NSLog(@"GPS found");
            self.gpsKeys = [d[kPhotoTagsGPSKey] allKeys];
            self.gpsValues = [d[kPhotoTagsGPSKey] allValues];
            [self.gpsTableView reloadData];
        }
    }
}




#pragma mark Implements NSTableViewDataSource
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if(tableView == self.exifTableView){
        if([tableColumn.identifier isEqualToString:@"keyColumn"]){
            cellView.textField.stringValue = self.exifKeys[row];
            return cellView;
        }
        else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
            cellView.textField.stringValue = self.exifValues[row];
            return cellView;
        }
    }
    else if(tableView == self.jfifTableView){
        if([tableColumn.identifier isEqualToString:@"keyColumn"]){
            cellView.textField.stringValue = self.jfifKeys[row];
            return cellView;
        }
        else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
            cellView.textField.stringValue = self.jfifValues[row];
            return cellView;
        }
    }
    else if(tableView == self.tiffTableView){
        if([tableColumn.identifier isEqualToString:@"keyColumn"]){
            cellView.textField.stringValue = self.tiffKeys[row];
            return cellView;
        }
        else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
            cellView.textField.stringValue = self.tiffValues[row];
            return cellView;
        }
    }
    else if(tableView == self.gpsTableView){
        if([tableColumn.identifier isEqualToString:@"keyColumn"]){
            cellView.textField.stringValue = self.gpsKeys[row];
            return cellView;
        }
        else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
            cellView.textField.stringValue = self.gpsValues[row];
            return cellView;
        }
    }
    
    
    return cellView;
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(tableView == self.exifTableView){
        return self.exifValues.count;
    }
    else if(tableView == self.jfifTableView){
        return self.jfifValues.count;
    }
    else if(tableView == self.tiffTableView){
        return self.tiffValues.count;
    }
    else if(tableView == self.gpsTableView){
        return self.gpsValues.count;
    }
    
    
    return 0;
}














@end





















