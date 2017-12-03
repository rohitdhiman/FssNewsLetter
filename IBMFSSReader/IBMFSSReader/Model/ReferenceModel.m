//
//  ReferenceModel.m
//  IBMFSSReader
//
//  Created by Rohit on 12/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "ReferenceModel.h"

@implementation ReferenceModel
@synthesize _reference;

//Parsing method
-(NSDictionary *)jsonMapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"_reference",@"_reference",
            nil];
}

+(ReferenceModel *)referenceModelFromDictionary:(NSDictionary *)dictionary {
    ReferenceModel *referenceModel = [[ReferenceModel alloc] init];
    NSDictionary *mapping = [referenceModel jsonMapping];
    for(NSString *attribute in [mapping allKeys])
    {
        NSString *classProperty = [mapping objectForKey:attribute];
        NSString *attributeValue = [dictionary objectForKey:attribute];
        if(attributeValue != nil && !([attributeValue isKindOfClass:[NSNull class]]))
        {
            [referenceModel setValue:attributeValue forKey:classProperty];
        }
    }
    return referenceModel;
}

+(NSDictionary *)dictionaryFromReferenceModel:(ReferenceModel *)referenceModel {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSDictionary *mapping = [referenceModel jsonMapping];
    for(NSString *attribute in [mapping allKeys])
    {
        NSString *classProperty = [mapping objectForKey:attribute];
        if([referenceModel valueForKeyPath:attribute] == nil)
        {
            [dict setValue:[NSNull null] forKey:classProperty];
        }
        else
        {
            NSString *attributeValue = [referenceModel valueForKeyPath:attribute];
            if(attributeValue != nil && !([attributeValue isKindOfClass:[NSNull class]]))
            {
                [dict setValue:attributeValue forKey:classProperty];
            }
        }
    }
    return dict;
}

@end
