//
//  ResponsiveLabel.h
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Custom NSTextAttributeName which takes value of type PatternTapHandler.
 It specifies the action to be performed when a range of text with that attribute is tapped.
 */
static NSString *RLTapResponderAttributeName = @"Tap Responder Name";

/**
  Type for responder block to be specfied with RLTapResponderAttributeName
 */
typedef void (^PatternTapHandler)(NSString *tappedString);

@interface ResponsiveLabel : UILabel

@property (nonatomic, strong) NSAttributedString *attributedTruncationToken;

- (void)setText:(NSString *)text withTruncation:(BOOL)truncation;
- (void)setAttributedText:(NSAttributedString *)attributedText withTruncation:(BOOL)truncation;

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken withAction:(PatternTapHandler)action;
- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableUserHandleDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;
- (void)enableStringDetection:(NSString *)string withAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action;

@end
