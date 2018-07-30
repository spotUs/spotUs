//
//  StatsViewController.h
//  spotUs
//
//  Created by Martin Winton on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>

@interface StatsViewController : UIViewController
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;


@end
