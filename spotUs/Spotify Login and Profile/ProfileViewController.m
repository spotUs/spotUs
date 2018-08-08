//
//  ProfileViewController.m
//  spotUs
//
//  Created by Martin Winton on 7/17/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "ProfileViewController.h"
#import "PlayerView.h"
#import "UIImageView+AFNetworking.h"
#import "City.h"
#import "PhotoMapViewController.h"
#import "GifViewController.h"
#import "SignUpViewController.h"
#import "PlaylistViewController.h"
#import "FavoriteViewController.h"
#import "QueryManager.h"
#import "StatsViewController.h"
#import "FriendSearchViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *hometownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredImage;
@property (weak, nonatomic) IBOutlet UIImageView *skylineImageView;
@property (strong, nonatomic) City *userCity;
@property (weak, nonatomic) IBOutlet UIView *planeView;
@property (strong, nonatomic) UIImageView *planeImageView;
@property (strong, nonatomic) CAEmitterLayer *emitterLayer;

@end

@implementation ProfileViewController
- (IBAction)didTapHomeTown:(id)sender {
    [self performSegueWithIdentifier:@"hometown" sender:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;

    

    self.profileImageView.image = QueryManager.userImage;
    
    PFUser *currentUser = QueryManager.currentParseUser;
    
    /*
    [QueryManager getUserfromUsername:[PFUser currentUser].username withCompletion:^(PFUser *user, NSError *error) {
        City *usercity = user[@"city"];
        self.skylineImageView.image = [UIImage imageNamed:usercity[@"imageName"]];
        self.hometownLabel.text = [usercity.name uppercaseString];
        self.blurredImage.image = [self blurredImageWithImage: QueryManager.userImage];
        
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"pin-30"];
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[usercity.name uppercaseString]];
        [myString appendAttributedString:attachmentString];
        
        self.hometownLabel.attributedText = myString;
    }];
     */
    
    // populate dictionary volume for all tracks
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSArray<Track*> *tracks = objects;
        for (Track *tr in tracks){
            [QueryManager makeVolumeDict:tr.spotifyID withCompletion:^(NSDictionary *volumeDict, NSError *error) {
                tr.volumeDict = volumeDict;
                NSLog(@"volumedict %@",volumeDict);
                [tr setObject:volumeDict forKey:@"volumeDict"];
                [tr saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    NSLog(@"saved i guess lol");
                    if (error) {
                        NSLog(@"errorrr: %@",error.localizedDescription);
                    }
                }];
            }];
        }
    }];*/
    
    
    
    City *blankCity = currentUser[@"city"];
    
    self.userCity = (City* )[QueryManager getCityFromID:blankCity.objectId];
    self.skylineImageView.image = [UIImage imageNamed:self.userCity[@"imageName"]];

    
    self.hometownLabel.text = [self.userCity.name uppercaseString];
    

    self.blurredImage.image = [self blurredImageWithImage: QueryManager.userImage];


        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"pin-30"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[self.userCity.name uppercaseString]];
    [myString appendAttributedString:attachmentString];
    
    self.hometownLabel.attributedText = myString;
    
    self.planeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.planeView.frame.origin.x-70, self.planeView.center.y -50 , 60, 50)];
    [self goPlaneGo];

    self.planeImageView.image = [UIImage imageNamed:@"plane"];
    [self.view addSubview:self.planeImageView];
    [self goPlaneGo];
    
    
    //animations emitter
    self.emitterLayer = [CAEmitterLayer layer];
    self.emitterLayer.emitterPosition = CGPointMake(self.profileImageView.frame.origin.x + self.profileImageView.frame.size.width/2, self.profileImageView.frame.origin.y+self.profileImageView.frame.size.height/2);
    
    self.emitterLayer.emitterZPosition = 10;
    self.emitterLayer.emitterSize = CGSizeMake(self.profileImageView.frame.size.width, 0);
    self.emitterLayer.emitterShape = kCAEmitterLayerPoint;
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.scale = 0.1;
    cell.scaleRange = 0.2;
    cell.emissionRange = 2 * M_PI;
    cell.lifetime = 3.0;
    cell.birthRate = 1;
    cell.velocity = 175;
    cell.velocityRange = 0;
    cell.yAcceleration = 0;
    
    cell.contents = (id)[[UIImage imageNamed:@"pin"] CGImage];
    
    self.emitterLayer.emitterCells = [NSArray arrayWithObject:cell];
    
    [self.view.layer addSublayer:self.emitterLayer];
    [self.view bringSubviewToFront:self.profileImageView];
    
    //listener
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeMusicAnimation:)
                                                 name:@"PlayingSongAtTime"
                                               object:nil];
}

