//
//  TinyPlayerViewController.h
//  spotUs
//
//  Created by Megan Ung on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <MediaPlayer/MediaPlayer.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <Parse/Parse.h>
#import "City.h"

@interface TinyPlayerViewController : UIViewController
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property BOOL nowPlaying;
@property BOOL didSelect;
@property (nonatomic, strong) NSString *playlistTitle;




@end
