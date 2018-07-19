//
//  GifViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/19/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "GifViewController.h"

@interface GifViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webViewBG;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation GifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WebViewContent" ofType:@"html"];
    NSURL *htmlURL = [[NSURL alloc] initFileURLWithPath:htmlPath];
    NSData *htmlData = [[NSData alloc] initWithContentsOfURL:htmlURL];
    
    [self.webViewBG loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[htmlURL URLByDeletingLastPathComponent]];
    
    self.loginButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.loginButton.layer.borderWidth = 2.0;
    
    self.signUpButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.signUpButton.layer.borderWidth = 2.0f;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
