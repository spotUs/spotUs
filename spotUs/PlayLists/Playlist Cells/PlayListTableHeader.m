//
//  PlayListTableHeader.m
//  spotUs
//
//  Created by Martin Winton on 7/30/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PlayListTableHeader.h"

@implementation PlayListTableHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    self.playButton.layer.cornerRadius = 10;
    self.playButton.clipsToBounds = true;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsEmpty:(BOOL)isEmpty{
    
    [self.playButton setHidden:isEmpty];
    
    
    
    
}

@end
