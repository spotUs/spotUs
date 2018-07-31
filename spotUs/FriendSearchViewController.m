//
//  FriendSearchViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "FriendSearchTableViewCell.h"

@interface FriendSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray <PFUser *> *users;
@property (strong, nonatomic) NSArray <PFUser *> *filteredFriends;
@property (strong, nonatomic) NSArray <PFUser *> *filteredNotFriends;
@property (strong, nonatomic) NSArray <PFUser *> *usersFriends;
@property (strong, nonatomic) NSArray <PFUser *> *usersNotFriends;

@end

@implementation FriendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    self.usersFriends = [NSArray array];
    self.usersNotFriends = [NSArray array];
    self.filteredFriends = self.usersFriends;
    self.filteredNotFriends = self.usersNotFriends;
    
    [self updateUsers];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUsers {
    // get users that are not current user and friends
    PFQuery *friendQuery = [PFUser query];
    [friendQuery whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    [friendQuery whereKey:@"username" containedIn:[PFUser currentUser][@"friends"]];
    [friendQuery orderByAscending:@"username"];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.usersFriends = objects;
        self.filteredFriends = objects;
        NSLog(@"filteredfriends %@",self.filteredFriends);
        [self.tableView reloadData];
    }];
    // get non friends
    PFQuery *notFriendQuery = [PFUser query];
    [notFriendQuery whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    [notFriendQuery whereKey:@"username" notContainedIn:[PFUser currentUser][@"friends"]];
    [notFriendQuery orderByAscending:@"username"];
    [notFriendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.usersNotFriends = objects;
        self.filteredNotFriends = objects;
        [self.tableView reloadData];
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        cell.textLabel.text = @"Friends: ";
        return cell;
    } else if (indexPath.row == self.filteredFriends.count + 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        cell.textLabel.text = @"Other Users: ";
        return cell;
    } else {
        FriendSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendSearchCell" forIndexPath:indexPath];
        if (indexPath.row - 1 < self.filteredFriends.count){
            [cell updateFriendSearchCellwithUser:self.filteredFriends[indexPath.row - 1]];
        } else {
            [cell updateFriendSearchCellwithUser:self.filteredNotFriends[indexPath.row - 2 - self.filteredFriends.count]];
        }
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredFriends.count + self.filteredNotFriends.count + 2;
}

//search bar
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            return [[evaluatedObject.username lowercaseString] containsString:[searchText lowercaseString]];
        }];
        self.filteredFriends = [self.usersFriends filteredArrayUsingPredicate:predicate];
        self.filteredNotFriends = [self.usersNotFriends filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredNotFriends = self.usersNotFriends;
        self.filteredFriends = self.usersFriends;
    }
    [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
