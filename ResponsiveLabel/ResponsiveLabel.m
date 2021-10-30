//
//  ResponsiveLabel.m
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "ResponsiveLabel.h"
#import "NSAttributedString+Processing.h"
#import "NSMutableAttributedString+BoundChecker.h"
#import "InlineTextAttachment.h"
#import "CustomLayoutManager.h"

static NSString *kRegexStringForHashTag = @"#(\\w+){1,}?";
static NSString *kRegexStringForUserHandle = @"@(\\w+){1,}?";
static NSString *kRegexFormatForSearchWord = @"(%@)";

NSString *RLTapResponderAttributeName = @"TapResponder";
NSString *RLHighlightedForegroundColorAttributeName = @"HighlightedForegroundColor";
NSString *RLHighlightedBackgroundColorAttributeName = @"HighlightedBackgroundColor";
NSString *RLHighlightedBackgroundCornerRadius = @"HighlightedBackgroundCornerRadius";


@interface ResponsiveLabel ()

@property (nonatomic, retain) CustomLayoutManager *layoutManager;
@property (nonatomic, retain) NSTextContainer *textContainer;
@property (nonatomic, retain) NSTextStorage *textStorage;

@property (nonatomic, strong) NSMutableDictionary *patternDescriptorDictionary;
@property (nonatomic, strong) NSMutableDictionary *rangeAttributeDictionary;

@property (nonatomic, strong) NSAttributedString *attributedTruncationToken;
@property (nonatomic, strong) NSAttributedString *currentAttributedString;

@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign) NSRange truncatedRange;
@property (nonatomic, assign) NSRange truncatedPatternRange;

@end

@implementation ResponsiveLabel

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configureForGestures];
		self.patternDescriptorDictionary = [NSMutableDictionary new];
		self.selectedRange = NSMakeRange(NSNotFound, 0);
		self.truncatedRange = NSMakeRange(NSNotFound, 0);
		self.truncatedPatternRange = NSMakeRange(NSNotFound, 0);
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self configureForGestures];
		self.patternDescriptorDictionary = [NSMutableDictionary new];
		self.selectedRange = NSMakeRange(NSNotFound, 0);
		self.truncatedRange = NSMakeRange(NSNotFound, 0);
		self.truncatedPatternRange = NSMakeRange(NSNotFound, 0);
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self initialTextConfiguration];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.textContainer.size = self.bounds.size;
}

#pragma mark - Custom Getters

- (NSTextStorage *)textStorage {
	if (!_textStorage) {
		[_textStorage removeLayoutManager:_layoutManager];
		_textStorage = [[NSTextStorage alloc] init];
		[_textStorage addLayoutManager:self.layoutManager];
		[self.layoutManager setTextStorage:_textStorage];
	}
	return _textStorage;
}

- (NSTextContainer *)textContainer {
	if (!_textContainer) {
		_textContainer = [[NSTextContainer alloc] init];
		_textContainer.lineFragmentPadding = 0;
		_textContainer.maximumNumberOfLines = self.numberOfLines;
		_textContainer.lineBreakMode = self.lineBreakMode;
		_textContainer.widthTracksTextView = YES;
		_textContainer.size = self.frame.size;
		[_textContainer setLayoutManager:self.layoutManager];
	}
	return _textContainer;
}

- (NSLayoutManager *)layoutManager {
	if (!_layoutManager) {
		_layoutManager = [[CustomLayoutManager alloc] init];
		[_layoutManager addTextContainer:self.textContainer];
	}
	return _layoutManager;
}

- (NSString *)truncationToken {
	return self.attributedTruncationToken.string;
}

#pragma mark - Custom Setters

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self updateTextContainerSize:frame.size];
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	[self updateTextContainerSize:bounds.size];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
	[super setPreferredMaxLayoutWidth:preferredMaxLayoutWidth];
	[self updateTextContainerSize:self.bounds.size];
}

