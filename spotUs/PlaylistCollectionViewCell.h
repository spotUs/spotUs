//
//  PlaylistCollectionViewCell.h
//  spotUs
//
//  Created by Megan Ung on 7/18/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *songImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIView *cellview;

- (void) updateTrackCellwithData: (NSDictionary *)trackdict;

@end
