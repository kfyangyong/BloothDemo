//
//  UIView+TraverseViewController.h
//  YMFPaymentService
//
//  Created by ayong on 2018/4/9.
//  Copyright © 2018年 ayong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (TraverseViewController)

- (UIViewController *)firstAvailableUIViewController;
- (id)traverseResponderChainForUIViewController;


@end
