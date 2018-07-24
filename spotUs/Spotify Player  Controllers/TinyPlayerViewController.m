//
//  TinyPlayerViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "TinyPlayerViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PlayerView.h"




@interface TinyPlayerViewController () <SPTAudioStreamingPlaybackDelegate, DismissDelegate>
@property (nonatomic, strong) NSArray<NSString*>   *citySongIDs;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property BOOL isSeeking;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property int currentSongIndex;


@end

@implementation TinyPlayerViewController


- (IBAction)pauseOrUnpause:(id)sender {
    
    if(self.player.playbackState.isPlaying){
        
        [self.player setIsPlaying:NO callback:nil];
        [self.pauseButton setSelected:YES];
        
        
    }
    
    else{
        [self.player setIsPlaying:YES callback:nil];
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
    self.currentSongIndex = 0;
 
}


- (void) receiveTestNotification:(NSNotification *) notification{

    
    if ([[notification name] isEqualToString:@"Chose Playlist"]){
        NSLog (@"Successfully received the chose Playlist!");
        self.player.playbackDelegate = self;
        NSDictionary *userInfo = notification.userInfo;

        self.city = userInfo[@"city"];
        self.currentSongIndex = [userInfo[@"index"] intValue];
        
        NSArray *citySongs = self.city.tracks;
        self.citySongIDs = citySongs;
        
        
        [self startMusic];
        
    }
    
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
    [self.pauseButton setSelected:NO];
    [self.player setRepeat:SPTRepeatOff callback:nil];
    
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
    
    
}


-(void)refreshSongData{
    
    SPTPlaybackTrack *albumArtTrack = self.player.metadata.currentTrack;
    self.songTitle.text = albumArtTrack.name;
    self.albumTitleLabel.text = albumArtTrack.albumName;
    
  
    [self.pauseButton setSelected:!self.player.playbackState.isPlaying];
    
}


- (void)didDismissWithIndex:(NSNumber *)index{
    
    self.currentSongIndex = [index intValue];
    [self refreshSongData];
    self.player.playbackDelegate = self;
    
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *navigationController = [segue destinationViewController];
        
        
    }
    
    else if([[segue destinationViewController]  isKindOfClass:[PlayerView class]]){
        PlayerView *playerView = (PlayerView *)[segue destinationViewController];
        playerView.player = self.player;
        playerView.auth = self.auth;
        playerView.city = self.city;
        playerView.currentSongIndex = self.currentSongIndex;
        playerView.nowPlaying = YES;
        playerView.dismissDelegate = self;
    }
    
    
    
    
}






@end
