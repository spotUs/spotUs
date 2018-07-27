//
//  PlayerView.m
//  spotUs
//
//  Created by Martin Winton on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlayerView.h"
#import "UIImageView+AFNetworking.h"
#import "PlaylistViewController.h"
#import "QueryManager.h"


@interface PlayerView () <SPTAudioStreamingPlaybackDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;

@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property BOOL isSeeking;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (strong, nonatomic) NSMutableArray *ina;


@end

@implementation PlayerView
- (IBAction)didClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.dismissDelegate didDismissWithIndex:[NSNumber numberWithUnsignedInteger:self.currentSongIndex]];
}

- (IBAction)didChangeSlide:(id)sender {
    
    self.timeElapsedLabel.text = [self stringFromTimeInterval:self.musicSlider.value];
    self.timeLeftLabel.text = [self stringFromTimeInterval:self.player.metadata.currentTrack.duration-self.musicSlider.value];
    // update times while user is dragging
    
}
- (IBAction)didStartSeek:(id)sender {
    [self.player setIsPlaying:NO callback:nil];
    [self.pauseButton setSelected:YES];
    // pause music when user begins to seek
}

- (IBAction)didLetGo:(id)sender {
    [self.player seekTo:self.musicSlider.value callback:nil];
    [self.player setIsPlaying:YES callback:nil];
    [self.pauseButton setSelected:NO];
    // start music again and seek when user lets go
}
- (IBAction)goBack:(id)sender {
    
    
    if(self.player.playbackState.position < 5){
        
        
        self.currentSongIndex = MAX(self.currentSongIndex-3, 0);
    }
    else{
        
        self.currentSongIndex = MAX(self.currentSongIndex-2, 0);
        
    }
    
    NSString *song = self.citySongIDs[self.currentSongIndex];
    self.currentSongIndex++;

    NSString *playRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song];
    [self.player playSpotifyURI:playRequest startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
        
        if(error){
            NSLog(@"Error starting music: %@", error.localizedDescription);
        }
        
    }];
    
    
    
}

- (IBAction)goFoward:(id)sender {
    [self.player skipNext:nil];
}

- (IBAction)pauseOrUnpause:(id)sender {
    if(self.player.playbackState.isPlaying){
        [self.player setIsPlaying:NO callback:nil];
        [self.pauseButton setSelected:YES];
    } else {
        [self.player setIsPlaying:YES callback:nil];
        [self.pauseButton setSelected:NO];
    }
}

- (IBAction)repeatOrUnrepeat:(id)sender {
    if (self.player.playbackState.isRepeating) {
        [self.player setRepeat:SPTRepeatOff callback:nil];
        [self.repeatButton setSelected:NO];
    } else {
        [self.player setRepeat:SPTRepeatOne callback:nil];
        [self.repeatButton setSelected:YES];
    }
}


- (void) viewDidLoad {
    [super viewDidLoad];
    self.player.playbackDelegate = self;
    self.musicSlider.minimumValue = 0.0;
    self.musicSlider.value = 0;
    [self refreshSongData];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSString *)trackUri{
    
    
    [self refreshSongData];
    [self.pauseButton setSelected:NO];
    
    [self.player setRepeat:SPTRepeatOff callback:nil];
    [self.repeatButton setSelected:NO];
    if (self.player.metadata.nextTrack == nil) {
        if (self.currentSongIndex == self.citySongIDs.count){
            self.currentSongIndex = 0;
        }
        NSString *song = self.citySongIDs[self.currentSongIndex];
        NSString *queueRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song];
        [self.player queueSpotifyURI:queueRequest callback:^(NSError *error) {
            if (error) {
                NSLog(@"Error queueing song: %@", error.localizedDescription);
            }
        }];
        self.currentSongIndex++;
    }
}

- (void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming{
    [self refreshSongData];
    [self.player setRepeat:SPTRepeatOff callback:nil];
    [self.repeatButton setSelected:NO];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePosition:(NSTimeInterval)position{
    self.musicSlider.value = position;
    self.timeElapsedLabel.text = [self stringFromTimeInterval:position];
    self.timeLeftLabel.text = [self stringFromTimeInterval:self.player.metadata.currentTrack.duration-position];
}


- (void) refreshSongData{
    SPTPlaybackTrack *albumArtTrack = self.player.metadata.currentTrack;
    self.songTitle.text = albumArtTrack.name;
    self.artistNameLabel.text = albumArtTrack.artistName;
    NSURL *albumURL = [NSURL URLWithString:albumArtTrack.albumCoverArtURL];
    [QueryManager fadeImg:albumURL imgView:self.songImage];
    //[self.songImage setImageWithURL:albumURL];
    self.musicSlider.maximumValue = self.player.metadata.currentTrack.duration;
    self.musicSlider.value =  self.player.playbackState.position;
    self.timeElapsedLabel.text = [self stringFromTimeInterval:self.musicSlider.value];
    self.timeLeftLabel.text = [self stringFromTimeInterval:self.player.metadata.currentTrack.duration-self.musicSlider.value];
    [self.repeatButton setSelected:self.player.playbackState.isRepeating];
    [self.pauseButton setSelected:!self.player.playbackState.isPlaying];

    [QueryManager fetchFavs:^(NSArray * _Nonnull favs, NSError * _Nullable error) {
        NSString *stringID = [self.player.metadata.currentTrack.uri substringFromIndex:14];
        if([favs containsObject:stringID]) {
            [self.favoriteButton setSelected: YES];
        }
        else {
            [self.favoriteButton setSelected: NO];
        }
    }];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    
    return [NSString stringWithFormat:@"%01ld:%02ld",  (long)minutes, (long)seconds];
}


- (IBAction)isFavorite:(id)sender {
    
    NSString *stringID = [self.player.metadata.currentTrack.uri substringFromIndex:14];
    [QueryManager addFavSongId:stringID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Update Favorites"
                                                            object:self];
    }];
    
    if(self.favoriteButton.isSelected){
        [self.favoriteButton setSelected:NO];
        
    }
    else {
        [self.favoriteButton setSelected:YES];
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
}

- (IBAction)flagged:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Flagged!" message:@"Why did you flag this song?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Inappropriate Material",@"Does not match city", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView firstOtherButtonIndex]){
        [self.ina addObject:@"Report"];
        NSLog(@"inappropriate Material");
        NSString *stringID = [self.player.metadata.currentTrack.uri substringFromIndex:14];
        [QueryManager addInappropriate:stringID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Update Favorites"
                                                                object:self];
        }];
        
    }
    else if(buttonIndex == [alertView cancelButtonIndex]){
        NSLog(@"cancelled");
    }
    else {
        NSString *stringID = [self.player.metadata.currentTrack.uri substringFromIndex:14];
        [QueryManager addUnmatched:stringID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Update Favorites"
                                                                object:self];
        }];
        NSLog(@"Does not match city");
    }
}
@end
