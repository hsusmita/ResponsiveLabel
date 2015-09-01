//
//  CustomLayoutManager.m
//  ResponsiveLabel
//
//  Created by hsusmita on 27/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "CustomLayoutManager.h"

@implementation CustomLayoutManager

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
  [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
  
  NSRange range = glyphsToShow;
  if (range.length == 0) {
    return;
  }
  
  NSTextContainer *textContainer = [self textContainerForGlyphAtIndex:range.location effectiveRange:nil];
  CGRect boundingRect = [self boundingRectForGlyphRange:range
                                        inTextContainer:textContainer];
  boundingRect.origin.x += origin.x;
  boundingRect.origin.y += origin.y;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:boundingRect cornerRadius:self.cornerRadius];
  if (self.backgroundColor) {
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    [bezierPath fill];
  }
  
  CGContextRestoreGState(context);
}

@end
