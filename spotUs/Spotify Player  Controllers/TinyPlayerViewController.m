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
@property (weak, nonatomic) IBOutlet UIImageView *spotUsLogo;

@property int currentSongIndex;


@end

@implementation TinyPlayerViewController
- (IBAction)onTap:(id)sender {
    
    if(self.player.playbackState.isPlaying){
    [self performSegueWithIdentifier:@"expandplayer" sender:self];
    }
}

- (IBAction)onTapHomeBtn:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"homeNotification"
     object:self];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.pauseButton setEnabled:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"Chose Playlist"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"Play Favorites"
                                               object:nil];

    
    self.player.playbackDelegate = self;
    self.currentSongIndex = 0;
 
}


- (void) receiveTestNotification:(NSNotification *) notification{
    if ([[notification name] isEqualToString:@"Chose Playlist"]){
        NSLog (@"Successfully received the chosen Playlist!");
        self.player.playbackDelegate = self;
        NSDictionary *userInfo = notification.userInfo;

        self.citySongIDs = userInfo[@"citytracks"];

        self.currentSongIndex = [userInfo[@"index"] intValue];
        

        [self startMusic];
        
    }
    
    else if ([[notification name] isEqualToString:@"Play Favorites"]){
        
        NSLog (@"Successfully received the favorites music!");
        self.player.playbackDelegate = self;
        NSDictionary *userInfo = notification.userInfo;
        
        self.currentSongIndex = [userInfo[@"index"] intValue];
        self.citySongIDs = userInfo[@"favtracks"];
        
        [self startMusic];
        
        
        
        
    }
    
}

-(void)startMusic{
    
    
    [self.spotUsLogo setHidden:YES];
    [self.pauseButton setEnabled:YES];
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

    if([[segue destinationViewController]  isKindOfClass:[PlayerView class]]){
        PlayerView *playerView = (PlayerView *)[segue destinationViewController];
        playerView.player = self.player;
        playerView.auth = self.auth;
        playerView.citySongIDs = self.citySongIDs;
        playerView.currentSongIndex = self.currentSongIndex;
        playerView.nowPlaying = YES;
        playerView.dismissDelegate = self;
    }
    
    
    
    
}






@end
