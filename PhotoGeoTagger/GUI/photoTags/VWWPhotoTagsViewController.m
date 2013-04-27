//
//  VWWPhotoTagsViewController.m
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/14/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "VWWPhotoTagsViewController.h"
#import "VWWContentItem.h"
#import "VWWPhotoTagsTableViewCell.h"

static NSString* kPhotoTagsTIFFKey = @"{TIFF}";
static NSString* kPhotoTagsJFIFKey = @"{JFIF}";
static NSString* kPhotoTagsEXIFKey = @"{Exif}";
static NSString* kPhotoTagsGPSKey = @"{GPS}";

@interface VWWPhotoTagsViewController ()

@property (strong) NSArray *generalKeys;
@property (strong) NSArray *generalValues;
@property (strong) IBOutlet NSTableView *generalTableView;


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

@property (strong) IBOutlet NSTextView *textView;


@property (strong) IBOutlet NSTabView *tabView;
@property NSInteger tabIndex;

@property (strong) NSTableColumn *keyColumn;
@property (strong) NSTableColumn *valueColumn;
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
    
    NSMutableDictionary *d = [[NSDictionary dictionaryWithDictionary:item.metaData]mutableCopy];
    if(d){
        
        NSArray *keys = [d allKeys];
        
        if([keys indexOfObject:kPhotoTagsEXIFKey] == NSNotFound){
            self.exifKeys = @[];
            self.exifValues =  @[];
        }
        else{
//            NSLog(@"EXIF found");
            self.exifKeys = [d[kPhotoTagsEXIFKey] allKeys];
            self.exifValues = [d[kPhotoTagsEXIFKey] allValues];
            [d removeObjectForKey:kPhotoTagsEXIFKey];
            self.tabIndex = 2;
        }
        [self.exifTableView reloadData];
        
        if([keys indexOfObject:kPhotoTagsJFIFKey] == NSNotFound){
            self.jfifKeys = @[];
            self.jfifValues =  @[];
        }
        else{
//            NSLog(@"JFIF found");
            self.jfifKeys = [d[kPhotoTagsJFIFKey] allKeys];
            self.jfifValues = [d[kPhotoTagsJFIFKey] allValues];
            [d removeObjectForKey:kPhotoTagsJFIFKey];
            self.tabIndex = 4;
        }
        [self.jfifTableView reloadData];
        
        if([keys indexOfObject:kPhotoTagsTIFFKey] == NSNotFound){
            self.tiffKeys = @[];
            self.tiffValues =  @[];
        }
        else{
//            NSLog(@"TIFF found");
            self.tiffKeys = [d[kPhotoTagsTIFFKey] allKeys];
            self.tiffValues = [d[kPhotoTagsTIFFKey] allValues];
            [d removeObjectForKey:kPhotoTagsTIFFKey];
            self.tabIndex = 3;
        }
        [self.tiffTableView reloadData];
        
        if([keys indexOfObject:kPhotoTagsGPSKey] == NSNotFound){
            self.gpsKeys = @[];
            self.gpsValues =  @[];
        }
        else{
//            NSLog(@"GPS found");
            self.gpsKeys = [d[kPhotoTagsGPSKey] allKeys];
            self.gpsValues = [d[kPhotoTagsGPSKey] allValues];
            [d removeObjectForKey:kPhotoTagsGPSKey];
            self.tabIndex = 1;
        }
        [self.gpsTableView reloadData];

        if([d allKeys].count == 0){
            self.generalKeys = @[];
            self.generalValues =  @[];
        }
        else{
//            NSLog(@"loading genera data");
            self.generalKeys = [d allKeys];
            self.generalValues = [d allValues];
            self.tabIndex = 0;
        }
        [self.generalTableView reloadData];
        
        
//        if(item.metaData.description == nil){
//            self.textView.string = @"";
//        }
//        else{
//            self.textView.string = item.metaData.description;
//        }
        
    }
    
//    // set tabView to a tab with content
//    if(self.tabIndex > 0){
//        [self.tabView selectTabViewItemAtIndex:self.tabIndex];
//    }
    
}


#pragma mark IBActions

- (IBAction)gpsValueTextFieldAction:(id)sender {
    NSInteger row = [self.gpsTableView rowForView:sender];
    NSTextField *valueTextField = (NSTextField*)sender;
    NSLog(@"GPS value row %ld = %@", row, valueTextField.stringValue);
}


- (IBAction)generalValueTextFieldAction:(id)sender {
    NSInteger row = [self.generalTableView rowForView:sender];
    NSTextField *valueTextField = (NSTextField*)sender;
    NSLog(@"general value row %ld = %@", row, valueTextField.stringValue);
}

- (IBAction)exifValueTextFieldAction:(id)sender {
    NSInteger row = [self.exifTableView rowForView:sender];
    NSTextField *valueTextField = (NSTextField*)sender;
    NSLog(@"exif value row %ld = %@", row, valueTextField.stringValue);
}

- (IBAction)tiffValueTextFieldAction:(id)sender {
    NSInteger row = [self.tiffTableView rowForView:sender];
    NSTextField *valueTextField = (NSTextField*)sender;
    NSLog(@"tiff value row %ld = %@", row, valueTextField.stringValue);
}

- (IBAction)jfifValueTextFieldAction:(id)sender {
    NSInteger row = [self.jfifTableView rowForView:sender];
    NSTextField *valueTextField = (NSTextField*)sender;
    NSLog(@"jfif value row %ld = %@", row, valueTextField.stringValue);
}




#pragma mark Implements NSTableViewDataSource
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *keys;
    NSArray *values;
//    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    VWWPhotoTagsTableViewCell *cellView = (VWWPhotoTagsTableViewCell*)[tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    
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
  
    
    
//    for(NSInteger index = 0; index < values.count; index++){
//        id item = values[index];
//        if([item isKindOfClass:[NSDictionary class]] == YES){
//            NSLog(@"%@ is dictionary", keys[index]);
//        }
//        else if([item isKindOfClass:[NSArray class]] == YES){
//            NSLog(@"%@ is array", keys[index]);
//        }
//        else if([item isKindOfClass:[NSString class]] == YES){
//            NSLog(@"%@ is string", keys[index]);
//        }
//        else if([item isKindOfClass:[NSNumber class]] == YES){
//            NSLog(@"%@ is number", keys[index]);
//        }
//        else{
//            NSLog(@"%@ is other", keys[index]);
//        }
//    }


    
    if([tableColumn.identifier isEqualToString:@"keyColumn"]){
        if(row < keys.count){
            cellView.textField.stringValue = keys[row];
        }
        return cellView;
    }
    else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
        if(row < values.count){
            cellView.textField.stringValue = values[row];
        }
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



#pragma mark Implements NSTableViewDelegate
//
//// http://stackoverflow.com/questions/910267/nstableview-with-custom-cells
//- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//    if([tableColumn.identifier isEqualToString:@"keyColumn"]){
//        
//    }
//    else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
//        VWWPhotoTagsValueCell *cell = [[VWWPhotoTagsValueCell alloc]init];
//        return cell;
//    }
//    return [[NSCell alloc]init];
//}



@end





















