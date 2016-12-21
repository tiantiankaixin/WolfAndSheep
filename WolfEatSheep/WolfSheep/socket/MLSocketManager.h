//
//  MLSocketManager.h
//  WolfEatSheep
//
//  Created by mal on 16/12/21.
//  Copyright © 2016年 mal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MLSocketManager : NSObject

+ (MLSocketManager *)shareManager;
- (void)startServer;
- (void)beginSearchServer;

@end
