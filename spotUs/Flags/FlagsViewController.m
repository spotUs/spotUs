//
//  FlagsViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/27/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FlagsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface FlagsViewController ()

@property (weak, nonatomic) IBOutlet UIView *popUpView;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@end

@implementation FlagsViewController

- (void)viewDidLoad {
    
    self.view.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:.6];
    self.popUpView.layer.cornerRadius = 5;
    self.popUpView.layer.shadowOpacity = 0.8;
    self.popUpView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [super viewDidLoad];
    

}
    - (void)showAnimate
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.view.alpha = 0;
        [UIView animateWithDuration:.25 animations:^{
            self.view.alpha = 1;
            self.view.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
    
    - (void)removeAnimate
    {
        [UIView animateWithDuration:.25 animations:^{
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.view removeFromSuperview];
            }
        }];
    }
    


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closePopup:(id)sender {
    [self removeAnimate];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self.view];
    if (animated) {
        [self showAnimate];
    }
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
