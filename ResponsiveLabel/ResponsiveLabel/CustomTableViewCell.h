//
//  CustomTableViewCell.h
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponsiveLabel.h"

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ResponsiveLabel *customLabel;

@end
