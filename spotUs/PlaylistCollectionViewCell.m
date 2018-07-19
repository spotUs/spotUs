//
//  PlaylistCollectionViewCell.m
//  spotUs
//
//  Created by Megan Ung on 7/18/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlaylistCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation PlaylistCollectionViewCell

- (void) updateTrackCellwithData: (NSDictionary *)trackdict{
    //get image
    NSArray *images = trackdict[@"album"][@"images"];
    if (images.count > 0){
        NSDictionary *imgData = images[0];
        NSLog(@"IMGURL %@",imgData[@"url"]);
        NSURL *imgURL = [NSURL URLWithString: imgData[@"url"]];
        [self.songImageView setImageWithURL:imgURL];
    } else {
        //get a place holder image
    }
    
    //get title
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
