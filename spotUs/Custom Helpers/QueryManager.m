//
//  QueryManager.m
//  spotUs
//
//  Created by Megan Ung on 7/20/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "QueryManager.h"
#import "Parse.h"
#import "UIImageView+AFNetworking.h"

@implementation QueryManager
static NSDictionary *_citiesdict = nil;
static NSDictionary *_citiesIDdict = nil;

static NSArray *_citiesarray = nil;
static PFUser *_currentParseUser = nil;
static UIImage *_profileImage = nil;
static SPTAuth *_auth = nil;


+ (SPTAuth *)auth{

    return _auth;
}

+ (void)setAuth:(SPTAuth *)auth{
    
    _auth = auth;
    
}



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

+ (NSDictionary *)citiesIDdict{
    if (_citiesIDdict == nil) {
        _citiesIDdict = [NSDictionary dictionary];
    }
    return _citiesdict;
}

+ (void)setCitiesIDdict:(NSDictionary *)newcitiesdict{
    if (_citiesIDdict != newcitiesdict){
        _citiesIDdict = [newcitiesdict copy];
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

+ (PFUser *)currentParseUser{
    if (_currentParseUser == nil) {
        _currentParseUser = [PFUser currentUser];
    }
    return _currentParseUser;
}

+ (void)setCurrentParseUser:(PFUser *)newParseUser{
    if (_currentParseUser != newParseUser){
        _currentParseUser = [newParseUser copy];
    }
}

+ (UIImage*)userImage{
    
    return _profileImage;
}


+ (void)setUserImage:(UIImage *)userImage{
    
    
    if (_profileImage != userImage){
        _profileImage = userImage;
    }
    
}
    
    

+ (void) fetchCities:(void(^)(NSArray *cities, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    query.limit = 20;
    [query includeKey:@"lng"];
    [query includeKey:@"lat"];
    [query includeKey:@"name"];
    [query includeKey:@"tracks"];
    [query includeKey:@"imageName"];

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

+ (City *)getCityFromID:(NSString *)objectID{
    return [_citiesIDdict objectForKey:objectID];
}


+ (void) addFavSongId: (NSString *)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFUser *currUser = [PFUser currentUser];
    [self fetchFavs:^(NSArray *favs, NSError *error) {
        NSMutableArray *favarray = [NSMutableArray arrayWithArray:favs];
        if (![self user:favs HasLiked:songId]) {
            [favarray addObject:songId];
            [currUser setObject:favarray forKey:@"favs"];
            [currUser saveInBackgroundWithBlock:completion];
            NSLog(@"added");
        }
        else {
            NSMutableArray *temp = [NSMutableArray arrayWithArray:favs];
            NSMutableArray *discarded = [NSMutableArray array];
            for(int i = 0; i<temp.count; i++) {
                if([temp[i] isEqualToString:songId]) {
                    [discarded addObject:temp[i]];
                }
            }
            [temp removeObjectsInArray:discarded];
            [currUser setObject:[NSArray arrayWithArray:temp] forKey:@"favs"];
            [currUser saveInBackgroundWithBlock:completion];
            NSLog(@"removed");
        }
    }];
}

+ (void) addLastPlayed: (NSString *)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFUser *currUser = [PFUser currentUser];
    [self fetchLastPlayedOfUsername:[PFUser currentUser].username WithCompletion:^(NSArray *lastPlayed, NSError *error) {
        NSMutableArray *lastPlayedArray = [NSMutableArray arrayWithArray:lastPlayed];
        if (![lastPlayedArray containsObject:songId]) {
            [lastPlayedArray addObject:songId];
        }
        
        else{
        
        for(NSString *song in [NSArray arrayWithArray:lastPlayedArray]){
            
            if([song isEqualToString:songId]){
                
                [lastPlayedArray removeObject:songId];
                [lastPlayedArray addObject:songId];
                // if song already in last played, move to top of queue

            }
        }
            
        }
        
        if([lastPlayedArray count] > 5){
            
            [lastPlayedArray removeObjectAtIndex:0];
            // remove last played song
        }
            
        [currUser setObject:lastPlayedArray forKey:@"lastPlayed"];

        [currUser saveInBackgroundWithBlock:completion];

 
    }];
    
}


+(BOOL)user:(NSArray *) favs HasLiked:(NSString *)songId {
    for(NSString *s in favs) {
        if([s isEqualToString:songId]) {
            return YES;
        }
    }
    return NO;
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



+ (void) fetchLastPlayedOfUsername:(NSString *)username WithCompletion:(void(^)(NSArray *lastPlayed, NSError *error))completion {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query includeKey:@"lastPlayed"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            PFUser *user = (PFUser *)object;
            NSArray *lastPlayed = user[@"lastPlayed"];
            if (completion) {
                completion(lastPlayed, nil);}
        } else {
            NSLog(@"%@",error.localizedDescription);
            if(completion) {
                completion(nil,error);}
        }
    }];
}

