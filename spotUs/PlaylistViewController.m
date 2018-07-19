//
//  PlaylistViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/18/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PlaylistCollectionViewCell.h"


@interface PlaylistViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray<NSString *> *songIDs;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *dataArray;
@property (strong, nonatomic) NSArray<NSDictionary *> *filteredDataArray;

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.songIDs = self.city.tracks;
    //testing delete this and actually get the songIDs from city passed
    self.songIDs = [NSMutableArray array];
    [self.songIDs addObject:@"01Mi9xc3nOoxuJWSptf7LY"];
    [self.songIDs addObject:@"6FT9FZccFD6nE8dMNslz2n"];
    [self.songIDs addObject:@"6e13443Ve7RGcAUScTgYtl"];
    ////
    
    self.dataArray = [NSMutableArray array];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.searchBar.delegate = self;
    
    //set the size of the cells
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    CGFloat cellsPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (cellsPerLine - 1)) / cellsPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    //populate the dataArray
    for (NSUInteger i = 0; i < self.songIDs.count; i++){
        [self fetchTrackData:self.songIDs[i]];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchTrackData: (NSString *)songID{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[@"https://api.spotify.com/v1/tracks/" stringByAppendingString:songID]]];
    NSDictionary *headers = @{@"Authorization":[@"Bearer " stringByAppendingString:@"BQAM0Q1i87r4pKBfmTNddoEwyNu8mTZ98c2jVE-89w0ph91Dmslb14We2-SS2tSyoWJGUZ4HmmzcS9b2JxYJknmXBal0ZmgiDNUXE7T8cOS3i1Cx_PR6je1Ol0PV_NkJduwKr4nDE_MeGQ4"]};//self.auth.session.accessToken]};
    [request setAllHTTPHeaderFields:(headers)];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];            
            [self.dataArray addObject:dataDictionary];
            self.filteredDataArray = self.dataArray;
            [self.collectionView reloadData];
        }
    }];
    [task resume];
}

//collection view implementation
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaylistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playlistCollectionCell" forIndexPath:indexPath];
    //[cell updateTrackCellwithData:self.dataArray[indexPath.row]];
    [cell updateTrackCellwithData:self.filteredDataArray[indexPath.row]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredDataArray.count;
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings){
            return [[evaluatedObject[@"name"] lowercaseString] containsString:[searchText lowercaseString]];
        }];
        self.filteredDataArray = [self.dataArray filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@",self.dataArray);
    }
    else {
        self.filteredDataArray = self.dataArray;
    }
    [self.collectionView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
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
