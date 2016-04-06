//
//  NSMutableAttributedString+BoundChecker.h
//  ResponsiveLabel
//
//  Created by Susmita Horrow on 06/04/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (BoundChecker)

- (void)addAttributeWithBoundsCheck:(NSString *)name value:(id)value range:(NSRange)range;
- (void)removeAttributeWithBoundsCheck:(NSString *)name range:(NSRange)range;
- (void)addAttributesWithBoundsCheck:(NSDictionary<NSString *, id> *)attrs range:(NSRange)range;

@end
