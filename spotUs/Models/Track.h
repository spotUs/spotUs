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


+ (void) addNewTrack: (NSString *)spotifyID withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end
