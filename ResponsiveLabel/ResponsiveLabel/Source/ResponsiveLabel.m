//
//  ResponsiveLabel.m
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "ResponsiveLabel.h"

const NSString *kPatternAttribute = @"PatternAttribue";
const NSString *kPatternAction  = @"PatternAction";

static NSString *kRegexStringForHashTag = @"(?<!\\w)#([\\w\\_]+)?";
static NSString *kRegexStringForUserHandle = @"(?<!\\w)@([\\w\\_]+)?";
static NSString *kRegexFormatForSearchWord = @"(%@)";

@interface ResponsiveLabel ()<NSLayoutManagerDelegate>

@property (nonatomic, retain) NSLayoutManager *layoutManager;
@property (nonatomic, retain) NSTextContainer *textContainer;
@property (nonatomic, retain) NSTextStorage *textStorage;

@property (nonatomic, strong) UIColor *selectedLinkBackgroundColor;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, strong) NSMutableArray *patternDescriptors;
@property (nonatomic, strong) NSAttributedString *attributedTruncationToken;


@end

@implementation ResponsiveLabel

#pragma mark - Initializers

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

- (void)setText:(NSString *)text {
  [self setText:text withTruncation:NO];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
  [self setAttributedText:attributedText withTruncation:NO];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
  [super setNumberOfLines:numberOfLines];
  _textContainer.maximumNumberOfLines = numberOfLines;
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

+ (BOOL)requiresConstraintBasedLayout {
  return YES;
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

- (void)appendTokenToText:(NSString *)currentText {
  NSRange tokenRange = NSMakeRange(NSNotFound, 0);
  NSString *stringToDisplay = currentText;
  if ([self isNewLinePresent:currentText]) {
    //Append token string at the end of last visible line
    [self.textStorage replaceCharactersInRange:[self rangeForTokenInsertionForStringWithNewLine:currentText]
                          withAttributedString:self.attributedTruncationToken];
    stringToDisplay = self.textStorage.string;
  }
  //Check for truncation range and append truncation token if required
  tokenRange = [self rangeForTokenInsertion:stringToDisplay];
  if (tokenRange.location != NSNotFound) {
    [self.textStorage replaceCharactersInRange:tokenRange withAttributedString:self.attributedTruncationToken];
  }
}

- (NSRange)rangeForTokenInsertion:(NSString *)text {
  NSInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:text.length - 1];
  NSRange range = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphIndex];
  if (range.location != NSNotFound) {
    range.length += self.attributedTruncationToken.length;
    range.location -= self.attributedTruncationToken.length;
  }
  return range;
}

- (NSRange)rangeForTokenInsertionForStringWithNewLine:(NSString *)text {
  NSRange rangeOfText = NSMakeRange(NSNotFound, 0);
  NSInteger numberOfLines, index, numberOfGlyphs = [self.layoutManager numberOfGlyphs];
  NSRange lineRange;
  NSInteger approximateNumberOfLines = CGRectGetHeight([self.layoutManager usedRectForTextContainer:self.textContainer])/self.font.lineHeight;
  
  for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
    [self.layoutManager lineFragmentRectForGlyphAtIndex:index
                                         effectiveRange:&lineRange];
      if (numberOfLines == approximateNumberOfLines - 1) break;
      index = NSMaxRange(lineRange);
    }
  rangeOfText = NSMakeRange(lineRange.location + lineRange.length - 1, self.textStorage.length - lineRange.location - lineRange.length + 1);
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
  NSRange patternRange;
  PatternTapResponder tapHandler = [self tapResponderAtIndex:index effectiveRange:&patternRange];
  if (!tapHandler) {
    [super touchesEnded:touches withEvent:event];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[touches anyObject] locationInView:self];
  NSInteger index = [self stringIndexAtLocation:touchLocation];
  NSRange patternRange;
  PatternTapResponder tapHandler = [self tapResponderAtIndex:index effectiveRange:&patternRange];
  if (tapHandler) {
    tapHandler([self.textStorage.string substringWithRange:patternRange]);
  }else {
    [super touchesEnded:touches withEvent:event];
  }
}

#pragma mark - Pattern matching

- (void)generateRangesForPatterns {
  NSRange truncationRange = [self truncationRange];
  [self.patternDescriptors enumerateObjectsUsingBlock:^(PatternDescriptor *descriptor, NSUInteger idx, BOOL *stop) {
    NSArray *ranges = [descriptor patternRangesForString:self.textStorage.string];
    [ranges enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
      BOOL doesIntesectTruncationRange = (NSIntersectionRange(obj.rangeValue, truncationRange).length == 0);
      BOOL isTruncationRange = NSEqualRanges(obj.rangeValue, truncationRange);
      if (doesIntesectTruncationRange || isTruncationRange) {
        if (descriptor.patternAttributes)
          [self.textStorage addAttributes: descriptor.patternAttributes range:obj.rangeValue];
      }
    }];
  }];
}

