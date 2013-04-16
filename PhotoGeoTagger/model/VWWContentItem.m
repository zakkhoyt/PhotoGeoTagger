//
//  VWWContentItem.m
//  PhotoGeoTagger
//
//  Created by Zakk Hoyt on 4/14/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//

#import "VWWContentItem.h"

@implementation VWWContentItem

-(BOOL)hasGPSData{
    if(self.metaData == nil) return NO;
    for(NSString *key in [self.metaData allKeys]){
        if([key isEqualToString:@"{GPS}"]){
            return YES;
        }
    }
    return NO;
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
