//
//  FavoriteTableViewCell.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/24/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FavoriteTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation FavoriteTableViewCell

- (void) updateTrackCellwithData: (NSDictionary *)trackdict{
    //get image
    NSArray *images = trackdict[@"album"][@"images"];
    if (images.count > 0){
        NSDictionary *imgData = images[0];
       // NSLog(@"IMGURL %@",imgData[@"url"]);
        NSURL *imgURL = [NSURL URLWithString: imgData[@"url"]];
        [self.posterImage setImageWithURL:imgURL];
    }
    self.song.text = trackdict[@"name"];
    NSArray *artists = trackdict[@"artists"];
    NSString *artistStr = @"";
    for (NSUInteger i = 0; i < artists.count; i++){
        artistStr = [artistStr stringByAppendingString:artists[i][@"name"]];
        if (artists.count - 1 > i){
            artistStr = [artistStr stringByAppendingString:@", "];
        }
    }
    self.artist.text = artistStr;
}
@end
