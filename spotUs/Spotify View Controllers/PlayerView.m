//
//  PlayerView.m
//  spotUs
//
//  Created by Martin Winton on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlayerView.h"
#import "UIImageView+AFNetworking.h"



@interface PlayerView () <SPTAudioStreamingPlaybackDelegate>
@property (nonatomic, strong) NSArray<SPTSavedTrack*> *songs;
@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property BOOL isPlaying;

@property int currentSongIndex;



@end

@implementation PlayerView
- (IBAction)goFoward:(id)sender {
    
    [self.player skipNext:nil];
    
}

- (IBAction)pauseOrUnpause:(id)sender {
    
    if(self.isPlaying){
        
        [self.player setIsPlaying:NO callback:nil];
        self.isPlaying = NO;
    }
    
    else{
        [self.player setIsPlaying:YES callback:nil];
        self.isPlaying = YES;
        
    }
    
    
}



- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSString *)trackUri{
    
    [self refreshSongData];
    
    if(self.player.metadata.nextTrack == nil){
        
        SPTSavedTrack *song = self.songs[self.currentSongIndex];
        
        NSString *queueRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song.identifier];
        [self.player queueSpotifyURI:queueRequest callback:nil];
        self.currentSongIndex++;
        
        
        
        
    }
    
    
    
    
}
- (void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming{
    
    [self refreshSongData];
    
    
}


-(void)refreshSongData{
    
    SPTPlaybackTrack *albumArtTrack = self.player.metadata.currentTrack;
    self.songTitle.text = albumArtTrack.name;
    self.albumTitleLabel.text = albumArtTrack.albumName;
    
    
    NSURL *albumURL = [NSURL URLWithString:albumArtTrack.albumCoverArtURL];
    [self.songImage setImageWithURL:albumURL];
    
    self.musicSlider.maximumValue = self.player.metadata.currentTrack.duration;

    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isPlaying = YES;
    self.player.playbackDelegate = self;
    
    self.musicSlider.minimumValue = 0.0;
    
    
    self.currentSongIndex = 1;
    
    
    [SPTYourMusic  savedTracksForUserWithAccessToken:self.auth.session.accessToken callback:^(NSError *error, id object) {
        
        if(error){
            NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            
            
        }
        
        SPTListPage *musicPages = object;
        
        self.songs = musicPages.items;
        
        SPTSavedTrack *song = self.songs[0];
    
        NSString *playRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song.identifier];
        
        [self.player playSpotifyURI:playRequest startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
            
        }];
        
        
        
        
        
        
        
        
        
        
    }];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