- (void)setText:(NSString *)text {
	[super setText:text];
	NSString *finalText = (text!= nil) ? text : @"";
	NSAttributedString *attributedText =[[NSAttributedString alloc]initWithString:finalText
																	   attributes:[self attributesFromProperties]];
	[self updateTextStorage:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	[super setAttributedText:attributedText];
	[self updateTextStorage:[attributedText wordWrappedAttributedString]];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
	[super setNumberOfLines:numberOfLines];
	if (numberOfLines != _textContainer.maximumNumberOfLines) {
		_textContainer.maximumNumberOfLines = numberOfLines;
		[self initialTextConfiguration];
		[self layoutIfNeeded];
	}
}

- (void)setCustomTruncationEnabled:(BOOL)customTruncationEnabled {
	_customTruncationEnabled = customTruncationEnabled;
	[self setNeedsDisplay];
}

- (void)setTruncationToken:(NSString *)truncationToken {

	NSAttributedString *token = [[NSAttributedString alloc]initWithString:truncationToken
															   attributes:[self attributesFromProperties]];
	[self setAttributedTruncationToken:token];
}

- (void)setTextColor:(UIColor *)textColor {
	[super setTextColor:textColor];
	[self.textStorage addAttributeWithBoundsCheck:NSForegroundColorAttributeName
											value:textColor
											range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];
	[self.textStorage addAttributeWithBoundsCheck:NSFontAttributeName
											value:font
											range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setShadowColor:(UIColor *)shadowColor {
	[super setShadowColor:shadowColor];
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowColor = shadowColor;
	shadow.shadowOffset = self.shadowOffset;
	[self.textStorage addAttributeWithBoundsCheck:NSShadowAttributeName
											value:shadow
											range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
	[super setShadowOffset:shadowOffset];
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowColor = self.shadowColor;
	shadow.shadowOffset = shadowOffset;
	[self.textStorage addAttributeWithBoundsCheck:NSShadowAttributeName
											value:shadow
											range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
	[super setTextAlignment:textAlignment];
	NSRange fullRange = NSMakeRange(0, self.textStorage.length);
	__block NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];

	[self.textStorage enumerateAttribute:NSParagraphStyleAttributeName
								 inRange:fullRange
								 options:NSAttributedStringEnumerationReverse
							  usingBlock:^(NSMutableParagraphStyle *value, NSRange range, BOOL * stop) {
								  paragraph = value;
							  }];
	paragraph.alignment = self.textAlignment;
	[self.textStorage addAttributeWithBoundsCheck:NSParagraphStyleAttributeName
											value:paragraph
											range:fullRange];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self initialTextConfiguration];

}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	self.userInteractionEnabled = enabled;
	[self initialTextConfiguration];
}

#pragma mark - Drawing

- (void)drawTextInRect:(CGRect)rect {
	// Don't call super implementation. Might want to uncomment this out when
	// debugging layout and rendering problems.
	//   [super drawTextInRect:rect];

	//Handle truncation
	self.customTruncationEnabled ? [self appendTokenIfNeeded] : [self removeTokenIfPresent];

	//Draw after truncation process is complete
	NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];

	// Calculate the offset of the text in the view
	CGPoint textOffset = [self textOffsetForGlyphRange:glyphRange];

	// Drawing code

	[_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textOffset];
	[_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textOffset];

}

/**
 This method calculates text offset to draw the given glyph range such that text is center aligned veritically
 @param glyphRange : NSRange
 @return CGPoint : The text offset

 */
- (CGPoint)textOffsetForGlyphRange:(NSRange)glyphRange {
	CGPoint textOffset = CGPointZero;

	CGRect textBounds = [self.layoutManager boundingRectForGlyphRange:glyphRange
													  inTextContainer:self.textContainer];
	CGFloat paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0f;
	if (paddingHeight > 0)
		textOffset.y = paddingHeight;

	return textOffset;
}

/**
 Convenience method to draw text for a given range
 @param range : NSRange
 */

- (void)redrawTextForRange:(NSRange)range {
	NSRange glyphRange = NSMakeRange(NSNotFound, 0);
	[self.layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
	CGRect rect = [self.layoutManager usedRectForTextContainer:self.textContainer];
	NSRange totalGlyphRange = [self.layoutManager
							   glyphRangeForTextContainer:self.textContainer];
	CGPoint point = [self textOffsetForGlyphRange:totalGlyphRange];
	rect.origin.y += point.y;
	[self setNeedsDisplayInRect:rect];
}


#pragma mark - Override UILabel Methods

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
	CGRect requiredRect = [self rectFittingTextForContainerSize:bounds.size
												forNumberOfLine:numberOfLines];
	self.textContainer.size = requiredRect.size;
	return requiredRect;
}

- (CGRect)rectFittingTextForContainerSize:(CGSize)size
						  forNumberOfLine:(NSInteger)numberOfLines {
	self.textContainer.size = size;
	self.textContainer.maximumNumberOfLines = numberOfLines;
	CGRect textBounds = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(0, self.layoutManager.numberOfGlyphs)
													  inTextContainer:self.textContainer];
	NSInteger totalLines = textBounds.size.height / self.font.lineHeight;

	if (numberOfLines > 0 && (numberOfLines < totalLines)) {
		textBounds.size.height -= (totalLines - numberOfLines) * self.font.lineHeight;
	}else if (numberOfLines > 0 && (numberOfLines > totalLines)) {
		textBounds.size.height += (numberOfLines - totalLines) * self.font.lineHeight;
	}
	textBounds.size.width = ceilf(textBounds.size.width);
	textBounds.size.height = ceilf(textBounds.size.height);
	return textBounds;
}

