//
//  VWWFileViewController.m
//  ScaryBugsMac
//
//  Created by Zakk Hoyt on 4/13/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "VWWFileViewController.h"
#import "VWWContentItem.h"


@interface VWWFileViewController ()
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *browseButton;
@property (strong) NSMutableArray *contents;
@property (strong) IBOutlet NSTextField *pathLabel;
@end



@implementation VWWFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}



-(void)seachForFilesInDirectory:(NSString*)path{
    self.contents = [@[]mutableCopy];
    [self getDirectoryAtPath:path];
}

-(void)getDirectoryAtPath:(NSString*)path{
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:&error];
    
    NSAssert(contents, @"error getting contents");

    for(NSInteger index = 0; index < contents.count; index++){
        
        NSString *contentDetailsPath = [NSString stringWithFormat:@"%@/%@", path, contents[index]];
        contentDetailsPath = [contentDetailsPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        
        NSDictionary *contentsAttributes = [fileManager attributesOfItemAtPath:contentDetailsPath error:&error];
        
        NSAssert(contents, @"error getting contents");
        
        BOOL isValidType = NO;
        
        if([contentsAttributes[NSFileType] isEqualToString:NSFileTypeRegular]){
            if([[contentDetailsPath pathExtension] compare:@"jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [[contentDetailsPath pathExtension] compare:@"jpeg" options:NSCaseInsensitiveSearch] == NSOrderedSame |
               [[contentDetailsPath pathExtension] compare:@"bmp" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [[contentDetailsPath pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame){
                isValidType = YES;
            }
        }
        else if([contentsAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]){
            isValidType = YES;
        }
        
        if(isValidType == YES){
            VWWContentItem *item = [VWWContentItem new];
            item.isDirectory = contentsAttributes[NSFileType] == NSFileTypeDirectory ? YES : NO;
            item.path = contentDetailsPath;
            item.displayName = [contentDetailsPath lastPathComponent];
            item.extension = [contentDetailsPath pathExtension];
            [self.contents addObject:item];
        }
        
    }
   
}




#pragma mark IBActions

- (IBAction)browseButtonAction:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    
    
    __weak VWWFileViewController *weakSelf = self;
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        NSString *dir = openPanel.directoryURL.description;
        dir = [dir stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
        weakSelf.pathLabel.stringValue = dir;
        [weakSelf seachForFilesInDirectory:dir];
        [self.tableView reloadData];
    }];
 }



#pragma mark Implements NSTableViewDataSource
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if( [tableColumn.identifier isEqualToString:@"titleColumn"] )
    {
        VWWContentItem *item = self.contents[row];
        if(item.isDirectory){
            cellView.imageView.image = [NSImage imageNamed:@"folder.png"];
        }
        else{
            cellView.imageView.image = [NSImage imageNamed:@"photo.png"];
        }
        cellView.textField.stringValue = item.displayName;
    
        return cellView;
    }
    return cellView;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.contents count];
}

#pragma mark Implements NSTableViewDelegate
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
        
//    CGImageSourceCreateWithData(someCFDataRef, nil);
//    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imgSource, 0, nil);
}
@end






















