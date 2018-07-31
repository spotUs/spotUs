//
//  FavoriteCollectionViewCell.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FavoriteCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"


@implementation FavoriteCollectionViewCell

- (void) updateTrackCellwithData: (SPTTrack *)spTrack{
    
    NSArray<SPTPartialArtist*> *artists = spTrack.artists;
    self.song.text = spTrack.name;
    self.artist.text = artists[0].name;
    NSURL *imgURL =  spTrack.album.largestCover.imageURL;
    [QueryManager fadeImg:imgURL imgView:self.posterImage];

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
            self.city.text = citystr;
        }
    }];

}

@end
