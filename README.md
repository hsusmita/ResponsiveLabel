[![Version](https://img.shields.io/badge/pod-1.0.11-green.svg)](https://cocoapods.org/pods/ResponsiveLabel/1.0.11/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://cocoapods.org/pods/ResponsiveLabel)
[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg?style=flat)](http://cocoadocs.org/docsets/ResponsiveLabel)

#ResponsiveLabel
A UILabel subclass which responds to touch on specified patterns. It has the following features:

1. It can detect pattern specified by regular expression and apply style like font, color etc.
2. It allows to replace default ellipse with tappable attributed string to mark truncation
3. Convenience methods are provided to detect hashtags, username handler and URLs

#Installation

Add following lines in your pod file  
pod 'ResponsiveLabel', '~> 1.0.11'

#Usage

The following snippets explain the usage of public methods. These snippets assume an instance of ResponsiveLabel named "customLabel". 
```objc
#import <ResponsiveLabel.h>
```

In interface builder, set the custom class of your UILabel to ResponsiveLabel. You may get an error message saying "error: IB Designables: Failed to update auto layout status: Failed to load designables from path (null)" This appears to be an issue with Xcode and Cocoapods and does not seem to cause any problems, but some have been able to fix it, see this [Stackoverflow question](http://stackoverflow.com/questions/28204108/ib-designables-failed-to-update-auto-layout-status-failed-to-load-designables) for more details.


#### Pattern Detection
```objc
//Detects email in text
NSString *emailRegexString = @"[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}";
NSError *error;
NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:emailRegexString
options:0
error:&error];
PatternDescriptor *descriptor = [[PatternDescriptor alloc]initWithRegex:regex withSearchType:PatternSearchTypeAll 
withPatternAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
[self.customLabel enablePatternDetection:descriptor];
```

#### String Detection
```objc
self.customLabel.userInteractionEnabled = YES;
PatternTapResponder tapResponder = ^(NSString *string) {
    NSLog(@"tapped = %@",string);
};
[self.customLabel enableStringDetection:@"text" withAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                                 RLTapResponderAttributeName: tapResponder}];
```

#### Array of String Detection
```objc
self.customLabel.userInteractionEnabled = YES;
PatternTapResponder stringTapAction = ^(NSString *tappedString) {
    NSLog(@"tapped string = %@",tappedString);
  };
[self.customLabel enableDetectionForStrings:@[@"text",@"long"] withAttributes:@{NSForegroundColorAttributeName:[UIColor brownColor],
                                                                                  RLTapResponderAttributeName:stringTapAction}];
```

#### HashTag Detection
```objc
self.customLabel.userInteractionEnabled = YES;
PatternTapResponder hashTagTapAction = ^(NSString *tappedString) {
NSLog(@"HashTag Tapped = %@",tappedString);
};
[self.customLabel enableHashTagDetectionWithAttributes:
@{NSForegroundColorAttributeName:[UIColor redColor], RLTapResponderAttributeName:hashTagTapAction}];
```   

#### Username Handle Detection

```objc
self.customLabel.userInteractionEnabled = YES;
PatternTapResponder userHandleTapAction = ^(NSString *tappedString){
NSLog(@"Username Handler Tapped = %@",tappedString);
};
[self.customLabel enableUserHandleDetectionWithAttributes:
@{NSForegroundColorAttributeName:[UIColor grayColor],RLTapResponderAttributeName:userHandleTapAction}];
```

#### URL Detection

```objc
self.customLabel.userInteractionEnabled = YES;
PatternTapResponder urlTapAction = ^(NSString *tappedString) {
NSLog(@"URL Tapped = %@",tappedString);
};
[self.customLabel enableURLDetectionWithAttributes:
@{NSForegroundColorAttributeName:[UIColor cyanColor],NSUnderlineStyleAttributeName:[NSNumber
numberWithInt:1],RLTapResponderAttributeName:urlTapAction}];
```
#### Highlight Patterns On Tap
To highlight patterns, one can set the attributes:
* RLHighlightedForegroundColorAttributeName
* RLHighlightedBackgroundColorAttributeName
* RLHighlightedBackgroundCornerRadius

```objc
self.customLabel.userInteractionEnabled = YES;
PatternTapResponder userHandleTapAction = ^(NSString *tappedString){
NSLog(@"Username Handler Tapped = %@",tappedString);
};
[self.customLabel enableUserHandleDetectionWithAttributes:
@{NSForegroundColorAttributeName:[UIColor grayColor],RLHighlightedForegroundColorAttributeName:[UIColor greenColor],RLHighlightedBackgroundCornerRadius:@5,RLHighlightedBackgroundColorAttributeName:[UIColor blackColor],RLTapResponderAttributeName:userHandleTapAction}];
```
#### Custom Truncation Token
##### Set attributed string as truncation token
##### Deprecated in 1.0.10

```objc
NSString *expansionToken = @"Read More ...";
NSString *str = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:kExpansionToken attributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:self.customLabel.font}];
[self.customLabel setAttributedTruncationToken:attribString withAction:^(NSString *tappedString) {
NSLog(@"Tap on truncation text");
}];
[self.customLabel setText:str withTruncation:YES];
```

##### Latest introduced on 1.0.10

```objc
NSString *expansionToken = @"Read More ...";
NSString *str = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
PatternTapResponder tap = ^(NSString *string) {
   NSLog(@"Tap on truncation text");
  }
NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:kExpansionToken attributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:self.customLabel.font,RLTapResponderAttributeName:tap}];
[self.customLabel setAttributedTruncationToken:attribString];
[self.customLabel setText:str withTruncation:YES];
```

##### Set image as truncation token
The height of image size should be approximately equal to or less than the font height. Otherwise the image will not be rendered properly
```objc
[self.customLabel setTruncationIndicatorImage:[UIImage imageNamed:@"more_image"] withSize:CGSizeMake(25, 5) andAction:^(NSString *tappedString) {
    NSLog(@"tapped on image");
 }];
```
##### Set from interface builder
<img src="https://cloud.githubusercontent.com/assets/3590619/8694465/df3c1bce-2afc-11e5-9409-78e82e1f294c.png" display="inline-block">

# Screenshots
<img src="https://cloud.githubusercontent.com/assets/3590619/7828584/f7ba853a-0452-11e5-9d6a-c9923d89ee8a.png" width="400" display="inline-block">
<img src="https://cloud.githubusercontent.com/assets/3590619/7828632/b0425196-0453-11e5-911a-79d56e7a8539.png" width="400" display="inline-block">

# References

The underlying implementation of ResponsiveLabel is based on KILabel(https://github.com/Krelborn/KILabel).
ResponsiveLabel is made flexible to enable detection of any pattern specified by regular expression.

The following articles were helpful in enhancing the functionalities. 

* http://www.cocoanetics.com/2015/03/customizing-uilabel-hyperlinks/
* http://www.cocoanetics.com/2015/03/tappable-uilabel-hyperlinks/
