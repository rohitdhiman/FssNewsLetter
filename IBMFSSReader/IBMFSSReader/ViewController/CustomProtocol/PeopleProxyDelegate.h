//
//  PeopleProxyDelegate.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PeopleModel.h"

@protocol PeopleProxyDelegate <NSObject>

@optional
- (void) getPeopleFSSReader : (PeopleModel *)peopleModel;

@required
- (void) peopleDidFail : (NSString *)errorMessage;

@end
