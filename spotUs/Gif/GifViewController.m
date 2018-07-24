//
//  GifViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/19/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "GifViewController.h"
#import "SpotifyLoginViewController.h"
#import "PlayerView.h"
#import "Parse.h"
#import "SignUpViewController.h"
#import "ProfileViewController.h"
#import "ParentViewController.h"

@interface GifViewController () <UIApplicationDelegate,SPTAudioStreamingDelegate>

@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTUser *currentUser;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIViewController *authViewController;

@property (weak, nonatomic) IBOutlet UIWebView *webViewBG;
@property (weak, nonatomic) IBOutlet UIButton *loginWithSpotify;

@end

@implementation GifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WebViewContent" ofType:@"html"];
    NSURL *htmlURL = [[NSURL alloc] initFileURLWithPath:htmlPath];
    NSData *htmlData = [[NSData alloc] initWithContentsOfURL:htmlURL];
    [self.webViewBG loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[htmlURL URLByDeletingLastPathComponent]];
    
    self.loginWithSpotify.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.loginWithSpotify.layer.borderWidth = 2.0;
    
    //spotify login setup
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
  
}

- (void)viewDidAppear:(BOOL)animated{
    // Start authenticating when the app is finished launching
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startAuthenticationFlow];
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)startAuthenticationFlow {
    // Check if we could use the access token we already have
    if ([self.auth.session isValid]) {
        // Use it to log in
        [self.player loginWithAccessToken:self.auth.session.accessToken];
        NSLog(@"loggedin");
        [SPTUser requestCurrentUserWithAccessToken:self.auth.session.accessToken callback:^(NSError *error, id object) {
            SPTUser *currentUser = (SPTUser *)object;
            self.currentUser = currentUser;
            if (error){
                NSLog(@"Error when requesting uesr access token in startAuthenticationFlow: %@", error.localizedDescription);
            }
        }];
    } else {
        //TODO LINK BUTTON AND PUT THIS CODE IN ON TAP FUNCTION
        // Get the URL to the Spotify authorization portal
        NSURL *authURL = [self.auth spotifyWebAuthenticationURL];
        // Present in a SafariViewController
        self.authViewController = [[SFSafariViewController alloc] initWithURL:authURL];
        [self  presentViewController:self.authViewController animated:YES completion:nil];
    }
}

// Handle from app delegate
- (BOOL)finishAuthWithURL:(NSURL *)url {
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
    
    NSLog(@"audiostreaming");
    [SPTUser requestCurrentUserWithAccessToken:self.auth.session.accessToken callback:^(NSError *error, id object) {
        SPTUser *currentUser = (SPTUser *)object;
        self.currentUser = currentUser;
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
                            //TODO perform segue to parent vc
                            //[self performSegueWithIdentifier:@"goodlogin" sender:nil];
                        }
                    }];
                }
                else{
                    NSLog(@"loggedout parse");
                    PFUser *newUser = [PFUser user];
                    newUser.username = currentUser.displayName;
                    newUser.password = @"spotify";
                    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                        if (error != nil) {
                            NSLog(@"Error: %@", error.localizedDescription);
                        } else {
                            NSLog(@"User registered successfully");
                            //TODO perform segue to signup page
                            //[self performSegueWithIdentifier:@"goodsignup" sender:nil];
                            // manually segue to logged in view
                        }
                    }];
                }
            }
        }];
    }];
}

- (void) audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming{
    NSLog(@"logged out");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*SpotifyLoginViewController *loginView = (SpotifyLoginViewController*)[segue destinationViewController];
    self.delegate = loginView;*/
    if ([[segue destinationViewController] isKindOfClass:[ParentViewController class]]){
        ParentViewController *parentVC = (ParentViewController *)[segue destinationViewController];
        parentVC.auth = self.auth;
        parentVC.player = self.player;
        parentVC.currentUser = self.currentUser;
    }
    else if ([[segue destinationViewController] isKindOfClass:[SignUpViewController class]]){
        SignUpViewController *signupVC = [segue destinationViewController];
        signupVC.player = self.player;
        signupVC.auth = self.auth;
        signupVC.currentUser = self.currentUser;
    }
}


@end
