//
//  FlagsViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/27/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FlagsViewController.h"
#import "QueryManager.h"
#import "PlayerView.h"

@interface FlagsViewController ()

@property (strong, nonatomic) NSArray *flags;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *dataArray;

@end

@implementation FlagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QueryManager fetchFlags:^(NSArray *flag, NSError *error) {
        //NSLog(@"FAVS %@", favs);
        self.flags = flag;
        NSDictionary *emptyDic = [NSDictionary dictionary];
        NSMutableArray *mutableStorage = [NSMutableArray array];
        for (int i = 0; i < self.flags.count; i++) {
            [mutableStorage addObject:emptyDic];
        }
       
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchTrackData: (NSUInteger)songIndex{
   /*
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[@"https://api.spotify.com/v1/tracks/" stringByAppendingString:self.flags[songIndex]]]];
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
    */
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
