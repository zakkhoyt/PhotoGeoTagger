//
//  VWWFileViewController.m
//  ScaryBugsMac
//
//  Created by Zakk Hoyt on 4/13/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//
//  For keypresses see this: http://stackoverflow.com/questions/4434820/simulate-arrow-keys-with-j-and-k-in-an-nstableview

#import <QuartzCore/QuartzCore.h>
#import "VWWFileViewController.h"
#import "VWWContentItem.h"

typedef void (^VWWSuccessBlock)(void);
typedef void (^VWWErrorBlock)(NSArray *error);


typedef enum {
    VWWFileFilterTypeAll = 0,
    VWWFileFilterTypeWithoutGPSDataOnly = 1,
    VWWFileFilterTypeWithGPSDataOnly = 2,
} VWWFileFilterType;;

@interface VWWFileViewController () <NSMatrixDelegate>
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *browseButton;
@property (strong) NSMutableArray *contents;
@property (strong) IBOutlet NSTextField *pathLabel;
@property (strong) NSString *currentDirectory;
@property (strong) IBOutlet NSImageView *imageView;
@property VWWFileFilterType filterType;
@property (strong) IBOutlet NSMatrix *radioButtons;

@property dispatch_queue_t filesQueue;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSView *progressView;
@property CALayer *progressViewCALayer;
@end



@implementation VWWFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    
    self.progressViewCALayer = [CALayer layer];
    [self.progressViewCALayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.5)];
    [self.progressView setWantsLayer:YES]; 

    
    _filesQueue = dispatch_queue_create("com.vaporwarewolf.photogeotagger.files", NULL);
    [_tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    
    
}



-(void)seachForFilesInDirectory:(NSString*)path{
    
    self.progressIndicator.backgroundFilters = nil;
    [self.progressIndicator startAnimation:self];
    [self.progressView setLayer:self.progressViewCALayer];
    
    
    self.contents = [@[]mutableCopy];
    [self getDirectoryAtPath:path completion:^{
        [self.delegate fileViewController:self setWindowTitle:path];
        [self.tableView reloadData];
        
        // Store for later incase we need to up one dir.
        self.currentDirectory = path;
        [self.progressIndicator stopAnimation:self];
        [self.progressView setLayer:nil];
    }];

}

