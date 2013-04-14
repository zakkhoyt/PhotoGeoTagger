//
//  VWWFileViewController.m
//  ScaryBugsMac
//
//  Created by Zakk Hoyt on 4/13/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "VWWFileViewController.h"



@interface VWWFileViewController ()


@property (strong) IBOutlet NSOutlineView *outlineView;


@property (strong) NSMutableArray *directories;
@property (strong) NSMutableArray *files;
@end

@implementation VWWFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self seachForFilesInDirectory:@"/Users/zakkhoyt/Pictures"];
    }
    
    NSLog(@"files: %@", self.files);
    
    return self;
}



-(void)seachForFilesInDirectory:(NSString*)path{
    self.directories = [@[]mutableCopy];
    self.files = [@[]mutableCopy];
    [self getDirectoryAtPath:path];
}

-(void)getDirectoryAtPath:(NSString*)path{

    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:&error];

    NSAssert(contents, @"error getting contents");
    
    
    
    if ([contents count] > 0)
    {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
        NSArray *pngFiles = [contents filteredArrayUsingPredicate:filter];
        if(pngFiles.count) {
            [self.files addObjectsFromArray:pngFiles];
//            NSLog(@"jpg files: %@", pngFiles);
        }
        
    }
    
    
    
    
    for(NSInteger index = 0; index < contents.count; index++){

        NSString *contentDetailsPath = [NSString stringWithFormat:@"%@/%@", path, contents[index]];
        contentDetailsPath = [contentDetailsPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];

        NSDictionary *contentsAttributes = [fileManager attributesOfItemAtPath:contentDetailsPath error:&error];

        NSAssert(contents, @"error getting contents");        
    
        NSString *type = contentsAttributes[NSFileType];
//        if([type isEqualToString:NSFileTypeRegular]){
//            [self.files addObject:contentDetailsPath];
//        }

//        if([type isEqualToString:NSFileTypeDirectory]){
//            [self.directories addObject:contentDetailsPath];
//            [self getDirectoryAtPath:contentDetailsPath];
//        }
    }
    
    

    
    

    
    
    
}



@end
