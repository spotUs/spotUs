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


@end
