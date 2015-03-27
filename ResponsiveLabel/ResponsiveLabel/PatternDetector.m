//
//  PatternDetector.m
//  ResponsiveLabel
//
//  Created by hsusmita on 25/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "PatternDetector.h"
#import <UIKit/UIKit.h>

/* pattern --> ranges
 //
 //
 array of patterns --> array of ranges
 PatternObject : NSString *regex
 action
 attributes
 occurance:all/first/last
 
 
 generate ranges for patternObject
 
 Given index, get me range, attribute and action
 indexing via range -> PatternObject
 
 //Usage
 enableDetection --- store patterns
 setText == Invalidate ranges,
 generate ranges
 and apply style
 */

@implementation PatternDescriptor

- (id)initWithRegex:(NSRegularExpression *)expression
     withSearchType:(PatternSearchType)searchType
withPatternAttributes:(NSDictionary *)patternAttributes

    andTapResponder:(PatternTapResponder)tapResponder {
  
  self = [super init];
  if (self) {
    _patternExpression = expression;
    _searchType = searchType;
    _patternAttributes = patternAttributes;
    _tapResponder = tapResponder;
  }
  return self;
}

///get ranges for this pattern
// on searching-- we need range,attribute, action at once
@end

@interface PatternDetector()


@property (nonatomic, strong) NSMutableArray *patternDescriptors;
@property (nonatomic, strong) NSMutableDictionary *matchedRanges;
@property (nonatomic, strong) NSMutableDictionary *rangeCache;

@end

@implementation PatternDetector

- (id)init {
  self = [super init];
  if (self) {
    self.patternDescriptors = [NSMutableArray array];
    self.matchedRanges = [NSMutableDictionary dictionary];
    self.rangeCache = [NSMutableDictionary dictionary];
  }
  return self;
}

- (id)initWithAttributedString:(NSAttributedString *)attibutedString {
  self = [super init];
  if (self) {
    self.stringTobeParsed = attibutedString;
    self.patternDescriptors = [NSMutableArray array];
    self.matchedRanges = [NSMutableDictionary dictionary];
    self.rangeCache = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSArray *)patternRanges {
  return [self.rangeCache allKeys];
}

- (void)enableDetectionForPatternDescriptor:(PatternDescriptor *)patternDescriptor {
  [self.patternDescriptors addObject:patternDescriptor];
}

- (void)generateRangeForString:(NSString *)stringTobeParsed {
  self.rangeCache = [NSMutableDictionary dictionary];

  [self.patternDescriptors enumerateObjectsUsingBlock:^(PatternDescriptor *obj, NSUInteger idx, BOOL *stop) {
    NSRegularExpression *expression = obj.patternExpression;
    NSArray *matches = [expression matchesInString:stringTobeParsed options:0 range:NSMakeRange(0, stringTobeParsed.length)];
    
    for (NSTextCheckingResult *match in matches) {
      NSRange matchRange = [match range];
      [self.rangeCache setObject:obj forKey:[NSValue valueWithRange:matchRange]];
      
    }
  }];
}

- (PatternDescriptor *)patternDescriptorForRange:(NSRange)range {
  return [self.rangeCache objectForKeyedSubscript:[NSValue valueWithRange:range]];
}

- (NSRange)patternRangeAtIndex:(NSInteger)index {
  NSRange requiredRange = NSMakeRange(NSNotFound, 0);
  NSArray *rangeKeys = [self.rangeCache allKeys];
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSValue *key, NSDictionary *bindings) {
    NSRange range = key.rangeValue;
    return (index > range.location && index < range.location + range.length);
  }];
  NSValue *rangeValue = [[rangeKeys filteredArrayUsingPredicate:predicate] firstObject];
  if (rangeValue != NULL) {
    requiredRange = rangeValue.rangeValue;
  }
  return requiredRange;
}



#pragma mark - Internal methods

//- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapResponder)action {
//  NSError *error = nil;
//  NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
//  NSString *plainText = self.stringTobeParsed.string;
//  NSArray *matches = [detector matchesInString:plainText
//                                       options:0
//                                         range:NSMakeRange(0, self.stringTobeParsed.length)];
//  for (NSTextCheckingResult *match in matches) {
//    NSRange matchRange = [match range];
//    NSString *realURL = [self.stringTobeParsed attribute:NSLinkAttributeName atIndex:matchRange.location effectiveRange:nil];
//    if (realURL == nil) {
//      realURL = [plainText substringWithRange:matchRange];
//    }
//    NSMutableDictionary *urlAttributes = [NSMutableDictionary dictionaryWithDictionary:dictionary];
//    [urlAttributes setObject:NSLinkAttributeName forKey:realURL];
//    [self generateRangeDescriptorsMatchingRegex:detector withAttributes:urlAttributes andAction:action];
//  }
//}
//
//- (void)enableDetectionForRegexString:(NSString *)string withAttributes:(NSDictionary*)dictionary withAction:action {
//  NSError *error;
//  NSRegularExpression	*regex = [[NSRegularExpression alloc] initWithPattern:string options:0 error:&error];
//  NSArray *matches = [regex matchesInString:self.stringTobeParsed.string options:0 range:NSMakeRange(0, self.stringTobeParsed.length)];
//  
//  for (NSTextCheckingResult *match in matches) {
//    NSRange matchRange = [match range];
//    [self enableDetectionForRange:matchRange withAttributes:dictionary withAction:action];
// 	}
//  
//}

//- (void)enableDetectionForRange:(NSRange)range withAttributes:(NSDictionary*)dictionary withAction:(PatternTapResponder)block {
//  if (range.location + range.length <= self.stringTobeParsed.length) {
//    RangeDescriptor *rangeDescriptor = [[RangeDescriptor alloc]init];
//    rangeDescriptor.range = range;
//    rangeDescriptor.rangeAttributes = dictionary;
//    rangeDescriptor.tapResponder = block;
//    [self.patternDescriptors addObject:rangeDescriptor];
//  
//  }else {
//    NSAssert(@"Out of Bounds ", @"Range exceeds text length");
//  }
//}

@end
