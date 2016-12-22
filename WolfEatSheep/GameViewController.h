//
//  GameViewController.h
//  WolfEatSheep
//
//  Created by mal on 16/12/21.
//  Copyright © 2016年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameView.h"

@interface GameViewController : UIViewController

@property (nonatomic, assign) NodeType type;

+ (GameViewController *)gameVC;

@end
