//
//  HomePageViewController.h
//  DSQ
//
//  Created by mengyun on 2017/4/15.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTool.h"

@interface HomePageViewController : UIViewController
- (IBAction)Click:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *buttonAI;
@property (strong, nonatomic) IBOutlet UIButton *button2P;
@property (strong, nonatomic) IBOutlet UIButton *buttonNet;
@property (strong, nonatomic) IBOutlet UIButton *buttonSet;
//@property (nonatomic, strong) MCTool *mcTool;
@property (nonatomic,assign)int VCID;

@end
