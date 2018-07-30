//
//  StatsViewController.m
//  spotUs
//
//  Created by Martin Winton on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "StatsViewController.h"
#import "QueryManager.h"

@interface StatsViewController ()

@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [QueryManager fetchLastPlayed:^(NSArray *lastPlayed, NSError *error) {
        
        
        NSMutableArray *properFormat = [NSMutableArray array];
        
        for(NSString *stringID in lastPlayed){
            
            
            [properFormat addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"spotify:track:",stringID]]];
        }
        
        
        [SPTTrack tracksWithURIs:properFormat accessToken:self.auth.session.accessToken market:nil callback:^(NSError *error, id object) {
            
            if(error){
                
                NSLog(@"%@",error.localizedDescription);
            }
            
            else{
                
                NSArray *tracks = (NSArray *)object;
                
                for(SPTTrack *track in tracks){
                    
                }
            }
            
            
            
            
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
