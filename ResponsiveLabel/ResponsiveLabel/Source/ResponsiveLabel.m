//
//  ResponsiveLabel.m
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "ResponsiveLabel.h"
#import "TouchGestureRecognizer.h"

const NSString *kPatternAttribute = @"PatternAttribue";
const NSString *kPatternAction  = @"PatternAction";

@interface ResponsiveLabel ()<NSLayoutManagerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *searchStrings;
@property (nonatomic, retain) NSLayoutManager *layoutManager;
@property (nonatomic, retain) NSTextContainer *textContainer;
@property (nonatomic, retain) NSTextStorage *textStorage;

@property (nonatomic, strong) UIColor *selectedLinkBackgroundColor;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign) BOOL isTouchMoved;
@property (nonatomic, strong) NSString *truncationToken;
@property (nonatomic, strong) NSAttributedString *attributedTruncationToken;
@property (nonatomic, strong) NSMutableDictionary *patternDictionary;

@end
@implementation ResponsiveLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
      [self setupTextSystem];
      [self configureForGestures];
      self.patternDictionary = [NSMutableDictionary new];
      }
    return self;
  }

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupTextSystem];
    [self configureForGestures];
    self.patternDictionary = [NSMutableDictionary new];
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
    // Create a layout manager for rendering
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
  [super setAttributedText:attributedText];
  [self.textStorage setAttributedString:attributedText];
}

- (void)setText:(NSString *)text {
  [super setText:text];
  [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:text]];
}

#pragma mark - Drawing

- (void)drawTextInRect:(CGRect)rect {
  // Don't call super implementation. Might want to uncomment this out when
  // debugging layout and rendering problems.
  // [super drawTextInRect:rect];
  
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

- (void)setupTextSystem
{
  // Create a text container and set it up to match our label properties
//  _textContainer = [[NSTextContainer alloc] init];
  _textContainer.lineFragmentPadding = 0;
  _textContainer.maximumNumberOfLines = self.numberOfLines;
  _textContainer.lineBreakMode = self.lineBreakMode;
  _textContainer.size = self.frame.size;
  
  // Create a layout manager for rendering
//  _layoutManager = [[NSLayoutManager alloc] init];
  _layoutManager.delegate = self;
  [_layoutManager addTextContainer:_textContainer];
  
  // Attach the layou manager to the container and storage
  [_textContainer setLayoutManager:_layoutManager];
  
  // Make sure user interaction is enabled so we can accept touches
  self.userInteractionEnabled = YES;
  
//  // Don't go via public setter as this will have undesired side effect
//  _automaticLinkDetectionEnabled = YES;
//  
//  // All links are detectable by default
//  _linkDetectionTypes = KILinkTypeAll;
//  
//  // Link Type Attributes. Default is empty (no attributes).
//  _linkTypeAttributes = [NSMutableDictionary dictionary];
//  
//  // Don't underline URL links by default.
//  _systemURLStyle = NO;
  
  self.selectedLinkBackgroundColor = nil;//[UIColor colorWithWhite:0.95 alpha:1.0];
  
  // Establish the text store with our current text
  [self updateTextStoreWithText];
}

- (void)updateTextStoreWithText
{
  // Now update our storage from either the attributedString or the plain text
  if (self.attributedText)
    [self updateTextStoreWithAttributedString:self.attributedText];
  else if (self.text)
    [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:self.text attributes:[self attributesFromProperties]]];
  else
    [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:[self attributesFromProperties]]];
  
  [self setNeedsDisplay];
}

- (void)updateTextStoreWithAttributedString:(NSAttributedString *)attributedString
{
 /* if (attributedString.length != 0)
    {
    attributedString = [KILabel sanitizeAttributedString:attributedString];
    }
  
  if (self.isAutomaticLinkDetectionEnabled && (attributedString.length != 0))
    {
//    self.linkRanges = [self getRangesForLinks:attributedString];
//    attributedString = [self addLinkAttributesToAttributedString:attributedString linkRanges:self.linkRanges];
    }
  else
    {
    self.linkRanges = nil;
    }
  */
  if (_textStorage)
    {
    // Set the string on the storage
    [_textStorage setAttributedString:attributedString];
    }
  else
    {
    // Create a new text storage and attach it correctly to the layout manager
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    [_textStorage addLayoutManager:_layoutManager];
    [_layoutManager setTextStorage:_textStorage];
    }
}

