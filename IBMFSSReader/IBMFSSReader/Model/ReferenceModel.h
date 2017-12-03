//
//  ReferenceModel.h
//  IBMFSSReader
//
//  Created by Rohit on 12/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReferenceModel : NSObject

@property (nonatomic, weak) NSString *_reference;

//Parsing method
-(NSDictionary *)jsonMapping;
+(ReferenceModel *)referenceModelFromDictionary:(NSDictionary *)dictionary;
+(NSDictionary *)dictionaryFromReferenceModel:(ReferenceModel *)referenceModel;

@end
