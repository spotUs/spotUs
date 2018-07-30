//
//  GifViewController.h
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/19/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <Parse/Parse.h>
#import "QueryManager.h"

@protocol GifViewControllerDelegate
@end
@interface GifViewController : UIViewController

@property (nonatomic, weak) id<GifViewControllerDelegate> delegate;
- (BOOL)finishAuthWithURL:(NSURL *)url;


@end
