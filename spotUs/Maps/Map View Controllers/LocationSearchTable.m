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
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
