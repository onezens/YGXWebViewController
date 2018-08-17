//
//  YGXWebListController.m
//  YGXWebViewController
//
//  Created by wz on 2018/7/4.
//  Copyright © 2018年 wz. All rights reserved.
//

#import "YGXWebListController.h"
#import "YGXWebViewController.h"

@interface WebInfo:NSObject

@property (nonatomic, copy) NSString  *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL record;

@end

@implementation WebInfo

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end

@interface YGXWebListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@end

@implementation YGXWebListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"WebList";
    [self loadData];
    [self addTableView];
    [self addSetting];
}

- (void)addSetting {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(goSetting)];
}

- (void)goSetting {
    
}

- (void)loadData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *metaArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray *dataArrM = [NSMutableArray arrayWithCapacity:metaArr.count];
    for (NSDictionary *dict in metaArr) {
        WebInfo *info = [WebInfo new];
        [info setValuesForKeysWithDictionary:dict];
        [dataArrM addObject:info];
    }
    self.dataArr = dataArrM;
}

- (void)addTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [self.view addSubview:tableView];
}

#pragma mark - tableview delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellId = @"YGXWebListControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    WebInfo *info = self.dataArr[indexPath.row];
    cell.textLabel.text =  info.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YGXWebViewController *webViewVc = [YGXWebViewController new];
    WebInfo *info = self.dataArr[indexPath.row];
    webViewVc.url = info.url;
    [self.navigationController pushViewController:webViewVc animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end









