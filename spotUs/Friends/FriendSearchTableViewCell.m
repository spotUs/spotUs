//
//  FriendSearchTableViewCell.m
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendSearchTableViewCell.h"

@interface FriendSearchTableViewCell()

@property (strong, nonatomic) PFUser *user;

@end

@implementation FriendSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onTapAddFriend:(id)sender {
    
    if(self.isRequest){
        
        [self acceptRequest];
    }
    
    else{
        
    
    
    if ([self userAdded]){
        [self removeFriend];
    } else {
        [self addFriend];
    }
        
    }
}

- (void) updateFriendSearchCellwithUser: (PFUser *)user{
    self.user = user;
    self.nameLabel.text = user.username;
    self.addUserBtn.selected = [self userAdded];
}

- (BOOL) userAdded {
    return [[PFUser currentUser][@"friends"] containsObject: self.user.username];
}

- (void) removeFriend {
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
            [self.delegate didChangeFriendStatus];
        }
    }];
}

- (void) addFriend{
    self.addUserBtn.selected = YES;

    NSMutableArray *friends = [PFUser currentUser][@"friends"];
    [friends addObject:self.user.username];
    [[PFUser currentUser] setObject:friends forKey:@"friends"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            self.addUserBtn.selected = NO;

            NSLog(@"error adding friend: %@",error.localizedDescription);
        } else {
            NSLog(@"succesfully added friend");
            [self updateFriendSearchCellwithUser:self.user];
            [self.delegate didChangeFriendStatus];

        }
    }];
}

- (void) acceptRequest{
    
    NSMutableArray *friends = [PFUser currentUser][@"friends"];
    [friends addObject:self.user.username];
    [[PFUser currentUser] setObject:friends forKey:@"friends"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            self.addUserBtn.selected = NO;
            
            NSLog(@"error adding friend: %@",error.localizedDescription);
        } else {
            NSLog(@"succesfully added friend");
            [self updateFriendSearchCellwithUser:self.user];
            [self.delegate didChangeFriendStatus];
            
        }
    }];
    
    
    
    
}


@end
