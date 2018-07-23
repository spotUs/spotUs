//
//  LocationSearchTable.m
//  spotUs
//
//  Created by Martin Winton on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "LocationSearchTable.h"

@interface LocationSearchTable () <UISearchResultsUpdating>
@property (strong, nonatomic) NSArray<City*> *cities;
@property (strong, nonatomic) NSArray<City*> *filteredCities;
@end

@implementation LocationSearchTable

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchCities];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)fetchCities{
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    query.limit = 20;
    [query includeKey:@"lng"];
    [query includeKey:@"lat"];
    [query includeKey:@"name"];
    [query includeKey:@"tracks"];
    [query orderByAscending:@"name"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *cities, NSError *error) {
        if (!error) {
            self.cities = cities;
            if (self.filteredCities == nil){
                self.filteredCities = cities;
            }
            NSLog(@"%@",self.filteredCities);
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell"];
    City *city = self.filteredCities[indexPath.row];
    cell.textLabel.text = city.name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredCities.count;
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings){
            return [[evaluatedObject[@"name"] lowercaseString] containsString:[searchText lowercaseString]];
        }];
        self.filteredCities
        = [self.cities filteredArrayUsingPredicate:predicate];
        NSLog(@"%@",self.filteredCities);
    } else {
        self.filteredCities = self.cities;
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    NSString *searchText = searchController.searchBar.text;
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings){
            return [[evaluatedObject[@"name"] lowercaseString] containsString:[searchText lowercaseString]];
        }];
        self.filteredCities
        = [self.cities filteredArrayUsingPredicate:predicate];
        NSLog(@"%@",self.filteredCities);
    }
    else {
        self.filteredCities = self.cities;
    }
    [self.tableView reloadData];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    City *city = self.filteredCities[indexPath.row];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:city.lat longitude:city.lng];
    
    [self.handleMapsearchDelegate ZoomInOnLocation:location];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
