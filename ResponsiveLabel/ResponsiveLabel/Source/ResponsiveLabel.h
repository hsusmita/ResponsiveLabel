//
//  ResponsiveLabel.h
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatternDescriptor.h"

/**
 Custom NSTextAttributeName which takes value of type PatternTapHandler.
 It specifies the action to be performed when a range of text with that attribute is tapped.
 */
static NSString *RLTapResponderAttributeName = @"TapResponder";
static NSString *RLHighlightedForegroundColorAttributeName = @"HighlightedForegroundColor";
static NSString *RLHighlightedBackgroundColorAttributeName = @"HighlightedBackgroundColor";

/**
 Type for responder block to be specfied with RLTapResponderAttributeName
 */
typedef void (^PatternTapResponder)(NSString *tappedString);


IB_DESIGNABLE
/**
 UILabel subclass which responds to touch on specified patterns.
 This allows to replace the default truncation token with custom attributed string which can be made tappable
 */

@interface ResponsiveLabel : UILabel

@property (nonatomic,assign) IBInspectable BOOL customTruncationEnabled;
@property (nonatomic,strong) IBInspectable NSString *truncationToken;


- (void)setTruncationIndicatorImage:(UIImage *)image withSize:(CGSize)size andAction:(PatternTapResponder)action;
/** Method to set custom truncation token
 @param attributedTruncationToken:NSAttributedString Custom truncation token to be used instead of default ellipse
 @param action:PatternTapResponder Action to be performed on tap on truncation token
 */

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken withAction:(PatternTapResponder)action;

/** Method to set text
 @param text : NSString
 @param withTruncation : BOOL
 */

- (void)setText:(NSString *)text withTruncation:(BOOL)truncation;

/** Method to set attributed text
 @param attributedText : NSAttributedString
 @param withTruncation : BOOL
 */
- (void)setAttributedText:(NSAttributedString *)attributedText withTruncation:(BOOL)truncation;

/**
 Generates pattern, applies attributes and handles touch(If action specified) according to patternDescriptor.
 @param patternDescriptor:PatternDescriptor
 This object encapsulates the regular expression and attributes to be added to the pattern.
 To patterns tappable, add attribute RLTapResponderAttributeName key with block of type PatternTapResponder
 */

- (void)enablePatternDetection:(PatternDescriptor *)patternDescriptor;
- (void)disablePatternDetection:(PatternDescriptor *)patternDescriptor;

- (void)disableURLDetection;
- (void)disableUserHandleDetection;

/**
 Applies attributes to all the occurances of given string according to the attributes defines in the dictionary.
 @param string:NSString
 @param dictionary:NSDictionary
 A dictionary containing the attributes to add. To make hashtags tappable, set attribute RLTapResponderAttributeName key with block of type PatternTapResponder
 */

- (void)enableStringDetection:(NSString *)string withAttributes:(NSDictionary*)dictionary;

/**
 Applies attributes to all the occurances of strings specified in the array according to the attributes defines in the dictionary.
 @param stringsArray : NSArray
 @param dictionary:NSDictionary
 A dictionary containing the attributes to add. To make hashtags tappable, set attribute RLTapResponderAttributeName key with block of type PatternTapResponder
 */

- (void)enableDetectionForStrings:(NSArray *)stringsArray withAttributes:(NSDictionary*)dictionary;

/**
 Applies attributes to all the occurances of hashtags according to the attributes defines in the dictionary.
 @param dictionary:NSDictionary
 A dictionary containing the attributes to add. To make hashtags tappable, set @attribute RLTapResponderAttributeName key with block of type PatternTapResponder
 */

- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary;

/**
 Applies attributes to all the occurances of urls according to the attributes defines in the dictionary.
 @param dictionary:NSDictionary
 A dictionary containing the attributes to add. To make hashtags tappable, set @attribute RLTapResponderAttributeName key with block of type PatternTapResponder
 */

- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary;

/**
 Applies attributes to all the occurances of user handles according to the attributes defines in the dictionary.
 @param dictionary:NSDictionary
 A dictionary containing the attributes to add. To make hashtags tappable, set @attribute RLTapResponderAttributeName key with block of type PatternTapResponder
 */

- (void)enableUserHandleDetectionWithAttributes:(NSDictionary*)dictionary;
- (void)disableHashTagDetection;

@end
