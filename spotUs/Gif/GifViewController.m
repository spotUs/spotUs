//
//  GifViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/19/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "GifViewController.h"
#import "SpotifyLoginViewController.h"

@interface GifViewController () <SpotifyLoginViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webViewBG;

@property (weak, nonatomic) IBOutlet UIButton *loginWithSpotify;

@end

@implementation GifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *pathForFile = [[NSBundle mainBundle] pathForResource: @"violin" ofType: @"gif"];
//    NSData *dataOfGif = [NSData dataWithContentsOfFile: pathForFile];
//    [self.webViewBG loadData:dataOfGif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
  
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WebViewContent" ofType:@"html"];
    NSURL *htmlURL = [[NSURL alloc] initFileURLWithPath:htmlPath];
    NSData *htmlData = [[NSData alloc] initWithContentsOfURL:htmlURL];
    
    [self.webViewBG loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[htmlURL URLByDeletingLastPathComponent]];
    
   
self.loginWithSpotify.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.loginWithSpotify.layer.borderWidth = 2.0;
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SpotifyLoginViewController *loginView = (SpotifyLoginViewController*)[segue destinationViewController];
    self.delegate = loginView;
}


@end
