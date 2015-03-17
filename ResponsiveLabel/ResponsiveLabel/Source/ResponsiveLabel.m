//
//  ResponsiveLabel.m
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "ResponsiveLabel.h"
#import <CoreText/CoreText.h>

@interface ResponsiveLabel ()<NSLayoutManagerDelegate>

@property (nonatomic, strong) NSMutableArray *searchStrings;

@end

@implementation ResponsiveLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.searchStrings = [NSMutableArray array];
      }
    return self;
  }


#pragma mark - Handle Truncation Token

- (void)setText:(NSString *)text AndTruncationToken:(NSString *)truncationToken {
  _truncationToken = truncationToken;
  self.text = text;
  self.attributedText = [[NSAttributedString alloc]initWithString:text];
  self.attributedText =[[NSAttributedString alloc]initWithString :[self approximateTruncatedString]];
}

+ (BOOL)requiresConstraintBasedLayout {
  return YES;
}

- (NSString *)approximateTruncatedString {
  NSArray *segmentsOfLines = [self truncate:self.text forLabel:self];
  if (segmentsOfLines.count > 1) {
    NSString *firstSegment = [segmentsOfLines firstObject];
    NSInteger visibleCharacterCount = firstSegment.length - self.truncationToken.length;
    NSString *approximateString = [self truncatedStringWithVisibleCharacterCount:visibleCharacterCount];
    
    NSArray *segments = [self truncate:approximateString forLabel:self];
    if (segments.count > 1) {
      NSString *truncatedString = [[self truncate:approximateString forLabel:self] lastObject];
      visibleCharacterCount = firstSegment.length - self.truncationToken.length - truncatedString.length;
      return [self truncatedStringWithVisibleCharacterCount:visibleCharacterCount];
    }else {
      return approximateString;
    }
  }
  return self.text;
}

- (NSString *)truncatedStringWithVisibleCharacterCount:(NSInteger)visibleCharacterCount {
  NSRange range = NSMakeRange(visibleCharacterCount,
                              self.text.length - visibleCharacterCount);
  
  return [self.text stringByReplacingCharactersInRange:range withString:self.truncationToken];
}


- (NSArray *)truncate:(NSString *)text forLabel: (UILabel*) label {
  NSMutableArray *textChunks = [[NSMutableArray alloc] init];
  
  NSString *chunk = [[NSString alloc] init];
  NSMutableAttributedString *attrString = nil;
  UIFont *uiFont = label.font;
  CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)uiFont.fontName, uiFont.pointSize, NULL);
  NSDictionary *attr = [NSDictionary dictionaryWithObject:(__bridge id)ctFont forKey:(id)kCTFontAttributeName];
  attrString  = [[NSMutableAttributedString alloc] initWithString:text attributes:attr];
  CTFramesetterRef frameSetter;
  
  
  CFRange fitRange;
  while (attrString.length > 0) {
    
    frameSetter = CTFramesetterCreateWithAttributedString ((__bridge CFAttributedStringRef) attrString);

    CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0,0), NULL, CGSizeMake(label.bounds.size.width, label.bounds.size.height), &fitRange);
    CFRelease(frameSetter);
    
    chunk = [[attrString attributedSubstringFromRange:NSMakeRange(0, fitRange.length)] string];
    
    [textChunks addObject:chunk];
    
    [attrString setAttributedString: [attrString attributedSubstringFromRange:NSMakeRange(fitRange.length, attrString.string.length-fitRange.length)]];
    
  }
  return textChunks;
}


@end