#pragma mark - Override UIView methods

+ (BOOL)requiresConstraintBasedLayout {
	return YES;
}

#pragma mark - Truncation Handlers

/**
 This method removes token if already added
 */

- (void)removeTokenIfPresent {
	if (![self truncationTokenAppended]) return;
	NSRange truncationRange =
	[self.textStorage.string rangeOfString:self.attributedTruncationToken.string];

	NSAttributedString *visibleString =
	[self.textStorage attributedSubstringFromRange:NSMakeRange(0, truncationRange.location)];
	NSAttributedString *hiddenString = [self.attributedText attributedSubstringFromRange:self.truncatedRange];

	NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc]initWithAttributedString:visibleString];
	[finalString appendAttributedString:hiddenString];

	[self.textStorage setAttributedString:finalString];

	//configure truncated pattern range
	NSDictionary *patternAttributes = [self.rangeAttributeDictionary objectForKey:[NSValue valueWithRange:self.truncatedPatternRange]];
	if (patternAttributes)
		[self.textStorage addAttributesWithBoundsCheck:patternAttributes range:self.truncatedPatternRange];

	self.truncatedPatternRange = NSMakeRange(NSNotFound, 0);
	self.truncatedRange = NSMakeRange(NSNotFound, 0);
}

/**
 This method appends truncation token if required
 Conditions : 1. self.customTruncationEnabled = YES
 2. self.attributedTruncationToken.length > 0
 3. Truncation token is not appended
 */

- (void)appendTokenIfNeeded {
	if ([self shouldAppendTruncationToken] && ![self truncationTokenAppended]) {
		if ([self.textStorage isNewLinePresent]) {
			//Append token string at the end of last visible line
			NSRange range = [self rangeForTokenInsertionForStringWithNewLine];
			if (range.length > 0)
				[self.textStorage replaceCharactersInRange:range
									  withAttributedString:self.attributedTruncationToken];
		}

		//Check for truncation range and append truncation token if required
		NSRange tokenRange =[self rangeForTokenInsertion];
		if (tokenRange.location != NSNotFound) {
			[self updateTextStorageReplacingRange:tokenRange];
		}
	}
}

- (void)updateTextStorageReplacingRange:(NSRange)replaceRange {
	// set truncated range
	self.truncatedRange = NSMakeRange(replaceRange.location, self.attributedText.length - replaceRange.location);

	// Append truncation token
	[self.textStorage replaceCharactersInRange:replaceRange
						  withAttributedString:self.attributedTruncationToken];

	//set pattern truncation range
	[self.rangeAttributeDictionary.allKeys enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
		if ([self isRangeTruncated:obj.rangeValue]) {
			self.truncatedPatternRange = obj.rangeValue;
		}
	}];

	// Remove attribute from truncated pattern
	[self removeAttributeForTruncatedRange];

	// Add attribute to truncation range
	[self addAttributesToTruncationToken];
}

- (void)removeAttributeForTruncatedRange {
	NSDictionary *patternAttributes = [self.rangeAttributeDictionary objectForKey:[NSValue valueWithRange:self.truncatedPatternRange]];
	[patternAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		NSRange availableRange = NSMakeRange(self.truncatedPatternRange.location, self.textStorage.length - self.attributedTruncationToken.length - self.truncatedPatternRange.location);
		[self.textStorage removeAttributeWithBoundsCheck:key range:availableRange];
	}];
}

- (void)addAttributesToTruncationToken {
	NSRange truncationRange = [self rangeOfTruncationToken];
	//Apply attributes to the truncation token
	NSString *key = [NSString stringWithFormat:kRegexFormatForSearchWord,self.attributedTruncationToken.string];
	PatternDescriptor *descriptor = [self.patternDescriptorDictionary objectForKey:key];
	if (descriptor && self.enabled) {
		[self.textStorage addAttributesWithBoundsCheck:descriptor.patternAttributes range:truncationRange];
	}
}

- (NSRange)rangeForTokenInsertion {
	self.textContainer.size = self.bounds.size;
	if (self.text.length == 0) {
		return NSMakeRange(NSNotFound, 0);
	}

	NSInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:self.textStorage.length - 1];
	NSRange range = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphIndex];

	if (range.location != NSNotFound && self.customTruncationEnabled) {
		range.length += self.attributedTruncationToken.length;
		range.location -= self.attributedTruncationToken.length;
	}
	return range;
}

