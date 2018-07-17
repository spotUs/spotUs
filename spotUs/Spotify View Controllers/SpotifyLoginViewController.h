//
//  SpotifyLoginViewController.h
//  spotUs
//
//  Created by Martin Winton on 7/17/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <Parse/Parse.h>

@interface SpotifyLoginViewController : UIViewController

@property (strong, nonatomic) UIWindow *window;
- (BOOL)finishAuthWithURL:(NSURL *)url;

@end
