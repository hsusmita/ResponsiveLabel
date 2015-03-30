//
//  CustomTableViewCell.h
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponsiveLabel.h"
#import "KILabel.h"

@protocol CustomTableViewCellDelegate;

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ResponsiveLabel *customLabel;

@property (nonatomic, weak) id<CustomTableViewCellDelegate>delegate;

- (void)configureText:(NSString*)str forExpandedState:(BOOL)isExpanded;
@end

@protocol CustomTableViewCellDelegate<NSObject>

- (void)didTapOnMoreButton:(CustomTableViewCell *)cell;

@end