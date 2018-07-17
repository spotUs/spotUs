//
//  City.m
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "City.h"

@implementation City
@dynamic name, lat, lng, tracks;

+ (nonnull NSString *)parseClassName {
    return @"City";
}

+ (void) addNewCity: (NSString *)name atLat:(double)lat andLng:(double)lng withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    City *newCity = [[City alloc] init];
    newCity.name = name;
    newCity.lat = lat;
    newCity.lng = lng;
    newCity.tracks = [NSArray array];
    
    [newCity saveInBackgroundWithBlock: completion];
}

+ (void) addTrack: (Track *)track toCity:(City *)city withCompletion:(PFBooleanResultBlock _Nullable)completion{
    [city.tracks arrayByAddingObject:track];
    [city saveInBackgroundWithBlock:completion];
}

@end
