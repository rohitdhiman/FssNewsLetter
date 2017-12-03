//
//  FeedXMLParser.m
//  IBMFSSReader
//
//  Created by Rohit on 13/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "FeedXMLParser.h"

@interface FeedXMLParser ()

@property (nonatomic, strong) NSMutableString *summaryXML;

@end

@implementation FeedXMLParser

- (void) startRSFeedParser : (NSString *)xmlDataToParse {

    NSData *xmlData = [xmlDataToParse dataUsingEncoding:NSUTF8StringEncoding
                                   allowLossyConversion:YES];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];

}

#pragma mark
#pragma mark XMLParser Delegate Method
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"summary"]){
        self.summaryXML = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.summaryXML appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"summary"]) {
        if(self.feedXMLParserDelegate && [self.feedXMLParserDelegate conformsToProtocol:@protocol(FeedXMLParserDelegate)]) {
            [self.feedXMLParserDelegate showXMLFeed:self.summaryXML];
        }
    }
}

@end
