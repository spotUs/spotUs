//
//  PlaylistTableViewCell.m
//  spotUs
//
//  Created by Megan Ung on 7/27/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlaylistTableViewCell.h"
#import "QueryManager.h"

@implementation PlaylistTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) updateTrackCellwithData: (SPTTrack *)spTrack{
    
    NSArray<SPTPartialArtist*> *artists = spTrack.artists;
    self.titleLabel.text = spTrack.name;
    self.artistLabel.text = artists[0].name;
    
    [QueryManager getTrackfromID:spTrack.identifier withCompletion:^(Track *track, NSError *error) {
        if (error){
            NSLog(@"error could not get city: %@",error.localizedDescription);
        } else {
            NSUInteger i = 0;
            NSString *citystr = @"";
            while (track.citynames.count > i){
                citystr = [citystr stringByAppendingString:track.citynames[i]];
                i = i + 1;
                if (i != track.citynames.count){
                    citystr = [citystr stringByAppendingString:@", "];
                }
            }
            self.cityLabel.text = citystr;
        }
    }];
    
    
}

@end
