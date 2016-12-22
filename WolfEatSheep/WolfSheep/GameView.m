//
//  GameView.m
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import "GameView.h"
#import "UIView+Extension.h"

#define LineBgColor [UIColor blackColor]
#define LineWidth 1

typedef NS_ENUM(NSInteger,LineDirection){
    
    v_line,
    h_line
};

@interface GameView()<NodeViewDelegate>

@property (nonatomic, strong) NSMutableArray *nodeArray;
@property (nonatomic, strong) NSMutableArray *nodeViewArray;
@property (nonatomic, strong) NSMutableArray *selectNodeViewArray;

@end

@implementation GameView

//MARK: get
- (NSMutableArray *)selectNodeViewArray
{
    if (_selectNodeViewArray == nil)
    {
        _selectNodeViewArray = [[NSMutableArray alloc] init];
    }
    return _selectNodeViewArray;
}

- (NSMutableArray *)nodeViewArray
{
    if (_nodeViewArray == nil)
    {
        _nodeViewArray = [NSMutableArray array];
    }
    return _nodeViewArray;
}

- (NSMutableArray *)nodeArray
{
    if (_nodeArray == nil)
    {
        _nodeArray = [NSMutableArray array];
    }
    return _nodeArray;
}

- (UIView *)lineViewWithDirection:(LineDirection)direction
{
    UIView *lineView = [[UIView alloc] init];
    if(direction == h_line)
    {
        lineView.height = LineWidth;
        lineView.width = self.width - NodeViewWH;
    }
    else if (direction == v_line)
    {
        lineView.width = LineWidth;
        lineView.height = self.height - NodeViewWH;
    }
    lineView.backgroundColor = LineBgColor;
    return lineView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setUpView];
    }
    return self;
}

//MARK: 生成数据源
- (void)createDataSource
{
    for (int row = 0; row < 5; row++)
    {
        for (int col = 0; col < 5; col++)
        {
            NodeModel *node = [[NodeModel alloc] init];
            node.type = empty;
            node.row = row;
            node.col = col;
            if (row > 1)
            {
                node.type = sheep;
            }
            else if(row == 0)
            {
                if (col > 0 && col < 4)
                {
                    node.type = wolf;
                }
            }
            [self.nodeArray addObject:node];
        }
    }
}

//MARK: 两个棋子之间的间隔
- (CGFloat)nodeMargin
{
    return (self.width - NodeViewWH) / 4;
}

//MARK: 生成棋盘
- (void)createQiPan
{
    CGFloat margin = [self nodeMargin];
    for (int i = 0; i < 5; i++)
    {
        UIView *vLine = [self lineViewWithDirection:v_line];
        vLine.top = NodeViewWH / 2;
        vLine.left = i * margin + NodeViewWH / 2;
        UIView *hLine = [self lineViewWithDirection:h_line];
        hLine.left = NodeViewWH / 2;
        hLine.top = i * margin + NodeViewWH / 2;
        [self addSubview:vLine];
        [self addSubview:hLine];
    }
}

//MARK: 生成node view
- (void)createNodeView
{
    for (NodeModel *node in self.nodeArray)
    {
        NodeView *view = [NodeView nodeWithModel:node];
        view.m_delegate = self;
        [self addSubview:view];
        [self.nodeViewArray addObject:view];
    }
    [self layoutNodeView];
}

//MARK: 给棋子布局
- (void)layoutNodeView
{
    CGFloat margin = [self nodeMargin];
    for (NodeView *view in self.nodeViewArray)
    {
        NodeModel *node = view.nodeModel;
        view.centerX = NodeViewWH / 2 + node.col * margin;
        view.centerY = NodeViewWH / 2 + node.row * margin;
    }
}

- (void)setUpView
{
    //1、生成数据源
    [self createDataSource];
    //2、生成棋盘
    [self createQiPan];
    //3、生成棋子
    [self createNodeView];
    self.role = wolf;
    self.isCanMove = YES;
}

//MARK: NodeViewDelegate
- (void)tapWithView:(NodeView *)nodeView
{
    NodeModel *tapModel = nodeView.nodeModel;
    NodeType type = tapModel.type;
    BOOL isSelect = tapModel.isSelect;
    if(self.selectNodeViewArray.count <= 0 || [[self.selectNodeViewArray firstObject] isEqual:nodeView])//空或者选了同一个node
    {
        if (type != empty)
        {
            if (type == self.role)
            {
                [nodeView selectView:!isSelect];
                if (!isSelect)
                {
                    [self.selectNodeViewArray addObject:nodeView];
                }
                else
                {
                    [self.selectNodeViewArray removeObject:nodeView];
                }
            }
        }
    }
    else if (self.selectNodeViewArray.count == 1)//已经选中一个了
    {
        NodeView *selectNodeView = [self.selectNodeViewArray firstObject];
        NodeModel *selectModel = selectNodeView.nodeModel;
        TapType tapType = [selectModel tapTypeWithNode:tapModel nodeList:self.nodeArray];
        if (tapType == sameTap)
        {
            [selectNodeView selectView:NO];
            [self.selectNodeViewArray removeObject:selectNodeView];
            [nodeView selectView:YES];
            [self.selectNodeViewArray addObject:nodeView];
        }
        else if (tapType == rightTap)
        {
            [self exChangePlayRole];//交换角色
            if (type == empty)//点了个空白的地方
            {
                [self exchangeView:nodeView withView:selectNodeView];
            }
            else
            {
                [nodeView setType:empty];
                [self exchangeView:nodeView withView:selectNodeView];
            }
            [selectNodeView selectView:NO];
            [self.selectNodeViewArray removeObject:selectNodeView];
        }
    }
}

- (void)exChangePlayRole
{
    if (self.isPlaySelf)
    {
        if (self.role == wolf)
        {
            self.role = sheep;
        }
        else if (self.role == sheep)
        {
            self.role = wolf;
        }
    }
}

- (void)exchangeView:(NodeView *)view1 withView:(NodeView *)view2
{
    NodeModel *tapModel = view1.nodeModel;
    NodeModel *selectModel = view2.nodeModel;
    
    NodeType type = tapModel.type;
    tapModel.type = selectModel.type;
    selectModel.type = type;
    
    view1.nodeModel = selectModel;
    view2.nodeModel = tapModel;
    [self layoutNodeView];
    NSUInteger idx1 = [self.nodeViewArray indexOfObject:view1];
    NSUInteger idx2 = [self.nodeViewArray indexOfObject:view2];
    if ([self.m_delegate respondsToSelector:@selector(exChangeIdx:withIdx:)])
    {
        [self.m_delegate exChangeIdx:idx1 withIdx:idx2];
    }
}

@end
