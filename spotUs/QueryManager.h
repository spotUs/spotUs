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
@property (class, nonatomic, strong) NSDictionary *citiesdict;
@property (class, nonatomic, strong) NSArray *citiesarray;

+ (void) fetchCities:(void(^)(NSArray *cities, NSError *error))completion ;

+ (City *) getCityFromName: (NSString *)name;

+ (void) addFavSongId: (NSString *)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) fetchFavs: (void(^)(NSArray *favs, NSError *error))completion ;

@end
