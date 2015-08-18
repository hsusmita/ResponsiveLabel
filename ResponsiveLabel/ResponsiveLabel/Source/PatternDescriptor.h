//
//  PatternDescriptor.h
//  ResponsiveLabel
//
//  Created by hsusmita on 27/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Specifies the type of Pattern Search
 */
typedef NS_ENUM(NSInteger,PatternSearchType) {
  PatternSearchTypeAll,
  PatternSearchTypeFirst,
  PatternSearchTypeLast
};

/**
 PatternDescriptor object encapsulates information regarding pattern to be matched,
 the attributes the pattern should possess
 */

@interface PatternDescriptor : NSObject

@property (nonatomic, strong,readonly) NSRegularExpression *patternExpression;
@property (nonatomic, assign,readonly) PatternSearchType searchType;
@property (nonatomic, strong,readonly) NSDictionary *patternAttributes;

- (id)initWithRegex:(NSRegularExpression *)expression
     withSearchType:(PatternSearchType)searchType
withPatternAttributes:(NSDictionary *)patternAttributes;

/**
  Generates array of ranges for the matches found in given string
*/
- (NSArray *)patternRangesForString:(NSString *)string;

@end