//
//  ViewController.m
//  WolfEatSheep
//
//  Created by mal on 16/12/20.
//  Copyright © 2016年 mal. All rights reserved.
//

#import "ViewController.h"
#import "MLSocketManager.h"
#import "GameViewController.h"

@interface ViewController ()<MLSocketManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    [self startServer];
}

- (void)startServer
{
    MLSocketManager *manager = [MLSocketManager shareManager];
    [manager startServer];
    [manager beginSearchServer];
    manager.m_delegate = self;
}

- (void)setUpView
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSNetService *service = self.dataSource[indexPath.row];
    cell.textLabel.text = service.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNetService *service = self.dataSource[indexPath.row];
    [[MLSocketManager shareManager] connectService:service];
}

//MARK: MLSocketManagerDelegate
- (void)updatePlayerList:(NSMutableArray *)playerList
{
    self.dataSource = playerList;
    [self.tableView reloadData];
}

- (void)connectSuccess
{
    GameViewController *gameVC = [[GameViewController alloc] init];
    [self.navigationController pushViewController:gameVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
