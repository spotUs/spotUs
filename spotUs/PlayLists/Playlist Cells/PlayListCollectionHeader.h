//
//  PlayListCollectionHeader.h
//  spotUs
//
//  Created by Martin Winton on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListCollectionHeader : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (nonatomic) BOOL isEmpty;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end
