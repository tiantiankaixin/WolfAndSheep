//
//  MLSocketManager.h
//  WolfEatSheep
//
//  Created by mal on 16/12/21.
//  Copyright © 2016年 mal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NodeModel.h"

@protocol MLSocketManagerDelegate <NSObject>

@optional
- (void)updatePlayerList:(NSMutableArray *)playerList;
- (void)connectSuccess;
- (void)receiveMessage:(NSString *)message;

@end

@interface MLSocketManager : NSObject

@property (nonatomic, weak) id<MLSocketManagerDelegate> m_delegate;

+ (MLSocketManager *)shareManager;
- (void)startServer;
- (void)beginSearchServer;
//MARK: fuction
- (void)connectService:(NSNetService *)service;
+ (NodeType)roleType;
- (void)sendMessage:(NSString *)message;

@end
