//
//  NSMutableAttributedString+BoundChecker.m
//  ResponsiveLabel
//
//  Created by Susmita Horrow on 06/04/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

#import "NSMutableAttributedString+BoundChecker.h"

@implementation NSMutableAttributedString (BoundChecker)

- (void)addAttributeWithBoundsCheck:(NSString *)name value:(id)value range:(NSRange)range {
	NSRange totalRange = NSMakeRange(0, self.length);
	if (NSEqualRanges(range, NSIntersectionRange(totalRange, range))) {
		[self addAttribute:name value:value range:range];
	} else {
		NSLog(@"Cannot add attribute %@ to %@: Given range %@ is out of bounds", name, self.mutableString, NSStringFromRange(range));
	}
}

- (void)removeAttributeWithBoundsCheck:(NSString *)name range:(NSRange)range {
	NSRange totalRange = NSMakeRange(0, self.length);
	if (NSEqualRanges(range, NSIntersectionRange(totalRange, range))) {
		[self removeAttribute:name range:range];
	} else {
		NSLog(@"Cannot remove attribute %@ from %@: Given range %@ is out of bounds", name, self.mutableString, NSStringFromRange(range));
	}
}

- (void)addAttributesWithBoundsCheck:(NSDictionary<NSString *, id> *)attrs range:(NSRange)range {
	NSRange totalRange = NSMakeRange(0, self.length);
	if (NSEqualRanges(range, NSIntersectionRange(totalRange, range))) {
		[self addAttributes:attrs range:range];
	} else {
		NSLog(@"Cannot add attributes to %@: Given range %@ is out of bounds", self.mutableString, NSStringFromRange(range));
	}
}

@end
