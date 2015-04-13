//
//  PatternDescriptor.h
//  ResponsiveLabel
//
//  Created by sah-fueled on 27/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PatternTapResponder)(NSString *tappedString);

/**
 Specifies the type of Pattern Search
 */
typedef NS_ENUM(NSInteger,PatternSearchType) {
  kPatternSearchTypeAll,
  kPatternSearchTypeFirst,
  kPatternSearchTypeLast
};

@interface PatternDescriptor : NSObject

/**
 PatternDescriptor object encapsulates information regarding pattern to be matched,
 the attrinutes the pattern should possess and the action on the tapping the pattern
 */

@property (nonatomic, strong) NSRegularExpression *patternExpression;
@property (nonatomic, copy) PatternTapResponder tapResponder;
@property (nonatomic, assign)PatternSearchType searchType;
@property (nonatomic, strong) NSDictionary *patternAttributes;

- (id)initWithRegex:(NSRegularExpression *)expression
     withSearchType:(PatternSearchType)searchType
withPatternAttributes:(NSDictionary *)patternAttributes
    andTapResponder:(PatternTapResponder)tapResponder;

/**
  Generates array of ranges for the matches found in given string
*/
- (NSArray *)patternRangesForString:(NSString *)string;

@end