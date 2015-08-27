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
//  if self.wordRange.length == 0 {
//    return
//  }
//  var range = self.glyphRangeForCharacterRange(self.wordRange, actualCharacterRange:nil)
//  range = NSIntersectionRange(glyphsToShow, range)
  NSRange range = glyphsToShow;
  if (range.length == 0) {
    return;
  }
  
  NSTextContainer *tc = [self textContainerForGlyphAtIndex:range.location effectiveRange:nil];
  CGRect boundingRect = [self boundingRectForGlyphRange:range
                                        inTextContainer:tc];
  boundingRect.origin.x += origin.x;
  boundingRect.origin.y += origin.y;
//  boundingRect.size.height /= 2;
//  boundingRect.size.width /= 3;
  CGContextRef c = UIGraphicsGetCurrentContext();
  CGContextSaveGState(c);
//  CGContextSetStrokeColorWithColor(c, self.outlineColor.CGColor);
//  CGContextSetLineWidth(c, 1.0);
//  CGContextStrokeRect(c, boundingRect);
//  
  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:boundingRect cornerRadius:5.0];
  if (self.outlineColor) {
  CGContextSetFillColorWithColor(c, self.outlineColor.CGColor);
  //  CGContextSetStrokeColorWithColor(c, self.outlineColor.CGColor);
    [bezierPath fill];
  }
  
  CGContextRestoreGState(c);
}

@end
