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

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,CustomTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet ResponsiveLabel *label;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *expandedIndexPaths;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.label.userInteractionEnabled =  YES;
  [self.label setText:@"ResponsiveLabel Usage" withTruncation:NO];
  self.expandedIndexPaths = [NSMutableArray array];
  self.tableView.estimatedRowHeight = 50.0f;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
  [cell.customLabel layoutIfNeeded];
  NSString *str = @"A long text with #hashTag text, with @username and URL http://www.google.com ";
  for (NSInteger i = 0 ; i < indexPath.row ; i++) {
    str = [NSString stringWithFormat:@"%@ %@",str,@"A long text\n"];
  }
  str = [NSString stringWithFormat:@"%@",str];
  [cell configureText:str forExpandedState:[self.expandedIndexPaths containsObject:indexPath]];
  
  cell.delegate = self;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self.expandedIndexPaths containsObject:indexPath]) {
    return UITableViewAutomaticDimension;
  }else {
    return 100.0;
  }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  NSLog(@"did tap the cell");
  
}

- (void)didTapOnMoreButton:(CustomTableViewCell *)cell {
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
  if (indexPath == nil)return;
  if ([self.expandedIndexPaths containsObject:indexPath]) {
    [self.expandedIndexPaths removeObject:indexPath];
  }else {
    [self.expandedIndexPaths addObject:indexPath];
  }
  [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)customTableViewCell:(CustomTableViewCell *)cell didTapOnHashTag:(NSString *)hashTag {
  NSString *message = [NSString stringWithFormat:@"You have tapped hashTag = %@!",hashTag];
  [self showAlertWithMessage:message];
}

- (void)customTableViewCell:(CustomTableViewCell *)cell didTapOnUserHandle:(NSString *)userHandle {
  NSString *message = [NSString stringWithFormat:@"You have tapped user handle = %@!",userHandle];
  [self showAlertWithMessage:message];
}

- (void)customTableViewCell:(CustomTableViewCell *)cell didTapOnURL:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  if ([[UIApplication sharedApplication] canOpenURL:url]){
    [[UIApplication sharedApplication] openURL:url];
  }
  else {
    [self showAlertWithMessage:@"The selected link cannot be opened."];
  }
}

- (void)showAlertWithMessage:(NSString *)message {
  UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Message" message:message preferredStyle:UIAlertControllerStyleAlert];
  [self presentViewController:controller animated:YES completion:nil];
  UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    [controller dismissViewControllerAnimated:YES completion:nil];
  }];
  [controller addAction:action];
}

@end
