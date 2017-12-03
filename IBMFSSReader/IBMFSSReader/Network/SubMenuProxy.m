//
//  SubMenuProxy.m
//  IBMFSSNewsLetter
//
//  Created by Rohit on 25/07/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "SubMenuProxy.h"

static NSString *const kTagURL = @"W7717e71a40ca_4af8_81e3_7118dc81740c/page/";

@interface SubMenuProxy ()

@property (nonatomic, strong) NSString *requestName;

@end

@implementation SubMenuProxy

#pragma mark
#pragma mark GET Method

- (void) getNewsFSSSubMenuWithPageIdentifier : (NSString *)paramPageIdentifier {
    
    NSMutableString *urlStr = [[NSMutableString alloc] initWithFormat:@"%@%@%@/media?convertTo=html",[Cache cache].baseURL,kTagURL,[paramPageIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super getRequestDataWithURL:urlStr
                 usingSessionKey:@""
                  andRequestName:kFSSSubMenuRequest];
    self.requestName = kFSSSubMenuRequest;
}

#pragma mark
#pragma mark Proxy Super Method

- (void) connectionFinishLoadingWithResponse:(NSString *)responseString
{
    if([self.requestName isEqualToString:kFSSSubMenuRequest])
    {
        [self saveSubMenuDetail:responseString];
    }
}

- (void) connectionFinishLoadingWithError : (NSString *)errorString
{
    if(self.subMenuProxyDelegate && [self.subMenuProxyDelegate conformsToProtocol:@protocol(SubMenuProxyDelegate)])
    {
        [self.subMenuProxyDelegate subMenuDidFail:[NSString stringWithFormat:@"%@",errorString]];
    }
}

#pragma mark
#pragma mark Parser Method

- (void) saveSubMenuDetail : (NSString *) paramResponse {
   
    NSMutableArray *subMenuArray = nil;
    
    @try {
        subMenuArray = [self formatHTMLWithParaTags:paramResponse];
        if(self.subMenuProxyDelegate && [self.subMenuProxyDelegate conformsToProtocol:@protocol(SubMenuProxyDelegate)])
        {
            [self.subMenuProxyDelegate loadSubMenuFromParent:subMenuArray];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception occured while subMenu : %@",[exception reason]);
    }
    @finally {    }
    
}

#pragma mark
#pragma mark Private Method

- (NSMutableArray *) formatHTMLWithParaTags : (NSString *)paramResponseString {
        
    NSString *scanHTMContent = [self scanString:paramResponseString
                                       startTag:@"<td style=\"width: 722px; vertical-align: top; box-shadow: 0px 9px 0px 0px white, 0px -9px 0px 0px white, 12px 0px 15px -4px rgb(232, 232, 232), -12px 0px 15px -4px white;\">"
                                         endTag:@"</table>"];
    
    NSMutableArray *pTagSepratedHTMLArray = [self extractPTagFromHTML:scanHTMContent];
    NSMutableArray *filterHTMLContentArray = [NSMutableArray array];
    
    for (NSString *pTagHTMLString in pTagSepratedHTMLArray) {
        NSString *paraHTML = [self flattenHTML:pTagHTMLString
                                trimWhiteSpace:YES];
        
        [filterHTMLContentArray addObject:[self getMainParas:[paraHTML componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n\r"]]]];
    }
    NSLog(@"%@", filterHTMLContentArray);
    
    return filterHTMLContentArray;

}

- (NSString *)scanString : (NSString *)paramHTMLResponse
                startTag : (NSString *)paramStartTag
                  endTag : (NSString *)paramEndTag {
    
    NSString* scanString = @"";
    
    if (paramHTMLResponse.length > 0) {
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:paramHTMLResponse];
        
        @try {
            [scanner scanUpToString:paramStartTag intoString:nil];
            scanner.scanLocation += [paramStartTag length];
            [scanner scanUpToString:paramEndTag intoString:&scanString];
        }
        @catch (NSException *exception) {
            return nil;
        }
        @finally {
            return [scanString isEqualToString:@""] ? nil : scanString;
        }
        return [scanString isEqualToString:@""] ? nil : scanString;
    }
    else
        return nil;
}

- (NSMutableArray *)extractPTagFromHTML : (NSString *)paramHTMLString {
    
    NSMutableArray *htmlWithPTagArray = [NSMutableArray array];
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:paramHTMLString];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<tr>" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@"</tr>" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        [htmlWithPTagArray addObject:text];
    }
    return htmlWithPTagArray;
    
}

- (NSString *) flattenHTML : (NSString *)paramHTML
            trimWhiteSpace : (BOOL)trim {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:paramHTML];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        paramHTML = [paramHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text]
                                                         withString:@""];
    }
    // trim off whitespace
    return trim ? [paramHTML stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : paramHTML;
}


- (NSMutableArray *) getMainParas:(NSArray *)componentSeperatedHTMLArray
{
    NSMutableArray *paras = [NSMutableArray array];
    for (NSString *str in componentSeperatedHTMLArray) {
        if (![str isEqualToString:@""] && ![str isEqualToString:@"&nbsp;"]) {
            [paras addObject:str];
        }
    }
    return paras;
}

@end
