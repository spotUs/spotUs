//
//  FriendSearchTableViewCell.m
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendSearchTableViewCell.h"
#import "FriendRequest.h"
#import "SVProgressHUD.h"

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
        TYAlertView *alert = [TYAlertView alertViewWithTitle:@"Remove Friend" message:@"Are you sure you want to delete this friend? You won't be able to see their profile!"];

        [alert addAction:[TYAlertAction actionWithTitle:@"Yes" style:TYAlertActionStyleDefault handler:^(TYAlertAction *action) {
            [self removeFriend];
        }]];
        
        [alert addAction:[TYAlertAction actionWithTitle:@"No" style:TYAlertActionStyleCancel handler:^(TYAlertAction *action) {
        }]];
        

        
        
        
        
        [self.removeDelegate showAlert:alert];
        
        
        
        
        
    }
}

- (void) updateFriendSearchCellwithUser: (PFUser *)user{
    self.user = user;
    self.nameLabel.text = user.username;
}



- (void) removeFriend {
    [SVProgressHUD showWithStatus:@"Removing Friend :("];
    self.addUserBtn.selected = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    query.limit = 20;
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    [query whereKey:@"accepted" equalTo:@(YES)];
    [query whereKey:@"notifiedAccepted" equalTo:@(YES)];
    [query whereKey:@"removed" equalTo:@(NO)];
    [query whereKey:@"notifiedRemoved" equalTo:@(NO)];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        NSArray<FriendRequest*> *requests = objects;
        
        for(FriendRequest *request in requests){
            
            if(([request.receiver.username isEqualToString:self.user.username] && [request.sender.username isEqualToString:[PFUser currentUser].username]) || ([request.receiver.username isEqualToString:[PFUser currentUser].username] && [request.sender.username isEqualToString:self.user.username])){
                
                request.removed = YES;
                request.removee = self.user.username;
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
            [self.delegate didChangeFriendStatus];
        }
    }];
}



- (void) acceptRequest{
    [SVProgressHUD showWithStatus:@"Adding Friend..."];
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        PFUser *me = (PFUser *)object;
        
        NSMutableArray *friends = me[@"friends"];
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
                [query whereKey:@"notifiedAccepted" equalTo:@(NO)];
                [query whereKey:@"accepted" equalTo:@(NO)];
                [query whereKey:@"removed" equalTo:@(NO)];
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
        
        
        
        
        
        
    }];
    

    
    
    
}


@end
