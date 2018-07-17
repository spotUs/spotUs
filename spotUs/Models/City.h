//
//  City.h
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Track.h"

@interface City : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *name;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic, strong) NSArray *tracks;

+ (void) addNewCity: ( NSString *)name atLat:(double)lat andLng:(double)lng withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) addTrack: (Track *)track toCity:(City *)city withCompletion: (PFBooleanResultBlock _Nullable)completion;

@end
