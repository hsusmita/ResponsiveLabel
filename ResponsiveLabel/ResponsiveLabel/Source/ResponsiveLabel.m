//
//  ResponsiveLabel.m
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "ResponsiveLabel.h"
#import "PatternDescriptor.h"

const NSString *kPatternAttribute = @"PatternAttribue";
const NSString *kPatternAction  = @"PatternAction";

static NSString *kRegexStringForHashTag = @"(?<!\\w)#([\\w\\_]+)?";
static NSString *kRegexStringForUserHandle = @"(?<!\\w)@([\\w\\_]+)?";
static NSString *kRegexFormatForSearchWord = @"\\b%@?\\b";

@interface ResponsiveLabel ()<NSLayoutManagerDelegate>

@property (nonatomic, retain) NSLayoutManager *layoutManager;
@property (nonatomic, retain) NSTextContainer *textContainer;
@property (nonatomic, retain) NSTextStorage *textStorage;

@property (nonatomic, strong) UIColor *selectedLinkBackgroundColor;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, strong) NSMutableArray *patternDescriptors;

@end
@implementation ResponsiveLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
      [self configureForGestures];
      self.patternDescriptors = [NSMutableArray new];
      }
    return self;
  }

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self configureForGestures];
    self.patternDescriptors = [NSMutableArray new];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  // Update our container size when the view frame changes
  self.textContainer.size = self.bounds.size;
}

#pragma mark - Custom Getters

- (NSTextStorage *)textStorage {
  if (!_textStorage) {
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
    _layoutManager = [[NSLayoutManager alloc] init];
    _layoutManager.delegate = self;
    [_layoutManager addTextContainer:self.textContainer];
  }
  
  return _layoutManager;
}

#pragma mark - Custom Setters

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  
  CGSize size = frame.size;
  size.width = MIN(size.width, self.preferredMaxLayoutWidth);
  size.height = 0;
  self.textContainer.size = size;
}

- (void)setBounds:(CGRect)bounds {
  [super setBounds:bounds];
  
  CGSize size = bounds.size;
  size.width = MIN(size.width, self.preferredMaxLayoutWidth);
  size.height = 0;
  self.textContainer.size = size;
}


- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
  [super setPreferredMaxLayoutWidth:preferredMaxLayoutWidth];
  
  CGSize size = self.bounds.size;
  size.width = MIN(size.width, self.preferredMaxLayoutWidth);
  self.textContainer.size = size;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
  [self setAttributedText:attributedText withTruncation:NO];
}

- (void)setText:(NSString *)text {
  [self setText:text withTruncation:NO];
}

- (void)setText:(NSString *)text withTruncation:(BOOL)truncation {
  [super setText:text];
  NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                       attributes:[self attributesFromProperties]];
  [self.textStorage setAttributedString:attributedText];

  if (truncation) {
    [self configureTruncationToken];
  }
  [self generateRangesForPatterns];
}

- (void)setAttributedText:(NSAttributedString *)attributedText withTruncation:(BOOL)truncation {
  [super setAttributedText:attributedText];
  [self.textStorage setAttributedString:attributedText];

  if (truncation) {
    [self configureTruncationToken];
  }
  [self generateRangesForPatterns];
}

- (void)setTruncationToken:(NSString *)truncationToken {
  _truncationToken = truncationToken;
}

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken {
  _attributedTruncationToken = attributedTruncationToken;
}

#pragma mark - Drawing

- (void)drawTextInRect:(CGRect)rect {
  // Don't call super implementation. Might want to uncomment this out when
  // debugging layout and rendering problems.
//   [super drawTextInRect:rect];
  
  // Calculate the offset of the text in the view
  CGPoint textOffset;
  NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
  textOffset = [self calcTextOffsetForGlyphRange:glyphRange];
  
  // Drawing code
  [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textOffset];
  [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textOffset];
}

- (CGPoint)calcTextOffsetForGlyphRange:(NSRange)glyphRange {
  CGPoint textOffset = CGPointZero;
  
  CGRect textBounds = [_layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:_textContainer];
  CGFloat paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0f;
  if (paddingHeight > 0)
    textOffset.y = paddingHeight;
  
  return textOffset;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
  [super setNumberOfLines:numberOfLines];
  _textContainer.maximumNumberOfLines = numberOfLines;
}

+ (NSAttributedString *)sanitizeAttributedString:(NSAttributedString *)attributedString
{
  // Setup paragraph alignement properly. IB applies the line break style
  // to the attributed string. The problem is that the text container then
  // breaks at the first line of text. If we set the line break to wrapping
  // then the text container defines the break mode and it works.
  // NOTE: This is either an Apple bug or something I've misunderstood.
  
  // Get the current paragraph style. IB only allows a single paragraph so
  // getting the style of the first char is fine.
  NSRange range;
  NSParagraphStyle *paragraphStyle = [attributedString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:&range];
  
  if (paragraphStyle == nil)
    return attributedString;
  
  // Remove the line breaks
  NSMutableParagraphStyle *mutableParagraphStyle = [paragraphStyle mutableCopy];
  mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  
  // Apply new style
  NSMutableAttributedString *restyled = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
  [restyled addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle range:NSMakeRange(0, restyled.length)];
  
  return restyled;
}

