//
//  PatternDescriptor.h
//  ResponsiveLabel
//
//  Created by sah-fueled on 27/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PatternTapResponder)(NSString *tappedString);

typedef enum {
  kPatternSearchTypeAll,
  kPatternSearchTypeFirst,
  kPatternSearchTypeLast
}PatternSearchType;

@interface PatternDescriptor : NSObject

@property (nonatomic, strong) NSRegularExpression *patternExpression;
@property (nonatomic, copy) PatternTapResponder tapResponder;
@property (nonatomic, assign)PatternSearchType searchType;
@property (nonatomic, strong) NSDictionary *patternAttributes;

- (id)initWithRegex:(NSRegularExpression *)expression
     withSearchType:(PatternSearchType)searchType
withPatternAttributes:(NSDictionary *)patternAttributes
    andTapResponder:(PatternTapResponder)tapResponder;

- (NSArray *)patternRangesForString:(NSString *)string;

@end