//
//  NodeModel.h
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,NodeType){
    
    wolf,
    sheep,
    empty
};

typedef NS_ENUM(NSInteger,TapType){

    sameTap,//点了一样的
    errorTap,//无效点击
    rightTap//正确的点击
};

@interface NodeModel : NSObject

@property (nonatomic, assign) NodeType type;
@property (nonatomic, assign) int col;
@property (nonatomic, assign) int row;
@property (nonatomic, assign) BOOL isSelect;

- (TapType)tapTypeWithNode:(NodeModel *)node nodeList:(NSMutableArray *)nodeList;
- (void)exchangePositionWithNode:(NodeModel *)node;

@end
