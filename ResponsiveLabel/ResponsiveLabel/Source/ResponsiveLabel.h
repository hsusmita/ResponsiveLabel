//
//  ResponsiveLabel.h
//  ResponsiveLabel
//
//  Created by hsusmita on 13/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResponsiveLabel : UILabel

@property (nonatomic, strong) NSString *truncationToken;
- (void)setText:(NSString *)text AndTruncationToken:(NSString *)truncationToken;

@end
