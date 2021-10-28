//
//  CustomTableViewCell.h
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponsiveLabel.h"

@protocol CustomTableViewCellDelegate;

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ResponsiveLabel *customLabel;
@property (nonatomic, weak) id<CustomTableViewCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet ResponsiveLabel *secondaryLabel;

- (void)configureText:(NSString*)str forExpandedState:(BOOL)isExpanded;

@end

@protocol CustomTableViewCellDelegate<NSObject>

@optional
- (void)didTapOnMoreButton:(CustomTableViewCell *)cell;
- (void)customTableViewCell:(CustomTableViewCell *)cell didTapOnHashTag:(NSString *)hashTag;
- (void)customTableViewCell:(CustomTableViewCell *)cell didTapOnUserHandle:(NSString *)userHandle;
- (void)customTableViewCell:(CustomTableViewCell *)cell didTapOnURL:(NSString *)urlString;

@end