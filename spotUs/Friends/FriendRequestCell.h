//
//  FriendRequestCell.h
//  spotUs
//
//  Created by Martin Winton on 8/2/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse.h"

@interface FriendRequestCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addUserBtn;

- (void) updateFriendSearchCellwithUser: (PFUser *)user;
@end
