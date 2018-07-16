//
//  City.h
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface City : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSArray *tracks;

@end