- (NSDictionary *)attributesFromProperties {
  // Setup shadow attributes
  NSShadow *shadow = shadow = [[NSShadow alloc] init];
  if (self.shadowColor)
    {
    shadow.shadowColor = self.shadowColor;
    shadow.shadowOffset = self.shadowOffset;
    }
  else
    {
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowColor = nil;
    }
  
  // Setup colour attributes
  UIColor *colour = self.textColor;
  if (!self.isEnabled)
    colour = [UIColor lightGrayColor];
  else if (self.isHighlighted)
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

#pragma mark - Override UILabel Methods

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
  // Use our text container to calculate the bounds required. First save our
  // current text container setup
  CGSize savedTextContainerSize = self.textContainer.size;
  NSInteger savedTextContainerNumberOfLines = self.textContainer.maximumNumberOfLines;
  
  // Apply the new potential bounds and number of lines
  self.textContainer.size = bounds.size;
  self.textContainer.maximumNumberOfLines = numberOfLines;
  
  // Measure the text with the new state
  CGRect textBounds;
  @try
  {
  NSRange glyphRange = [self.layoutManager
                        glyphRangeForTextContainer:self.textContainer];
  textBounds = [self.layoutManager boundingRectForGlyphRange:glyphRange
                                             inTextContainer:self.textContainer];
  
  // Position the bounds and round up the size for good measure
  textBounds.origin = bounds.origin;
  textBounds.size.width = ceilf(textBounds.size.width);
  textBounds.size.height = ceilf(textBounds.size.height);
  }
  @finally
  {
  // Restore the old container state before we exit under any circumstances
  self.textContainer.size = savedTextContainerSize;
  self.textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines;
  }
  
  return textBounds;
}

#pragma mark - Truncation Handlers

- (void)configureTruncationToken {
  if (self.attributedTruncationToken) {
    [self appendAttributedTruncationToken];
  }else if (self.truncationToken) {
    [self appendTruncationToken];
  }
}

- (BOOL)isTruncationEnabled {
  return (self.truncationToken || self.attributedTruncationToken);
}

- (void)appendTruncationToken {
  NSString *currentText = self.attributedText.string;
  NSRange range = [self rangeForTokenInsertion:currentText];
  if (range.location == NSNotFound) {
    range = [self rangeForTokenInsertionForStringWithNewLine:currentText];
  }
  if (range.location != NSNotFound) {
    [self.textStorage replaceCharactersInRange:range withString:self.truncationToken];
  }
}

- (void)appendAttributedTruncationToken {
  NSString *currentText = self.attributedText.string;
  NSRange range = [self rangeForTokenInsertion:currentText];
  if (range.location == NSNotFound) {
    range = [self rangeForTokenInsertionForStringWithNewLine:currentText];
  }
  if (range.location != NSNotFound) {
    [self.textStorage replaceCharactersInRange:range withString:@""];
    [self.textStorage appendAttributedString:self.attributedTruncationToken];
  }
}

- (NSRange)rangeForTokenInsertion:(NSString *)text {
  NSInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:text.length - 1];
  NSRange range = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphIndex];
  NSString *tokenString = self.attributedTruncationToken ? self.attributedTruncationToken.string : self.truncationToken;
  if (range.location != NSNotFound) {
    range.length += tokenString.length;
    range.location -= tokenString.length;
  }
  return range;
}

- (NSRange)rangeForTokenInsertionForStringWithNewLine:(NSString *)text {
  NSRange newLineRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
  NSRange rangeOfText = NSMakeRange(NSNotFound, 0);
  if (newLineRange.location != NSNotFound) {
    
    NSInteger numberOfLines, index, numberOfGlyphs = [self.layoutManager numberOfGlyphs];
    NSRange lineRange;
    NSInteger approximateNumberOfLines = CGRectGetHeight([self.layoutManager usedRectForTextContainer:self.textContainer])/self.font.lineHeight;

    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
      [self.layoutManager lineFragmentRectForGlyphAtIndex:index
                                           effectiveRange:&lineRange];
      if (numberOfLines == approximateNumberOfLines - 1) break;
      index = NSMaxRange(lineRange);
    }
    rangeOfText = lineRange;
    NSString *tokenString = self.attributedTruncationToken ? self.attributedTruncationToken.string : self.truncationToken;
    rangeOfText.location += rangeOfText.length - tokenString.length + 1;
    rangeOfText.length = text.length - rangeOfText.location;
  }
  return rangeOfText;
}

#pragma mark - Touch Handlers

