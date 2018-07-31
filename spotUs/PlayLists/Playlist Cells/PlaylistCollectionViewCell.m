//
//  PlaylistCollectionViewCell.m
//  spotUs
//
//  Created by Megan Ung on 7/18/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlaylistCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "QueryManager.h"

@implementation PlaylistCollectionViewCell

- (void) updateTrackCellwithData: (SPTTrack *)spTrack{
    
    NSArray<SPTPartialArtist*> *artists = spTrack.artists;
    self.titleLabel.text = spTrack.name;
    self.artistLabel.text = artists[0].name;
    NSURL *imgURL =  spTrack.album.largestCover.imageURL;
    [QueryManager fadeImg:imgURL imgView:self.songImageView];

    
}

@end
