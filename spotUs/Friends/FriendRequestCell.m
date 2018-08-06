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
 
    if(!self.addUserBtn.selected){
    
        [self addRequest];
    }
    
}

- (void) updateFriendSearchCellwithUser: (PFUser *)user{
    self.user = user;
    self.nameLabel.text = user.username;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    query.limit = 20;
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    [query includeKey:@"accepted"];
    [query whereKey:@"receiver" equalTo:self.user];
    [query whereKey:@"dead" notEqualTo:@(YES)];
    [query whereKey:@"accepted" notEqualTo:@(YES)];

    [query orderByAscending:@"reciever"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if(objects.count > 0){
            self.addUserBtn.selected = YES;

        }
        else{
            self.addUserBtn.selected = NO;

            
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
            self.addUserBtn.selected = NO;

            
            NSLog(@"error adding friend: %@",error.localizedDescription);
        } else {
            NSLog(@"succesfully added friend request");
    
            
            
            
            
            
        }
    }];
}

@end
