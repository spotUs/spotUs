//
//  FriendRequest.m
//  spotUs
//
//  Created by Martin Winton on 8/2/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "FriendRequest.h"

@implementation FriendRequest
@dynamic receiver,sender,accepted,notifiedAccepted,removed,notifiedRemoved,removee;

+ (nonnull NSString *)parseClassName {
    return @"FriendRequest";
}


+ (FriendRequest*) sendRequestFrom: (PFUser *)sender To:(PFUser *)receiver withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    FriendRequest *request = [[FriendRequest alloc] init];
    request.sender = sender;
    request.receiver = receiver;
    request.accepted = NO;
    request.notifiedAccepted = NO;
    request.removed = NO;
    request.notifiedRemoved = NO;

    request.removee = @"";

    
    
    [request saveInBackgroundWithBlock: completion];

    return request;
 
}

@end
