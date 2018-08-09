//
//  FriendRequestViewConttoller.m
//  spotUs
//
//  Created by Martin Winton on 8/2/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendRequestViewConttoller.h"
#import "FriendSearchTableViewCell.h"
#import "StatsViewController.h"
#import "SVProgressHUD.h"

@interface FriendRequestViewConttoller () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *friendTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray <PFUser *> *users;
@property (strong, nonatomic) NSArray <PFUser *> *filteredUsers;
@property (weak, nonatomic) IBOutlet UIImageView *slideShow;


@end

@implementation FriendRequestViewConttoller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendTable.delegate = self;
    self.friendTable.dataSource = self;
    self.searchBar.delegate = self;
    [SVProgressHUD showWithStatus:@"Loading Users..."];
    [self updateUsers];
    // Do any additional setup after loading the view.
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredUsers.count;
}


- (void) updateUsers {
    // get users that are not current user and friends
    
    
    // get non friends
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    [userQuery whereKey:@"username" notContainedIn:[PFUser currentUser][@"friends"]];
    [userQuery includeKey:@"friendRequests"];
    [userQuery includeKey:@"sentfriendRequests"];

    [userQuery orderByAscending:@"username"];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error fetching non friends: %@", error.localizedDescription);
        } else {
            self.users = objects;
            self.filteredUsers = objects;
            [self.friendTable reloadData];
            [SVProgressHUD dismiss];
        }
    }];
    

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FriendSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCell" forIndexPath:indexPath];
        [cell updateFriendSearchCellwithUser:self.self.filteredUsers[indexPath.row]];
 
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.friendTable deselectRowAtIndexPath:indexPath animated:YES];
}


//search bar
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            return [[evaluatedObject.username lowercaseString] containsString:[searchText lowercaseString]];
        }];
        self.filteredUsers = [self.users filteredArrayUsingPredicate:predicate];
      
    } else {
        self.filteredUsers = self.users;
    }
    [self.friendTable reloadData];
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