- (NSRange)rangeForTokenInsertionForStringWithNewLine {
	NSInteger numberOfLines, index, numberOfGlyphs = [self.layoutManager numberOfGlyphs];
	NSRange lineRange = NSMakeRange(NSNotFound, 0);
	NSInteger approximateNumberOfLines = CGRectGetHeight([self.layoutManager usedRectForTextContainer:self.textContainer])/self.font.lineHeight;
	for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
		[self.layoutManager lineFragmentRectForGlyphAtIndex:index
											 effectiveRange:&lineRange];
		if (numberOfLines == approximateNumberOfLines - 1) break;
		index = NSMaxRange(lineRange);
	}
	NSRange rangeOfText = NSMakeRange(lineRange.location + lineRange.length - 1,
									  self.textStorage.length - lineRange.location - lineRange.length + 1);
	return rangeOfText;
}

- (NSRange)rangeOfTruncationToken {
	__block NSRange truncationRange;
	if (self.attributedTruncationToken && self.customTruncationEnabled) {
		truncationRange = [self.textStorage.string rangeOfString:self.attributedTruncationToken.string];
	}else {
		truncationRange = [self rangeForTokenInsertion];
	}
	return truncationRange;
}

- (BOOL)shouldAppendTruncationToken {
	return (self.textStorage.length > 0 && self.customTruncationEnabled && self.attributedTruncationToken.length > 0);
}

- (BOOL)truncationTokenAppended {
	return (self.textStorage.length > 0 && (self.attributedTruncationToken.length > 0) &&
			([self.textStorage.string rangeOfString:self.attributedTruncationToken.string].location != NSNotFound));
}

- (void)updateTruncationToken:(NSAttributedString *)attributedTruncationToken {
	// Disable old truncation pattern detection
	if (self.attributedTruncationToken.length > 0) {
		NSString *patternKey = [NSString stringWithFormat:kRegexFormatForSearchWord,self.attributedTruncationToken.string];
		[self disablePatternDetection:[self.patternDescriptorDictionary objectForKey:patternKey]];
	}

	// Assign new truncation pattern
	_attributedTruncationToken = attributedTruncationToken;

	// Enable new truncation pattern detection

	__block PatternTapResponder action;
	[attributedTruncationToken enumerateAttribute:RLTapResponderAttributeName
  										inRange:NSMakeRange(0, attributedTruncationToken.length)
										  options:NSAttributedStringEnumerationReverse
									   usingBlock:^(PatternTapResponder value, NSRange range, BOOL *stop) {
										   action = value;
									   }];
	NSError *error;

	if (action) {
		NSString *pattern = [NSString stringWithFormat:kRegexFormatForSearchWord,self.attributedTruncationToken.string];
		NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&error];
		PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
																 withSearchType:PatternSearchTypeLast
														  withPatternAttributes:@{RLTapResponderAttributeName:action}];
		[self enablePatternDetection:descriptor];
	}
}

#pragma mark - Touch Handlers

