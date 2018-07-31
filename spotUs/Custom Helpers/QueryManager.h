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
#import "Track.h"
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>

@interface QueryManager : NSObject
@property (class, nonatomic, strong) NSDictionary * _Nullable citiesdict;
@property (class, nonatomic, strong) NSDictionary * _Nullable citiesIDdict;
@property (class, nonatomic, strong) NSArray * _Nullable citiesarray;
@property (class, nonatomic, strong) PFUser * _Nullable currentParseUser;
@property (class, nonatomic, strong) UIImage  * _Nonnull userImage;
@property (class, nonatomic, strong) SPTAuth *auth;





+ (void) fetchCities:(void(^_Nullable)(NSArray * _Nonnull cities, NSError * _Nullable error))completion ;

+ (City *_Nonnull) getCityFromName: (NSString *_Nonnull)name;
+ (City *_Nonnull) getCityFromID: (NSString *_Nonnull)objectID;


+ (void) addFavSongId: (NSString *_Nonnull)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion;


+ (void) fetchFavs: (void(^_Nullable)(NSArray * _Nonnull favs, NSError * _Nullable error))completion ;

+ (void) flagMismatchWithID: (NSString *)songID withCompletion:(PFBooleanResultBlock _Nullable)completion;
+ (void) fadeImg: (NSURL *_Nullable)imgURL imgView:(UIImageView *_Nullable)imgView;

+ (void) getTrackfromID: (NSString *) spotifyID withCompletion:(void(^)(Track *track, NSError *error))completion;

+ (void) getUserfromUsername: (NSString *)username withCompletion:(void(^)(PFUser *user, NSError *error))completion;

+ (void) addLastPlayed: (NSString *)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) fetchLastPlayedOfUsername:(NSString *)username WithCompletion:(void(^)(NSArray *lastPlayed, NSError *error))completion;

+ (void) getSPTracksFromIDs: (NSArray<NSString*>*)spotifyIDs withCompletion: (PFIdResultBlock  _Nullable)completion;


@end
