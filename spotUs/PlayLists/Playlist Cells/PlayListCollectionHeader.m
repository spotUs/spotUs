//
//  PlayListCollectionHeader.m
//  spotUs
//
//  Created by Martin Winton on 7/23/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlayListCollectionHeader.h"

@implementation PlayListCollectionHeader

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.playButton.layer.cornerRadius = 10;
    self.playButton.clipsToBounds = true;
    
}

- (void)setIsEmpty:(BOOL)isEmpty{
    
    [self.playButton setHidden:isEmpty];

    
    
    
}

@end
