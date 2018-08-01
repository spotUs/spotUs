//
//  PlayerView.h
//  spotUs
//
//  Created by Martin Winton on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import "City.h"

#import <Parse/Parse.h>


@protocol DismissDelegate


-(void)didDismissWithIndex:(NSNumber*)index;


@end


@interface PlayerView : UIViewController

- (IBAction)flagged:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *alertText;

@property (nonatomic, weak) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) NSArray<NSString*>   *citySongIDs;
@property BOOL nowPlaying;
@property BOOL didSelect;
@property NSInteger currentSongIndex;


@property (nonatomic, weak) id<DismissDelegate> dismissDelegate;


@end
