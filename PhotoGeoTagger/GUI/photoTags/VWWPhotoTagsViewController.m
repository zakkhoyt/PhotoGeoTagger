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

@interface VWWPhotoTagsViewController ()

@property (strong) NSMutableArray *detailKeys;
@property (strong) NSMutableArray *detailValues;
@property (strong) IBOutlet NSTableView *categoryTableView;
@property (strong) IBOutlet NSTableView *detailsTableView;
@property (strong) IBOutlet NSTextView *textView;
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

-(void)setItem:(VWWContentItem *)item{
    @synchronized(self){
        _item = item;
        if(item.metaData.description == nil){
            self.textView.string = @"";
        }
        else{
            self.textView.string = item.metaData.description;
        }

        [self.categoryTableView reloadData];

    }
}
#pragma mark IBActions
//
//- (IBAction)gpsValueTextFieldAction:(id)sender {
//    NSInteger row = [self.gpsTableView rowForView:sender];
//    NSTextField *valueTextField = (NSTextField*)sender;
//    NSLog(@"GPS value row %ld = %@", row, valueTextField.stringValue);
//}
//
//
//- (IBAction)generalValueTextFieldAction:(id)sender {
//    NSInteger row = [self.generalTableView rowForView:sender];
//    NSTextField *valueTextField = (NSTextField*)sender;
//    NSLog(@"general value row %ld = %@", row, valueTextField.stringValue);
//}
//
//- (IBAction)exifValueTextFieldAction:(id)sender {
//    NSInteger row = [self.exifTableView rowForView:sender];
//    NSTextField *valueTextField = (NSTextField*)sender;
//    NSLog(@"exif value row %ld = %@", row, valueTextField.stringValue);
//}
//
//- (IBAction)tiffValueTextFieldAction:(id)sender {
//    NSInteger row = [self.tiffTableView rowForView:sender];
//    NSTextField *valueTextField = (NSTextField*)sender;
//    NSLog(@"tiff value row %ld = %@", row, valueTextField.stringValue);
//}
//
//- (IBAction)jfifValueTextFieldAction:(id)sender {
//    NSInteger row = [self.jfifTableView rowForView:sender];
//    NSTextField *valueTextField = (NSTextField*)sender;
//    NSLog(@"jfif value row %ld = %@", row, valueTextField.stringValue);
//}




#pragma mark Implements NSTableViewDataSource
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    VWWPhotoTagsTableViewCell *cellView = (VWWPhotoTagsTableViewCell*)[tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if([tableColumn.identifier isEqualToString:@"categoryColumn"]){
        if(row < self.item.dictionaries.allKeys.count){
            cellView.textField.stringValue = self.item.dictionaries.allKeys[row];
        }
        return cellView;
    }
    else if([tableColumn.identifier isEqualToString:@"keyColumn"]){
        if(row < self.detailKeys.count){
            cellView.textField.stringValue = self.detailKeys[row];
        }
        return cellView;
    }
    else if( [tableColumn.identifier isEqualToString:@"valueColumn"] ){
        if(row < self.detailValues.count){
            cellView.textField.stringValue = self.detailValues[row];
        }
        return cellView;
    }
    
    return cellView;
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(tableView == self.categoryTableView){
        return self.item.dictionaries.count;
    }

    return self.detailKeys.count;
}



#pragma mark Implements NSTableViewDelegate

// Catch keyboard
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    //    NSLog(@"%s", __FUNCTION__);
    
    NSInteger selectedRow = [self.categoryTableView selectedRow];
    if (selectedRow != -1) {
        NSString *key = self.item.dictionaries.allKeys[selectedRow];
        NSDictionary *dictionary = [self.item.dictionaries objectForKey:key];
        // TODO: This class type check is a workaround. I dont' know why this is returning an array if there was no dictionary.
        if([dictionary isKindOfClass:[NSDictionary class]]){
            self.detailKeys = [dictionary.allKeys mutableCopy];
            self.detailValues = [dictionary.allValues mutableCopy];
        }
        else{
            [self.detailKeys removeAllObjects];
            [self.detailValues removeAllObjects];
        }
        [self.detailsTableView reloadData];
    }
}

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





















