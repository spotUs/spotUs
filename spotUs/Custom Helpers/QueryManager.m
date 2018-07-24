//
//  QueryManager.m
//  spotUs
//
//  Created by Megan Ung on 7/20/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "QueryManager.h"

@implementation QueryManager
static NSDictionary *_citiesdict = nil;
static NSArray *_citiesarray = nil;

+ (NSDictionary *)citiesdict{
    if (_citiesdict == nil) {
        _citiesdict = [NSDictionary dictionary];
    }
    return _citiesdict;
}

+ (void)setCitiesdict:(NSDictionary *)newcitiesdict{
    if (_citiesdict != newcitiesdict){
        _citiesdict = [newcitiesdict copy];
    }
}

+ (NSArray *)citiesarray{
    if (_citiesarray == nil) {
        _citiesarray = [NSArray array];
    }
    return _citiesarray;
}

+ (void)setCitiesarray:(NSArray *)newcitiesarray {
    if (_citiesarray != newcitiesarray){
        _citiesarray = [newcitiesarray copy];
    }
}

+ (void) fetchCities:(void(^)(NSArray *cities, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    query.limit = 20;
    [query includeKey:@"lng"];
    [query includeKey:@"lat"];
    [query includeKey:@"name"];
    [query includeKey:@"tracks"];
    [query orderByAscending:@"name"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *cities, NSError *error) {
        if (!error) {
            if (completion) { completion(cities, nil); }
        } else {
            NSLog(@"%@", error.localizedDescription);
            if (completion) { completion(nil, error); }
        }
    }];
}


+ (City *) getCityFromName: (NSString *)name {
    return [_citiesdict objectForKey:name];
}

+ (void) addFavSongId: (NSString *)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFUser *currUser = [PFUser currentUser];
    [self fetchFavs:^(NSArray *favs, NSError *error) {
        NSMutableArray *favarray = [NSMutableArray arrayWithArray:favs];
        [favarray addObject:songId];
        [currUser setObject:favarray forKey:@"favs"];
        [currUser saveInBackgroundWithBlock:completion];
    }];
}

+ (void) fetchFavs: (void(^)(NSArray *favs, NSError *error))completion {
    PFUser *currUser = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:currUser.username];
    [query includeKey:@"favs"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            PFUser *user = (PFUser *)object;
            NSArray *favs = user[@"favs"];
            if (completion) {completion(favs, nil);}
        } else {
            NSLog(@"%@",error.localizedDescription);
            if(completion) {completion(nil,error);}
        }
    }];
}


@end
