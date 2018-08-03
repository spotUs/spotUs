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
@property (strong, nonatomic) NSMutableArray<SPTTrack *> *dataArray;
@property (strong, nonatomic) NSArray<SPTTrack *> *filteredDataArray;
@property (strong, nonatomic) NSArray *favorites;
@property (strong, nonatomic) UIBarButtonItem *gridButton;
@property (strong, nonatomic) UIBarButtonItem *listButton;
@property (weak, nonatomic) IBOutlet UITableView *favoriteTableView;
@property (weak, nonatomic) IBOutlet UILabel *favoritesMessageLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FavoriteViewController


- (IBAction)didclickPlay:(id)sender {
    
    NSDictionary *cityDic =  @{ @"citytracks"     : self.favorites,
                                @"index" : [NSNumber numberWithInt:0],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
    
    
}




-(void)toggleView{
    
    if ([self.favoriteCollectionView isHidden]) {
        NSLog(@"changing tableview");
        [self.favoriteCollectionView setHidden:NO];
        [self.favoriteTableView setHidden:YES];
        self.navigationItem.leftBarButtonItem= self.listButton;
    } else {
        [self.favoriteCollectionView setHidden:YES];
        [self.favoriteTableView setHidden:NO];
        self.navigationItem.leftBarButtonItem= self.gridButton;
        
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.favoriteCollectionView.backgroundColor = [UIColor clearColor];
    self.favoriteCollectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.gridButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"grid"]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(toggleView)];
    self.listButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"list"]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(toggleView)];
    
    self.navigationItem.leftBarButtonItem= self.listButton;
    //backbutton on right side
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                style:UIBarButtonItemStylePlain
                                   target:self
                            action:@selector(backBtnClicked:)];
    self.navigationItem.rightBarButtonItem = backButton;
    
    
    
    self.favoriteTableView.delegate = self;
    self.favoriteTableView.dataSource = self;
    self.favoriteCollectionView.delegate = self;
    self.favoriteCollectionView.dataSource = self;
    self.searchBar.delegate = self;
    // Do any additional setup after loading the view.

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

- (void)backBtnClicked:(id)sender{
    NSLog(@"clicked back button");
    [self performSegueWithIdentifier:@"favtohomesegue" sender:nil];
}


//collection view implementation
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FavoriteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"favoriteCollectionViewCell" forIndexPath:indexPath];
    [cell updateTrackCellwithData:self.filteredDataArray[indexPath.row]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //NSLog(@"COUNTER %lu", (unsigned long)self.favorites.count);
    return self.filteredDataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *cityDic =  @{ @"favtracks"     : self.favorites,
                                @"index" : [NSNumber numberWithInteger:indexPath.row],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Play Favorites"
                                                        object:self userInfo:cityDic];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.favoriteTableView deselectRowAtIndexPath:indexPath animated:YES];

    
    NSDictionary *cityDic =  @{ @"favtracks"     : self.favorites,
                                @"index" : [NSNumber numberWithInteger:indexPath.row-1],
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Play Favorites"
                                                        object:self userInfo:cityDic];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayListTableHeader * header = [tableView dequeueReusableCellWithIdentifier:@"PlayListTableHeader" forIndexPath:indexPath];

    if(indexPath.row == 0){
        
        if(self.favorites.count == 0){
            header.isEmpty = YES;
            self.favoriteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
        else{
            
            header.isEmpty = NO;
            self.favoriteTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

            
        
        }
        
        
        header.cityLabel.text = @"Favorites";
        return header;
    }
    
    else{
        
        FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteTableViewCell" forIndexPath:indexPath];
        NSLog(@"updating?");
        cell.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
        [cell updateTrackCellwithData:self.filteredDataArray[indexPath.row-1]];
        return cell;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu",self.filteredDataArray.count);
    
    
    return self.filteredDataArray.count+1;
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
        
        [QueryManager getSPTracksFromIDs:self.favorites withCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            
            
            self.dataArray = object;
            self.filteredDataArray = self.dataArray;
            
            [self.favoriteCollectionView reloadData];
            [self.favoriteTableView reloadData];
            
            
        }];
            

    
    
    }];
}
     

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SPTTrack *evaluatedObject, NSDictionary *bindings){
            return [[evaluatedObject.name lowercaseString] containsString:[searchText lowercaseString]];
        }];
        self.filteredDataArray = [self.dataArray filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@",self.dataArray);
    }
    else {
        self.filteredDataArray = self.dataArray;
    }
    [self.favoriteCollectionView reloadData];
    
    [self.favoriteTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
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
