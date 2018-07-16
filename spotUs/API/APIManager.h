//
//  APIManager.h
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"
#import "Tweet.h"

@interface APIManager : BDBOAuth1SessionManager

+ (instancetype)shared;
- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion;
- (void)getMainUserWithCompletion:(void (^)(User *, NSError *))completion;
- (void)getUserTimelineFromUser:(User *)user withCompletion:(void (^)(NSMutableArray *tweets, NSError *))completion;

- (void)postReplyWithText:(NSString *)text ID:(NSString *)tweetID completion:(void (^)(Tweet *, NSError *))completion;
- (void)getmoreTweetsWithMaxID:(NSString *)maxID Completion:(void(^)(NSMutableArray *tweets, NSError *error))completion;

- (void)getHomeTimelineWithCompletion:(void(^)(NSMutableArray *tweets, NSError *error))completion;
- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)unfavorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)unretweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;


@end
