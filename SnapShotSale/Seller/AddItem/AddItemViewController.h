//
//  AddItemViewController.h
//  SnapShotSale
//
//  Created by Manish on 11/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPlaceholderTextView.h"

@interface AddItemViewController : UIViewController
{
    __weak IBOutlet LPlaceholderTextView *_textView;
}

- (void)uploadImages;

@end
