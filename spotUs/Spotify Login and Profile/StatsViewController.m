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
#import "PlaylistViewController.h"
#import "SVProgressHUD.h"

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
    
    [SVProgressHUD showWithStatus:@"Loading Profile..."];
    
    self.statsTableView.dataSource = self;
    self.statsTableView.delegate = self;
    // Do any additional setup after loading the view.
    self.friendProfileImage.layer.cornerRadius = self.friendProfileImage.frame.size.width / 2;
    self.friendProfileImage.clipsToBounds = YES;
    self.mapView.delegate = self;
    
    
    
    NSString *username;
    
    if(self.user == nil){
        username = [PFUser currentUser].username;
    } else{
        username = self.user.username;
    }
    
    self.navigationItem.title = username;
    
    [QueryManager getUserfromUsername:username withCompletion:^(PFUser *user, NSError *error) {
        
        
        
        self.user = user;
        if(user[@"profileImageURL"] != nil && [user[@"profileImageURL"] length] > 2){
            
            [QueryManager fadeImg:[NSURL URLWithString:user[@"profileImageURL"]] imgView:self.friendProfileImage];
        }
        
        else{
            
            self.friendProfileImage.image = [UIImage imageNamed:@"profileicon"];
        }
        //[self.friendProfileImage setImageWithURL:[NSURL URLWithString:user[@"profileImageURL"]]];
        
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
            [SVProgressHUD dismiss];
        }];

    }];
    
  
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.statsTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *cityDic =  @{ @"tracks"     : self.lastPlayedIDs,
                                @"index" : [NSNumber numberWithInteger:indexPath.row],
                                @"title" : [NSString stringWithFormat:@"%@%@", self.user.username, @"'s Last Played"]

                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.lastPlayed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

        FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stats" forIndexPath:indexPath];
        cell.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        [cell updateTrackCellwithData:self.lastPlayed[indexPath.row]];
        return cell;
        
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PlaylistViewController *playlistVC = (PlaylistViewController *)[segue destinationViewController];
    playlistVC.auth = self.auth;
    playlistVC.city = self.selectedCity;
}


@end
