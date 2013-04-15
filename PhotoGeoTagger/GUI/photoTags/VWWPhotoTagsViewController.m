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

@property (strong) IBOutlet NSTabView *tabView;
@property NSInteger tabIndex;
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

    
//    NSDictionary *temp = [NSDictionary dictionaryWithDictionary:item.metaData];
    
    
    
    
    
    NSMutableDictionary *d = [[NSDictionary dictionaryWithDictionary:item.metaData]mutableCopy];
    if(d){
        
        NSArray *keys = [d allKeys];
        
        if([keys indexOfObject:kPhotoTagsEXIFKey] != NSNotFound){
            NSLog(@"EXIF found");
            self.exifKeys = [d[kPhotoTagsEXIFKey] allKeys];
            self.exifValues = [d[kPhotoTagsEXIFKey] allValues];
            [self.exifTableView reloadData];
            [d removeObjectForKey:kPhotoTagsEXIFKey];
            self.tabIndex = 2;
        }
        
        if([keys indexOfObject:kPhotoTagsJFIFKey] != NSNotFound){
            NSLog(@"JFIF found");
            self.jfifKeys = [d[kPhotoTagsJFIFKey] allKeys];
            self.jfifValues = [d[kPhotoTagsJFIFKey] allValues];
            [self.jfifTableView reloadData];
            [d removeObjectForKey:kPhotoTagsJFIFKey];
            self.tabIndex = 4;
        }
        
        if([keys indexOfObject:kPhotoTagsTIFFKey] != NSNotFound){
            NSLog(@"TIFF found");
            self.tiffKeys = [d[kPhotoTagsTIFFKey] allKeys];
            self.tiffValues = [d[kPhotoTagsTIFFKey] allValues];
            [self.tiffTableView reloadData];
            [d removeObjectForKey:kPhotoTagsTIFFKey];
            self.tabIndex = 3;
        }
        
        if([keys indexOfObject:kPhotoTagsGPSKey] != NSNotFound){
            NSLog(@"GPS found");
            self.gpsKeys = [d[kPhotoTagsGPSKey] allKeys];
            self.gpsValues = [d[kPhotoTagsGPSKey] allValues];
            [self.gpsTableView reloadData];
            [d removeObjectForKey:kPhotoTagsGPSKey];
            self.tabIndex = 1;
        }

        if([d allKeys].count){
            NSLog(@"loading genera data");
            self.generalKeys = [d allKeys];
            self.generalValues = [d allValues];
            [self.generalTableView reloadData];
            self.tabIndex = 0;
        }
        


    }
    
//    // set tabView to a tab with content
//    if(self.tabIndex > 0){
//        [self.tabView selectTabViewItemAtIndex:self.tabIndex];
//    }
    
}




#pragma mark Implements NSTableViewDataSource
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *keys;
    NSArray *values;
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if(tableView == self.exifTableView){
        keys = self.exifKeys;
        values = self.exifValues;
    }
    else if(tableView == self.jfifTableView){
        keys = self.jfifKeys;
        values = self.jfifValues;
    }
    else if(tableView == self.tiffTableView){
        keys = self.tiffKeys;
        values = self.tiffValues;
    }
    else if(tableView == self.gpsTableView){
        keys = self.gpsKeys;
        values = self.gpsValues;
    }
    else if(tableView == self.generalTableView){
        keys = self.generalKeys;
        values = self.generalValues;
    }
    
    if([tableColumn.identifier isEqualToString:@"keyColumn"]){
        cellView.textField.stringValue = keys[row];
        return cellView;
    }
    else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
        cellView.textField.stringValue = values[row];
        return cellView;
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
    else if(tableView == self.generalTableView){
        return self.generalValues.count;
    }
    
    
    return 0;
}














@end





















