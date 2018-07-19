//
//  AppDelegate.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/6/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerView.h"
#import "SpotifyLoginViewController.h"
#import "StartViewController.h"
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
    
    return YES;
     
     
}

- (void)startAuthenticationFlow
{
    // Check if we could use the access token we already have
    if ([self.auth.session isValid]) {
        // Use it to log in
        [self.player loginWithAccessToken:self.auth.session.accessToken];
    } else {
        // Get the URL to the Spotify authorization portal
        NSURL *authURL = [self.auth spotifyWebAuthenticationURL];
        // Present in a SafariViewController
        self.authViewController = [[SFSafariViewController alloc] initWithURL:authURL];
        [self.window.rootViewController presentViewController:self.authViewController animated:YES completion:nil];
    }
}

// run spotify delegate method

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options

{
    
    StartViewController *startController = (StartViewController *) self.window.rootViewController;
    
    SpotifyLoginViewController *spotifyController = (SpotifyLoginViewController *)startController.delegate;

    
    
    
    [spotifyController finishAuthWithURL:url];
    return TRUE;
}



- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SpotifyLoginStoryBoard" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"spotify"];
    
    PlayerView *playerView = (PlayerView*)navigationController.topViewController;
    playerView.player = self.player;
    playerView.auth = self.auth;

    self.window.rootViewController = navigationController;

    
}



@end
