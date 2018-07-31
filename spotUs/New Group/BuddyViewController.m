//
//  BuddyViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/31/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "BuddyViewController.h"

@interface BuddyViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@end

@implementation BuddyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.mapView.delegate = self;
    // Do any additional setup after loading the view.
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
