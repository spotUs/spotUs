//
//  FavoriteViewController.h
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <Parse/Parse.h>
#import "City.h"

@protocol PlayListViewControllerDelegate
-(void)didChooseSongWithIndex:(NSUInteger)index;
@end

@interface FavoriteViewController : UIViewController

@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) City *city;
@property (nonatomic, weak) id<PlayListViewControllerDelegate> delegate;

@end
