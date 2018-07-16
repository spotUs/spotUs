//
//  PlayerView.m
//  spotUs
//
//  Created by Martin Winton on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlayerView.h"


@interface PlayerView ()
@property (nonatomic, strong) NSArray *songs;


@end

@implementation PlayerView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    [SPTYourMusic  savedTracksForUserWithAccessToken:self.auth.session.accessToken callback:^(NSError *error, id object) {
        
        if(error){
            NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            
            
        }
        
        SPTListPage *musicPages = object;
        
        self.songs = musicPages.items;
        
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
