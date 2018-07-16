//
//  Track.h
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Track : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *spotifyID;
+ (void) addNewTrack: (NSString *)spotifyID withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end
