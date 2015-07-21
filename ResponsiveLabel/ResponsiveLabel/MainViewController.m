//
//  MainViewController.m
//  ResponsiveLabel
//
//  Created by sah-fueled on 15/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "MainViewController.h"
#import "ResponsiveLabel.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet ResponsiveLabel *responsiveLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *truncationEnableButton;


@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self handleSegmentChange:nil];
  self.truncationEnableButton.selected = self.responsiveLabel.customTruncationEnabled;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)enableHashTagButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  if (sender.selected) {
  PatternTapResponder hashTagTapAction = ^(NSString *tappedString){
    NSLog(@"hash tag enabled");
  };
  [self.responsiveLabel enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                    RLHighlightedBackgroundColorAttributeName:[UIColor orangeColor],
                                                                  RLTapResponderAttributeName:hashTagTapAction}];
  }else {
    [self.responsiveLabel disableHashTagDetection];
  }
}

- (IBAction)enableUserhandleButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  if (sender.selected) {
    PatternTapResponder userHandleTapAction = ^(NSString *tappedString){
      NSLog(@"userhandle enabled");
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
      NSLog(@"URL enabled= %@",tappedString);
    };
    [self.responsiveLabel enableURLDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor], RLTapResponderAttributeName:URLTapAction}];
  }else {
    [self.responsiveLabel disableURLDetection];
  }
}


- (IBAction)handleSegmentChange:(UISegmentedControl*)sender {
  switch (self.segmentControl.selectedSegmentIndex) {
    case 0: {
      [self.responsiveLabel setAttributedTruncationToken:[[NSAttributedString alloc]initWithString:@"...More"
                                                                                        attributes:@{NSFontAttributeName:self.responsiveLabel.font,NSForegroundColorAttributeName:[UIColor greenColor]}]
                                              withAction:^(NSString *tappedString) {
                                                NSLog(@"get more");
                                              }];
      break;
    }
    case 1:
//      [self.responsiveLabel setTruncationIndicatorImage:[UIImage imageNamed:@"Add-Caption-Plus"] withSize:CGSizeMake(20,20) andAction:^(NSString *tappedString) {
//        NSLog(@"tapped on image");
//      }];
      [self.responsiveLabel setAttributedTruncationToken:[[NSAttributedString alloc]initWithString:@"...Less"
                                                                                        attributes:@{NSFontAttributeName:self.responsiveLabel.font,NSForegroundColorAttributeName:[UIColor greenColor]}]
                                              withAction:^(NSString *tappedString) {
                                                NSLog(@"get more");
                                              }];
      break;
      
    default:
      break;
  }

}

- (IBAction)enableTruncation:(UIButton *)sender {
  sender.selected = !sender.selected;
  self.responsiveLabel.customTruncationEnabled = sender.selected;
}

@end
