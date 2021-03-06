//
//  FavoriteTableViewCell.h
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/24/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueryManager.h"

@interface FavoriteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UILabel *song;
@property (weak, nonatomic) IBOutlet UILabel *city;

- (void) updateTrackCellwithData: (SPTTrack *)trackdict;

@end
