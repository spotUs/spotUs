//
//  Track.m
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "Track.h"

@implementation Track
@dynamic spotifyID, citynames, numFlags;

+ (nonnull NSString *)parseClassName {
    return @"Track";
}

+ (void) addNewTrack: (NSString *)spotifyID in:(NSString *)cityname withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    //check if track already exists
    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    [query whereKey:@"spotifyID" equalTo:spotifyID];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count == 0){
            //this track obj does not already exist so create new one
            Track *newTrack = [[Track alloc] init];
            newTrack.spotifyID = spotifyID;
            newTrack.numFlags = 0;
            newTrack.citynames = [NSMutableArray array];
            [newTrack.citynames addObject:cityname];
            [newTrack saveInBackgroundWithBlock:completion];
        } else {
            //track obj does exist so add the city to it
            Track *track = (Track *)objects[0];
            NSMutableArray<NSString *> *trackcities = [NSMutableArray array];
            trackcities = track.citynames;
            if (![trackcities containsObject:cityname]){
                [trackcities arrayByAddingObject:cityname];
                [track setObject:trackcities forKey:@"cities"];
                [track saveInBackgroundWithBlock:completion];
            }
        }
    }];
    
}

+ (void) addFlag: (Track *) track {
    track.numFlags = track.numFlags + 1;
    [track saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            NSLog(@"error could not add flag: %@",error.localizedDescription);
        } else {
            NSLog(@"added flag");
        }
    }];
}

@end
