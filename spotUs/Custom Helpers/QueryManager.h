//
//  QueryManager.h
//  spotUs
//
//  Created by Megan Ung on 7/20/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "City.h"

@interface QueryManager : NSObject
@property (class, nonatomic, strong) NSDictionary * _Nullable citiesdict;
@property (class, nonatomic, strong) NSDictionary * _Nullable citiesIDdict;
@property (class, nonatomic, strong) NSArray * _Nullable citiesarray;
@property (class, nonatomic, strong) PFUser * _Nullable currentParseUser;


+ (void) fetchCities:(void(^_Nullable)(NSArray * _Nonnull cities, NSError * _Nullable error))completion ;

+ (City *_Nonnull) getCityFromName: (NSString *_Nonnull)name;
+ (City *_Nonnull) getCityFromID: (NSString *_Nonnull)objectID;


+ (void) addFavSongId: (NSString *_Nonnull)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion;
    
+ (void) fetchFavs: (void(^_Nullable)(NSArray * _Nonnull favs, NSError * _Nullable error))completion ;

@end
