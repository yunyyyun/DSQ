//
//  HomePageViewController.m
//  DSQ
//
//  Created by mengyun on 2017/4/15.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "HomePageViewController.h"
#import "GameViewController.h"
#import "MCTool.h"
#import "Common.h"

@interface HomePageViewController ()<MCToolDelegate>

@end

@implementation HomePageViewController

//- (MCTool *)mcTool {
//    
//    if (!_mcTool) {
//        _mcTool = [MCTool tool];
//        //_mcTool.delegate = self;
//    }
//    _mcTool.delegate = self;
//    return _mcTool;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self roundView:_buttonAI];
    [self roundView:_button2P];
    [self roundView:_buttonNet];
    [self roundView:_buttonSet];
    _VCID = 0;
    //[MCTool sharedTool].delegate = self;
    self.navigationItem.title = @"动物棋翻牌版";
}

- (void)viewWillAppear:(BOOL)animated{
    [MCTool sharedTool].delegate = self;
}

- (void)roundView:(UIView *)view{
    
    [view.layer setCornerRadius:4];
    [view.layer setMasksToBounds:YES];
    
    [view.layer setBorderWidth:2.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 11.0/255.0, 44.0/255.0, 77.0/255.0, 1 });
    [view.layer setBorderColor:colorref];//边框颜色
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)Click:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 1:
        {
            GameViewController *gameVC = [[GameViewController alloc]init];
            gameVC.gameType = PLAYING_AGAINST_AI;
            [self.navigationController pushViewController:gameVC animated:YES];
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
        }

            break;
        case 2:
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择双人对战模式" message:@"无线对战需要使用蓝牙连接，或者双方处于同一个局域网" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *WifiOrBluetoothAction = [UIAlertAction actionWithTitle:@"无线对战" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                MCTool *tool = [MCTool sharedTool];
                tool.browser = [tool browser];
                [self presentViewController:tool.browser animated:YES completion:^{
                }];

            }];
            UIAlertAction *sharedScreenAction = [UIAlertAction actionWithTitle:@"同屏对战" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                GameViewController *gameVC = [[GameViewController alloc]init];
                gameVC.gameType = PLAYING_AGAINST_PEOPLE_IN_SAME_VIEW;
                [self.navigationController pushViewController:gameVC animated:YES];
                self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:WifiOrBluetoothAction];
            [alertController addAction:sharedScreenAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case 3:
        {
            GameViewController *gameVC = [[GameViewController alloc]init];
            gameVC.gameType = PLAYING_AGAINST_PEOPLE_ON_THE_INTERNET;
            [self.navigationController pushViewController:gameVC animated:YES];
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - MCToolDelegate
- (void)browserControllerConnectedConfirm {
    GameViewController *gameVC = [[GameViewController alloc]init];
    gameVC.gameType = PLAYING_AGAINST_PEOPLE_ON_A_LAN;
    gameVC.chessboard.youFirst = 1;
    [self.navigationController pushViewController:gameVC animated:YES];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
}
@end












