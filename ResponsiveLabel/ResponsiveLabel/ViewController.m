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
  NSString *str = @"A long text";
  for (NSInteger i = 0 ; i < indexPath.row ; i++) {
    str = [NSString stringWithFormat:@"%@ %@",str,@"A long text"];
  }
  str = [NSString stringWithFormat:@"%@ %ld",str,indexPath.row];

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  NSLog(@"did tap the cell");
}

@end
