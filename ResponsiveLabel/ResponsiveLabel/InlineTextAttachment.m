//
//  InlineTextAttachment.m
//  ResponsiveLabel
//
//  Created by hsusmita on 21/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "InlineTextAttachment.h"

@interface InlineTextAttachment()

@end

@implementation InlineTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
  CGRect superRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
  superRect.origin.y = self.fontDescender;
  return superRect;
}

@end
