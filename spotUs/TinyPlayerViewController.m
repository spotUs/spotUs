//
//  TinyPlayerViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "TinyPlayerViewController.h"
#import "UIImageView+AFNetworking.h"




@interface TinyPlayerViewController () <SPTAudioStreamingPlaybackDelegate>
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

@property int currentSongIndex;



@end

@implementation TinyPlayerViewController




- (IBAction)pauseOrUnpause:(id)sender {
    
    if(self.isPlaying){
        
        [self.player setIsPlaying:NO callback:nil];
        self.isPlaying = NO;
        [self.pauseButton setSelected:YES];
        
        
    }
    
    else{
        [self.player setIsPlaying:YES callback:nil];
        self.isPlaying = YES;
        [self.pauseButton setSelected:NO];
        
        
        
    }
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"Chose Playlist"
                                               object:nil];

    
    self.player.playbackDelegate = self;
    self.musicSlider.minimumValue = 0.0;
    self.musicSlider.value = 0;
    self.isRepeating = self.player.playbackState.isRepeating;
    self.isPlaying = self.player.playbackState.isPlaying;
    self.currentSongIndex = 0;
    
    
    if(self.nowPlaying){
        
        [self refreshSongData];
        
    }
    else{
        
        
        [self getCityTracks];
    }
    
    
    
}


- (void) receiveTestNotification:(NSNotification *) notification{

    
    if ([[notification name] isEqualToString:@"Chose Playlist"]){
        NSLog (@"Successfully received the chose Playlist!");
        self.player.playbackDelegate = self;
        NSDictionary *userInfo = notification.userInfo;

        self.city = userInfo[@"city"];
        self.currentSongIndex = [userInfo[@"index"] intValue];

        [self refreshSongData];
        
    }
    
}

-(void)getCityTracks{
    
    
    
    [self.city fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        
        City *city = (City*)object;
        
        NSArray *citySongs = city.tracks;
        self.citySongIDs = citySongs;
        
        [self startMusic];
        
        
    }];
    
    
}

-(void)startMusic{
    
    
    
    NSString *song = self.citySongIDs[self.currentSongIndex];
    self.currentSongIndex++;
    NSString *playRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song];
    [self.player playSpotifyURI:playRequest startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
        
        if(error){
            NSLog(@"Error starting music: %@", error.localizedDescription);
        }
        
    }];
    
}




- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSString *)trackUri{
    
    [self refreshSongData];
    self.isPlaying = YES;
    [self.pauseButton setSelected:NO];
    
    [self.player setRepeat:SPTRepeatOff callback:nil];
    self.isRepeating = NO;
    [self.repeatButton setSelected:NO];
    
    if(self.player.metadata.nextTrack == nil){
        
        if(self.currentSongIndex == self.citySongIDs.count){
            self.currentSongIndex = 0;
        }
        
        
        NSString *song = self.citySongIDs[self.currentSongIndex];
        
        NSString *queueRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song];
        [self.player queueSpotifyURI:queueRequest callback:^(NSError *error) {
            
            if(error){
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


-(void)refreshSongData{
    
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




@end
