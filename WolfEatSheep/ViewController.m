//
//  ViewController.m
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extension.h"
#import "GameView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    GameView *gameView = [[GameView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    gameView.isPlaySelf = YES;
    gameView.center = CGPointMake(self.view.width / 2, self.view.height / 2);
    [self.view addSubview:gameView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
