//
//  FriendRequest.m
//  spotUs
//
//  Created by Martin Winton on 8/2/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendRequest.h"

@implementation FriendRequest
@dynamic receiver,sender,accepted,dead,removed;

+ (nonnull NSString *)parseClassName {
    return @"FriendRequest";
}


+ (FriendRequest*) sendRequestFrom: (PFUser *)sender To:(PFUser *)receiver withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    FriendRequest *request = [[FriendRequest alloc] init];
    request.sender = sender;
    request.receiver = receiver;
    request.accepted = NO;
    request.dead = NO;
    request.removed = NO;
    
    [request saveInBackgroundWithBlock: completion];

    return request;
 
}

@end
