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

@interface ParentViewController ()
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) UINavigationController *navController;
@end
@implementation ParentViewController

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"homeNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        //remove current navController top child VCs from stack
        [self.navController willMoveToParentViewController:nil];
        [self.navController.view removeFromSuperview];
        [self.navController removeFromParentViewController];
        //clear the navController's hierarchy history of stack VCs
        [self.navController popToRootViewControllerAnimated:YES];
        //add the navController back to the container
        [self addChildViewController:self.navController];
        [self.container addSubview:self.navController.view];
        [self.navController didMoveToParentViewController:self];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.'
    
    
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        self.navController = (UINavigationController *)[segue destinationViewController];
        
        if([self.navController.topViewController isKindOfClass:ProfileViewController.class]){
            
            ProfileViewController *profileVC = (ProfileViewController*)self.navController.topViewController;
            profileVC.auth = self.auth;
            profileVC.player = self.player;
            profileVC.currentUser = self.currentUser;
            
            
        }
    }
    
    
    else if ([[segue destinationViewController] isKindOfClass:[TinyPlayerViewController class]]){
        TinyPlayerViewController *tinyplayerVC = (TinyPlayerViewController*)[segue destinationViewController];
        tinyplayerVC.auth = self.auth;
        tinyplayerVC.player = self.player;
        
    }
    
    
    
}

- (void)didStartPlayingonCityParent:(City *)city{
    
    
}

@end
