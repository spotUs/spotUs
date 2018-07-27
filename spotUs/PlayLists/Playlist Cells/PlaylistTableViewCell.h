//
//  PlaylistTableViewCell.h
//  spotUs
//
//  Created by Megan Ung on 7/27/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

- (void) updateTrackCellwithData: (NSDictionary *)trackdict;

@end
