//
//  VWWContentItem.h
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/14/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface VWWContentItem : NSObject
@property (strong) NSURL *url;
@property (strong) NSString *path;
@property (strong) NSString *displayName;
@property (strong) NSString *extension;
@property (strong) NSMutableDictionary *metaData;
@property BOOL isDirectory;

-(BOOL)hasGeneralData;
-(BOOL)hasGPSData;
-(BOOL)hasJFIFData;
-(BOOL)hasTIFFData;
-(BOOL)hasEXIFData;

-(NSString *)description;
@end
