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


@interface PlayerView () <SPTAudioStreamingPlaybackDelegate,PlayListViewControllerDelegate>
@property (nonatomic, strong) NSArray<SPTSavedTrack*> *songs;
@property (nonatomic, strong) NSArray<NSString*>   *topSongIDs;
@property (nonatomic, strong) NSArray<NSString*>   *citySongIDs;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;

@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property BOOL isSeeking;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;

@property NSUInteger currentSongIndex;



@end

@implementation PlayerView

- (IBAction)didChangeSlide:(id)sender {
    
    self.timeElapsedLabel.text = [self stringFromTimeInterval:self.musicSlider.value];
    self.timeLeftLabel.text = [self stringFromTimeInterval:self.player.metadata.currentTrack.duration-self.musicSlider.value];
    // update times while user is dragging
    
}
- (IBAction)didStartSeek:(id)sender {
    [self.player setIsPlaying:NO callback:nil];
    self.isPlaying = NO;
    [self.pauseButton setSelected:YES];
    // pause music when user begins to seek
}

- (IBAction)didLetGo:(id)sender {
    [self.player seekTo:self.musicSlider.value callback:nil];
    [self.player setIsPlaying:YES callback:nil];
    self.isPlaying = YES;
    [self.pauseButton setSelected:NO];
    // start music again and seek when user lets go
}

- (IBAction)goFoward:(id)sender {
    [self.player skipNext:nil];
}

- (IBAction)pauseOrUnpause:(id)sender {
    if(self.isPlaying){
        [self.player setIsPlaying:NO callback:nil];
        self.isPlaying = NO;
        [self.pauseButton setSelected:YES];
    } else {
        [self.player setIsPlaying:YES callback:nil];
        self.isPlaying = YES;
        [self.pauseButton setSelected:NO];
    }
}

- (IBAction)repeatOrUnrepeat:(id)sender {
    if (self.isRepeating) {
        [self.player setRepeat:SPTRepeatOff callback:nil];
        self.isRepeating = NO;
        [self.repeatButton setSelected:NO];
    } else {
        [self.player setRepeat:SPTRepeatOne callback:nil];
        self.isRepeating = YES;
        [self.repeatButton setSelected:YES];
    }
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.player.playbackDelegate = self;
    self.musicSlider.minimumValue = 0.0;
    self.musicSlider.value = 0;
    self.isRepeating = self.player.playbackState.isRepeating;
    self.isPlaying = self.player.playbackState.isPlaying;
    if(self.songIndex != nil){
        self.currentSongIndex = self.songIndex;
    } else {
        self.currentSongIndex = 0;
    }
    if (self.nowPlaying) {
        [self refreshSongData];
    }
    else{
        [self getCityTracks];
    }
}

- (void) getCityTracks {
    [self.city fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        City *city = (City*)object;
        NSArray *citySongs = city.tracks;
        self.citySongIDs = citySongs;
        [self startMusic];
    }];
}

- (void) startMusic {
    NSString *song = self.citySongIDs[self.currentSongIndex];
    self.currentSongIndex++;
    NSString *playRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song];
    [self.player playSpotifyURI:playRequest startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
        if(error){
            NSLog(@"Error starting music: %@", error.localizedDescription);
        }
        [self.nowPlayingDelegate didStartPlayingonCity:self.city];
    }];
}




- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSString *)trackUri{
    

    NSDictionary *cityDic =  @{ @"city" : self.city,
                                @"index" : [NSNumber numberWithInt:self.currentSongIndex],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
     object:self userInfo:cityDic];
    [self refreshSongData];
    self.isPlaying = YES;
    [self.pauseButton setSelected:NO];
    [self.player setRepeat:SPTRepeatOff callback:nil];
    self.isRepeating = NO;
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
    self.isRepeating = NO;
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
    self.albumTitleLabel.text = albumArtTrack.albumName;
    NSURL *albumURL = [NSURL URLWithString:albumArtTrack.albumCoverArtURL];
    [self.songImage setImageWithURL:albumURL];
    self.musicSlider.maximumValue = self.player.metadata.currentTrack.duration;
    self.musicSlider.value =  self.player.playbackState.position;
    self.timeElapsedLabel.text = [self stringFromTimeInterval:self.musicSlider.value];
    self.timeLeftLabel.text = [self stringFromTimeInterval:self.player.metadata.currentTrack.duration-self.musicSlider.value];
    [self.repeatButton setSelected:self.isRepeating];
    [self.pauseButton setSelected:!self.isPlaying];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
  
    return [NSString stringWithFormat:@"%01ld:%02ld",  (long)minutes, (long)seconds];
}

- (void)didChooseSongWithIndex:(NSUInteger)index {
    self.currentSongIndex = index;
    [self startMusic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     PlaylistViewController *playlistVC = (PlaylistViewController *)[segue destinationViewController];
     playlistVC.auth = self.auth;
     playlistVC.player = self.player;
     playlistVC.city = self.city;
     playlistVC.delegate = self;
 }

- (IBAction)isFavorite:(id)sender {
    [QueryManager addFavSongId:self.citySongIDs[self.currentSongIndex] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
}



@end
