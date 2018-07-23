//
//  ParentViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "ParentViewController.h"
#import "ProfileViewController.h"
#import "TinyPlayerViewController.h"


@implementation ParentViewController


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.'
    
    
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        ProfileViewController *profileVC = (ProfileViewController*)navController.topViewController;
        profileVC.auth = self.auth;
        profileVC.player = self.player;
        profileVC.currentUser = self.currentUser;
        
    } else if ([[segue destinationViewController] isKindOfClass:[TinyPlayerViewController class]]){
        TinyPlayerViewController *tinyplayerVC = (TinyPlayerViewController*)[segue destinationViewController];
        tinyplayerVC.auth = self.auth;
        tinyplayerVC.player = self.player;
        
    }
    
    
}

@end
