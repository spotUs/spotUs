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
+ (void) addInappropriate: (NSString *)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFUser *currUser = [PFUser currentUser];
    [self fetchInappropriate:^(NSArray *flags, NSError *error) {
        NSMutableArray *flagArray = [NSMutableArray arrayWithArray:flags];
        if (![flagArray containsObject:songId]) {
            [flagArray addObject:songId];
            [currUser setObject:flagArray forKey:@"inappropriate"];
            [currUser saveInBackgroundWithBlock:completion];
        }
        else {
            [flagArray removeObject:songId];
            [currUser removeObject:flagArray forKey:@"inappropriate"];
            [currUser saveInBackgroundWithBlock:completion];
        }
    }];
    
}

+ (void) addUnmatched: (NSString *)songId withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFUser *currUser = [PFUser currentUser];
    [self fetchUnmatched:^(NSArray *flags, NSError *error) {
        NSMutableArray *flagArray = [NSMutableArray arrayWithArray:flags];
        if (![flagArray containsObject:songId]) {
            [flagArray addObject:songId];
            [currUser setObject:flagArray forKey:@"unmatch"];
            [currUser saveInBackgroundWithBlock:completion];
        }
        else {
            [flagArray removeObject:songId];
            [currUser removeObject:flagArray forKey:@"unmatch"];
            [currUser saveInBackgroundWithBlock:completion];
        }
    }];
    
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
    [self fetchLastPlayed:^(NSArray *lastPlayed, NSError *error) {
        NSMutableArray *lastPlayedArray = [NSMutableArray arrayWithArray:lastPlayed];
        if (![lastPlayedArray containsObject:songId]) {
            [lastPlayedArray addObject:songId];
        }
        
        if([lastPlayedArray count] > 5){
            
            [lastPlayedArray removeObjectAtIndex:0];
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
+ (void) fetchInappropriate: (void(^)(NSArray *favs, NSError *error))completion {
    PFUser *currUser = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:currUser.username];
    [query includeKey:@"inappropriate"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            PFUser *user = (PFUser *)object;
            NSArray *flags = user[@"inappropriate"];
            if (completion) {
                completion(flags, nil);}
        } else {
            NSLog(@"%@",error.localizedDescription);
            if(completion) {
                completion(nil,error);}
        }
    }];
}
+ (void) fetchUnmatched: (void(^)(NSArray *favs, NSError *error))completion {
    PFUser *currUser = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:currUser.username];
    [query includeKey:@"unmatched"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            PFUser *user = (PFUser *)object;
            NSArray *flags = user[@"unmatched"];
            if (completion) {
                completion(flags, nil);}
        } else {
            NSLog(@"%@",error.localizedDescription);
            if(completion) {
                completion(nil,error);}
        }
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

+ (void) fetchFlags: (void(^)(NSArray *favs, NSError *error))completion {
    PFUser *currUser = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:currUser.username];
    [query includeKey:@"flag"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            PFUser *user = (PFUser *)object;
            NSArray *flags = user[@"flag"];
            if (completion) {
                completion(flags, nil);}
        } else {
            NSLog(@"%@",error.localizedDescription);
            if(completion) {
                completion(nil,error);}
        }
    }];
}

+ (void) fetchLastPlayed: (void(^)(NSArray *lastPlayed, NSError *error))completion {
    PFUser *currUser = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:currUser.username];
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
 

@end
