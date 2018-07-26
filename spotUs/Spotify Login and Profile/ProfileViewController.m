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

@interface ProfileViewController () 
@property (weak, nonatomic) IBOutlet UILabel *hometownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredImage;
@property (weak, nonatomic) IBOutlet UIView *favoriteView;
@property (weak, nonatomic) IBOutlet UIView *exploreView;
@property (strong, nonatomic) City *userCity;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
 
    self.favoriteView.layer.borderColor = [UIColor colorWithRed:1.00 green:0.38 blue:0.58 alpha:1.0].CGColor;
    self.favoriteView.layer.borderWidth = 3.0;
    [self.favoriteView.layer setShadowOffset:CGSizeMake(2, 2)];
    [self.favoriteView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.favoriteView.layer setShadowOpacity:0.3];
    

    
    self.exploreView.layer.borderColor = [UIColor colorWithRed:0.20 green:0.64 blue:0.00 alpha:1.0].CGColor;
    self.exploreView.layer.borderWidth = 3.0;
    [self.exploreView.layer setShadowOffset:CGSizeMake(2, 2)];
    [self.exploreView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.exploreView.layer setShadowOpacity:.3];
    
    
    self.navigationItem.title = self.currentUser.displayName;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.blurredImage.image = [self blurredImageWithImage:self.blurredImage.image];

    
    
    NSURL *profileURL = self.currentUser.largestImage.imageURL;
    [self.profileImageView setImageWithURL:profileURL];
    
    NSLog(@"usercity: %@",[PFUser currentUser][@"city"]);
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        PFUser *currentUser = (PFUser *)object;
        
        City *hometown = currentUser[@"city"];
        
        [hometown fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            City *fullHometown  = (City*)object;
            self.userCity = fullHometown;
            self.hometownLabel.attributedText=[[NSAttributedString alloc]
                                               initWithString:fullHometown.name
                                               attributes:@{
                                                            NSStrokeWidthAttributeName: @-3.0,
                                                            NSStrokeColorAttributeName:[UIColor blackColor],
                                                            NSForegroundColorAttributeName:[UIColor whiteColor]
                                                            }
                                               ];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[SignUpViewController class]]){
        SignUpViewController *signupVC = [segue destinationViewController];
        signupVC.msgLabel.text = @"SpotUs is currently only available in the cities below. Edit your city below and click confirm to save your changes.";
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
}



@end
