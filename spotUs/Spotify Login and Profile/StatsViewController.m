//
//  StatsViewController.m
//  spotUs
//
//  Created by Martin Winton on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "StatsViewController.h"
#import "QueryManager.h"
#import "FavoriteTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+AFNetworking.h"

#define METERS_PER_MILE 1609.344
@interface StatsViewController () <UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *statsTableView;
@property (strong, nonatomic) NSArray<SPTTrack*> *lastPlayed;
@property (strong, nonatomic) NSArray<NSString*> *lastPlayedIDs;
@property (weak, nonatomic) IBOutlet UIImageView *friendProfileImage;
@property (strong, nonatomic) City * selectedCity;



@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statsTableView.dataSource = self;
    self.statsTableView.delegate = self;
    // Do any additional setup after loading the view.
    self.friendProfileImage.layer.cornerRadius = self.friendProfileImage.frame.size.width / 2;
    self.friendProfileImage.clipsToBounds = YES;
    self.mapView.delegate = self;
    
    
    
    NSString *username;
    
    if(self.user == nil){
        
        username = [PFUser currentUser].username;
        
       
    }
    
    else{
        username = self.user.username;
        
        
    }
    
    self.navigationItem.title = username;
    
    [QueryManager getUserfromUsername:username withCompletion:^(PFUser *user, NSError *error) {
        
        
        self.user = user;
        [self.friendProfileImage setImageWithURL:[NSURL URLWithString:user[@"profileImageURL"]]];

        self.selectedCity =self.user[@"city"];
        
        NSLog(@"%@", self.user[@"city"]);
        
        CLLocationCoordinate2D  ctrpoint;
        
        double longi = [self.selectedCity[@"lng"] doubleValue];
        NSLog(@"%f",longi);
        double lat = [self.selectedCity[@"lat"] doubleValue];
        ctrpoint.latitude = lat;
        ctrpoint.longitude = longi;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:ctrpoint];
        
        NSString *myString = self.user.username;
        NSString *test = self.selectedCity.name;
        [annotation setTitle:test];
        [self.mapView addAnnotation:annotation];
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(ctrpoint, 0.9*METERS_PER_MILE, 0.9*METERS_PER_MILE);
        
        [self.mapView setRegion:viewRegion animated:YES];
    }];
    
    [QueryManager fetchLastPlayedOfUsername:username WithCompletion:^(NSArray *lastPlayed, NSError *error) {
        
        self.lastPlayedIDs = [lastPlayed reverseObjectEnumerator].allObjects;
        
        
        
        [QueryManager getSPTracksFromIDs:self.lastPlayedIDs withCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            
            self.lastPlayed = object;
            [self.statsTableView reloadData];
        }];

    }];
    
  
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.statsTableView deselectRowAtIndexPath:indexPath animated:YES];

    
    
    
    NSDictionary *cityDic =  @{ @"favtracks"     : self.lastPlayedIDs,
                                @"index" : [NSNumber numberWithInteger:indexPath.row],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Play Favorites"
                                                        object:self userInfo:cityDic];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.lastPlayed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

        FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stats" forIndexPath:indexPath];
        NSLog(@"updating?");
        cell.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        [cell updateTrackCellwithData:self.lastPlayed[indexPath.row]];
        return cell;
        
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillAppear:(BOOL)animated {
//    CLLocationCoordinate2D zoomLocation;
//    double longi = [self.selectedCity[@"lng"] doubleValue];
//    NSLog(@"%f",longi);
//    double lat = [self.selectedCity[@"lat"] doubleValue];
//    zoomLocation.latitude =lat;
//    zoomLocation.longitude= longi;
//
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
//
//    [_mapView setRegion:viewRegion animated:YES];
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
