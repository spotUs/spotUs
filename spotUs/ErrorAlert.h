//
//  ErrorAlert.h
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorAlert : UIAlertController

+ (void) showAlert: (NSString *)msg inVC:(UIViewController *)vc;

@end
