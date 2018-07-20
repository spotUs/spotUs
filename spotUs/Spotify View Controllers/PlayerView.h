//
//  PlayerView.h
//  spotUs
//
//  Created by Martin Winton on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import "City.h"

#import <Parse/Parse.h>

@protocol NowPlayingDelegate

-(void)didStartPlayingonCity:(City*)city;

@end
@protocol PlayerRepeatDelegate

-(void)didChangeRepeatStatusTo:(BOOL)isRepeating;

@end


@interface PlayerView : UIViewController
@property (nonatomic, weak) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) City *city;
@property BOOL nowPlaying;
@property BOOL isRepeating;


@property (nonatomic, weak) id<NowPlayingDelegate> nowPlayingDelegate;
@property (nonatomic, weak) id<PlayerRepeatDelegate> repeatDelegate;

@property NSInteger songIndex;





@end
