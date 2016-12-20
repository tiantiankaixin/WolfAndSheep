//
//  NodeModel.m
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import "NodeModel.h"

@implementation NodeModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"{%zd %zd %zd}",self.row,self.col,self.type];
}

- (TapType)tapTypeWithNode:(NodeModel *)node nodeList:(NSMutableArray *)nodeList
{
    //到这儿判断的都是选中一个了的 并且不会选择相同节点
    TapType tapType = errorTap;
    if (self.type == node.type)//点了相同的
    {
        tapType = sameTap;
    }
    else
    {
        if(node.type == empty)//点了个空节点
        {
            if(self.row == node.row)
            {
                if (ABS(self.col - node.col) == 1)
                {
                    tapType = rightTap;
                }
            }
            else if (self.col == node.col)
            {
                if (ABS(self.row - node.row) == 1)
                {
                    tapType = rightTap;
                }
            }
        }
        else if (node.type == sheep)
        {
            int centerIndex = -1;
            if(self.row == node.row)
            {
                if (ABS(self.col - node.col) == 2)
                {
                    int centerCol = MAX(self.col - 1, node.col - 1);
                    centerIndex = centerCol + self.row * 5;
                }
            }
            else if (self.col == node.col)
            {
                if (ABS(self.row - node.row) == 2)
                {
                    int centerRow = MAX(self.row - 1, node.row - 1);
                    centerIndex = self.col + centerRow * 5;
                }
            }
            if (centerIndex > 0 && centerIndex < nodeList.count)
            {
                NodeModel *centerNode = nodeList[centerIndex];
                if (centerNode.type == empty)
                {
                    tapType = rightTap;
                }
            }
        }
    }
    return tapType;
}

- (void)exchangePositionWithNode:(NodeModel *)node
{
    int row = node.row;
    int col = node.col;
    node.row = self.row;
    node.col = self.col;
    self.row = row;
    self.col = col;
}

@end
