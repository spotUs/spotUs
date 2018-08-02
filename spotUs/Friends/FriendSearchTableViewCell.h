//
//  FriendSearchTableViewCell.h
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@protocol FriendStatusDelegate

- (void)didChangeFriendStatus;

@end

@interface FriendSearchTableViewCell : UITableViewCell
@property (nonatomic, weak) id<FriendStatusDelegate> delegate;
@property BOOL isRequest;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addUserBtn;

- (void) updateFriendSearchCellwithUser: (PFUser *)user;

@end
