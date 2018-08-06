//
//  FriendSearchTableViewCell.h
//  spotUs
//
//  Created by Megan Ung on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UIView+TYAlertView.h"


@protocol FriendStatusDelegate

- (void)didChangeFriendStatus;

@end

@protocol RemoveFriendDelegate

- (void)showAlert:(TYAlertView*)alert;

@end

@interface FriendSearchTableViewCell : UITableViewCell
@property (nonatomic, weak) id<FriendStatusDelegate> delegate;
@property (nonatomic, weak) id<RemoveFriendDelegate> removeDelegate;

@property BOOL isRequest;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addUserBtn;

- (void) updateFriendSearchCellwithUser: (PFUser *)user;

@end
