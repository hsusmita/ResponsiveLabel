//
//  NSAttributedString+Helpers.m
//  ResponsiveLabel
//
//  Created by hsusmita on 14/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAttributedString+Processing.h"

@implementation NSAttributedString (Processing)

- (BOOL)isNewLinePresent {
  NSRange newLineRange = [self.string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
  return (newLineRange.location != NSNotFound);
}

/** Setup paragraph alignement properly.
 Interface builder applies line break style to the attributed string. This makes
 text container break at first line of text. So we need to set the line break to
 wrapping. IB only allows a single paragraph so getting the style of the first
 char is fine.
 */

- (NSAttributedString *)wordWrappedAttributedString {
  NSAttributedString *processedString = self;
  if (self.length > 0) {
    NSRange range;
    NSParagraphStyle *paragraphStyle = [self attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:&range];
    if (paragraphStyle) {
      // Remove the line breaks
      NSMutableParagraphStyle *mutableParagraphStyle = [paragraphStyle mutableCopy];
      mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
      // Apply new style
      NSMutableAttributedString *restyled = [[NSMutableAttributedString alloc] initWithAttributedString:self];
      [restyled addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle range:NSMakeRange(0, restyled.length)];
      processedString = restyled;
    }
  }
  return processedString;
}

@end
