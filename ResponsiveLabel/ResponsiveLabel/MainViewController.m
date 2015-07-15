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


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//  [self handleSegmentChange:nil];
  [self.responsiveLabel setTruncationIndicatorImage:[UIImage imageNamed:@"check"] withSize:CGSizeMake(55, 10) andAction:^(NSString *tappedString) {
    NSLog(@"tapped on image");
  }];
      // Do any additional setup after loading the view.
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
  [self.responsiveLabel enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],RLHighlightedBackgroundColorAttributeName:[UIColor orangeColor],
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
                                                                RLHighlightedForegroundColorAttributeName:[UIColor greenColor],RLHighlightedBackgroundColorAttributeName:[UIColor blackColor],
                                                                    RLTapResponderAttributeName:userHandleTapAction}];
  }else {
    [self.responsiveLabel disableUserHandleDetection];
  }
  
}

- (IBAction)enableURLButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  if (sender.selected) {
    PatternTapResponder URLTapAction = ^(NSString *tappedString){
      NSLog(@"URL enabled");
    };
    [self.responsiveLabel enableURLDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor], RLTapResponderAttributeName:URLTapAction}];
  }else {
    [self.responsiveLabel disableURLDetection];
  }
}


- (IBAction)handleSegmentChange:(UISegmentedControl*)sender {
  NSLog(@"tapped truncate");
  switch (self.segmentControl.selectedSegmentIndex) {
    case 0:
      [self.responsiveLabel setAttributedTruncationToken:[[NSAttributedString alloc]initWithString:@"...More"
                                                                                        attributes:@{NSFontAttributeName:self.responsiveLabel.font,NSForegroundColorAttributeName:[UIColor greenColor]}]
                                              withAction:^(NSString *tappedString) {
                                                NSLog(@"get more");
                                              }];
      break;
    case 1:
      [self.responsiveLabel setTruncationIndicatorImage:[UIImage imageNamed:@"check"] withSize:CGSizeMake(55, 10) andAction:^(NSString *tappedString) {
        NSLog(@"tapped on image");
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
