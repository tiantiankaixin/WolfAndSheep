//
//  NodeView.m
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import "NodeView.h"

@implementation NodeView

+ (NodeView *)nodeWithModel:(NodeModel *)model
{
    NodeView *nodeView = [[NodeView alloc] initWithFrame:CGRectMake(0, 0, NodeViewWH, NodeViewWH)];
    nodeView.layer.cornerRadius = NodeViewWH / 2;
    nodeView.layer.masksToBounds = YES;
    if (model.type == wolf)
    {
        nodeView.backgroundColor = [UIColor redColor];
    }
    else if(model.type == sheep)
    {
        nodeView.backgroundColor = [UIColor blueColor];
    }
    else
    {
        nodeView.backgroundColor = [UIColor clearColor];
    }
    nodeView.nodeModel = model;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nodeView action:@selector(tap:)];
    [nodeView addGestureRecognizer:tap];
    return nodeView;
}

- (void)tap:(UITapGestureRecognizer *)tapGes
{
    if ([self.m_delegate respondsToSelector:@selector(tapWithView:)])
    {
        [self.m_delegate tapWithView:self];
    }
}

- (void)selectView:(BOOL)isSelect
{
    self.nodeModel.isSelect = isSelect;
    if (isSelect)
    {
        self.layer.borderColor = [UIColor greenColor].CGColor;
        self.layer.borderWidth = 2;
    }
    else
    {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)setType:(NodeType)type
{
    self.nodeModel.type = type;
    if (type == empty)
    {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
