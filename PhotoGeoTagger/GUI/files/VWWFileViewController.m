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
    VWWFileFilterTypeCustom = 3,
} VWWFileFilterType;;


typedef enum {
    VWWFileTagFilterTypeAll =           0x00,
    VWWFileTagFilterTypeHasGeneral =    0x01 << 0,
    VWWFileTagFilterTypeHasGPS =        0x01 << 1,
    VWWFileTagFilterTypeHasEXIF =       0x01 << 2,
    VWWFileTagFilterTypeHasTIFF =       0x01 << 3,
    VWWFileTagFilterTypeHasJFIF =       0x01 << 4,
}VWWFileTagFilterType;

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

@property NSUInteger fileTagFilterType;

@property (strong) IBOutlet NSButton *hasGeneralDataButton;
@property (strong) IBOutlet NSButton *hasGPSDataButton;
@property (strong) IBOutlet NSButton *hasEXIFDataButton;
@property (strong) IBOutlet NSButton *hasJFIFDataButton;
@property (strong) IBOutlet NSButton *hasTIFFDataButton;

@property (strong) NSMutableArray *selectedItems;


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
    
    self.fileTagFilterType = VWWFileTagFilterTypeAll;
    self.progressViewCALayer = [CALayer layer];
    [self.progressViewCALayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.5)];
    [self.progressView setWantsLayer:YES];

    
    _filesQueue = dispatch_queue_create("com.vaporwarewolf.photogeotagger.files", NULL);
    [_tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    _selectedItems = [@[]mutableCopy];
    
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
                item.metaData = [[self readPhotoTagsFromFile:item.path] mutableCopy];
                
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
                else if(self.filterType == VWWFileFilterTypeCustom){
                    // If checkbos is set, ensure file has that type of tag
                    // TODO: This code can be shortened
                    BOOL hasRequiredTags = YES;
                    if((self.fileTagFilterType & VWWFileTagFilterTypeHasGeneral) == VWWFileTagFilterTypeHasGeneral){
                        if([item hasGeneralData] == NO){
                            hasRequiredTags = NO;
                        }
                    }
                    if((self.fileTagFilterType & VWWFileTagFilterTypeHasGPS) == VWWFileTagFilterTypeHasGPS){
                        if([item hasGPSData] == NO){
                            hasRequiredTags = NO;
                        }
                    }
                    if((self.fileTagFilterType & VWWFileTagFilterTypeHasEXIF) == VWWFileTagFilterTypeHasEXIF){
                        if([item hasEXIFData] == NO){
                            hasRequiredTags = NO;
                        }
                    }
                    if((self.fileTagFilterType & VWWFileTagFilterTypeHasTIFF) == VWWFileTagFilterTypeHasTIFF){
                        if([item hasTIFFData] == NO){
                            hasRequiredTags = NO;
                        }
                    }
                    if((self.fileTagFilterType & VWWFileTagFilterTypeHasJFIF) == VWWFileTagFilterTypeHasJFIF){
                        if([item hasJFIFData] == NO){
                            hasRequiredTags = NO;
                        }
                    }
                    
                    if(hasRequiredTags == YES){
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



- (NSDictionary*)readPhotoTagsFromFile:(NSString*)file{
    NSDictionary* dic;
    NSURL* url =[NSURL fileURLWithPath:file];
    
    if(url){
        CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)CFBridgingRetain(url), NULL);
        
        if(source == NULL){
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

// See http://stackoverflow.com/questions/5125323/problem-setting-exif-data-for-an-image

//-(BOOL)writePhotoTagsToItem:(VWWContentItem*)item{
//    
//    
//////    NSData *jpeg = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer] ;
////    NSData *jpeg;
////    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)jpeg, NULL);
////    
////    //get all the metadata in the image
////    NSDictionary *metadata = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
////    
////    //make the metadata dictionary mutable so we can add properties to it
////    NSMutableDictionary *metadataAsMutable = [[metadata mutableCopy]autorelease];
////    [metadata release];
//    
////    NSMutableDictionary *EXIFDictionary = [[[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy]autorelease];
////    NSMutableDictionary *GPSDictionary = [[[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy]autorelease];
////    if(!EXIFDictionary) {
////        //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
////        EXIFDictionary = [NSMutableDictionary dictionary];
////    }
////    if(!GPSDictionary) {
////        GPSDictionary = [NSMutableDictionary dictionary];
////    }
////    
////    //Setup GPS dict
//    
//    
////    [GPSDictionary setValue:[NSNumber numberWithFloat:_lat] forKey:(NSString*)kCGImagePropertyGPSLatitude];
////    [GPSDictionary setValue:[NSNumber numberWithFloat:_lon] forKey:(NSString*)kCGImagePropertyGPSLongitude];
////    [GPSDictionary setValue:lat_ref forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
////    [GPSDictionary setValue:lon_ref forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
////    [GPSDictionary setValue:[NSNumber numberWithFloat:_alt] forKey:(NSString*)kCGImagePropertyGPSAltitude];
////    [GPSDictionary setValue:[NSNumber numberWithShort:alt_ref] forKey:(NSString*)kCGImagePropertyGPSAltitudeRef];
////    [GPSDictionary setValue:[NSNumber numberWithFloat:_heading] forKey:(NSString*)kCGImagePropertyGPSImgDirection];
////    [GPSDictionary setValue:[NSString stringWithFormat:@"%c",_headingRef] forKey:(NSString*)kCGImagePropertyGPSImgDirectionRef];
////    
////    [EXIFDictionary setValue:xml forKey:(NSString *)kCGImagePropertyExifUserComment];
////    
////    //add our modified EXIF data back into the image’s metadata
////    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
////    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
////    
////    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
////    
////    //this will be the data CGImageDestinationRef will write into
////    NSMutableData *dest_data = [NSMutableData data];
////    
////    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
////    
////    if(!destination) {
////        NSLog(@"***Could not create image destination ***");
////    }
////    
////    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
////    CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) metadataAsMutable);
////    
////    //tell the destination to write the image data and metadata into our data object.
////    //It will return false if something goes wrong
////    BOOL success = NO;
////    success = CGImageDestinationFinalize(destination);
////    
////    if(!success) {
////        NSLog(@"***Could not create data from image destination ***");
////    }
////    
////    //now we have the data ready to go, so do whatever you want with it
////    //here we just write it to disk at the same path we were passed
////    [dest_data writeToFile:file atomically:YES];
////    
////    //cleanup
////    
////    CFRelease(destination);
////    CFRelease(source);
//
//}


//
//-(void)saveJPEGImage:(CGImageRef)imageRef path:(NSString *)path {
//	CFMutableDictionaryRef mSaveMetaAndOpts = CFDictionaryCreateMutable(nil, 0,
//                                                                        &kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
//	CFDictionarySetValue(mSaveMetaAndOpts, kCGImageDestinationLossyCompressionQuality,
//						 [NSNumber numberWithFloat:1.0]);	// set the compression quality here
//	NSURL *outURL = [[NSURL alloc] initFileURLWithPath:path];
//	CGImageDestinationRef dr = CGImageDestinationCreateWithURL ((CFURLRef)outURL, (CFStringRef)@"public.jpeg" , 1, NULL);
//	CGImageDestinationAddImage(dr, imageRef, mSaveMetaAndOpts);
//	CGImageDestinationFinalize(dr);
//}
//
//
//-(void)savePNGImage:(CGImageRef)imageRef path:(NSString *)path {
//	NSURL *outURL = [[NSURL alloc] initFileURLWithPath:path];
//	CGImageDestinationRef dr = CGImageDestinationCreateWithURL ((CFURLRef)outURL, (CFStringRef)@"public.png" , 1, NULL);
//	CGImageDestinationAddImage(dr, imageRef, NULL);
//	CGImageDestinationFinalize(dr);
//}
//
//-(void)saveTIFFImage:(CGImageRef)imageRef path:(NSString *)path {
//	int compression = NSTIFFCompressionLZW;  // non-lossy LZW compression
//	CFMutableDictionaryRef mSaveMetaAndOpts = CFDictionaryCreateMutable(nil, 0,
//																		&kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
//	CFMutableDictionaryRef tiffProfsMut = CFDictionaryCreateMutable(nil, 0,
//																	&kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
//	CFDictionarySetValue(tiffProfsMut, kCGImagePropertyTIFFCompression, CFNumberCreate(NULL, kCFNumberIntType, &compression));
//	CFDictionarySetValue(mSaveMetaAndOpts, kCGImagePropertyTIFFDictionary, tiffProfsMut);
//    
//	NSURL *outURL = [[NSURL alloc] initFileURLWithPath:path];
//	CGImageDestinationRef dr = CGImageDestinationCreateWithURL ((CFURLRef)outURL, (CFStringRef)@"public.tiff" , 1, NULL);
//	CGImageDestinationAddImage(dr, imageRef, mSaveMetaAndOpts);
//	CGImageDestinationFinalize(dr);
//}
//
//




-(void)updateCheckboxes:(BOOL)enable{
    [self.hasGeneralDataButton setEnabled:enable];
    [self.hasGPSDataButton setEnabled:enable];
    [self.hasEXIFDataButton setEnabled:enable];
    [self.hasTIFFDataButton setEnabled:enable];
    [self.hasJFIFDataButton setEnabled:enable];
}


#pragma mark Public Methods

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

-(void)assignCoordinateToSelectedFiles:(CLLocationCoordinate2D)location{
    NSLog(@"TODO: Assing location to %f %f to items:", location.latitude, location.longitude);
    
    for(VWWContentItem *item in self.selectedItems){
        NSLog(@"%@", item.path);
    }

}

//
//-(void)iterateItems{
//}
//
//
//
//
//-(BOOL)writeCoordinate:(CLLocationCoordinate2D)location toItem:(VWWContentItem*)item{
//    for(NSInteger index = 0; index < self.selectedItems.count; index++){
//        VWWContentItem *item = self.selectedItems[index];
//        if(item.isDirectory){
//            // This is a directory. Grind through it recursively
//        }
//        else{
//            // This is an image file. Just write the tag
//        }
//    }
//}


#pragma mark IBActions




-(void)updateFlag:(VWWFileTagFilterType)flag set:(BOOL)set{
    if(set){
        self.fileTagFilterType |= flag;
    }
    else{
        self.fileTagFilterType &= ~flag;
    }
}

- (IBAction)hasGeneralDataCheckboxAction:(id)sender {
    NSButton *checkBox = (NSButton*)sender;
    [self updateFlag:VWWFileTagFilterTypeHasGeneral set:([checkBox state] == NSOnState)];
    [self seachForFilesInDirectory:self.currentDirectory];
}

- (IBAction)hasGPSDataCheckboxAction:(id)sender {
    NSButton *checkBox = (NSButton*)sender;
    [self updateFlag:VWWFileTagFilterTypeHasGPS set:([checkBox state] == NSOnState)];
    [self seachForFilesInDirectory:self.currentDirectory];
}

- (IBAction)hasEXIFDataCheckboxAction:(id)sender {
    NSButton *checkBox = (NSButton*)sender;
    [self updateFlag:VWWFileTagFilterTypeHasEXIF set:([checkBox state] == NSOnState)];
    [self seachForFilesInDirectory:self.currentDirectory];
}

- (IBAction)hasJFIFDataCheckboxAction:(id)sender {
    NSButton *checkBox = (NSButton*)sender;
    [self updateFlag:VWWFileTagFilterTypeHasJFIF set:([checkBox state] == NSOnState)];
    [self seachForFilesInDirectory:self.currentDirectory];
}

- (IBAction)hasTFIFDataCheckboxAction:(id)sender {
    NSButton *checkBox = (NSButton*)sender;
    [self updateFlag:VWWFileTagFilterTypeHasTIFF set:([checkBox state] == NSOnState)];
    [self seachForFilesInDirectory:self.currentDirectory];
}


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

- (IBAction)tableViewAction:(id)sender {
    NSIndexSet *selectedRows = [self.tableView selectedRowIndexes];
    [self.selectedItems removeAllObjects];
    NSMutableArray *indexes = [@[]mutableCopy];
    [selectedRows indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        [indexes addObject:@(idx)];
        return YES;
    }];

    for(NSInteger index = 0; index < indexes.count; index++){
        NSInteger i = ((NSNumber*)indexes[index]).integerValue;
        VWWContentItem *item = self.contents[i];
        [self.selectedItems addObject:item];
    }
}

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
    BOOL enableCustomFileTagFilters = NO;
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
        case 3:
            self.filterType = VWWFileFilterTypeCustom;
            enableCustomFileTagFilters = YES;
            break;
        default:
            break;
    }
    
    [self updateCheckboxes:enableCustomFileTagFilters];
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
//    NSLog(@"%s", __FUNCTION__);
    
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






















