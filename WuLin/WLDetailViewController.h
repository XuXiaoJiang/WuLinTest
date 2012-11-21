//
//  WLDetailViewController.h
//  WuLin
//
//  Created by Xu Xiaojiang on 21/11/12.
//  Copyright (c) 2012 must2334. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