+ (void) getSPTracksFromIDs: (NSArray<NSString*>*)spotifyIDs withCompletion: (PFIdResultBlock  _Nullable)completion{
    
    NSMutableArray *properFormat = [NSMutableArray array];
    
    
    for(NSString *stringID in spotifyIDs){
        
    
        [properFormat addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"spotify:track:",stringID]]];
    }
    
    
    [SPTTrack tracksWithURIs:properFormat accessToken:self.auth.session.accessToken market:nil callback:^(NSError *error, id object) {
        
        if (!error) {
            if (completion) {
                completion(object, nil);}
        } else {
            NSLog(@"%@",error.localizedDescription);
            if(completion) {
                completion(nil,error);}
        }
        
  
        }];
        
}

+ (void) fadeImg: (NSURL *)imgURL imgView:(UIImageView *)imgView {
    NSURLRequest *request = [NSURLRequest requestWithURL:imgURL];
    __weak UIImageView *weakImg = imgView;
    [imgView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
        // imageResponse will be nil if the image is cached
        if (imageResponse) {
            NSLog(@"Image was NOT cached, fade in image");
            weakImg.alpha = 0.0;
            weakImg.image = image;
            //Animate UIImageView back to alpha 1 over 0.4sec
            [UIView animateWithDuration:0.4 animations:^{
                weakImg.alpha = 1.0;
            }];
        }
        else {
            NSLog(@"Image was cached so just update the image");
            weakImg.image = image;
        }
    }
                            failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                NSLog(@"ERROR with loading image");
                            }];
}

+ (void) getTrackfromID: (NSString *) spotifyID withCompletion:(void(^)(Track *track, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    [query whereKey:@"spotifyID" equalTo:spotifyID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error){
            NSLog(@"error getting track obj: %@",error.localizedDescription);
            if (completion) {completion(nil,error);}
        } else {
            Track *track = (Track *)object;
            if (completion) {completion(track,nil);}
        }
    }];
}


+ (void) flagMismatchWithID: (NSString *)songID withCompletion:(PFBooleanResultBlock _Nullable)completion{
    
    [self getTrackfromID:songID withCompletion:^(Track *track, NSError *error) {
        
        
        if(error){
            
            completion(NO,error);
        }
        
        else{
            
            
            NSMutableArray<NSString*> *flaggers = [NSMutableArray arrayWithArray:track.flaggers];
            
            if(![flaggers containsObject:[PFUser currentUser].username]){
                
                [flaggers addObject:[PFUser currentUser].username];
            }
            
            
            track.flaggers = flaggers;
            [track saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if(error){
                    
                    completion(NO,error);
                    
                }
                else{
                    completion(YES,nil);
                }
            }];
            
            
            
        }
    }];
    
    
    
    
}
 
+ (void) getUserfromUsername: (NSString *)username withCompletion:(void(^)(PFUser *user, NSError *error))completion {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query includeKey:@"username"];
    [query includeKey:@"city"];
    [query includeKey:@"favs"];
    [query includeKey:@"lastPlayed"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error){
            NSLog(@"error getting user: %@",error.localizedDescription);
            if (completion) {completion (nil,error);}
        } else {
            PFUser *user = (PFUser *)object;
            if (completion) {completion(user,nil);}
        }
    }];
}
@end