- (void)configureForGestures {
	if (self.isEnabled) {
		self.userInteractionEnabled = YES;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchLocation = [[touches anyObject] locationInView:self];
	NSInteger index = [self characterIndexAtLocation:touchLocation];
	NSRange rangeOfTappedText;
	if (index < self.textStorage.length) {
		rangeOfTappedText = [self.layoutManager rangeOfNominallySpacedGlyphsContainingIndex:index];
	}

	if (rangeOfTappedText.location != NSNotFound &&
		![self patternTouchInProgress] &&
		[self shouldHandleTouchAtIndex:index]) {

		[self handleTouchBeginForRange:rangeOfTappedText];
	}else {
		[super touchesBegan:touches withEvent:event];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	[self handleTouchCancelled];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([self patternTouchInProgress] && [self shouldHandleTouchAtIndex:self.selectedRange.location]) {
		[self performSelector:@selector(handleTouchEnd)
				   withObject:nil
				   afterDelay:0.05];
	}else {
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)handleTouchBeginForRange:(NSRange)range {
	if (![self patternTouchInProgress]) {
		//Set global variable
		self.selectedRange = range;
		self.currentAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.textStorage];
		[self addHighlightingForIndex:range.location];
	}
}

- (void)handleTouchEnd {
	if ([self patternTouchInProgress]) {
		[self removeHighlightingForIndex:self.selectedRange.location];
		//Perform action after heighlight is removed
		[self performActionAtIndex:self.selectedRange.location];

		//Clear global Variable
		self.selectedRange = NSMakeRange(NSNotFound, 0);
		self.currentAttributedString = nil;
	}
}

- (void)handleTouchCancelled {
	if ([self patternTouchInProgress]) {
		[self removeHighlightingForIndex:self.selectedRange.location];

		//Clear global Variable
		self.selectedRange = NSMakeRange(NSNotFound, 0);
		self.currentAttributedString = nil;
	}
}

- (BOOL)patternTouchInProgress {
	return self.selectedRange.location != NSNotFound;
}

/**
 This method checks whether the given index can handle touch
 Touch will be handled if any of these attributes are set: RLTapResponderAttributeName
 or RLHighlightedBackgroundColorAttributeName
 or RLHighlightedForegroundColorAttributeName
 @param index: NSInteger - Index to be checked
 @return It returns a BOOL incating if touch handling is enabled or not
 */

- (BOOL)shouldHandleTouchAtIndex:(NSInteger)index {
	if (index > self.textStorage.length) return NO;
	NSRange range;
	NSDictionary *dictionary = [self.textStorage attributesAtIndex:index effectiveRange:&range];
	BOOL touchAttributesSet = (dictionary && ([dictionary.allKeys containsObject:RLTapResponderAttributeName] ||
											  [dictionary.allKeys containsObject:RLHighlightedBackgroundColorAttributeName] ||
											  [dictionary.allKeys containsObject:RLHighlightedForegroundColorAttributeName]));

	return touchAttributesSet;
}

/**
 This method executes the block corresponding to RLTapResponderAttributeName.
 @param index : NSInteger - Index at which the action to be performed
 */
- (void)performActionAtIndex:(NSInteger)index {
	NSRange patternRange;
	if (index < self.textStorage.length) {
		PatternTapResponder tapResponder = [self.textStorage attribute:RLTapResponderAttributeName
															   atIndex:index
														effectiveRange:&patternRange];
		if (tapResponder) {
			tapResponder([self.textStorage.string substringWithRange:patternRange]);
		}
	}
}

#pragma mark - Highlighting

- (void)addHighlightingForIndex:(NSInteger)index {
	if (index > self.textStorage.length) return;
	UIColor *backgroundcolor = nil;
	UIColor *foregroundcolor = nil;
	NSRange patternRange = NSMakeRange(0, self.textStorage.length);

	if (index < self.textStorage.length) {

		backgroundcolor = [self.textStorage attribute:RLHighlightedBackgroundColorAttributeName
											  atIndex:index
									   effectiveRange:&patternRange];
		foregroundcolor = [self.textStorage attribute:RLHighlightedForegroundColorAttributeName
											  atIndex:index
									   effectiveRange:&patternRange];

		NSNumber *cornerRadius = [self.textStorage attribute:RLHighlightedBackgroundCornerRadius atIndex:index effectiveRange:&patternRange];
		if (backgroundcolor) {
			self.layoutManager.backgroundColor = backgroundcolor;
			[self.textStorage addAttributeWithBoundsCheck:NSBackgroundColorAttributeName
													value:backgroundcolor
													range:patternRange];
			self.layoutManager.cornerRadius = cornerRadius.floatValue;
		}
		if (foregroundcolor) {
			[self.textStorage addAttributeWithBoundsCheck:NSForegroundColorAttributeName
													value:foregroundcolor
													range:patternRange];
		}
	}
	[self redrawTextForRange:patternRange];
}

- (void)removeHighlightingForIndex:(NSInteger)index {
	if (self.selectedRange.location != NSNotFound && self.textStorage.length > index) {
		UIColor *backgroundcolor = nil;
		UIColor *foregroundcolor = nil;
		NSRange patternRange = NSMakeRange(0, self.textStorage.length);

		if (index < self.textStorage.length) {
			backgroundcolor = [self.currentAttributedString attribute:NSBackgroundColorAttributeName
															  atIndex:index
													   effectiveRange:&patternRange];
			foregroundcolor = [self.currentAttributedString attribute:NSForegroundColorAttributeName
															  atIndex:index
													   effectiveRange:&patternRange];

			if (backgroundcolor) {
		  [self.textStorage addAttributeWithBoundsCheck:NSBackgroundColorAttributeName
												  value:backgroundcolor
												  range:patternRange];
			}else {

				[self.textStorage removeAttributeWithBoundsCheck:NSBackgroundColorAttributeName range:patternRange];
			}

			if (foregroundcolor) {
		  [self.textStorage addAttributeWithBoundsCheck:NSForegroundColorAttributeName
												  value:foregroundcolor
												  range:patternRange];
			}else {
				[self.textStorage removeAttributeWithBoundsCheck:NSForegroundColorAttributeName
											range:patternRange];
			}
		}
		[self redrawTextForRange:patternRange];
	}
}

#pragma mark - Pattern matching

/**
 This method searches ranges for patternDescriptor and stores in rangeAttributeDictionary,
 adds corresponding entry to self.rangeAttributeDictionary.
 Then the attributes are added to those ranges depending upon the following conditions

 1. The range is not truncated by truncation token

 2. The range is out of bound of current textStorage

 @param patternDescriptor : PatternDescriptor
 */

- (void)addAttributesForPatternDescriptor:(PatternDescriptor *)patternDescriptor {
	//Generate ranges for attributed text of the label
	NSArray *patternRanges = [patternDescriptor patternRangesForString:self.attributedText.string];

	//Apply attributes to the ranges conditionally
	[patternRanges enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
		[self.rangeAttributeDictionary setObject:patternDescriptor.patternAttributes forKey:obj];
		if ([self isRangeTruncated:obj.rangeValue]) {
			self.truncatedPatternRange = obj.rangeValue;
		}else if ((obj.rangeValue.location + obj.rangeValue.length) <= self.textStorage.length) {
			[self.textStorage addAttributesWithBoundsCheck: patternDescriptor.patternAttributes range:obj.rangeValue];
			[self redrawTextForRange:obj.rangeValue];
		}
	}];
}

/**
 This method searches ranages for patterns speficed in patternDescriptor for self.textStorage,
 removes corresponding entry from self.rangeAttributeDictionary.
 Then the attribites dictated by patternDescriptors are removed under the following conditions

 1. The range is not truncated by truncation token

 2. The range is out of bound of current textStorage

 @param patternDescriptor : PatternDescriptor

 */

- (void)removeAttributesForPatternDescriptor:(PatternDescriptor *)patternDescriptor {
	//Generate ranges for current text of textStorage
	NSArray *patternRanges = [patternDescriptor patternRangesForString:self.textStorage.string];

	//Remove attributes from the ranges conditionally
	[patternRanges enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
		[self.rangeAttributeDictionary removeObjectForKey:obj];
		if ([self isRangeTruncated:obj.rangeValue]) {
			self.truncatedPatternRange = NSMakeRange(NSNotFound, 0);
		}else if ((obj.rangeValue.location + obj.rangeValue.length) <= self.textStorage.length) {
			[patternDescriptor.patternAttributes enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, id attributeValue, BOOL *stop) {
		  if ([attributeName isEqualToString:NSForegroundColorAttributeName]) {
			  //Color will be set based on the state of the Label whether it is enabled or highlighted
			  [self updateTextColorForRange:obj.rangeValue];
		  }else {
			  [self.textStorage removeAttributeWithBoundsCheck:attributeName range:obj.rangeValue];
		  }
			}];
			[self redrawTextForRange:obj.rangeValue];
		}
	}];
}