- (void)configureForGestures {
  self.userInteractionEnabled = YES;
  self.selectedLinkBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[touches anyObject] locationInView:self];
  
  NSInteger index = [self stringIndexAtLocation:touchLocation];
  
  NSRange aRange;
  if (index < self.textStorage.length) {
    PatternTapResponder attrib =[self.textStorage attribute:RLTapResponderAttributeName atIndex:index effectiveRange:&aRange];
    if (attrib) {
    }else {
      [super touchesBegan:touches withEvent:event];
    }
  }else {
    [super touchesBegan:touches withEvent:event];

  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[touches anyObject] locationInView:self];
  
  NSInteger index = [self stringIndexAtLocation:touchLocation];
  NSRange aRange;
  if (index < self.textStorage.length) {
    PatternTapResponder attrib =[self.textStorage attribute:RLTapResponderAttributeName atIndex:index effectiveRange:&aRange];
    if (attrib) {
      NSString *string = [self.attributedText.string substringWithRange:aRange];
      attrib(string);
    }else {
      [super touchesEnded:touches withEvent:event];
    }
  }else {
    [super touchesEnded:touches withEvent:event];

  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
}

- (NSUInteger)stringIndexAtLocation:(CGPoint)location {
  // Do nothing if we have no text
  if (self.textStorage.string.length == 0) {
    return NSNotFound;
  }
  
  // Work out the offset of the text in the view
  CGPoint textOffset;
  NSRange glyphRange = [self.layoutManager
                        glyphRangeForTextContainer:self.textContainer];
  textOffset = [self calcTextOffsetForGlyphRange:glyphRange];
  
  // Get the touch location and use text offset to convert to text cotainer coords
  location.x -= textOffset.x;
  location.y -= textOffset.y;
  
  NSUInteger glyphIndex = [self.layoutManager glyphIndexForPoint:location
                                                 inTextContainer:self.textContainer];
  
  // If the touch is in white space after the last glyph on the line we don't
  // count it as a hit on the text
  NSRange lineRange;
  CGRect lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex
                                                             effectiveRange:&lineRange];
  
  if (!CGRectContainsPoint(lineRect, location)) {
    return NSNotFound;
    }
  
  return [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
}


+ (BOOL)requiresConstraintBasedLayout {
  return YES;
}

#pragma mark - Pattern matching

- (void)generateRangesForPatterns {
  [self.patternDescriptors enumerateObjectsUsingBlock:^(PatternDescriptor *descriptor, NSUInteger idx, BOOL *stop) {
    NSArray *ranges = [descriptor patternRangesForString:self.textStorage.string];
    [ranges enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
      if (descriptor.patternAttributes)
        [self.textStorage addAttributes: descriptor.patternAttributes range:obj.rangeValue];
      if (descriptor.tapResponder)
        [self.textStorage addAttribute:RLTapResponderAttributeName value:descriptor.tapResponder range:obj.rangeValue];
    }];
  }];
}

- (void)setTruncationToken:(NSString *)truncationToken withAction:(PatternTapHandler)action {
  self.truncationToken = truncationToken;
  NSError *error;
  NSString *pattern = [NSString stringWithFormat:kRegexFormatForSearchWord,self.truncationToken];
  NSRegularExpression	*regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:kPatternSearchTypeLast
                                                    withPatternAttributes:nil
                                                          andTapResponder:action];
  [self.patternDescriptors addObject:descriptor];
}

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken withAction:(PatternTapHandler)action {
  self.attributedTruncationToken = attributedTruncationToken;
  NSError *error;
  NSString *pattern = [NSString stringWithFormat:kRegexFormatForSearchWord,self.attributedTruncationToken.string];
  NSRegularExpression	*regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:kPatternSearchTypeLast
                                                    withPatternAttributes:nil
                                                          andTapResponder:action];
  [self.patternDescriptors addObject:descriptor];
}


- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {  
  NSError *error = nil;
  NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:detector
                                                           withSearchType:kPatternSearchTypeAll
                                                    withPatternAttributes:dictionary
                                                          andTapResponder:action];
  [self.patternDescriptors addObject:descriptor];
}

- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {
  NSError *error;
  NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:kRegexStringForHashTag options:0 error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:kPatternSearchTypeAll
                                                    withPatternAttributes:dictionary
                                                          andTapResponder:action];
  [self.patternDescriptors addObject:descriptor];
}

- (void)enableUserHandleDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {
  NSError *error;
  NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:kRegexStringForUserHandle
                                                                    options:0
                                                                      error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:kPatternSearchTypeAll
                                                    withPatternAttributes:dictionary
                                                          andTapResponder:action];
  [self.patternDescriptors addObject:descriptor];
}

- (void)enableStringDetection:(NSString *)string withAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {
  NSError *error;
  NSString *pattern = [NSString stringWithFormat:kRegexFormatForSearchWord,string];
  NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:pattern
                                                                  options:0
                                                                    error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:kPatternSearchTypeAll
                                                    withPatternAttributes:dictionary
                                                          andTapResponder:action];
  [self.patternDescriptors addObject:descriptor];
}

@end
