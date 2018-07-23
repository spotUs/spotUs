//
//  LocationSearchTable.h
//  spotUs
//
//  Created by Martin Winton on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <Parse/Parse.h>
#import "City.h"
#import "PhotoMapViewController.h"

@interface LocationSearchTable : UITableViewController

@property (strong ,nonatomic) id<HandleMapSearch> handleMapsearchDelegate;

@end
