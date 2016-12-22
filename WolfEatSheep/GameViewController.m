//
//  GameViewController.m
//  WolfEatSheep
//
//  Created by mal on 16/12/21.
//  Copyright © 2016年 mal. All rights reserved.
//

#import "GameViewController.h"
#import "UIView+Extension.h"
#import "MLSocketManager.h"

@interface GameViewController ()<GameViewDelegate>

@property (nonatomic, weak) GameView *gameView;

@end

@implementation GameViewController

+ (GameViewController *)gameVC
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpGameView];
    // Do any additional setup after loading the view.
}

- (void)setUpGameView
{
    GameView *gameView = [[GameView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    gameView.m_delegate = self;
    gameView.role = [MLSocketManager roleType];
    gameView.center = CGPointMake(self.view.width / 2, self.view.height / 2);
    [self.view addSubview:gameView];
    self.gameView = gameView;
}

#pragma mark - GameViewDelegate
- (void)exChangeIdx:(NSUInteger)idx withIdx:(NSUInteger)idx1
{
    NSString *message = [NSString stringWithFormat:@"%zd+%zd",idx,idx1];
    [[MLSocketManager shareManager] sendMessage:message];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
