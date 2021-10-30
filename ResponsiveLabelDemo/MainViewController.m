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
@property (weak, nonatomic) IBOutlet UIButton *labelEnableButton;
@property (weak, nonatomic) IBOutlet UIButton *highlightButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self handleSegmentChange:nil];

  self.truncationEnableButton.selected = self.responsiveLabel.customTruncationEnabled;
  self.labelEnableButton.selected = self.responsiveLabel.enabled;
  
  PatternTapResponder stringTapAction = ^(NSString *tappedString) {
    NSLog(@"tapped string = %@",tappedString);
  };

  [self.responsiveLabel setHighlightedTextColor:[UIColor colorWithRed:229/255.0 green:120/255.0 blue:142/255.0 alpha:1]];

  // Add collapse token

  PatternTapResponder tap = ^(NSString *string) {
	self.responsiveLabel.numberOfLines = 4;
  };

  NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc]initWithAttributedString:self.responsiveLabel.attributedText];
  [finalString appendAttributedString:[[NSAttributedString alloc] initWithString:@"...Less"
						   attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
		  RLTapResponderAttributeName:tap}]];
  [self.responsiveLabel setAttributedText:finalString];

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
                                                               RLHighlightedBackgroundColorAttributeName:[UIColor blackColor],NSBackgroundColorAttributeName:[UIColor cyanColor],RLHighlightedBackgroundCornerRadius:@5,
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

- (IBAction)enableResponsiveLabel:(UIButton *)sender {
  sender.selected = !sender.selected;
  self.responsiveLabel.enabled = sender.selected;
  self.messageLabel.enabled = sender.selected;
}

- (IBAction)highlightLabel:(UIButton *)sender {
  sender.selected = !sender.selected;
  [self.responsiveLabel setHighlighted:sender.selected];
  [self.messageLabel setHighlighted:sender.selected];
}

- (IBAction)handleSegmentChange:(UISegmentedControl*)sender {
  switch (self.segmentControl.selectedSegmentIndex) {
    case 0: {        
      NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:@"...More"];

      PatternTapResponder tapAction = ^(NSString *tappedString) {
        self.messageLabel.text = @"You have tapped token string";
          if (self.responsiveLabel.numberOfLines == 0) {
            self.responsiveLabel.numberOfLines = 4;
          }else {
            self.responsiveLabel.numberOfLines = 0;
            [self.responsiveLabel layoutIfNeeded];
          }
//                                                self.responsiveLabel.customTruncationEnabled = NO;
//                                                [self.responsiveLabel setAttributedText:[self.responsiveLabel.attributedText wordWrappedAttributedString]withTruncation:NO];
            
        };

        [attribString addAttributes:@{NSForegroundColorAttributeName:[UIColor brownColor],
                                                 NSFontAttributeName:self.responsiveLabel.font,
                                         RLTapResponderAttributeName:tapAction}
                              range:NSMakeRange(0, attribString.length)];
        [self.responsiveLabel setAttributedTruncationToken:attribString];
        
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
