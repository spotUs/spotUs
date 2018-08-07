//
//  FriendRequest.h
//  spotUs
//
//  Created by Martin Winton on 8/2/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "PFObject.h"
#import <Parse/Parse.h>


@interface FriendRequest : PFObject <PFSubclassing>

@property (strong, nonatomic) PFUser * _Nonnull sender;
@property (strong,nonatomic) PFUser * _Nonnull receiver;
@property BOOL accepted;
@property BOOL notifiedAccepted;
@property BOOL removed;
@property BOOL notifiedRemoved;
@property NSString *removee;





+ (FriendRequest*) sendRequestFrom: (PFUser *)sender To:(PFUser *)receiver withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end
