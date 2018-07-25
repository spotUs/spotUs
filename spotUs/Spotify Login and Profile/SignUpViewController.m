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
#import "City.h"
#import "ParentViewController.h"
#import "QueryManager.h"

@interface SignUpViewController () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *cityPicker;
@property (strong, nonatomic) NSArray<City*> *cities;
@property (strong, nonatomic) NSArray<NSString*> *mostPlayedIDs;
@property (strong, nonatomic) City *selectedCity;






@end

@implementation SignUpViewController
- (IBAction)onTapConfirm:(id)sender {
    
    [self saveUserCity];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cityPicker.dataSource = self;
    self.cityPicker.delegate = self;
    self.cities = QueryManager.citiesarray;
    [self.cityPicker reloadAllComponents];
    self.msgLabel.text = self.msg;
}

- (void)setPickerViewIndex {
    if (self.signup == NO){
        NSLog(@"%@",self.userCity);
        NSLog(@"%@",self.cities);
        NSUInteger index = [self.cities indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(City * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"obj: %@",obj.name);
            NSLog(@"usercity: %@",self.userCity.name);
            if ([obj.name isEqualToString: self.userCity.name]) {
                return YES;
            } else {
                return NO;
            }
        }];
        NSLog(@"index: %d",index);
        if (index < [self.cityPicker numberOfRowsInComponent:0]){
            NSLog(@"number of rows: %d",[self.cityPicker numberOfRowsInComponent:0]);
            //[self.cityPicker selectedRowInComponent:index];
            //[self.cityPicker selectRow:index inComponent:0 animated:YES];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveUserCity {
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
            if (self.signup == YES){
                [self performSegueWithIdentifier:@"create" sender:self];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
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
    [self setPickerViewIndex];
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
            } else{
                NSLog(@"Error adding user top tracks : %@", error.localizedDescription);
            }
        }];
    }] resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[ParentViewController class]]){
        ParentViewController *parentVC = (ParentViewController *)[segue destinationViewController];
        parentVC.auth = self.auth;
        parentVC.player = self.player;
    } else if ([[segue destinationViewController] isKindOfClass:[ProfileViewController class]]){
        ProfileViewController *profileVC = (ProfileViewController *)[segue destinationViewController];
        profileVC.auth = self.auth;
        profileVC.player = self.player;
        profileVC.currentUser = self.currentUser;
    }
}


@end
