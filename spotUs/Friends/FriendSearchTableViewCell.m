//
//  FriendSearchTableViewCell.m
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendSearchTableViewCell.h"
#import "FriendRequest.h"

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
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Remove Friend"
                                     message:@"Are you sure you want to delete this friend? You won't be able to see their profile!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yes = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [self removeFriend];

                                  
                                }];
        UIAlertAction* no = [UIAlertAction
                              actionWithTitle:@"No"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  
                              }];
        
        [alert addAction:yes];
        [alert addAction:no];
        
        
        [self.removeDelegate showAlert:alert];
        
        
        
        
        
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    query.limit = 20;
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    [query includeKey:@"accepted"];
    [query includeKey:@"dead"];
    [query includeKey:@"removed"];


    [query whereKey:@"accepted" equalTo:@(YES)];
    [query whereKey:@"dead" equalTo:@(YES)];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        NSArray<FriendRequest*> *requests = objects;
        
        for(FriendRequest *request in requests){
            
            if(([request.receiver.username isEqualToString:self.user.username] && [request.sender.username isEqualToString:[PFUser currentUser].username]) || ([request.receiver.username isEqualToString:[PFUser currentUser].username] && [request.sender.username isEqualToString:self.user.username])){
                
                request.removed = YES;
                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if(succeeded){
                        
                        
                        NSLog(@"updated request");
                        
                        
                        
                    }
                }];
            }
        }
        
   
    }];

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
            
            
            PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
            query.limit = 20;
            [query includeKey:@"sender"];
            [query includeKey:@"receiver"];
            [query includeKey:@"accepted"];
            [query whereKey:@"receiver" equalTo:[PFUser currentUser]];
            [query whereKey:@"sender" equalTo:self.user];

            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                FriendRequest *request = (FriendRequest *)object;
                request.accepted = YES;
                NSLog(@"Set to accepted");
                
                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if(succeeded){
                        [self.delegate didChangeFriendStatus];

                        
                        NSLog(@"updated request");

                        
                        
                    }
                }];
            }];
            
        }
    }];
    
    
    
    
}


@end