- (BOOL)isRangeTruncated:(NSRange)range {
	NSRange truncationRange = [self rangeOfTruncationToken];
	return ((NSIntersectionRange(range, truncationRange).length > 0) && (range.location < truncationRange.location));
}

/**
 This method returns the key for the given PatternDescriptor stored in patternDescriptorDictionary.
 In patternDescriptorDictionary, each entry has the format (NSString, PatternDescriptor).
 @param: PatternDescriptor
 @return: NSString
 */

- (NSString *)patternNameKeyForPatternDescriptor:(PatternDescriptor *)patternDescriptor {
	NSString *key;
	if ([patternDescriptor.patternExpression isKindOfClass:[NSDataDetector class]]) {
		//As NSDataDetector class, patternExpression.pattern = nil,
		//we need to set key according to checkingTypes
		NSTextCheckingTypes types = ((NSDataDetector *)patternDescriptor.patternExpression).checkingTypes;
		key = [NSString stringWithFormat:@"%llu",types];
	}else {
		key = patternDescriptor.patternExpression.pattern;
	}
	return key;
}

#pragma mark - Helper Methods

/**
 This method does initial text configuration which includes updating text storage
 and appending truncation token
 */

- (void)initialTextConfiguration {
	NSAttributedString *currentText;
	if (self.attributedText.length > 0) {
		currentText = [self.attributedText wordWrappedAttributedString];
	}else if (self.text.length > 0){
		currentText = [[NSAttributedString alloc]initWithString:self.text
													 attributes:[self attributesFromProperties]];
	}
	[self updateTextStorage:currentText];
}

