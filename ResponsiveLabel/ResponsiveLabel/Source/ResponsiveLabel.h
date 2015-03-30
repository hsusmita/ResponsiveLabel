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

@property (nonatomic, strong) NSString *truncationToken;
@property (nonatomic, strong) NSAttributedString *attributedTruncationToken;

- (void)setTruncationToken:(NSString *)truncationToken withAction:(PatternTapHandler)action;
- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken withAction:(PatternTapHandler)action;

- (void)setText:(NSString *)text withTruncation:(BOOL)truncation;
- (void)setAttributedText:(NSAttributedString *)attributedText withTruncation:(BOOL)truncation;

- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableUserHandleDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableStringDetection:(NSString *)string withAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;

@end
