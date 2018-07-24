//
//  AppDelegate.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/6/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerView.h"
#import "GifViewController.h"
#import "QueryManager.h"

@interface AppDelegate ()
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIViewController *authViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Parse setup
    ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"spotusapp";
        configuration.clientKey = @"fbuinterns";
        configuration.server = @"https://spotusapp.herokuapp.com/parse";
    }];
    [Parse initializeWithConfiguration:config];
    [QueryManager fetchCities:^(NSArray *cities, NSError *error) {
        QueryManager.citiesarray = cities;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (int i = 0; i < cities.count; i++){
            [dict setObject:cities[i] forKey:cities[i][@"name"]];
        }
        QueryManager.citiesdict = dict;
    }];
    return YES;
}


// run spotify delegate method

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    
    GifViewController *gifController = (GifViewController *) self.window.rootViewController;
    //SpotifyLoginViewController *spotifyController = (SpotifyLoginViewController *)gifController.delegate;
    NSLog(@"inappdelegate");
    [gifController finishAuthWithURL:url];
    return TRUE;
}

@end
