//
//  Track.h
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "City.h"

@interface Track : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *spotifyID;
@property (nonatomic, strong) NSMutableArray <NSString *> *citynames;
@property (nonatomic) NSMutableArray<NSString*> *flaggers;
@property (nonatomic, strong) NSDictionary *volumeDict;

+ (void) addNewTrack: (NSString *)spotifyID in:(NSString *)cityname withCompletion: (PFBooleanResultBlock  _Nullable)completion;


@end
