//
//  PlayerView.m
//  spotUs
//
//  Created by Martin Winton on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlayerView.h"


@interface PlayerView () <SPTAudioStreamingPlaybackDelegate>
@property (nonatomic, strong) NSArray<SPTSavedTrack*> *songs;
@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property BOOL isPlaying;


@end

@implementation PlayerView
- (IBAction)goFoward:(id)sender {
    
    [self.player skipNext:^(NSError *error) {
        
    }];
}
- (IBAction)goBack:(id)sender {
    
    [self.player skipPrevious:^(NSError *error) {
        
    }];
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

- (void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming{
    
    SPTPlaybackMetadata *metedata = audioStreaming.metadata;
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isPlaying = NO;
    self.player.playbackDelegate = self;
    
    

    [SPTYourMusic  savedTracksForUserWithAccessToken:self.auth.session.accessToken callback:^(NSError *error, id object) {
        
        if(error){
            NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            
            
        }
        
        SPTListPage *musicPages = object;
        
        self.songs = musicPages.items;
        
        
        for(SPTSavedTrack *song in self.songs){
       

            
            NSString *playRequest = [NSString stringWithFormat:@"%@%@",@"spotify:track:",song.identifier];
            [self.player queueSpotifyURI:playRequest callback:nil];


            
            
        }
        SPTPlaybackMetadata *metedata = self.player.metadata;


   

        
        
        
    
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
