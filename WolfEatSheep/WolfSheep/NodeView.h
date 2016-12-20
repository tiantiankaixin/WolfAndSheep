//
//  NodeView.h
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NodeModel.h"
#define NodeViewWH 30
@class NodeView;
@protocol NodeViewDelegate <NSObject>

- (void)tapWithView:(NodeView *)nodeView;

@end

@interface NodeView : UIView

@property (nonatomic, weak) NodeModel *nodeModel;
@property (nonatomic, weak) id<NodeViewDelegate> m_delegate;

+ (NodeView *)nodeWithModel:(NodeModel *)model;
- (void)selectView:(BOOL)isSelect;
- (void)setType:(NodeType)type;

@end
