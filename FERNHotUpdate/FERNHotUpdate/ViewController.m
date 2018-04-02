//
//  ViewController.m
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/2.
//  Copyright © 2018年 rrd. All rights reserved.
//

#import "ViewController.h"
#import "BSDiffPatch.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
    NSString *path = [self getApplicationSupportDirectory];
    NSLog(@"路径不存在：%@",path);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.row == 0) {
        [self patchTest];
    } else if (indexPath.row == 1) {
        
    } else {
        
    }
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 64);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.tableView];
    self.data = [[NSMutableArray alloc] initWithObjects:@"bundle差异包合并", @"zip包下载解压", nil];
}

- (NSString *)getApplicationSupportDirectory {
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    return applicationSupportDirectory;
}

- (void)patchTest {
    NSString *originPath = [[[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"jsbundle"] path];
    NSString *patchPath = [[[NSBundle mainBundle] URLForResource:@"patch.ios" withExtension:@"jsbundle"] path];
    NSLog(@"原始文件的位置:%@",originPath);
    NSLog(@"增量的文件的位置:%@",patchPath);
    NSString *desthPath = [[self getApplicationSupportDirectory] stringByAppendingString:@"/patch_2017.jsbundle"];
    NSLog(@"patch文件中的路径:%@",desthPath);
    //    BOOL result = [BSDiff bsdiffPatch:patchPath origin:originPath toDestination:desthPath];
    BOOL result = [BSDiffPatch beginPatch:patchPath origin:originPath toDestination:desthPath];
    if (result) {
        NSLog(@"差异包合并成功");
    } else {
        NSLog(@"差异包合并失败");
    }
}

@end
