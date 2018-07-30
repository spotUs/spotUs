//
//  Track.m
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "Track.h"

@implementation Track
@dynamic spotifyID, cities;

+ (nonnull NSString *)parseClassName {
    return @"Track";
}

+ (void) addNewTrack: (NSString *)spotifyID in:(City *)city withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    //check if track already exists
    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    [query whereKey:@"spotifyID" equalTo:spotifyID];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects == nil){
            //this track obj does not already exist so create new one
            Track *newTrack = [[Track alloc] init];
            newTrack.spotifyID = spotifyID;
            newTrack.cities = [NSMutableArray arrayWithObject:city];
            [newTrack saveInBackgroundWithBlock:completion];
        } else {
            //track obj does exist so add the city to it
            Track *track = objects[0];
            NSMutableArray<City *> *trackcities = [NSMutableArray array];
            trackcities = track.cities;
            [trackcities arrayByAddingObject:city];
            [track setObject:trackcities forKey:@"cities"];
            [track saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error trying adding a city to the track: %@",error.localizedDescription);
                } else {
                    NSLog(@"successfully added a city to the track");
                }
            }];
        }
    }];
    
}

@end
