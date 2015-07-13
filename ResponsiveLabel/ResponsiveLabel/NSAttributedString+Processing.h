//
//  NSAttributedString+Helpers.h
//  ResponsiveLabel
//
//  Created by hsusmita on 14/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Processing)

- (BOOL)isNewLinePresent;
- (NSAttributedString *)wordWrappedAttributedString;

@end
