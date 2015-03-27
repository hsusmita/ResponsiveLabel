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

- (NSArray *)patternRangesForString:(NSString *)string {
  NSMutableArray *generatedRanges = [NSMutableArray array];
  NSArray *finalRanges = [NSArray new];
  NSRegularExpression *expression = self.patternExpression;
  NSArray *matches = [expression matchesInString:string options:0 range:NSMakeRange(0,  string.length)];
  for (NSTextCheckingResult *match in matches) {
    NSRange matchRange = [match range];
    [generatedRanges addObject:[NSValue valueWithRange:matchRange]];
  }
  if (generatedRanges.count == 0) return finalRanges;
  switch (self.searchType) {
    case kPatternSearchTypeFirst:
      finalRanges = [NSArray arrayWithObject:generatedRanges.firstObject];
      break;
      
    case kPatternSearchTypeLast:
      finalRanges = [NSArray arrayWithObject:generatedRanges.lastObject];
      break;
      
    case kPatternSearchTypeAll:
      finalRanges = [NSArray arrayWithArray:generatedRanges];
      break;
  
    default:
      break;
  }
  return finalRanges;
}

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

@end
