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
                    [self performSegueWithIdentifier:@"create" sender:self];
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

- (void) getUserTopTracks {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.spotify.com/v1/me/top/tracks"]];
    NSDictionary *headers = @{@"Authorization":[@"Bearer " stringByAppendingString:self.auth.session.accessToken]};
    [request setAllHTTPHeaderFields:(headers)];
    [request setHTTPMethod:@"GET"];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *datadict = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        NSArray *tracksArray = datadict[@"items"]; //iterate through the array to get the id of each song
        NSMutableArray<NSString*> *songIDs = [NSMutableArray new];
        for(NSDictionary *dictionary in tracksArray){
            
            NSString *spotifyID = dictionary[@"id"];
            [songIDs addObject:spotifyID];
        }
        
        
        
    }] resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
    ProfileViewController *profileVC = navController.topViewController;
    profileVC.player = self.player;
    profileVC.auth = self.auth;
    profileVC.currentUser = self.currentUser;
}


@end
