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
	if (glyphsToShow.length == 0) {
		return;
	} else if ([self customBackgroundAttributesPresent]) {
		[self drawCustomBackgroundForGlyphRange:glyphsToShow atPoint:origin];
	} else {
		[super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
	}
}

- (BOOL)customBackgroundAttributesPresent {
	__block BOOL result = NO;
	[self.textStorage  enumerateAttributesInRange:NSMakeRange(0, [self.textStorage length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
	 ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
	 	if ([attributes.allKeys containsObject: RLHighlightedBackgroundCornerRadius]) {
			result = YES;
		}
	 }];
	return result;
	}

- (void)drawCustomBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
	NSRange range = glyphsToShow;
	NSTextContainer *textContainer = [self textContainerForGlyphAtIndex:range.location
														 effectiveRange:nil];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	[self.textStorage enumerateAttribute:NSBackgroundColorAttributeName
								 inRange:range
								 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
							  usingBlock:^(id value, NSRange range, BOOL *stop) {
								  CGRect boundingRect = [self boundingRectForGlyphRange:range
																		inTextContainer:textContainer];
								  boundingRect.origin.x += origin.x;
								  boundingRect.origin.y += origin.y;
								  UIColor *backgroundColor = [self.textStorage attribute:NSBackgroundColorAttributeName
																				 atIndex:range.location
																		  effectiveRange:nil];
								  CGFloat cornerRadius = ((NSNumber *)[self.textStorage attribute:RLHighlightedBackgroundCornerRadius
																						  atIndex:range.location
																				   effectiveRange:nil]).floatValue;
								  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:boundingRect
																						cornerRadius:cornerRadius];
								  if (backgroundColor) {
									  CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
									  [bezierPath fill];
								  }
							  }];
	CGContextRestoreGState(context);
}
@end
