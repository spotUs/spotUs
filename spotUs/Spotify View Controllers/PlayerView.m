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
@property (nonatomic, strong) NSArray<NSString*>   *topSongIDs;
@property (nonatomic, strong) NSArray<NSString*>   *citySongIDs;

@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property BOOL isPlaying;
@property BOOL isSeeking;

@property int currentSongIndex;



@end

@implementation PlayerView
- (IBAction)didChangeSlide:(id)sender {
    
    __weak PlayerView *weakSelf = self;

    
    [self.player setIsPlaying:NO callback:^(NSError *error) {
        [weakSelf.player seekTo:self.musicSlider.value callback:^(NSError *error) {
            [weakSelf.player setIsPlaying:YES callback:nil];

        }];

    }];

    

    
    
    
    
    
    
}
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
        
        if(self.currentSongIndex == self.citySongIDs.count){
            self.currentSongIndex = 0;
        }
        
        
        NSString *song = self.citySongIDs[self.currentSongIndex];
        
        NSString *queueRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song];
        [self.player queueSpotifyURI:queueRequest callback:nil];
        self.currentSongIndex++;
            
        
    }
    
    

    
}
- (void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming{
    
    [self refreshSongData];
    
    
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePosition:(NSTimeInterval)position{
    
    self.musicSlider.value = position;
    
    
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
    [self getCityTracks];
    
    

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
    
        NSString *song = self.citySongIDs[0];
        NSString *playRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song];
        [self.player playSpotifyURI:playRequest startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
            NSLog(@"Error queueing songs: %@", error.localizedDescription);
        }];
    
}

- (void) getUserTopTracks {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.spotify.com/v1/me/top/tracks"]];
    NSDictionary *headers = @{@"Authorization":[@"Bearer " stringByAppendingString:self.auth.session.accessToken]};
    [request setAllHTTPHeaderFields:(headers)];
    [request setHTTPMethod:@"GET"];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *datadict = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        NSArray *tracksArray = datadict[@"items"]; //iterate through the array to get the id of each song
        NSMutableArray<NSString*> *songIDs = [NSMutableArray new];
        for(NSDictionary *dictionary in tracksArray){
            
            NSString *spotifyID = dictionary[@"id"];
            [songIDs addObject:spotifyID];
        }
        
        self.topSongIDs =songIDs;
        [self startMusic];
    
    
    }] resume];
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
