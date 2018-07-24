//
//  FavoriteViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteCollectionViewCell.h"
#import "PlayerView.h"
#import "QueryManager.h"

@interface FavoriteViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *favoriteCollectionView;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *dataArray;
@property (strong, nonatomic) NSArray<NSDictionary *> *filteredDataArray;
@property (strong, nonatomic) NSArray *favorites;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *emptyDic = [NSDictionary dictionary];
    self.dataArray = [NSMutableArray array];
    for (int i = 0; i < self.favorites.count; i++) {
        [self.dataArray addObject:emptyDic];
    }
    
    self.favoriteCollectionView.delegate = self;
    self.favoriteCollectionView.dataSource = self;
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.favoriteCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    CGFloat cellsPerLine = 2;
    CGFloat itemWidth = (self.favoriteCollectionView.frame.size.width - layout.minimumInteritemSpacing * (cellsPerLine - 1)) / cellsPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    //for (NSUInteger i = 0; i < self.city.tracks.count; i++){
        
       // [self fetchTrackData:i];
    //}
    
    [QueryManager fetchFavs:^(NSArray *favs, NSError *error) {
        NSLog(@"FAVS %@", favs);
            self.favorites = favs;
            [self.favoriteCollectionView reloadData];
        for (NSUInteger i = 0; i < self.favorites.count; i++){
            
            [self fetchTrackData:i];
        }
        
    }];
        [self.favoriteCollectionView reloadData];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchTrackData: (NSUInteger)songIndex{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[@"https://api.spotify.com/v1/tracks/" stringByAppendingString:self.favorites[songIndex]]]];
    NSDictionary *headers = @{@"Authorization":[@"Bearer " stringByAppendingString:@"BQAec91XNWk2aYaCd2y7bS7SLbIyEuRocj_S_LJgMfNa475qqXZG2VW8E1ZuRbNq-O_f674WxpovxFcG76LvrdAOg_dozsYRYA057kgH0K8YbuwnoyVy0bPqo0IgNce6dRhAaW_tc5DmNNM"]};
    [request setAllHTTPHeaderFields:(headers)];
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"INDEX %lu", (unsigned long)songIndex);
            self.dataArray[0] = dataDictionary;
            //self.filteredDataArray = self.dataArray;
            [self.favoriteCollectionView reloadData];
            NSLog(@"it's been fetched");
            
        }
    }];
    [task resume];
}

//collection view implementation
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FavoriteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"favoriteCollectionViewCell" forIndexPath:indexPath];
    [cell updateTrackCellwithData:self.dataArray[indexPath.row]];
    //[cell updateTrackCellwithData:self.filteredDataArray[indexPath.row]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"COUNTER %lu", (unsigned long)self.favorites.count);
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.delegate didChooseSongWithIndex:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
