//
//  PlaylistViewController.m
//  spotUs
//
//  Created by Megan Ung on 7/18/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PlaylistCollectionViewCell.h"
#import "PlayerView.h"
#import "PlayListCollectionHeader.h"
#import "PlaylistTableViewCell.h"


@interface PlaylistViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *skylineImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<NSDictionary *> *dataArray;
@property (strong, nonatomic) NSArray<NSDictionary *> *filteredDataArray;

@end

@implementation PlaylistViewController
- (IBAction)didClickPlay:(id)sender {
    
    
    NSDictionary *cityDic =  @{ @"citytracks"     : self.city.tracks,
                                @"index" : [NSNumber numberWithInt:0],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
    
    
}
- (IBAction)onTapViewToggle:(id)sender {
    if ([self.collectionView isHidden]) {
        NSLog(@"changing tableview");
        [self.collectionView setHidden:NO];
        [self.tableView setHidden:YES];
    } else {
        [self.collectionView setHidden:YES];
        [self.tableView setHidden:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.skylineImageView.image = [UIImage imageNamed:self.city[@"imageName"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

    NSDictionary *emptyDic = [NSDictionary dictionary];
    self.dataArray = [NSMutableArray array];
    for (int i = 0; i < self.city.tracks.count; i++) {
        [self.dataArray addObject:emptyDic];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
    for (NSUInteger i = 0; i < self.city.tracks.count; i++){
        
        [self fetchTrackData:i];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchTrackData: (NSUInteger)songIndex{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[@"https://api.spotify.com/v1/tracks/" stringByAppendingString:self.city.tracks[songIndex]]]];
    NSLog(@"sessiontoken: %@", self.auth.session.accessToken);
    NSDictionary *headers = @{@"Authorization":[@"Bearer " stringByAppendingString:self.auth.session.accessToken]};
    [request setAllHTTPHeaderFields:(headers)];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];            
            self.dataArray[songIndex] = dataDictionary;
            self.filteredDataArray = self.dataArray;
            [self.tableView reloadData];
            [self.collectionView reloadData];
            
        }
    }];
    [task resume];
}

//table view implementation
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistTableCell" forIndexPath:indexPath];
    NSLog(@"updating?");
    [cell updateTrackCellwithData:self.filteredDataArray[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu",self.filteredDataArray.count);
    return self.filteredDataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *cityDic =  @{ @"citytracks"     : self.city.tracks,
                                @"index" : [NSNumber numberWithInteger:indexPath.row],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
}

//collection view implementation
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaylistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playlistCollectionCell" forIndexPath:indexPath];
    //[cell updateTrackCellwithData:self.dataArray[indexPath.row]];
    [cell updateTrackCellwithData:self.filteredDataArray[indexPath.row]];
        return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    PlayListCollectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    header.cityLabel.text = self.city.name;
    return header;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredDataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *cityDic =  @{ @"citytracks"     : self.city.tracks,
                                @"index" : [NSNumber numberWithInteger:indexPath.row],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
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
    [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.'
    PlaylistViewController *playlistVC = (PlaylistViewController *)[segue destinationViewController];
    playlistVC.auth = self.auth;
    playlistVC.player = self.player;
    playlistVC.city = self.city;
    

}

@end
