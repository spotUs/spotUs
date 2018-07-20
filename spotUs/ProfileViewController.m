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
#import "CitiesViewController.h"
#import "PhotoMapViewController.h"
#import "GifViewController.h"


@interface ProfileViewController () <NowPlayingIntermediateDelegate>
@property (weak, nonatomic) IBOutlet UILabel *profileUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hometownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *nowPlayingButton;
@property (strong, nonatomic) City *playingCity;
@property (weak, nonatomic) IBOutlet UIView *nowPlayingView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredImage;
@property (weak, nonatomic) IBOutlet UIView *favoriteView;
@property (weak, nonatomic) IBOutlet UIView *exploreView;



@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.nowPlayingView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nowPlayingView.layer.borderWidth = 2.0f;
    self.favoriteView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.favoriteView.clipsToBounds = YES;
    self.nowPlayingView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.nowPlayingView.clipsToBounds = YES;
    self.favoriteView.layer.borderColor = [UIColor redColor].CGColor;
    self.favoriteView.layer.borderWidth = 1.0;
    self.favoriteView.layer.cornerRadius = 15;
    
    self.exploreView.layer.borderColor = [UIColor redColor].CGColor;
    self.exploreView.layer.borderWidth = 1.0;
    self.exploreView.layer.cornerRadius = 15;
    
    self.profileUsernameLabel.text = self.currentUser.displayName;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.blurredImage.image = [self blurredImageWithImage:self.blurredImage.image];

    
    
    NSURL *profileURL = self.currentUser.largestImage.imageURL;
    [self.profileImageView setImageWithURL:profileURL];
    
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        PFUser *currentUser = (PFUser *)object;
        
        City *hometown = currentUser[@"city"];
        
        [hometown fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            City *fullHometown  = (City*)object;
            self.hometownLabel.text = fullHometown.name;
            //self.hometownLabel.layer.borderColor = [UIColor whiteColor].CGColor;
            //self.hometownLabel.layer.borderWidth = 1.0;
           // self.hometownLabel.layer.cornerRadius = 15;



        }];
        
    }];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTapLogoutBtn:(id)sender {
    //[[SPTAudioStreamingController sharedInstance] logout];
    [self.player logout];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SpotifyLoginStoryBoard"
                                                         bundle:nil];
    GifViewController *gifVC = (GifViewController *) [storyboard instantiateViewControllerWithIdentifier:@"gifviewcontroller"]; //TODO add gifviewcontroller identifier
    [self presentViewController:gifVC animated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *navigationController = [segue destinationViewController];
        
        
    }
    else if ([[segue destinationViewController] isKindOfClass:[PhotoMapViewController class]]){
        PhotoMapViewController *mapVC = (PhotoMapViewController *)[segue destinationViewController];
        mapVC.auth = self.auth;
        mapVC.player = self.player;
    }
    
    else if([[segue destinationViewController]  isKindOfClass:[PlayerView class]]){
        PlayerView *playerView = (PlayerView *)[segue destinationViewController];
        playerView.player = self.player;
        playerView.auth = self.auth;
        playerView.city = self.playingCity;
        playerView.nowPlaying = YES;
    }
    
    else if([[segue destinationViewController]  isKindOfClass:[CitiesViewController class]]){
        CitiesViewController *cityView = (CitiesViewController *)[segue destinationViewController];
        cityView.player = self.player;
        cityView.auth = self.auth;
        cityView.nowPlayingIntermediateDelegate = self;
    }
    
    
}

- (void)didStartPlayingonCityIntermediate:(City *)city{
    
    self.playingCity = city;
    
    
}

- (UIImage *)blurredImageWithImage:(UIImage*)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:6.0f] forKey:@"inputRadius"];
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



@end
