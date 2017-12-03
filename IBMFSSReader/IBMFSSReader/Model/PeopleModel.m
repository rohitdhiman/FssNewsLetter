//
//  PeopleModel.m
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "PeopleModel.h"

@implementation PeopleModel
@synthesize peopleSummery = _peopleSummery;

- (id)initPeopleModelWithSummery : (NSString *)summery {
    self = [super init];
    if(self) {
        _peopleSummery = summery;
    }
    return self;
}

@end
