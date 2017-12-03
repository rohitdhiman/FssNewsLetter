//
//  PeopleProxy.m
//  IBMFSSReader
//
//  Created by Rohit on 07/06/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "PeopleProxy.h"
#import "XMLReader.h"

static NSString *const kTagURL = @"W7717e71a40ca_4af8_81e3_7118dc81740c/page/";
//static NSString *const kTagURL = @"46823d8e-fd6d-4fed-9742-63d8f407240a/page/";

@interface PeopleProxy ()

@property (nonatomic, strong) NSString *requestName;
@property (nonatomic, strong) FeedXMLParser *feedXMLParser;
@property (nonatomic, strong) NSString *presentedHTML;

@end

@implementation PeopleProxy

#pragma mark
#pragma mark GET Method

- (void) getNewsFSSDataWithPageIdentifer : (NSString *)pageIdentifer {   
    //NSMutableString *urlStr = [[NSMutableString alloc] initWithFormat:@"%@%@%@/entry",[Cache cache].baseURL,kTagURL,[pageIdentifer stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableString *urlStr = [[NSMutableString alloc] initWithFormat:@"%@%@%@/media?convertTo=html",[Cache cache].baseURL,kTagURL,[pageIdentifer stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super getRequestDataWithURL:urlStr
                 usingSessionKey:@""
                  andRequestName:kPeopleAPIRequest];
    self.requestName = kPeopleAPIRequest;
    
}

#pragma mark
#pragma mark Proxy Super Method
- (void) connectionFinishLoadingWithResponse:(NSString *)responseString
{
    if([self.requestName isEqualToString:kPeopleAPIRequest])
    {
        [self savePeopleDetail:responseString];
    }
    
}

- (void) connectionFinishLoadingWithError : (NSString *)errorString
{
    if(self.peopleProxyDelegate && [self.peopleProxyDelegate conformsToProtocol:@protocol(PeopleProxyDelegate)])
    {
        [self.peopleProxyDelegate peopleDidFail:[NSString stringWithFormat:@"%@",errorString]];
    }
}

- (void) savePeopleDetail : (NSString *)response {

    [self formatHTMLAccordingView:response];
    
}