- (NSDictionary *)attributesFromProperties
{
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

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
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

- (void)setText:(NSString *)text withTruncationToken:(NSString *)truncationToken withTapAction:(PatternTapHandler)block {
  self.truncationToken = truncationToken;
  [self setText:text];
  [self appendTruncationToken];
  [self enableDetectionForRange:[self.textStorage.string rangeOfString:truncationToken] withAttributes:nil withAction:block];
}

- (void)setText:(NSString *)text withAttributedTruncationToken:(NSAttributedString *)truncationToken withTapAction:(PatternTapHandler)block {
  self.attributedTruncationToken = truncationToken;
  [self setText:text];
  
  NSString *currentText = self.attributedText.string;
  NSRange range = [self rangeForTokenInsertion:currentText];
  if (range.location == NSNotFound) {
    range = [self rangeForTokenInsertionForStringWithNewLine:currentText];
  }
  
  if (range.location != NSNotFound) {
    [self.textStorage replaceCharactersInRange:range withAttributedString:self.attributedTruncationToken];
    
    //    NSString *finalString = [currentText stringByReplacingCharactersInRange:range withString:self.truncationToken];
    //    [self setAttributedText:[[NSAttributedString alloc] initWithString:finalString]];
    //    [self setText:finalString];
  }
  [self enableDetectionForRange:[self.textStorage.string rangeOfString:self.attributedTruncationToken.string]
                 withAttributes:[self.textStorage attributesAtIndex:self.textStorage.string.length - 1 effectiveRange:NULL]
                     withAction:block];
}

- (void)appendTruncationToken {
  NSString *currentText = self.attributedText.string;
  NSRange range = [self rangeForTokenInsertion:currentText];
  if (range.location == NSNotFound) {
    range = [self rangeForTokenInsertionForStringWithNewLine:currentText];
  }
  if (range.location != NSNotFound) {
    [self.textStorage replaceCharactersInRange:range withString:self.truncationToken];

//    NSString *finalString = [currentText stringByReplacingCharactersInRange:range withString:self.truncationToken];
//    [self setAttributedText:[[NSAttributedString alloc] initWithString:finalString]];
//    [self setText:finalString];
  }
  
}

- (NSRange )rangeForTokenInsertion:(NSString *)text {
  NSInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:text.length - 1];
  NSRange range = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphIndex];
  
  if (range.location != NSNotFound) {
    range.length += self.truncationToken.length + 1;
    range.location -= self.truncationToken.length + 1;
  }
  return range;
}

- (NSRange )rangeForTokenInsertionForStringWithNewLine:(NSString *)text {
  NSRange newLineRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
  NSRange rangeOfText = NSMakeRange(NSNotFound, 0);
  if (newLineRange.location != NSNotFound) {
    
    NSInteger numberOfLines, index, numberOfGlyphs = [self.layoutManager numberOfGlyphs];
    NSRange lineRange;
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
      [self.layoutManager lineFragmentRectForGlyphAtIndex:index
                                           effectiveRange:&lineRange];
      if (numberOfLines == self.numberOfLines - 1) break;
      index = NSMaxRange(lineRange);
    }
    rangeOfText = lineRange;
    rangeOfText.location += rangeOfText.length - self.truncationToken.length + 1;
    rangeOfText.length = text.length - rangeOfText.location;
  }
  return rangeOfText;
}

#pragma mark - Touch Handlers

- (void)configureForGestures {
  // Make sure user interaction is enabled so we can accept touches
  self.userInteractionEnabled = YES;
  
  // Default background colour looks good on a white background
  self.selectedLinkBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
  
  // Attach a default detection handler to help with debugging
//  self.linkTapHandler = ^(NSURL *URL) {
//    NSLog(@"Default handler for %@", URL);
//  };
  
//  TouchGestureRecognizer *touch = [[TouchGestureRecognizer alloc] initWithTarget:self
//                                                                          action:@selector(handleTouch:)];
//  touch.delegate = self;
//  [self addGestureRecognizer:touch];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[touches anyObject] locationInView:self];
  
  NSInteger index = [self stringIndexAtLocation:touchLocation];
  
  NSRange effectiveRange;
  NSURL *touchedURL = nil;
  
  if (index != NSNotFound)
    {
    touchedURL = [self.attributedText attribute:NSLinkAttributeName atIndex:index effectiveRange:&effectiveRange];
    }
  
  NSValue *rangeKeyForTouchPoint = [self rangeKeyForIndex:index];
  if (rangeKeyForTouchPoint == NULL) {
    [super touchesBegan:touches withEvent:event];
  }else {

  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[touches anyObject] locationInView:self];
  
  NSInteger index = [self stringIndexAtLocation:touchLocation];
  
  NSRange effectiveRange;
  NSURL *touchedURL = nil;
  
  if (index != NSNotFound)
    {
    touchedURL = [self.attributedText attribute:NSLinkAttributeName atIndex:index effectiveRange:&effectiveRange];
    }
  
  NSValue *rangeKeyForTouchPoint = [self rangeKeyForIndex:index];
  if (rangeKeyForTouchPoint == NULL) {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"if");
  }else {
    NSDictionary *patternObject = [self.patternDictionary objectForKey:rangeKeyForTouchPoint];
    PatternTapHandler action = [patternObject objectForKey:kPatternAction];
    if (action) {
      NSString *string = [self.attributedText.string substringWithRange:rangeKeyForTouchPoint.rangeValue];
      action (string);
    }
    NSLog(@"else");
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
}

