//
//  TouchGestureRecognizer.m
//  ResponsiveLabel
//
//  Created by hsusmita on 17/03/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "TouchGestureRecognizer.h"

@interface TouchGestureRecognizer()

@property (nonatomic, readwrite) UIGestureRecognizerState state;

@end

@implementation TouchGestureRecognizer

@synthesize state;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.state = UIGestureRecognizerStateCancelled;
}


@end
