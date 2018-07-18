//
//  StartViewController.h
//  spotUs
//
//  Created by Martin Winton on 7/17/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol StartViewControllerDelegate
@end

@interface StartViewController : UIViewController
@property (nonatomic, weak) id<StartViewControllerDelegate> delegate;

@end
