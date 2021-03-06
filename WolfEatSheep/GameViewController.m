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

@interface GameViewController ()<GameViewDelegate,MLSocketManagerDelegate>

@property (nonatomic, weak) GameView *gameView;
@property (nonatomic, assign) MPlayType playType;

@end

@implementation GameViewController

+ (GameViewController *)gameVCWithPlayType:(MPlayType)type
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameViewController *gameVC = (GameViewController *)[storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    gameVC.playType = type;
    return gameVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpGameView];
}

- (void)setUpGameView
{
    GameView *gameView = [[GameView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    gameView.isPlaySelf = YES;
    gameView.m_delegate = self;
    gameView.role = wolf;
    gameView.isCanMove = YES;
//    gameView.role = [MLSocketManager roleType];
//    [MLSocketManager shareManager].m_delegate = self;
//    if (gameView.role == wolf)
//    {
//        gameView.isCanMove = YES;
//    }
    gameView.center = CGPointMake(self.view.width / 2, self.view.height / 2);
    [self.view addSubview:gameView];
    self.gameView = gameView;
}

#pragma mark - GameViewDelegate
- (void)exChangeIdx:(NSUInteger)idx withIdx:(NSUInteger)idx1
{
//    NSString *message = [NSString stringWithFormat:@"%zd+%zd",idx,idx1];
//    self.gameView.isCanMove = NO;
//    [[MLSocketManager shareManager] sendMessage:message];
}

#pragma mark - MLSocketManager delegate
- (void)receiveMessage:(NSString *)message
{
    NSArray *idxArray = [message componentsSeparatedByString:@"+"];
    if (idxArray.count == 2)
    {
        self.gameView.isCanMove = YES;
        NSInteger idx1 = [[idxArray firstObject] integerValue];
        NSInteger idx2 = [[idxArray lastObject] integerValue];
        [self.gameView exchangeWithIdx1:idx1 idx2:idx2];
    }
}

- (IBAction)reStartBtnClick:(UIButton *)sender
{
    [self.gameView reStart];
    self.gameView.role = wolf;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