- (NSUInteger)stringIndexAtLocation:(CGPoint)location {
  // Do nothing if we have no text
  if (self.textStorage.string.length == 0)
    {
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
  
  if (!CGRectContainsPoint(lineRect, location))
    {
    return NSNotFound;
    }
  
  return [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
}


+ (BOOL)requiresConstraintBasedLayout {
  return YES;
}

#pragma mark - Pattern matching
//Low level handler

- (void)enableDetectionForRange:(NSRange)range withAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)block {
  
  //Boundary conditions
  // Text length = 0
  // dictionary and action passed as nil
  if ((range.location + range.length <= self.attributedText.length)||(range.location + range.length <= self.text.length)) {
    NSMutableDictionary *pattern = [NSMutableDictionary new];
    [pattern setObject:dictionary ? dictionary : [NSNull null] forKey:kPatternAttribute];
    if (block) {
      [pattern setObject:block forKey:kPatternAction];
    }else {
      [pattern setObject:[NSNull null] forKey:kPatternAction];
    }
    [self.patternDictionary setObject:[NSDictionary dictionaryWithDictionary:pattern]
                               forKey:[NSValue valueWithRange:range]];
    [self applyAttributes:dictionary forRange:range];
  }else {
    NSAssert(@"Out of Bounds ", @"Range exceeds text length");

  }
  
//  if (text == nil) {
//    NSAssert(text not specified);
//  }
//  //check if the range exceeds from the text
//  NSAssert(out of bound);
//  
//  create range object --> key --> range
//  value -->{dictionary, action }
}

- (void)applyAttributes:(NSDictionary *)attributes forRange:(NSRange)range {
  if (attributes == nil) return;
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.textStorage];
  [attributedString addAttributes:attributes range:range];
  [self setAttributedText:attributedString];
}

- (NSValue *)rangeKeyForIndex:(NSInteger)index {
  NSArray *keys = [self.patternDictionary allKeys];
  NSInteger keyIndex = [keys indexOfObjectPassingTest:^BOOL(NSValue *key, NSUInteger idx, BOOL *stop) {
    NSRange range = key.rangeValue;
    return (index > range.location && index < range.location + range.length);
  }];

  if (keyIndex == NSNotFound) {
    return NULL;
  }else {
    return [keys objectAtIndex:keyIndex];
  }
}

//Higher level handler

- (void)enableDetectionForRegexString:(NSString *)string withAttributes:(NSDictionary*)dictionary withAction:action {
  NSError *error;
  NSRegularExpression	*regex = [[NSRegularExpression alloc] initWithPattern:string options:0 error:&error];
  NSArray *matches = [regex matchesInString:self.attributedText.string options:0 range:NSMakeRange(0, self.attributedText.length)];

  for (NSTextCheckingResult *match in matches) {
    NSRange matchRange = [match range];
    [self enableDetectionForRange:matchRange withAttributes:dictionary withAction:action];
 	}
}

- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {
  [self enableDetectionForRegexString:@"(?<!\\w)#([\\w\\_]+)?" withAttributes:dictionary withAction:action];
}

- (void)enableUserHandleDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {
  [self enableDetectionForRegexString:@"(?<!\\w)@([\\w\\_]+)?" withAttributes:dictionary withAction:action];
}

- (void)enableTruncationTokenDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {
  NSRange tokenRange = [self.textStorage.string rangeOfString:self.truncationToken];
  [self enableDetectionForRange:tokenRange withAttributes:dictionary withAction:action];
}

- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary withAction:(PatternTapHandler)action {  
  NSError *error = nil;
  NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
  NSString *plainText = self.textStorage.string;
  NSArray *matches = [detector matchesInString:plainText
                                       options:0
                                         range:NSMakeRange(0, self.textStorage.length)];
    for (NSTextCheckingResult *match in matches) {
    NSRange matchRange = [match range];
    NSString *realURL = [self.textStorage attribute:NSLinkAttributeName atIndex:matchRange.location effectiveRange:nil];
    if (realURL == nil) {
      realURL = [plainText substringWithRange:matchRange];
    }
    NSMutableDictionary *urlAttributes = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [urlAttributes setObject:NSLinkAttributeName forKey:realURL];
    [self enableDetectionForRange:matchRange withAttributes:urlAttributes withAction:action];
  }
}

@end
