//
//  PatternDescriptor.m
//  ResponsiveLabel
//
//  Created by hsusmita on 27/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "PatternDescriptor.h"

@implementation PatternDescriptor

- (id)initWithRegex:(NSRegularExpression *)expression
     withSearchType:(PatternSearchType)searchType
withPatternAttributes:(NSDictionary *)patternAttributes {
  
  self = [super init];
  if (self) {
    _patternExpression = expression;
    _searchType = searchType;
    _patternAttributes = patternAttributes;
  }
  return self;
}

- (NSArray *)patternRangesForString:(NSString *)string {
  if (string.length == 0) return nil;
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
    case PatternSearchTypeFirst:
      finalRanges = [NSArray arrayWithObject:generatedRanges.firstObject];
      break;
      
    case PatternSearchTypeLast:
      finalRanges = [NSArray arrayWithObject:generatedRanges.lastObject];
      break;
      
    case PatternSearchTypeAll:
      finalRanges = [NSArray arrayWithArray:generatedRanges];
      break;
      
    default:
      break;
  }
  
  return finalRanges;
}

@end

