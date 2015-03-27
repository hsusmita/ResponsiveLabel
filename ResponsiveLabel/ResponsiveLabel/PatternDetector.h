//
//  PatternDetector.h
//  ResponsiveLabel
//
//  Created by sah-fueled on 25/03/15.
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

@end

@interface PatternDetector : NSObject

@property (nonatomic, strong) NSAttributedString *stringTobeParsed;

- (id)initWithAttributedString:(NSAttributedString *)attibutedString;
- (void)generateRangeDescriptorsMatchingRegex:(NSRegularExpression *)regex withAttributes:(NSDictionary *)rangeAttributes andAction:(PatternTapResponder)action;
- (NSArray *)patternRanges;
- (NSRange)patternRangeAtIndex:(NSInteger)index;
- (void)enableDetectionForPatternDescriptor:(PatternDescriptor *)patternDescriptor;
- (void)generateRangeForString:(NSString *)stringTobeParsed;
- (PatternDescriptor *)patternDescriptorForRange:(NSRange)range;

@end