/** This method extects the attributes from the properties of the label
 @return Dictionary of attributes
 */

- (NSDictionary *)attributesFromProperties {
	// Setup shadow attributes
	NSShadow *shadow = shadow = [[NSShadow alloc] init];
	if (self.shadowColor) {
		shadow.shadowColor = self.shadowColor;
		shadow.shadowOffset = self.shadowOffset;
	}
	else {
		shadow.shadowOffset = CGSizeMake(0, -1);
		shadow.shadowColor = nil;
	}

	// Setup colour attributes
	UIColor *colour = self.textColor;
	if (!self.isEnabled)
		colour = [UIColor lightGrayColor];
	else if (self.isHighlighted && self.highlightedTextColor)
		colour = self.highlightedTextColor;

	// Setup paragraph attributes
	NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
	paragraph.alignment = self.textAlignment;

	// Create the dictionary
	NSDictionary *attributes = @{NSFontAttributeName : self.font,
								 NSForegroundColorAttributeName : colour,
								 NSShadowAttributeName : shadow,
								 NSParagraphStyleAttributeName : paragraph,
								 };
	return attributes;
}

/** Updates text container size
 @param size: CGSize
 */

- (void)updateTextContainerSize:(CGSize)size {
	CGSize containerSize = size;
	containerSize.width = MIN(size.width, self.preferredMaxLayoutWidth);
	containerSize.height = 0;
	self.textContainer.size = containerSize;
}

/**
 This method sets the attributedString of text storage and applies required
 attributes specified in patternDescriptorDictionary
 @param attributedText: NSAttributedString
 */

- (void)updateTextStorage:(NSAttributedString *)attributedText {
	self.rangeAttributeDictionary = [NSMutableDictionary new];
	if (attributedText == nil) {
		NSAttributedString *emptyString = [[NSAttributedString alloc]initWithString:@""];
		[self.textStorage setAttributedString:emptyString];
	}else {
		[self.textStorage setAttributedString:attributedText];
	}
	[self updateTextColorForRange:NSMakeRange(0, self.textStorage.length)];
	[self.patternDescriptorDictionary enumerateKeysAndObjectsUsingBlock:^(id key, PatternDescriptor *descriptor, BOOL *stop) {
		[self addAttributesForPatternDescriptor:descriptor];
	}];
}

- (void)updateTextColorForRange:(NSRange)range {
	UIColor *colour = self.textColor;
	if (!self.isEnabled)
		colour = [UIColor lightGrayColor];
	else if (self.isHighlighted && self.highlightedTextColor)
		colour = self.highlightedTextColor;

	[self.attributedText enumerateAttribute:NSForegroundColorAttributeName
									inRange:range
									options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
								 usingBlock:^(UIColor *value, NSRange range, BOOL *stop) {
									 UIColor *foregroundColor = colour;
									 if (value) {
								   //If text color is different than attribute color, then retain that attribute color
								   foregroundColor = [value isEqual:self.textColor] ? colour : value;
									 }
									 [self.textStorage addAttributeWithBoundsCheck:NSForegroundColorAttributeName
																			 value:foregroundColor
																			 range:range];
	}];
}

/**
 Returns index of character located a given point
 @param location: CGPoint
 @return character index
 */

- (NSUInteger)characterIndexAtLocation:(CGPoint)location {
	NSUInteger chracterIndex = NSNotFound;
	if (self.textStorage.string.length > 0) {
		CGPoint textOffset = [self textOffsetForGlyphRange:
							  [self.layoutManager glyphRangeForTextContainer:self.textContainer]];

		// Get the touch location and use text offset to convert to text cotainer coords
		location.x -= textOffset.x;
		location.y -= textOffset.y;

		NSUInteger glyphIndex =
		[self.layoutManager glyphIndexForPoint:location
							   inTextContainer:self.textContainer];

		// If the touch is in white space after the last glyph on the line we don't
		// count it as a hit on the text
		NSRange lineRange;
		CGRect lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex
																   effectiveRange:&lineRange];
		lineRect.size.height = 60;  //Adjustment to increase tap area

		if (CGRectContainsPoint(lineRect, location)) {
			chracterIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
		}
	}
	return chracterIndex;
}

#pragma mark - Public Methods

- (void)setText:(NSString *)text withTruncation:(BOOL)truncation {
	[self setText:text];
	[self setCustomTruncationEnabled:truncation];
}

