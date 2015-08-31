//
//  MainViewController.m
//  ResponsiveLabel
//
//  Created by hsusmita on 15/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "MainViewController.h"
#import "ResponsiveLabel.h"
#import "NSAttributedString+Processing.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet ResponsiveLabel *responsiveLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *truncationEnableButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self handleSegmentChange:nil];
 
  self.truncationEnableButton.selected = self.responsiveLabel.customTruncationEnabled;
  PatternTapResponder stringTapAction = ^(NSString *tappedString) {
    NSLog(@"tapped string = %@",tappedString);
  };
  NSError *error;
  NSRegularExpression *expression = [[NSRegularExpression alloc]initWithPattern:@"(\"\\w+\")" options:NSRegularExpressionCaseInsensitive error:&error];
  PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:expression
                                                           withSearchType:PatternSearchTypeAll withPatternAttributes:@{NSForegroundColorAttributeName:[UIColor brownColor],RLTapResponderAttributeName:stringTapAction}];
  [self.responsiveLabel enablePatternDetection:descriptor];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableHashTagButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  if (sender.selected) {
  PatternTapResponder hashTagTapAction = ^(NSString *tappedString){
    self.messageLabel.text = [NSString stringWithFormat:@"You have tapped hashTag: %@",tappedString];
  };
  [self.responsiveLabel enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                    RLHighlightedBackgroundColorAttributeName:[UIColor blackColor],
                                                                  RLTapResponderAttributeName:hashTagTapAction}];
  }else {
    [self.responsiveLabel disableHashTagDetection];
  }
}

- (IBAction)enableUserhandleButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  if (sender.selected) {
    PatternTapResponder userHandleTapAction = ^(NSString *tappedString){
      self.messageLabel.text = [NSString stringWithFormat:@"You have tapped user handle: %@",tappedString];
    };
    
    [self.responsiveLabel enableUserHandleDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                         RLHighlightedForegroundColorAttributeName:[UIColor greenColor],
                                                         RLHighlightedBackgroundColorAttributeName:[UIColor blackColor],
                                                                       RLTapResponderAttributeName:userHandleTapAction}];
  }else {
    [self.responsiveLabel disableUserHandleDetection];
  }
  
}

- (IBAction)enableURLButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  if (sender.selected) {
    PatternTapResponder URLTapAction = ^(NSString *tappedString){
      self.messageLabel.text = [NSString stringWithFormat:@"You have tapped URL: %@",tappedString];
    };
    [self.responsiveLabel enableURLDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],
                                                             RLTapResponderAttributeName:URLTapAction}];
  }else {
    [self.responsiveLabel disableURLDetection];
  }
}


- (IBAction)handleSegmentChange:(UISegmentedControl*)sender {
  switch (self.segmentControl.selectedSegmentIndex) {
    case 0: {
      [self.responsiveLabel setAttributedTruncationToken:[[NSAttributedString alloc]initWithString:@"...More"
                                                                                        attributes:@{NSFontAttributeName:self.responsiveLabel.font,NSForegroundColorAttributeName:[UIColor brownColor]}]
                                              withAction:^(NSString *tappedString) {
                                                self.messageLabel.text = @"You have tapped token string";
                                                if (self.responsiveLabel.numberOfLines == 0) {
                                                  self.responsiveLabel.numberOfLines = 4;
                                                }else {
                                                  self.responsiveLabel.numberOfLines = 0;
                                                  [self.responsiveLabel layoutIfNeeded];
                                                }
//                                                self.responsiveLabel.customTruncationEnabled = NO;
//                                                [self.responsiveLabel setAttributedText:[self.responsiveLabel.attributedText wordWrappedAttributedString]withTruncation:NO];
                                                
                                              }];
      break;
    }
    case 1:{
      [self.responsiveLabel setTruncationIndicatorImage:[UIImage imageNamed:@"Add-Caption-Plus"]
                                               withSize:CGSizeMake(22,self.responsiveLabel.font.lineHeight)
                                              andAction:^(NSString *tappedString) {
        self.messageLabel.text = @"You have tapped token image";
      }];
     break;
    }
    default:
      break;
  }
}

- (IBAction)enableTruncation:(UIButton *)sender {
  sender.selected = !sender.selected;
  self.responsiveLabel.customTruncationEnabled = sender.selected;
}

@end
