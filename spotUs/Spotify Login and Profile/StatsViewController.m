//
//  StatsViewController.m
//  spotUs
//
//  Created by Martin Winton on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "StatsViewController.h"
#import "QueryManager.h"
#import "FavoriteTableViewCell.h"

@interface StatsViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *statsTableView;
@property (strong, nonatomic) NSArray<SPTTrack*> *lastPlayed;


@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statsTableView.dataSource = self;
    self.statsTableView.delegate = self;
    // Do any additional setup after loading the view.
    
    
    [QueryManager fetchLastPlayed:^(NSArray *lastPlayed, NSError *error) {
        
        
        [QueryManager getSPTracksFromIDs:lastPlayed withCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            
            self.lastPlayed = object;
        }];

    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *cityDic =  @{ @"favtracks"     : self.lastPlayed,
                                @"index" : [NSNumber numberWithInteger:indexPath.row-1],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Play Favorites"
                                                        object:self userInfo:cityDic];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.lastPlayed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

        FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteTableViewCell" forIndexPath:indexPath];
        NSLog(@"updating?");
        cell.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        [cell updateTrackCellwithData:self.lastPlayed[indexPath.row]];
        return cell;
        
    
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
