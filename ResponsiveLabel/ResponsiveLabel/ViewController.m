//
//  ViewController.m
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "ViewController.h"
#import "ResponsiveLabel.h"
#import "CustomTableViewCell.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet ResponsiveLabel *label;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.label.userInteractionEnabled =  YES;
  [self.label setText:@"A long text"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
  [cell.customLabel layoutIfNeeded];
  NSString *str = @"A long text #hashTag text www.google.com";
  for (NSInteger i = 0 ; i < indexPath.row ; i++) {
    str = [NSString stringWithFormat:@"%@ %@",str,@"A long text"];
  }
  str = [NSString stringWithFormat:@"%@ %ld",str,indexPath.row];
  [cell.customLabel enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} withAction:^(NSString *tappedString) {
    NSLog(@"Tap on hashtag = %@",tappedString);
  }];
  [cell.customLabel enableURLDetectionWithAttributes:@{NSForegroundColorAttributeName:[UIColor cyanColor],NSUnderlineStyleAttributeName:[NSNumber numberWithInt:1]} withAction:^(NSString *tappedString) {
    NSLog(@"URL tapped = %ld",indexPath.row);
  }];

 NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:@"...Read More."];
  [attribString addAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor]} range:NSMakeRange(0, 3)];
  [attribString addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]} range:NSMakeRange(3, @"...Read More".length -3)];
  
  [cell.customLabel enableTruncationTokenDetectionWithToken:attribString withAction:^(NSString *tappedString) {
    NSLog(@"read more");

  }];
  [cell.customLabel setText:str];
  
//  PatternTapHandler handler = ^(NSString *string ){
//    NSLog(@"read more");
//  };
//  NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc]initWithString:str];
//  [attributed addAttribute:RLTapResponderAttributeName value:handler range:NSMakeRange(0, 10)];
//  [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 10)];
//  cell.customLabel.attributedText = attributed;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 150.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  NSLog(@"did tap the cell");
  
}

@end
