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
#import "QueryManager.h"





@interface TinyPlayerViewController () <SPTAudioStreamingPlaybackDelegate, DismissDelegate>
@property (nonatomic, strong) NSArray<NSString*>   *citySongIDs;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property BOOL isSeeking;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UILabel *spotUsLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (strong ,nonatomic) UIImage *notificationImage;

@property int currentSongIndex;


@end

@implementation TinyPlayerViewController
- (IBAction)onTap:(id)sender {
    
    
    
    
    if(self.spotUsLabel.isHidden){
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
    

    
    self.player.playbackDelegate = self;
    self.currentSongIndex = 0;
 
}


- (void) receiveTestNotification:(NSNotification *) notification{
    if ([[notification name] isEqualToString:@"Chose Playlist"]){
        NSLog (@"Successfully received the chosen Playlist!");
        self.player.playbackDelegate = self;
        NSDictionary *userInfo = notification.userInfo;
        NSLog(@"%@",notification);
        self.citySongIDs = userInfo[@"tracks"];

        self.currentSongIndex = [userInfo[@"index"] intValue];
        self.playlistTitle = userInfo[@"title"];

        

        [self startMusic];
        
    }
    

    
}

-(void)startMusic{
    

    [self.spotUsLabel setHidden:YES];
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
    
    [[AVAudioSession sharedInstance] setCategory:@"AVAudioSessionCategoryPlayback" error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self becomeFirstResponder];

    [QueryManager addLastPlayed:self.citySongIDs[self.currentSongIndex-1] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"added last played");
    }];
    
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

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePosition:(NSTimeInterval)position{
    NSInteger seconds = position;
    [QueryManager getTrackfromID:[self.player.metadata.currentTrack.uri substringFromIndex:14] withCompletion:^(Track *track, NSError *error) {
        if ([track[@"volumeDict"] valueForKey:[@(seconds) stringValue]]){
            NSLog(@"sending post notif");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayingSongAtTime" object:self userInfo:[NSDictionary dictionaryWithObject:[track[@"volumeDict"] valueForKey:[@(seconds) stringValue]] forKey:@"volume"]];
        }
    }];
   
    
    self.progressBar.progress = position / self.player.metadata.currentTrack.duration;
    SPTPlaybackTrack *albumArtTrack = self.player.metadata.currentTrack;
    
    if(albumArtTrack != nil){
        
        
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        if(self.notificationImage != nil){
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: self.notificationImage];
            [songInfo setValue:albumArt forKey:MPMediaItemPropertyArtwork];
            
        }

        [songInfo setObject:albumArtTrack.name forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:albumArtTrack.artistName forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:albumArtTrack.albumName forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:[NSNumber numberWithDouble:albumArtTrack.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[NSNumber numberWithFloat:position] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
    
    
    
}
- (void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming{
    
    [self refreshSongData];
    [self.player setRepeat:SPTRepeatOff callback:nil];
    
    
    
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)goBack{
    
    
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

- (void)goFoward{
    [self.player skipNext:nil];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self pauseOrUnpause:nil];
            break;
            
        case UIEventSubtypeRemoteControlPause:
            [self pauseOrUnpause:nil];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self goBack];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self goFoward];
            
        default:
            break;
    }
}

-(void)refreshSongData{
    
    SPTPlaybackTrack *albumArtTrack = self.player.metadata.currentTrack;
    self.songTitle.text = albumArtTrack.name;
    self.artistNameLabel.text = albumArtTrack.artistName;
    
    [self updateControlCenterImage:[NSURL URLWithString:self.player.metadata.currentTrack.albumCoverArtURL]];
    
    
    
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    
    [songInfo setObject:[NSNumber numberWithInt:5]  forKey:MPMediaItemPropertyRating];

    [songInfo setObject:albumArtTrack.name forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:albumArtTrack.artistName forKey:MPMediaItemPropertyArtist];
    [songInfo setObject:albumArtTrack.albumName forKey:MPMediaItemPropertyAlbumTitle];
    [songInfo setObject:[NSNumber numberWithDouble:albumArtTrack.duration] forKey:MPMediaItemPropertyPlaybackDuration];
 
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    
  
    [self.pauseButton setSelected:!self.player.playbackState.isPlaying];
    
}



- (void)updateControlCenterImage:(NSURL *)imageUrl
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        UIImage *artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        if(artworkImage)
        {
            self.notificationImage = artworkImage;
        
        }
     
    });
}

- (void)didDismissWithIndex:(NSNumber *)index{
    
    self.currentSongIndex = [index intValue];
    [self refreshSongData];
    self.player.playbackDelegate = self;
    [[AVAudioSession sharedInstance] setCategory:@"AVAudioSessionCategoryPlayback" error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self becomeFirstResponder];
    
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
        playerView.playlistTitle = self.playlistTitle;
    }
    
    
    
    
}






@end
