//
//  FriendRequestCell.m
//  spotUs
//
//  Created by Martin Winton on 8/2/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendRequestCell.h"
#import "FriendRequest.h"

@interface FriendRequestCell()

@property (strong, nonatomic) PFUser *user;
@end
@implementation FriendRequestCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)onTapAddFriend:(id)sender {
    if ([self userAdded]){
        [self removeRequest];
    } else {
        [self addRequest];
    }
}

- (void) updateFriendSearchCellwithUser: (PFUser *)user{
    self.user = user;
    self.nameLabel.text = user.username;
    self.addUserBtn.selected = [self userAdded];
}

- (BOOL) userAdded {
    return [[PFUser currentUser][@"sentFriendRequests"] containsObject: self.user.username];
}

- (void) removeRequest {
    self.addUserBtn.selected = NO;
    
    NSMutableArray *friends = [PFUser currentUser][@"friends"];
    [friends removeObject:self.user.username];
    [[PFUser currentUser] setObject:friends forKey:@"friends"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            self.addUserBtn.selected = YES;
            
            NSLog(@"error removing friend: %@",error.localizedDescription);
        } else {
            NSLog(@"succesfully removed friend");
            [self updateFriendSearchCellwithUser:self.user];
       
        }
    }];
}

- (void) addRequest{
    self.addUserBtn.selected = YES;
    
    FriendRequest *request= [FriendRequest sendRequestFrom:[PFUser currentUser] To:self.user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        
        
    }];
    
    NSMutableArray *requests = [NSMutableArray arrayWithArray:[PFUser currentUser][@"sentFriendRequests"]];
    [requests addObject:request];
    [[PFUser currentUser] setObject:requests forKey:@"sentFriendRequests"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            
            NSLog(@"error adding friend: %@",error.localizedDescription);
        } else {
            NSLog(@"succesfully added friend request");
            [self updateFriendSearchCellwithUser:self.user];
    
            
            
            
            
            
        }
    }];
}

@end