- (void) changeMusicAnimation:(NSNotification *) notification{
    if (self.player.playbackState.isPlaying){
        NSDictionary *timeInfo = notification.userInfo;
        NSLog(@"timeinfo: %@",timeInfo);
        if ([timeInfo valueForKey:@"volume"]){
            NSNumber *vol = [timeInfo valueForKey:@"volume"];
            NSLog(@"animation: %@",vol);
            float fvol = ([vol floatValue] + (float)60.0);
            self.emitterLayer.birthRate = fvol * 4.0;
        }
    } else {
        self.emitterLayer.birthRate = 0;
    }
}

- (void)goPlaneGo {
     self.planeImageView.image = [UIImage imageNamed:@"plane"];
    [UIView animateWithDuration:5 animations:^{
       self.planeImageView.frame = CGRectMake(self.planeView.frame.size.width + 250, self.planeView.center.y - 50  , 60, 50);
    } completion:^(BOOL finished) {
        self.planeImageView.frame = CGRectMake(self.planeView.frame.size.width +250  , self.planeView.center.y -50 , 60, 50);
        [self otherWay];
    }];
}

- (void)otherWay {
    self.planeImageView.image = [UIImage imageNamed:@"otherPlane-1"];
    [UIView animateWithDuration:5 animations:^{
         self.planeImageView.frame = CGRectMake(self.planeView.frame.origin.x-70, self.planeView.center.y -50 , 60, 50);
     
    } completion:^(BOOL finished) {
          self.planeImageView.frame = CGRectMake(self.planeView.frame.origin.x-70,  self.planeView.center.y - 50 , 60, 50);
        [self goPlaneGo];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTapLogoutBtn:(id)sender {
    //[[SPTAudioStreamingController sharedInstance] logout];
    [self.player logout];
    self.auth.session = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SpotifyLoginStoryBoard"
                                                         bundle:nil];
    GifViewController *gifVC = (GifViewController *) [storyboard instantiateViewControllerWithIdentifier:@"gifviewcontroller"]; 
    [self presentViewController:gifVC animated:YES completion:nil];
}

- (UIImage *)blurredImageWithImage:(UIImage*)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
   [filter setValue:[NSNumber numberWithFloat:4.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    
    if (cgImage) {
        CGImageRelease(cgImage);
    }
    
    return retVal;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[SignUpViewController class]]){
        SignUpViewController *signupVC = [segue destinationViewController];
        signupVC.msg = @"SpotUs is currently only available in the cities above. Edit your city below and click confirm to save your changes.";
        signupVC.auth = self.auth;
        signupVC.player = self.player;
        signupVC.currentUser = self.currentUser;
        signupVC.signup = NO;
        signupVC.userCity = self.userCity;
    }
    else if ([[segue destinationViewController] isKindOfClass:[PhotoMapViewController class]]){
        PhotoMapViewController *mapVC = (PhotoMapViewController *)[segue destinationViewController];
        mapVC.auth = self.auth;
        mapVC.player = self.player;
    }
    else if ([[segue destinationViewController] isKindOfClass:[PlaylistViewController class]]){
        PlaylistViewController *playlistVC = (PlaylistViewController *)[segue destinationViewController];
        playlistVC.auth = self.auth;
        playlistVC.player = self.player;
        playlistVC.city = self.userCity;
        
    }
    else if ([[segue destinationViewController] isKindOfClass:[FavoriteViewController class]]){
        FavoriteViewController *favoriteVC = (FavoriteViewController *)[segue destinationViewController];
        favoriteVC.auth = self.auth;
        favoriteVC.player = self.player;
        
    }
    
    else if ([[segue destinationViewController] isKindOfClass:[StatsViewController class]]){
        StatsViewController *statsVC = (StatsViewController *)[segue destinationViewController];
        statsVC.auth = self.auth;
        
    }
    else if ([[segue destinationViewController] isKindOfClass:[FriendSearchViewController class]]){
        FriendSearchViewController *friendsVC = (FriendSearchViewController *)[segue destinationViewController];
        friendsVC.auth = self.auth;
        
    }
}



@end