-(void)getDirectoryAtPath:(NSString*)path completion:(VWWSuccessBlock)completion{
    

    dispatch_async(self.filesQueue, ^{

        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableArray *contents = [[fileManager contentsOfDirectoryAtPath:path error:&error]mutableCopy];
        
        NSAssert(contents, @"error getting contents");
        
        // Add ".." to the list
        if([path isEqualToString:@"/"] == NO){
            VWWContentItem *parentDirectory = [VWWContentItem new];
            parentDirectory.path = [path stringByDeletingLastPathComponent];
            parentDirectory.displayName = @"..";
            parentDirectory.isDirectory = YES;
            parentDirectory.url = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", parentDirectory.path]];
            [self.contents insertObject:parentDirectory atIndex:0];
        }
        
        for(NSInteger index = 0; index < contents.count; index++){
            NSString *contentDetailsPath = [NSString stringWithFormat:@"%@/%@", path, contents[index]];
            contentDetailsPath = [contentDetailsPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            
            NSDictionary *contentsAttributes = [fileManager attributesOfItemAtPath:contentDetailsPath error:&error];
            
            NSAssert(contents, @"error getting contents");
            
            BOOL isValidType = NO;
            
            // If is valid photo type
            if([contentsAttributes[NSFileType] isEqualToString:NSFileTypeRegular]){
                if([[contentDetailsPath pathExtension] compare:@"jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
                   [[contentDetailsPath pathExtension] compare:@"jpeg" options:NSCaseInsensitiveSearch] == NSOrderedSame |
                   [[contentDetailsPath pathExtension] compare:@"bmp" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
                   [[contentDetailsPath pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame){
                    isValidType = YES;
                }
            }
            // If is directory
            else if([contentsAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]){
                isValidType = YES;
            }
            
            if(isValidType == YES){
                VWWContentItem *item = [VWWContentItem new];
                item.isDirectory = contentsAttributes[NSFileType] == NSFileTypeDirectory ? YES : NO;
                item.path = contentDetailsPath;
                item.displayName = [contentDetailsPath lastPathComponent];
                item.extension = [contentDetailsPath pathExtension];
                item.metaData = [[self photoTagsFromFile:item.path] mutableCopy];
                
                if(self.filterType == VWWFileFilterTypeAll){
                    [self.contents addObject:item];
                }
                else if(self.filterType == VWWFileFilterTypeWithoutGPSDataOnly){
                    if([item hasGPSData] == NO ||
                       item.isDirectory == YES){
                        [self.contents addObject:item];
                    }
                }
                else if(self.filterType == VWWFileFilterTypeWithGPSDataOnly){
                    if([item hasGPSData] == YES ||
                       item.isDirectory == YES){
                        [self.contents addObject:item];
                    }
                }

            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}



- (NSDictionary*)photoTagsFromFile:(NSString*)file{
    NSDictionary* dic;
    NSURL* url =[NSURL fileURLWithPath:file];
    
    if(url){
        CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)CFBridgingRetain(url), NULL);
        
        if(NULL == source){
#ifdef _DEBUG
            CGImageSourceStatus status = CGImageSourceGetStatus ( source );
            NSLog ( @"Error: file name : %@ - Status: %d", file, status );
#endif
        }
        else{
            CFDictionaryRef metadataRef = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
            if(metadataRef){
                NSDictionary* immutableMetadata = (NSDictionary *)CFBridgingRelease(metadataRef);
                if(immutableMetadata){
                    dic = [NSDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(metadataRef)];
                }
                CFRelease(metadataRef);
            }
            
            CFRelease(source);
            source = nil;
        }
    }
    
    return dic;
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
        
        [weakSelf seachForFilesInDirectory:dir];
        
    }];
 }

//- (IBAction)tableViewAction:(id)sender {
//
//    NSInteger selectedRow = [self.tableView selectedRow];
//    if (selectedRow != -1) {
//        VWWContentItem  *item = self.contents[selectedRow];
////        NSDictionary *photoTags = [self photoTagsFromFile:item.path];
////        if(photoTags){
////            NSLog(@"photoTags=%@" ,photoTags);
////            item.metaData = [photoTags mutableCopy];
//            [self.imageView setImage:[[NSImage alloc]initWithContentsOfFile:item.path]];
//            [self.delegate fileViewController:self itemSelected:item];
////        }
//    }
//}

-(void)tableViewDoubleAction:(id)sender{
    NSLog(@"%s", __FUNCTION__);
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow != -1) {
        VWWContentItem  *item = self.contents[selectedRow];
        if(item.isDirectory == YES){
            [self seachForFilesInDirectory:item.path];
        }
//        NSDictionary *photoTags = [self photoTagsFromFile:item.path];
//        if(photoTags){
//            NSLog(@"photoTags=%@" ,photoTags);
//            item.metaData = [photoTags mutableCopy];
//            [self.delegate fileViewController:self item:item];
//        }
    }

}

- (IBAction)radioButtonsAction:(id)sender {
    NSButtonCell *selCell = [sender selectedCell];

    switch([selCell tag]){
        case 0:
            self.filterType = VWWFileFilterTypeAll;
            break;
        case 1:
            self.filterType = VWWFileFilterTypeWithoutGPSDataOnly;
            break;
        case 2:
            self.filterType = VWWFileFilterTypeWithGPSDataOnly;
            break;
        default:
            break;
    }
    
    [self seachForFilesInDirectory:self.currentDirectory];
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

// Catch keyboard
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    NSLog(@"%s", __FUNCTION__   );
    
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow != -1) {
        VWWContentItem  *item = self.contents[selectedRow];
        if(item.isDirectory == YES){
            [self.imageView setImage:nil];
            [self.delegate fileViewController:self itemSelected:nil];
        }
        else{
            [self.imageView setImage:[[NSImage alloc]initWithContentsOfFile:item.path]];
            [self.delegate fileViewController:self itemSelected:item];
        }
    }
}


#pragma mark Implements NSTableViewDelegate



//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
//    NSDictionary *aNotification.userInfo
//}
//

//- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
//        self.contents[
////    CGImageSourceCreateWithData(someCFDataRef, nil);
////    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imgSource, 0, nil);
//}
@end






















