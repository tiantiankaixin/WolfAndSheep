//
//  MenuViewController.m
//  WolfEatSheep
//
//  Created by mal on 2019/10/31.
//  Copyright © 2019 mal. All rights reserved.
//

#import "MenuViewController.h"
#import "GameViewController.h"

@interface MMenuItem : NSObject

@property (nonatomic, copy) NSString *itemTitle;
@property (nonatomic, assign) MPlayType type;

+ (MMenuItem *)itemWithTitle:(NSString *)title type:(MPlayType)type;

@end

@implementation MMenuItem

+ (MMenuItem *)itemWithTitle:(NSString *)title type:(MPlayType)type
{
    MMenuItem *item = [[MMenuItem alloc] init];
    item.itemTitle = title;
    item.type = type;
    return item;
}

@end


static NSString * const KCellIdentifier = @"MenuViewController_Cell";

@interface MenuViewController ()

@property (nonatomic, strong) NSMutableArray<MMenuItem *> *dataSource;

@end

@implementation MenuViewController

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil)
    {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    [self configueData];
}

- (void)setUpView
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KCellIdentifier];
}

- (void)configueData
{
    [self.dataSource addObject:[MMenuItem itemWithTitle:@"单机模式" type:local_play]];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KCellIdentifier];
    MMenuItem *item = self.dataSource[indexPath.row];
    cell.textLabel.text = item.itemTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMenuItem *item = self.dataSource[indexPath.row];
    switch (item.type)
    {
        case local_play:
        {
            [self localPlay];
            break;
        }
        default:
            break;
    }
}

- (void)localPlay
{
    GameViewController *gameVC = [GameViewController gameVCWithPlayType:local_play];
    [self.navigationController pushViewController:gameVC animated:YES];
}

@end