#pragma mark - Helper Methods

- (NSUInteger)stringIndexAtLocation:(CGPoint)location {
  NSUInteger stringIndex = NSNotFound;
  if (self.textStorage.string.length > 0) {
    NSUInteger glyphIndex = [self glyphIndexForLocation:location];
    // If the touch is in white space after the last glyph on the line we don't
    // count it as a hit on the text
    NSRange lineRange;
    CGRect lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex
                                                               effectiveRange:&lineRange];
    lineRect.size.height = 60;  //Adjustment to increase tap area
    if (CGRectContainsPoint(lineRect, location)) {
      stringIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    }
  }
  return stringIndex;
}

- (NSUInteger)glyphIndexForLocation:(CGPoint)location {
  // Work out the offset of the text in the view
  CGPoint textOffset;
  NSRange glyphRange = [self.layoutManager
                        glyphRangeForTextContainer:self.textContainer];
  textOffset = [self calcTextOffsetForGlyphRange:glyphRange];
  
  // Get the touch location and use text offset to convert to text cotainer coords
  location.x -= textOffset.x;
  location.y -= textOffset.y;
  
  return  [self.layoutManager glyphIndexForPoint:location
                                 inTextContainer:self.textContainer];
}

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

- (PatternTapResponder)tapResponderAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)patternRange {
  PatternTapResponder tapResponder = nil;
  if (index < self.textStorage.length) {
    tapResponder =[self.textStorage attribute:RLTapResponderAttributeName atIndex:index effectiveRange:patternRange];
  }
  return tapResponder;
}

- (BOOL)isNewLinePresent:(NSString *)currentText {
  NSRange newLineRange = [currentText rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
  return (newLineRange.location != NSNotFound);
}

- (NSRange)truncationRange {
  NSRange truncationRange = NSMakeRange(NSNotFound, 0);
  if (self.attributedTruncationToken) {
    truncationRange = [self.textStorage.string rangeOfString:self.attributedTruncationToken.string];
  }
  return truncationRange;
}

#pragma mark - Public Methods

- (void)setText:(NSString *)text withTruncation:(BOOL)truncation {
  [super setText:text];
  NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                       attributes:[self attributesFromProperties]];
  [self setAttributedText:attributedText withTruncation:truncation];
}

- (void)setAttributedText:(NSAttributedString *)attributedText withTruncation:(BOOL)truncation {
  [super setAttributedText:attributedText];
  [self.textStorage setAttributedString:attributedText];
  
  if (truncation && self.attributedText.length > 0) {
    [self appendTokenToText:self.attributedText.string];
  }
  [self generateRangesForPatterns];
}

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken withAction:(PatternTapResponder)action {
  self.attributedTruncationToken = attributedTruncationToken;
  NSError *error;
  NSString *pattern = [NSString stringWithFormat:kRegexFormatForSearchWord,self.attributedTruncationToken.string];
  NSRegularExpression	*regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:PatternSearchTypeLast
                                                    withPatternAttributes:@{RLTapResponderAttributeName:action}];
  [self enablePatternDetection:descriptor];
}

- (void)enableURLDetectionWithAttributes:(NSDictionary*)dictionary {
  NSError *error = nil;
  NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:detector
                                                           withSearchType:PatternSearchTypeAll
                                                    withPatternAttributes:dictionary];
  [self enablePatternDetection:descriptor];
}

- (void)enableHashTagDetectionWithAttributes:(NSDictionary*)dictionary {
  NSError *error;
  NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:kRegexStringForHashTag options:0 error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:PatternSearchTypeAll
                                                    withPatternAttributes:dictionary];
  [self enablePatternDetection:descriptor];
}

- (void)enableUserHandleDetectionWithAttributes:(NSDictionary*)dictionary{
  NSError *error;
  NSRegularExpression	*regex = [[NSRegularExpression alloc]initWithPattern:kRegexStringForUserHandle
                                                                   options:0
                                                                     error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex
                                                           withSearchType:PatternSearchTypeAll
                                                    withPatternAttributes:dictionary];
  [self enablePatternDetection:descriptor];
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

- (void)enablePatternDetection:(PatternDescriptor *)patternDescriptor {
  [self.patternDescriptors addObject:patternDescriptor];
}

@end
