//
//  PlayListTableHeader.h
//  spotUs
//
//  Created by Martin Winton on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListTableHeader : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (nonatomic) BOOL isEmpty;

@end
