//
//  VWWContentItem.m
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/14/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "VWWContentItem.h"



@implementation VWWContentItem

-(BOOL)hasDataWithTag:(NSString*)tag{
    if(self.metaData == nil) return NO;
    for(NSString *key in [self.metaData allKeys]){
        if([key isEqualToString:tag]){
            return YES;
        }
    }
    return NO;
}

// TODO: These strings are already declared as keys elsewhere in the app.
// Let's reuse them.
-(BOOL)hasGeneralData{
    return (BOOL)([self.metaData allKeys].count);
}
-(BOOL)hasGPSData{
    return [self hasDataWithTag:@"{GPS}"];
}
-(BOOL)hasJFIFData{
    return [self hasDataWithTag:@"{JFIF}"];
}
-(BOOL)hasTIFFData{
    return [self hasDataWithTag:@"{TIFF}"];
}
-(BOOL)hasEXIFData{
    return [self hasDataWithTag:@"{Exif}"];
}


-(NSString *)description{
    return [NSString stringWithFormat:@"url=%@\n"
            "displayName=%@"
            "path=%@"
            "extension=%@"
            "metaData=%@",
            self.url.absoluteString,
            self.displayName,
            self.path,
            self.extension,
            self.metaData];

}


@end
