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
#import "CitiesViewController.h"
#import "City.h"

@interface SignUpViewController () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *cityPicker;
@property (strong, nonatomic) NSArray<City*> *cities;
@property (strong, nonatomic) NSArray<NSString*> *mostPlayedIDs;
@property (strong, nonatomic) City *selectedCity;






@end

@implementation SignUpViewController
- (IBAction)onTapConfirm:(id)sender {
    
    [self registerUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cityPicker.dataSource = self;
    self.cityPicker.delegate = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    [query includeKey:@"name"];
    [query includeKey:@"tracks"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        self.cities = objects;
        [self.cityPicker reloadAllComponents];
    }];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerUser {
    // initialize a user object
    PFUser *currUser = [PFUser currentUser];
    //query the city object
    NSInteger row = [self.cityPicker selectedRowInComponent:0];
    self.selectedCity = self.cities[row];
    currUser[@"city"] = self.selectedCity;
    currUser[@"favs"] = [NSMutableArray array];
    [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error saving city: %@", error.localizedDescription);
            [ErrorAlert showAlert:error.localizedDescription inVC:self];
        } else {
            NSLog(@"User saved city successfully");
            
            [self getUserTopTracks];
            
        }
    }];

    
    
}


// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.cities.count;
    
}
// The data to return for the row and component (column) that's being passed in
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return self.cities[row].name;
    
    
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
        
        self.mostPlayedIDs = songIDs;
        
        
        NSMutableArray<NSString*> *citySongs = [NSMutableArray arrayWithArray:self.selectedCity.tracks];
        
        for(int i = 0; i < 5; i++){
            
            if(![citySongs containsObject:self.mostPlayedIDs[i]]){
                [citySongs addObject:self.mostPlayedIDs[i]];
            }
            
            if( i == self.mostPlayedIDs.count-1){
                
                break;
            }
            
        }
        
        self.selectedCity.tracks = citySongs;
        
        [self.selectedCity saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            
            if(succeeded){
                
                NSLog(@"User tracks sucessfully added");
                [self performSegueWithIdentifier:@"create" sender:self];

            }
            
            else{
                
                NSLog(@"Error queueing songs: %@", error.localizedDescription);

            }
        }];
        
        
        

        
        
    }] resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
    ProfileViewController *profileVC = (ProfileViewController *)navController.topViewController;
    profileVC.player = self.player;
    profileVC.auth = self.auth;
    profileVC.currentUser = self.currentUser;
}


@end