- (void) formatHTMLAccordingView : (NSString *)paramHTMLResponse {
    
    NSMutableString *formatedHMTL = [[NSMutableString alloc] initWithString:paramHTMLResponse];
    
    //Remove head
    NSRange headStart = [formatedHMTL rangeOfString:@"<head>"];
    NSRange headEnd = [formatedHMTL rangeOfString:@"</head>"];
    [formatedHMTL deleteCharactersInRange:(NSRange){headStart.location, headEnd.location+1}];
    
    //Remove <tr> from tbody
    NSString *trResult = nil;
    NSRange trStartRange = [formatedHMTL rangeOfString:@"<tr>" options:NSCaseInsensitiveSearch];
    if(trStartRange.location != NSNotFound) {
        
        NSRange trEndRange;
        
        trEndRange.location = trStartRange.length + trStartRange.location;
        trEndRange.length = [formatedHMTL length] - trEndRange.location;
        
        trEndRange = [formatedHMTL rangeOfString:@"</tr>"
                                         options:NSCaseInsensitiveSearch
                                           range:trEndRange];
        
        if(trEndRange.location != NSNotFound) {
            trStartRange.location += trStartRange.length;
            trStartRange.length = trEndRange.location - trStartRange.location;
            trResult = [formatedHMTL substringWithRange:trStartRange];
        }
    }
    
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:trResult
                                                           withString:@""];
    self.presentedHTML = formatedHMTL;
    
    NSString *tableRightTag = @"<table align=\"right\"";
    NSUInteger tagCount = [[formatedHMTL componentsSeparatedByString:tableRightTag] count]-1;
   
    formatedHMTL = (NSMutableString *)[self removeTableFromResponseHTML:formatedHMTL
                                                               andCount:tagCount
                                                                 andTag:tableRightTag];
    
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"table border=\"1\""
                                                                              withString:@"table border=\"0\""];
    
    NSString *tdRightTag = @"<td style=\"width: 242px; vertical-align: top;\">";
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:tdRightTag
                                                                              withString:@""];
    
    //replace width
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"650"
                                                                              withString:@"970"];
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"657"
                                                                              withString:@"970"];
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"663"
                                                                              withString:@"970"];
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"667"
                                                                              withString:@"970"];
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"697"
                                                                              withString:@"970"];
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"699"
                                                                              withString:@"970"];
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"699"
                                                                              withString:@"970"];
    //remove [TOP] aherf
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"box-shadow: 5px 5px 5px rgb(153, 153, 153)"
                                                                              withString:@""];
    formatedHMTL = (NSMutableString *)[formatedHMTL stringByReplacingOccurrencesOfString:@"<a href=\"#Top\">Top</a>"
                                                                              withString:@""];
    
    //adding customFont
    [formatedHMTL replaceOccurrencesOfString:@"Times New Roman, Times, serif"
                                  withString:@"Helvetica Neue; font-size: 13px"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    //font
    [formatedHMTL replaceOccurrencesOfString:@"Verdana, Geneva, sans-serif"
                                  withString:@"Helvetica Neue; font-size: 13px"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    
    [formatedHMTL replaceOccurrencesOfString:@"<p style=\"text-align: justify;\">"
                                  withString:@"<p style=\"text-align: justify; font-family: Helvetica Neue; font-size: 13px;\">"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    
    [formatedHMTL replaceOccurrencesOfString:@"<span style=\"\">"
                                  withString:@"<p style=\"text-align: justify; font-family: Helvetica Neue; font-size: 13px;\">"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"Tahoma"
                                  withString:@"Helvetica Neue"
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"2.5"
                                  withString:@"3.0"
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, formatedHMTL.length)];
    //font-size
    [formatedHMTL replaceOccurrencesOfString:@"12.0pt"
                                  withString:@"13.0pt"
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"14px"
                                  withString:@"13px"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    //textcolor #0000FF
    [formatedHMTL replaceOccurrencesOfString:@"#0000FF"
                                  withString:@"#000000"
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, formatedHMTL.length)];
    
    
    //remove italic text
    [formatedHMTL replaceOccurrencesOfString:@"<i>"
                                  withString:@""
                                     options:NSLiteralSearch range:NSMakeRange(0,formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"</i>"
                                  withString:@""
                                     options:NSLiteralSearch range:NSMakeRange(0,formatedHMTL.length)];
    
    [formatedHMTL replaceOccurrencesOfString:@"<em>"
                                  withString:@"<p style=\"text-align: justify; font-family: Helvetica Neue; font-size: 13px;\">"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"</em>"
                                  withString:@"</p>"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    NSString *bodyStyle = @"<body style='font-family: \"Helvetica Neue\";font-size: 13px;' bgcolor=\"white\">";
    [formatedHMTL replaceOccurrencesOfString:@"<body>"
                                  withString:bodyStyle
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"<br></br>"
                                  withString:@""
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    //modify ul/li
    [formatedHMTL replaceOccurrencesOfString:@"value=\"5\""
                                  withString:@""
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    NSString *currentLiString = @"<li style=\"text-align: justify;\">";
    NSString *currentExceptionalLiString = @"<li style=\"text-align: justify;\" >";
    NSString *changedLiString = @"<li style=\"text-align: justify; font-family: Helvetica Neue; font-size: 13px;\">";
    
    [formatedHMTL replaceOccurrencesOfString:currentLiString
                                  withString:changedLiString
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:currentExceptionalLiString
                                  withString:changedLiString
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"<li>"
                                  withString:changedLiString
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    //replace h3 with h5
    [formatedHMTL replaceOccurrencesOfString:@"h3"
                                  withString:@"h5"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    [formatedHMTL replaceOccurrencesOfString:@"h2"
                                  withString:@"h5"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];

    //span remove
    NSString *spanHTML = @"<span style=\"font-size:13.0pt;\"";
    [formatedHMTL replaceOccurrencesOfString:spanHTML
                                  withString:@"<span"
                                     options:NSLiteralSearch range:NSMakeRange(0, formatedHMTL.length)];
    
    
    if(self.peopleProxyDelegate && [self.peopleProxyDelegate conformsToProtocol:@protocol(PeopleProxyDelegate)]) {
        PeopleModel *peopleModel = [[PeopleModel alloc] initPeopleModelWithSummery:[NSString stringWithFormat:@"%@",formatedHMTL]];
        [self.peopleProxyDelegate getPeopleFSSReader:peopleModel];
    }
}

- (NSString *)removeTableFromResponseHTML : (NSString *)paramHTMLResponse
                                 andCount : (NSUInteger) count
                                   andTag : (NSString *)paramTagRemoved{
    
    NSString *resultHTML = @"";
    NSString *presentedHTML = [NSString stringWithFormat:@"%@",paramHTMLResponse];

    @try {
        for(NSUInteger index = 0; index < count; index++) {
            NSRange tdStyleStart = [presentedHTML rangeOfString:paramTagRemoved
                                                            options:NSCaseInsensitiveSearch];
            
            NSRange tdStyleEnd;
            tdStyleEnd.location = tdStyleStart.location + tdStyleStart.length;
            tdStyleEnd.length = [presentedHTML length] - tdStyleEnd.location;
            tdStyleEnd = [presentedHTML rangeOfString:@"</table>"
                                                  options:NSCaseInsensitiveSearch
                                                    range:tdStyleEnd];
            
            if(tdStyleEnd.location != NSNotFound) {
                tdStyleStart.location += tdStyleStart.length ;
                tdStyleStart.length = tdStyleEnd.location - tdStyleStart.location;
                
                resultHTML = [presentedHTML substringWithRange:tdStyleStart];
                resultHTML = [NSString stringWithFormat:@"%@%@",paramTagRemoved,resultHTML];
            }
            
            presentedHTML = [presentedHTML stringByReplacingOccurrencesOfString:resultHTML withString:@""];
            NSUInteger tagCount = [[paramHTMLResponse componentsSeparatedByString:paramTagRemoved] count]-1;
            count = tagCount;
        }
        return presentedHTML;
    }
    @catch (NSException *exception) {
        NSLog(@"exception occured %@",exception.reason);
    }
    @finally {
        NSLog(@"exception occured");
    }
    return presentedHTML;
}

#pragma mark
#pragma mark FeedXMLParser Delegate Method
- (void) showXMLFeed:(NSString *)summeryFeed {
    if(self.peopleProxyDelegate && [self.peopleProxyDelegate conformsToProtocol:@protocol(PeopleProxyDelegate)]) {
        PeopleModel *peopleModel = [[PeopleModel alloc] initPeopleModelWithSummery:[NSString stringWithFormat:@"%@",summeryFeed]];
        [self.peopleProxyDelegate getPeopleFSSReader:peopleModel];
    }
}

@end
