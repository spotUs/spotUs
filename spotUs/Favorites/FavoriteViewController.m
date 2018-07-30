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
#import "FavoriteTableViewCell.h"
#import "PlayListCollectionHeader.h"
#import "PlaylistTableViewCell.h"
#import "PlayListTableHeader.h"

@interface FavoriteViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *favoriteCollectionView;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *dataArray;
@property (strong, nonatomic) NSArray<NSDictionary *> *filteredDataArray;
@property (strong, nonatomic) NSArray *favorites;
@property (weak, nonatomic) IBOutlet UITableView *favoriteTableView;
@property (weak, nonatomic) IBOutlet UILabel *favoritesMessageLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewButton;

@end

@implementation FavoriteViewController


- (IBAction)didclickPlay:(id)sender {
    
    NSDictionary *cityDic =  @{ @"citytracks"     : self.favorites,
                                @"index" : [NSNumber numberWithInt:0],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
    
    
}


- (IBAction)onTapViewToggle:(id)sender {
    if ([self.favoriteCollectionView isHidden]) {
        NSLog(@"changing tableview");
        [self.favoriteCollectionView setHidden:NO];
        [self.favoriteTableView setHidden:YES];
        self.viewButton.title = @"TableView";
    } else {
        [self.favoriteCollectionView setHidden:YES];
        [self.favoriteTableView setHidden:NO];
        self.viewButton.title = @"GridView";
        
    }
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.favoriteCollectionView.backgroundColor = [UIColor clearColor];
    self.favoriteCollectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.favoriteTableView.delegate = self;
    self.favoriteTableView.dataSource = self;
    self.favoriteCollectionView.delegate = self;
    self.favoriteCollectionView.dataSource = self;
    // Do any additional setup after loading the view.
     self.favoriteTableView.rowHeight = 110;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.favoriteCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    CGFloat cellsPerLine = 2;
    CGFloat itemWidth = (self.favoriteCollectionView.frame.size.width - layout.minimumInteritemSpacing * (cellsPerLine - 1)) / cellsPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    [self updateFavData];

   
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"Update Favorites"
                                               object:nil];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) fetchTrackData: (NSUInteger)songIndex{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[@"https://api.spotify.com/v1/tracks/" stringByAppendingString:self.favorites[songIndex]]]];
    NSDictionary *headers = @{@"Authorization":[@"Bearer " stringByAppendingString:  self.auth.session.accessToken]};
    [request setAllHTTPHeaderFields:(headers)];
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"INDEX %lu", (unsigned long)songIndex);
            self.dataArray[songIndex] = dataDictionary;
            //self.filteredDataArray = self.dataArray;
            [self.favoriteCollectionView reloadData];
            [self.favoriteTableView reloadData];
           // NSLog(@"it's been fetched");
            
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
    //NSLog(@"COUNTER %lu", (unsigned long)self.favorites.count);
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *cityDic =  @{ @"favtracks"     : self.favorites,
                                @"index" : [NSNumber numberWithInteger:indexPath.row],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Play Favorites"
                                                        object:self userInfo:cityDic];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *cityDic =  @{ @"favtracks"     : self.favorites,
                                @"index" : [NSNumber numberWithInteger:indexPath.row-1],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Play Favorites"
                                                        object:self userInfo:cityDic];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        
        PlayListTableHeader * header = [tableView dequeueReusableCellWithIdentifier:@"PlayListTableHeader" forIndexPath:indexPath];
        
        header.cityLabel.text = @"Favorites";
        return header;
    }
    
    else{
        
        PlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistTableCell" forIndexPath:indexPath];
        NSLog(@"updating?");
        cell.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        [cell updateTrackCellwithData:self.dataArray[indexPath.row-1]];
        return cell;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.count+1;
}


- (void) receiveTestNotification:(NSNotification *) notification{
    if ([[notification name] isEqualToString:@"Update Favorites"]){
     
        [self updateFavData];
        
    }
   

    
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    PlayListCollectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    
    if(self.favorites.count == 0){
        header.isEmpty = YES;
    }
    
    else{
        
        header.isEmpty = NO;

        
        
    }
    
    
    return header;
    
    
    
}

-(void)updateFavData{
    [QueryManager fetchFavs:^(NSArray *favs, NSError *error) {
        //NSLog(@"FAVS %@", favs);
        self.favorites = favs;
        if(self.favorites.count > 0){
            self.favoritesMessageLabel.text = @"";
        }
        else{
            self.favoritesMessageLabel.text = @"You currently have no favorites! Click on the heart when playing music to add some!";
            
            
        }
        
        
        NSDictionary *emptyDic = [NSDictionary dictionary];
        NSMutableArray *mutableStorage = [NSMutableArray array];
        for (int i = 0; i < self.favorites.count; i++) {
            [mutableStorage addObject:emptyDic];
        }
        self.dataArray = [NSMutableArray arrayWithArray:mutableStorage];
        [self.favoriteCollectionView reloadData];
        for (NSUInteger i = 0; i < self.favorites.count; i++){
            
            [self fetchTrackData:i];
        }
        
    }];
    
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue destinationViewController] isKindOfClass:[FavoriteViewController class]]){
        FavoriteViewController *favoriteVC = (FavoriteViewController *)[segue destinationViewController];
        favoriteVC.auth = self.auth;
        favoriteVC.player = self.player;
        
    }
}

@end
