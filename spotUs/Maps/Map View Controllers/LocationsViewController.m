//
//  LocationsViewController.m
//  PhotoMap
//
//  Created by Lizbeth Alejandra Gonzalez on 7/17/18.
//  Copyright © 2018 Codepath. All rights reserved.
//

#import "LocationsViewController.h"
#import "LocationCell.h"
#import "Parse.h"

static NSString * const clientID = @"QA1L0Z0ZNA2QVEEDHFPQWK0I5F1DE3GPLSNW4BZEBGJXUCFL";
static NSString * const clientSecret = @"W2AOE1TYC4MHK5SZYOUGX0J3LVRALMPB4CXT3ZH21ZCPUMCU";

@interface LocationsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *results;

@end

@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    [cell updateWithLocation:self.results[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This is the selected venue
    NSDictionary *venue = self.results[indexPath.row];
    NSNumber *lat = [venue valueForKeyPath:@"location.lat"];
    NSNumber *lng = [venue valueForKeyPath:@"location.lng"];
    NSLog(@"%@, %@", lat, lng);
    
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    [self fetchLocations];
    return true;
}

- (void) tapSearchBarSearchButton:(UISearchBar *)searchBar {
    [self fetchLocations];
}

- (void)fetchLocations {
    
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    query.limit = 20;
    [query includeKey:@"lng"];
    [query includeKey:@"lat"];
    [query includeKey:@"name"];
    [query includeKey:@"tracks"];
    [query orderByAscending:@"name"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *cities, NSError *error) {
        if (!error) {
            //do something on success
        }
    
     else {
        NSLog(@"%@", error.localizedDescription);
    }
     }];
    
            //[self.tableView reloadData];
    
    //[task resume];
}

@end

