//
//  SignUpViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "SignUpViewController.h"
#import "ErrorAlert.h"
#import "ProfileViewController.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cityText;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerUser {
    // initialize a user object
    PFUser *currUser = [PFUser currentUser];
    //query the city object
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    [query whereKey:@"name" equalTo:self.cityText.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *cities, NSError *error) {
        if (!error) {
            currUser[@"city"] = cities[0];
            NSLog(@"%@",cities[0]);
            // save user's city
            [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (error != nil) {
                    NSLog(@"Error saving city: %@", error.localizedDescription);
                    [ErrorAlert showAlert:error.localizedDescription inVC:self];
                } else {
                    NSLog(@"User saved city successfully");
                }
            }];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    
}
- (IBAction)onTapSignUp:(id)sender {
    [self registerUser];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = [segue destinationViewController];
    ProfileViewController *profileVC = navController.topViewController;
    profileVC.player = self.player;
    profileVC.auth = self.auth;
    profileVC.currentUser = self.currentUser;
}


@end
