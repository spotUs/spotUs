//
//  SpotifyLoginViewController.m
//  spotUs
//
//  Created by Martin Winton on 7/17/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "SpotifyLoginViewController.h"
#import "PlayerView.h"
#import "Parse.h"
#import "ProfileViewController.h"

@interface SpotifyLoginViewController () <UIApplicationDelegate,SPTAudioStreamingDelegate>
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIViewController *authViewController;


@end

@implementation SpotifyLoginViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    self.auth = [SPTAuth defaultInstance];
    self.player = [SPTAudioStreamingController sharedInstance];
    // The client ID you got from the developer site
    self.auth.clientID = @"38565a78b5f04514afdc54566b0ed33b";
    // The redirect URL as you entered it at the developer site
    self.auth.redirectURL = [NSURL URLWithString:@"spotus-login://callback"];
    // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
    self.auth.sessionUserDefaultsKey = @"current session";
    // Set the scopes you need the user to authorize. `SPTAuthStreamingScope` is required for playing audio.
    self.auth.requestedScopes = @[SPTAuthUserLibraryModifyScope, SPTAuthUserReadTopScope, SPTAuthStreamingScope,SPTAuthUserReadPrivateScope,SPTAuthPlaylistReadPrivateScope,SPTAuthUserLibraryReadScope,SPTAuthUserReadTopScope];
    
    // Become the streaming controller delegate
    self.player.delegate = self;
    
    // Start up the streaming controller.
    NSError *audioStreamingInitError;
    if (![self.player startWithClientId:self.auth.clientID error:&audioStreamingInitError]) {
        NSLog(@"There was a problem starting the Spotify SDK: %@", audioStreamingInitError.description);
    }
    
    // Start authenticating when the app is finished launching
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startAuthenticationFlow];
        
        
    });}


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
        
        
        [self  presentViewController:self.authViewController animated:YES completion:nil];
        
        
        
        
    }
}

// Handle from app delegate
- (BOOL)finishAuthWithURL:(NSURL *)url



{
    // If the incoming url is what we expect we handle it
    if ([self.auth canHandleURL:url]) {
        
        
        // Close the authentication window
        [self.authViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        self.authViewController = nil;
        // Parse the incoming url to a session object
        [self.auth handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            if (session) {
                // login to the player
                [self.player loginWithAccessToken:self.auth.session.accessToken];
                
                
            }
        }];
        return YES;
    }
    return NO;
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    
    
    [SPTUser requestCurrentUserWithAccessToken:self.auth.session.accessToken callback:^(NSError *error, id object) {
    
        SPTUser *currentUser = (SPTUser *)object;
        
        
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:currentUser.displayName];
        query.limit = 1;
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (!error) {
                
                
                if(users.count != 0){
                    
                    
                    [PFUser logInWithUsernameInBackground:currentUser.displayName password:@"spotify" block:^(PFUser * user, NSError *  error) {
                        if (error != nil) {
                   
                            
                            NSLog(@"User log in failed: %@", error.localizedDescription);
                        } else {
                            NSLog(@"User logged in successfully");
                           [self performSegueWithIdentifier:@"goodlogin" sender:nil];
                            
                            
                        }
                    }];
                }
                
                
                else{
                    PFUser *newUser = [PFUser user];
                    newUser.username = currentUser.displayName;
                    newUser.password = @"spotify";
                    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                        if (error != nil) {
                            NSLog(@"Error: %@", error.localizedDescription);
                        } else {
                            NSLog(@"User registered successfully");
                           [self performSegueWithIdentifier:@"goodsignup" sender:nil];
                            
                            // manually segue to logged in view
                        }
                    }];
                    
                    
                }
                
                
                
            }
            
        }];
        
        
    }];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    UINavigationController *navigationController = [segue destinationViewController];
    
    
    if([ navigationController.topViewController isKindOfClass:[ProfileViewController class]]){
        
        ProfileViewController *profileView = (ProfileViewController*)navigationController.topViewController;
        profileView.player = self.player;
        profileView.auth = self.auth;
        
        
        
    }
    
    else{

    
    PlayerView *playerView = (PlayerView*)navigationController.topViewController;
    playerView.player = self.player;
    playerView.auth = self.auth;
    
}
}


@end
