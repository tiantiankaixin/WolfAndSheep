//
//  GameView.h
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NodeView.h"

@interface GameView : UIView

@property (nonatomic, assign) NodeType role;
@property (nonatomic, assign) BOOL isPlaySelf;
@property (nonatomic, assign) BOOL isCanMove;

@end