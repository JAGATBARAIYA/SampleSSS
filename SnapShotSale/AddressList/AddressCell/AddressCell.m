//
//  AddressCell.m
//  SnapShotSale
//
//  Created by Manish on 04/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import "AddressCell.h"
#import <objc/runtime.h>

#define kScreenBounds                           ([[UIScreen mainScreen] bounds])
#define kScreenWidth                            (kScreenBounds.size.width)
#define kScreenHeight                           (kScreenBounds.size.height)

CGFloat  firstX, firstY;
int intLastPanIndex;

@implementation AddressCell

- (void)awakeFromNib {
    self.roundedView.layer.cornerRadius = self.deleteView.layer.cornerRadius = 5.0;
    self.roundedView.layer.masksToBounds = self.deleteView.layer.masksToBounds = YES;
//    intLastPanIndex = 999;
//
//    for (UIGestureRecognizer *aRecognizer in self.roundedView.gestureRecognizers) {
//        [self.roundedView removeGestureRecognizer:aRecognizer];
//    }
//
//    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizer:)];
//    recognizer.delegate = self;
//    [self.roundedView addGestureRecognizer:recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UIEdgeInsets)layoutMargins{
    return UIEdgeInsetsZero;
}

//#pragma mark - Pan Gesture Recognizer
//
//- (void)panRecognizer:(UIPanGestureRecognizer *)recognizer {
//    UIPanGestureRecognizer *aRecognizer = (UIPanGestureRecognizer *)recognizer;
//
//    UIView *aPanView = aRecognizer.view;
//
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.roundedView setCenter:CGPointMake(kScreenWidth/2, self.roundedView.center.y)];
//    }];
//
//    NSIndexPath *aTblViewCurrentIndexPath = objc_getAssociatedObject(aPanView, @"Index");
//
//    CGPoint translatedPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self];
//    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateBegan) {
//        firstX = [[recognizer view] center].x;
//        firstY = [[recognizer view] center].y;
//    }
//
//    CGFloat finalX ;
//
//    finalX =  firstX+translatedPoint.x;
//
//    float aMaxPos = (kScreenWidth/2);
//    float aMinPos = (kScreenWidth/2)-55;
//
//    if (finalX >= aMaxPos)
//        finalX = aMaxPos;
//    else if (finalX<=aMinPos)
//        finalX = aMinPos;
//    else
//        finalX = aMinPos;
//
//    translatedPoint = CGPointMake(finalX, firstY);
//
//    [UIView animateWithDuration:0.2 animations:^{
//        [[recognizer view] setCenter:translatedPoint];
//    }];
//
//    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateEnded) {
//        translatedPoint = CGPointMake(finalX, firstY);
//        [[recognizer view] setCenter:translatedPoint];
//    }
//    intLastPanIndex = (int)aTblViewCurrentIndexPath.row;
//}
//
//#pragma mark UIGestureRecognizerDelegate Methods
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return NO;
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self];
//        BOOL shouldBegin = fabs(velocity.x) > fabs(velocity.y);
//        return shouldBegin;
//    }
//    return YES;
//}

@end
