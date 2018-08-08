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
#import "PlayListTableHeader.h"
#import "QueryManager.h"

@interface PlaylistViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *skylineImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIBarButtonItem *gridButton;
@property (strong, nonatomic) UIBarButtonItem *listButton;


@property (strong, nonatomic) NSMutableArray<NSDictionary *> *dataArray;
@property (strong, nonatomic) NSArray<NSDictionary *> *filteredDataArray;

@end

@implementation PlaylistViewController


- (IBAction)didClickPlay:(id)sender {
    
    [QueryManager setLastPlayedCity:self.city withCompletion:nil];
    NSDictionary *cityDic =  @{ @"tracks"     : self.city.tracks,
                                @"index" : [NSNumber numberWithInt:0],
                                @"title" : self.city.name,

                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.skylineImageView.image = [UIImage imageNamed:self.city[@"imageName"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];


    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.searchBar.delegate = self;
    
  
    
    self.gridButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"grid"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(toggleView)];
    self.listButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"list"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(toggleView)];
    
    self.navigationItem.rightBarButtonItem= self.listButton;
    
    
    //set the size of the cells
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    CGFloat cellsPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (cellsPerLine - 1)) / cellsPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    [self updateCityData];

}

-(void)toggleView{
    
    if ([self.collectionView isHidden]) {
        NSLog(@"changing tableview");
        [self.collectionView setHidden:NO];
        [self.tableView setHidden:YES];
        self.navigationItem.rightBarButtonItem= self.listButton;
    } else {
        [self.collectionView setHidden:YES];
        [self.tableView setHidden:NO];
        self.navigationItem.rightBarButtonItem= self.gridButton;

    }
    
    
}


-(void)updateCityData{

        [QueryManager getSPTracksFromIDs:self.city.tracks withCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            
            
            self.dataArray = object;
            self.filteredDataArray = self.dataArray;
            
            [self.collectionView reloadData];
            [self.tableView reloadData];
            
            
        }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//table view implementation
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row == 0){
        
        PlayListTableHeader * header = [tableView dequeueReusableCellWithIdentifier:@"PlayListTableHeader" forIndexPath:indexPath];
        
        header.cityLabel.text = self.city.name;
        header.isEmpty = NO;
        header.layer.backgroundColor = [[UIColor clearColor] CGColor];

        return header;
    }
    
    else{
    
    PlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistTableCell" forIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [QueryManager setLastPlayedCity:self.city withCompletion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *cityDic =  @{ @"tracks"     : self.city.tracks,
                                @"index" : [NSNumber numberWithInteger:indexPath.row-1],
                                @"title" : self.city.name,

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
    [QueryManager setLastPlayedCity:self.city withCompletion:nil];
    NSDictionary *cityDic =  @{ @"tracks"     : self.city.tracks,
                                @"index" : [NSNumber numberWithInteger:indexPath.row],
                                @"title" : self.city.name,

                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Chose Playlist"
                                                        object:self userInfo:cityDic];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SPTTrack *evaluatedObject, NSDictionary *bindings){
            NSArray<SPTPartialArtist*> *artists = evaluatedObject.artists;
            
            
            return [[evaluatedObject.name lowercaseString] containsString:[searchText lowercaseString]] || [[artists[0].name lowercaseString] containsString:[searchText lowercaseString]];
            
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
    

}

@end
