//
//  SignUpViewController.h
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <Parse/Parse.h>

@interface SignUpViewController : UIViewController
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTUser *currentUser;
@end
