//
//  CustomTableViewCell.m
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "CustomTableViewCell.h"

static NSString *kExpansionToken = @"...Read More";
static NSString *kCollapseToken = @"Read Less";

@implementation CustomTableViewCell

- (void)awakeFromNib {
  self.customLabel.userInteractionEnabled = YES;
  
  PatternTapResponder hashTagTapAction = ^(NSString *tappedString){
    if ([self.delegate respondsToSelector:@selector(customTableViewCell:didTapOnHashTag:)]) {
      [self.delegate customTableViewCell:self didTapOnHashTag:tappedString];
    }
  };
    PatternTapResponder action = ^(NSString *tappedString){
    //Action to be performed
    };
    [self.customLabel enableStringDetection:@"Tap Here" withAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                                        RLTapResponderAttributeName:action}];
  [self.customLabel enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],RLHighlightedBackgroundColorAttributeName:[UIColor orangeColor],
                                                           RLTapResponderAttributeName:hashTagTapAction}];
 
  PatternTapResponder urlTapAction = ^(NSString *tappedString) {
    if ([self.delegate respondsToSelector:@selector(customTableViewCell:didTapOnURL:)]) {
      [self.delegate customTableViewCell:self didTapOnURL:tappedString];
    }
  };
  [self.customLabel enableURLDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor cyanColor],
                                                       NSUnderlineStyleAttributeName:[NSNumber numberWithInt:1],
                                                       RLTapResponderAttributeName:urlTapAction}];
	
  PatternTapResponder userHandleTapAction = ^(NSString *tappedString){
    if ([self.delegate respondsToSelector:@selector(customTableViewCell:didTapOnUserHandle:)]) {
    [self.delegate customTableViewCell:self didTapOnUserHandle:tappedString];
  }};
  
	[self.customLabel enableUserHandleDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                              RLHighlightedForegroundColorAttributeName:[UIColor greenColor],RLHighlightedBackgroundColorAttributeName:[UIColor blackColor],
                             	                                 RLTapResponderAttributeName:userHandleTapAction}];
  
  NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:kExpansionToken];
  [attribString addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:self.customLabel.font}
                        range:NSMakeRange(3, kExpansionToken.length - 3)];
  [self.customLabel setAttributedTruncationToken:attribString withAction:^(NSString *tappedString) {
    if ([self.delegate respondsToSelector:@selector(didTapOnMoreButton:)]) {
      [self.delegate didTapOnMoreButton:self];
    }
  }];
  PatternTapResponder stringTapAction = ^(NSString *tappedString) {
    NSLog(@"tapped string = %@",tappedString);
  };
//  [self.customLabel enableDetectionForStrings:@[@"text",@"long"] withAttributes:@{NSForegroundColorAttributeName:[UIColor brownColor],
//                                                                                  RLTapResponderAttributeName:stringTapAction}];
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configureText:(NSString*)str forExpandedState:(BOOL)isExpanded {
  NSMutableAttributedString *finalString;
  if (isExpanded) {
    NSString *expandedString = [NSString stringWithFormat:@"%@%@",str,kCollapseToken];
    finalString = [[NSMutableAttributedString alloc]initWithString:expandedString attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    PatternTapResponder tap = ^(NSString *string) {
      if ([self.delegate respondsToSelector:@selector(didTapOnMoreButton:)]) {
        [self.delegate didTapOnMoreButton:self];
      }
    };
    [finalString addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],RLTapResponderAttributeName:tap}
                         range:[expandedString rangeOfString:kCollapseToken]];
    [finalString addAttributes:@{NSFontAttributeName:self.customLabel.font} range:NSMakeRange(0, finalString.length)];
    self.customLabel.numberOfLines = 0;
//    self.customLabel.customTruncationEnabled = NO;
//    self.customLabel.attributedText = finalString;
    [self.customLabel setAttributedText:finalString withTruncation:NO];

  }else {
    self.customLabel.numberOfLines = 3;
    self.customLabel.text = str;
//    self.customLabel.customTruncationEnabled = YES;
    [self.customLabel setText:str withTruncation:YES];
  }
}

@end
