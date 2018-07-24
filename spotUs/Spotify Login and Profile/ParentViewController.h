//
//  ParentViewController.h
//  spotUs
//
//  Created by Megan Ung on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <Parse/Parse.h>


@interface ParentViewController : UIViewController

@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTUser *currentUser;

@end
