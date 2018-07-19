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


@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *profileUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hometownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.profileUsernameLabel.text = self.currentUser.displayName;
    
    
    NSURL *profileURL = self.currentUser.largestImage.imageURL;
    [self.profileImageView setImageWithURL:profileURL];
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        PFUser *currentUser = (PFUser *)object;
        
        City *hometown = currentUser[@"city"];
        
        [hometown fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            City *fullHometown  = (City*)object;
            self.hometownLabel.text = fullHometown.name;


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
        PlayerView *profileView = (PlayerView *)[segue destinationViewController];
        profileView.player = self.player;
        profileView.auth = self.auth;
        
    }
    
    else if([[segue destinationViewController]  isKindOfClass:[CitiesViewController class]]){
        CitiesViewController *cityView = (CitiesViewController *)[segue destinationViewController];
        cityView.player = self.player;
        cityView.auth = self.auth;
    }
    
    
}



@end
