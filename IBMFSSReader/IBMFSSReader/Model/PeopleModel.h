//
//  PeopleModel.h
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeopleModel : NSObject

@property (nonatomic, strong) NSString *peopleSummery;

/**
 Method to intilize people model 
 @param: summery which is parsed object.
 */
- (id)initPeopleModelWithSummery : (NSString *)summery;
@end
