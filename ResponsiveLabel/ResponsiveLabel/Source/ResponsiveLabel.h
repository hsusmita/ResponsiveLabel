//
//  ResponsiveLabel.h
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *RLTapResponderAttributeName = @"Tap Responder Name";

typedef void (^PatternTapHandler)(NSString *tappedString);

@interface ResponsiveLabel : UILabel

- (void)setText:(NSString *)text withTruncationToken:(NSString *)truncationToken withTapAction:(PatternTapHandler)block;
- (void)setText:(NSString *)text withAttributedTruncationToken:(NSAttributedString *)truncationToken withTapAction:(PatternTapHandler)block;

- (void)enableDetectionForRange:(NSRange)range withAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)block;
- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableTruncationTokenDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;

@end
