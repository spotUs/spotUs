//
//  FriendSearchViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "FriendSearchTableViewCell.h"
#import "StatsViewController.h"
#import "SVProgressHUD.h"
#import "FriendRequest.h"
#import "UIView+TYAlertView.h"

@interface FriendSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FriendStatusDelegate, RemoveFriendDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *slideShow;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray <PFUser *> *users;
@property (strong, nonatomic) NSArray <PFUser *> *filteredFriends;
@property (strong, nonatomic) NSArray <PFUser *> *filteredNotFriends;
@property (strong, nonatomic) NSArray <PFUser *> *usersFriends;
@property (strong, nonatomic) NSArray <PFUser *> *usersNotFriends;
@property  NSInteger tappedIndex;


@end

@implementation FriendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(didPullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.usersFriends = [NSArray array];
    self.usersNotFriends = [NSArray array];
    self.filteredFriends = self.usersFriends;
    self.filteredNotFriends = self.usersNotFriends;
    self.tableView.rowHeight = 63;
    
    [SVProgressHUD showWithStatus:@"Loading Friends..."];
    NSArray *animationImages = [[NSArray alloc] initWithObjects:
                                [UIImage imageNamed:@"Adelle"],
                                [UIImage imageNamed:@"blake"],
                                [UIImage imageNamed:@"bts"], [UIImage imageNamed:@"chris"],
                                [UIImage imageNamed:@"drake"],[UIImage imageNamed:@"joan"],
                                [UIImage imageNamed:@"reik"],[UIImage imageNamed:@"selena"],
                                [UIImage imageNamed:@"taylor"],nil];
    _slideShow.animationImages=animationImages;
    [_slideShow setAnimationDuration: 6];
    [_slideShow startAnimating];
    
    [self updateUsers];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didPullToRefresh:(UIRefreshControl *)refreshControl{
    [self updateUsers];
}

- (void) updateUsers {
    // get users that are not current user and friends
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        PFUser *me = (PFUser*)object;
        
        PFQuery *removedFriendQuery = [PFQuery queryWithClassName:@"FriendRequest"];
        removedFriendQuery.limit = 20;
        [removedFriendQuery includeKey:@"sender"];
        [removedFriendQuery includeKey:@"receiver"];
        [removedFriendQuery includeKey:@"removee"];
        [removedFriendQuery whereKey:@"accepted" equalTo:@(YES)];
        [removedFriendQuery whereKey:@"notifiedAccepted" equalTo:@(YES)];
        [removedFriendQuery whereKey:@"removed" equalTo:@(YES)];
        [removedFriendQuery whereKey:@"notifiedRemoved" equalTo:@(NO)];

        
        
        [removedFriendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error){
                NSLog(@"error fetching friends: %@",error.localizedDescription);
            } else {
                
                NSArray<FriendRequest*> *requests = objects;
                NSMutableArray *mutableFriends =  [NSMutableArray arrayWithArray:me[@"friends"]];
                
                
                for(FriendRequest *request in requests){
                    
                    if([request.removee isEqualToString:me.username]){
                        
                        if([request.receiver.username isEqualToString:me.username]){
                            [mutableFriends removeObject:request.sender.username];
                            request.notifiedRemoved = YES;
                            
                            
                            
                            
                        }
                        
                        else if([request.sender.username isEqualToString:me.username]){
                            [mutableFriends removeObject:request.receiver.username];
                            request.notifiedRemoved = YES;
                            
                            
                            
                            
                        }
                    }
                    [request saveInBackground];
                }
                
                [PFUser currentUser][@"friends"] = mutableFriends;
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
                    query.limit = 20;
                    [query includeKey:@"sender"];
                    [query includeKey:@"receiver"];
                    [query includeKey:@"accepted"];
                    [query whereKey:@"sender" equalTo:[PFUser currentUser]];
                    [query orderByAscending:@"reciever"];
                    
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        
                        NSArray <FriendRequest*> *requests = objects;
                        
                        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                            
                            PFUser *me = (PFUser*)object;
                            
                            NSMutableArray<NSString*> *friends = [NSMutableArray arrayWithArray:object[@"friends"]];
                            
                            for( FriendRequest *request in requests){
                                
                                if(![friends containsObject:request.receiver.username] && request.accepted && !request.notifiedAccepted){
                                    
                                    request.notifiedAccepted = YES;
                                    
                                    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                        if (error){
                                            NSLog(@"error killing request: %@",error.localizedDescription);
                                        }
                                        
                                    }];
                                    
                                    [friends addObject:request.receiver.username];
                                    
                                }
                            }
                            
                            [[PFUser currentUser] setObject:friends forKey:@"friends"];
                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                
                                
                                PFQuery *friendQuery = [PFUser query];
                                [friendQuery whereKey:@"username" notEqualTo:[PFUser currentUser].username];
                                [friendQuery whereKey:@"username" containedIn:[PFUser currentUser][@"friends"]];
                                [friendQuery orderByAscending:@"username"];
                                [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                    if (error){
                                        NSLog(@"error fetching friends: %@",error.localizedDescription);
                                    } else {
                                        
                                        self.usersFriends = objects;
                                        self.filteredFriends = objects;
                                        NSLog(@"filteredfriends %@",self.filteredFriends);
                                        
                                        // get requests
                                        PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
                                        query.limit = 20;
                                        [query includeKey:@"sender"];
                                        [query includeKey:@"receiver"];
                                        [query includeKey:@"accepted"];
                                        [query whereKey:@"receiver" equalTo:[PFUser currentUser]];
                                        [query orderByAscending:@"reciever"];
                                        
                                        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                            if (error) {
                                                NSLog(@"error fetching non friends: %@", error.localizedDescription);
                                            } else {
                                                
                                                NSMutableArray *senderNames = [NSMutableArray array];
                                                for(FriendRequest *request in objects){
                                                    
                                                    if(!request.accepted){
                                                        
                                                        [senderNames addObject:request.sender];
                                                    }
                                                    
                                                    
                                                    
                                                }
                                                
                                                self.usersNotFriends = senderNames;
                                                self.filteredNotFriends = senderNames;
                                                [self.tableView reloadData];
                                                [SVProgressHUD dismiss];
                                            }
                                            [self.refreshControl endRefreshing];
                                        }];
                                    }
                                }];
                                
                                
                                
                            }];
                            
                            
                            
                        }];
                        
                    }];
                    
                    
                    
                    
                    
                    
                    
                    
                }];
                
            }
            
            
            
            
            
            
            
            
        }];
        
        
        
        
        
        
    }];
    

    
    
    
    

   
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        cell.textLabel.text = @" My Friends: ";
        [cell.textLabel setFont:[UIFont fontWithName:@"HindVadodara-Bold" size:20]];
         [cell.textLabel setTextColor:[UIColor colorWithRed:0.15 green:0.22 blue:0.40 alpha:1.0]];
    

        return cell;
    } else if (indexPath.row == self.filteredFriends.count + 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        cell.textLabel.text = @"Friend Request: ";
          [cell.textLabel setFont:[UIFont fontWithName:@"HindVadodara-Bold" size:20]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.15 green:0.22 blue:0.40 alpha:1.0]];
        return cell;
    } else {
        FriendSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendSearchCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.removeDelegate = self;
        if (indexPath.row - 1 < self.filteredFriends.count){
            cell.isRequest = NO;
            [cell updateFriendSearchCellwithUser:self.filteredFriends[indexPath.row - 1]];
        } else {
            cell.isRequest = YES;
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    self.tappedIndex = indexPath.row;
    
    if(self.tappedIndex - 1 < self.filteredFriends.count){

    [self performSegueWithIdentifier:@"stats" sender:indexPath];
    }
}

- (void)didChangeFriendStatus{
    
    [self updateUsers];

    
    
}

- (void)showAlert:(TYAlertController *)alert{
    
    
    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alert preferredStyle:TYAlertControllerStyleAlert transitionAnimation:TYAlertTransitionAnimationDropDown ];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue destinationViewController] isKindOfClass:[StatsViewController class]]){
        StatsViewController *statVC = (StatsViewController*)[segue destinationViewController];
        statVC.auth = self.auth;
        statVC.user = self.filteredFriends[self.tappedIndex-1];
        
    }

    
    
    
    
    
    
    
    
}





@end
