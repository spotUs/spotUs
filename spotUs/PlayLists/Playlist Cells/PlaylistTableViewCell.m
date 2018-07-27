//
//  PlaylistTableViewCell.m
//  spotUs
//
//  Created by Megan Ung on 7/27/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlaylistTableViewCell.h"

@implementation PlaylistTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) updateTrackCellwithData: (NSDictionary *)trackdict {
    //get title
    NSLog(@"%@",trackdict[@"name"]);

    self.titleLabel.text = trackdict[@"name"];
    //get artists
    NSArray *artists = trackdict[@"artists"];
    NSString *artistStr = @"";
    for (NSUInteger i = 0; i < artists.count; i++){
        artistStr = [artistStr stringByAppendingString:artists[i][@"name"]];
        if (artists.count - 1 > i){ // if it is not the last artist
            artistStr = [artistStr stringByAppendingString:@", "];
        }
    }
    self.artistLabel.text = artistStr;
}

@end