- (void)setAttributedText:(NSAttributedString *)attributedText withTruncation:(BOOL)truncation {
	[self setAttributedText:attributedText];
	[self setCustomTruncationEnabled:truncation];
}

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken withAction:(PatternTapResponder)action {
	NSMutableAttributedString *token = [[NSMutableAttributedString alloc]initWithAttributedString:attributedTruncationToken];
	[token addAttributeWithBoundsCheck:RLTapResponderAttributeName value:action range:NSMakeRange(0, attributedTruncationToken.length)];
	[self setAttributedTruncationToken:attributedTruncationToken];
}

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken {
	[self removeTokenIfPresent];
	[self updateTruncationToken:attributedTruncationToken];
	[self setNeedsDisplay];
}

- (void)setTruncationIndicatorImage:(UIImage *)image withSize:(CGSize)size andAction:(PatternTapResponder)action {
	InlineTextAttachment *textAttachment = [[InlineTextAttachment alloc]init];
	textAttachment.image = image;
	textAttachment.fontDescender = self.font.descender;
	textAttachment.bounds = CGRectMake(0, -self.font.descender - self.font.lineHeight/2,size.width,size.height);
	NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];

	NSAttributedString *paddingString = [[NSAttributedString alloc]initWithString:@" "];
	NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc]initWithAttributedString:paddingString];
	[finalString appendAttributedString:imageAttributedString];
	[finalString appendAttributedString:paddingString];
	[finalString addAttributeWithBoundsCheck:RLTapResponderAttributeName value:action range:NSMakeRange(0, finalString.length)];
	[self setAttributedTruncationToken:finalString];
}

- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary {
	NSError *error;
	NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:kRegexStringForHashTag options:0 error:&error];
	PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
															 withSearchType:PatternSearchTypeAll
													  withPatternAttributes:dictionary];
	[self enablePatternDetection:descriptor];
}

- (void)disableHashTagDetection {
	[self disablePatternDetection:[self.patternDescriptorDictionary objectForKey:kRegexStringForHashTag]];
}

- (void)enableUserHandleDetectionWithAttributes:(NSDictionary*)dictionary {
	NSError *error;
	NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:kRegexStringForUserHandle
																	 options:0
																	   error:&error];
	PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
															 withSearchType:PatternSearchTypeAll
													  withPatternAttributes:dictionary];
	[self enablePatternDetection:descriptor];
}

- (void)disableUserHandleDetection {
	[self disablePatternDetection:[self.patternDescriptorDictionary objectForKey:kRegexStringForUserHandle]];
}

- (void)enableStringDetection:(NSString *)string withAttributes:(NSDictionary*)dictionary {
	NSError *error;
	NSString *pattern = [NSString stringWithFormat:kRegexFormatForSearchWord,string];
	NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:pattern
																	 options:0
																	   error:&error];

	PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
															 withSearchType:PatternSearchTypeAll
													  withPatternAttributes:dictionary];
	[self enablePatternDetection:descriptor];
}

- (void)disableStringDetection:(NSString *)string {
	NSString *key = [NSString stringWithFormat:kRegexFormatForSearchWord,string];
	[self disablePatternDetection:[self.patternDescriptorDictionary objectForKey:key]];
}

- (void)enableDetectionForStrings:(NSArray *)stringsArray withAttributes:(NSDictionary *)dictionary {
	[stringsArray enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
		[self enableStringDetection:string withAttributes:dictionary];
	}];
}

- (void)disableDetectionForStrings:(NSArray *)stringsArray {
	[stringsArray enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
		[self disableStringDetection:string];
	}];
}

- (void)enablePatternDetection:(PatternDescriptor *)patternDescriptor {
	NSString *patternkey = [self patternNameKeyForPatternDescriptor:patternDescriptor];
	if (patternkey.length > 0) {
		[self.patternDescriptorDictionary setObject:patternDescriptor
											 forKey:patternkey];
		[self addAttributesForPatternDescriptor:patternDescriptor];
	}
}

- (void)disablePatternDetection:(PatternDescriptor *)patternDescriptor {
	NSString *patternkey = [self patternNameKeyForPatternDescriptor:patternDescriptor];
	if (patternkey.length > 0) {
		[self.patternDescriptorDictionary removeObjectForKey:patternkey];
		[self removeAttributesForPatternDescriptor:patternDescriptor];
	}
}

- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary {
	NSError *error = nil;
	NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
	PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:detector
															 withSearchType:PatternSearchTypeAll
													  withPatternAttributes:dictionary];
	[self enablePatternDetection:descriptor];
}

- (void)disableURLDetection {
	NSString *key = [NSString stringWithFormat:@"%llu",NSTextCheckingTypeLink];
	[self disablePatternDetection:[self.patternDescriptorDictionary objectForKey:key]];
}

@end
