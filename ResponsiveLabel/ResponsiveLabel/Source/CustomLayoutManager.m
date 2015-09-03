//
//  CustomLayoutManager.m
//  ResponsiveLabel
//
//  Created by hsusmita on 27/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "CustomLayoutManager.h"
#import "ResponsiveLabel.h"

@implementation CustomLayoutManager

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {

  NSRange range = glyphsToShow;
  if (range.length == 0) {
    return;
  }
  
  NSTextContainer *textContainer = [self textContainerForGlyphAtIndex:range.location effectiveRange:nil];
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  [self.textStorage enumerateAttribute:NSBackgroundColorAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
    CGRect boundingRect = [self boundingRectForGlyphRange:range
                                          inTextContainer:textContainer];
    boundingRect.origin.x += origin.x;
    boundingRect.origin.y += origin.y;
    NSLog(@"rect = %@",NSStringFromCGRect(boundingRect));
    UIColor *backgroundColor = [self.textStorage attribute:NSBackgroundColorAttributeName atIndex:range.location effectiveRange:nil];
    CGFloat cornerRadius = ((NSNumber *)[self.textStorage attribute:RLHighlightedBackgroundCornerRadius atIndex:range.location effectiveRange:nil]).floatValue;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:boundingRect cornerRadius:cornerRadius];
    if (backgroundColor) {
      CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
      [bezierPath fill];
    }else {
//      [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    }
    
  }];
  CGContextRestoreGState(context);
 
}

@end
