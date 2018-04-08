//
//  ViewController.m
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/2.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import "ViewController.h"
#import "BSDiffPatch.h"
#import "SSZipArchive.h"
#import "CodePullDownloader.h"
#import "CodePullUtil.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *files;
@property (strong, nonatomic) NSMutableDictionary *fileDict;
@property (assign, nonatomic) NSInteger downloadCount;
@property (strong, nonatomic) CodePullModel *pullModel;

@property (copy, nonatomic) NSString *zipPath;
@property (strong, nonatomic) CodePullDownloader *downloader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
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
        [self zipFile];
    } else if (indexPath.row == 2) {
        [self unzipFile];
    } else if (indexPath.row == 3) {
        [self download];
    } else if (indexPath.row == 4) {
        [self mergeDownloadBundle];
    } else if (indexPath.row == 5){
        [self createDir];
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
    self.data = [[NSMutableArray alloc] initWithObjects:@"bundle差异包合并", @"zip压缩", @"解压", @"下载", @"下载bundle合并", @"创建文件夹", nil];
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

#pragma mark - 差异包合并

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

#pragma mark - 压缩解压

- (void)zipFile {
    NSString *zipPath = [[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:@"zip" isDirectory:YES].path;
    NSString *destPath = [self tempZipPath];
    self.zipPath = destPath;
    BOOL success = [SSZipArchive createZipFileAtPath:destPath withContentsOfDirectory:zipPath];
    if (success) {
        NSLog(@"压缩成功---%@",destPath);
    }
}

- (void)unzipFile {
    NSString *unzipPath = [self tempUnzipPath];
    if (!unzipPath) {
        return;
    }
    BOOL success = [SSZipArchive unzipFileAtPath:self.zipPath toDestination:unzipPath];
    if (success) {
        NSLog(@"解压成功");
    }
}

- (NSString *)tempZipPath {
    NSString *path = [NSString stringWithFormat:@"%@/\%@.zip",
                      [self getApplicationSupportDirectory],
                      [NSUUID UUID].UUIDString];
    return path;
}

- (NSString *)tempUnzipPath {
    NSString *path = [NSString stringWithFormat:@"%@/\%@",
                      [self getApplicationSupportDirectory],
                      [NSUUID UUID].UUIDString];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:url
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
    if (error) {
        return nil;
    }
    return url.path;
}

#pragma mark - 下载

- (void)download {
    self.downloader = [[CodePullDownloader alloc] init];
    [self.downloader fetchVersionInfo:^(NSError *error, CodePullModel *model) {
        if (error) {
            NSLog(@"获取版本信息错误:%@", error.localizedDescription);
        } else {
            [self downloadAssests:model];
        }
    }];
}

- (void)downloadAssests:(CodePullModel *)model {
    self.pullModel = model;
    NSLog(@"全量包地址:%@--全量包的hash值:%@",model.fullPackageUrl,model.fullPackageMd5);
    self.fileDict = [[NSMutableDictionary alloc] init];
    NSString *packageName = [[NSURL URLWithString:model.fullPackageUrl] lastPathComponent];
    NSString *hash = [CodePullUtil computeHashForString:packageName];
    NSMutableDictionary *fullDict = [[NSMutableDictionary alloc] init];
    fullDict[@"contentHash"] = model.fullPackageMd5;
    fullDict[@"fileNameHash"] = hash;
    fullDict[@"savePath"] = @"";
    fullDict[@"isVerifiy"] = @"0";
    self.fileDict[model.fullPackageUrl] = fullDict;
    packageName = [[NSURL URLWithString:model.patchUrl] lastPathComponent];
    hash = [CodePullUtil computeHashForString:packageName];
    NSMutableDictionary *patchDict = [[NSMutableDictionary alloc] init];
    patchDict[@"contentHash"] = model.patchMd5;
    patchDict[@"fileNameHash"] = hash;
    patchDict[@"savePath"] = @"";
    fullDict[@"isVerifiy"] = @"0";
    self.fileDict[model.patchUrl] = patchDict;
    self.downloadCount = 0;
    [self.downloader download:self.fileDict.allKeys doneCallBack:^(NSError *error, NSURL *fileUrl) {
        NSLog(@"回调的存储地址:%@",[fileUrl path]);
        NSString *fileName = [fileUrl lastPathComponent];
        [self.fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *hashName = [obj objectForKey:@"fileNameHash"];
            if (hashName.length && [fileName containsString:hashName]) { // containsString 后面如果是nil, 会崩溃
                *stop = YES;
                if (*stop == YES) {
                    NSString *contentHash = [CodePullUtil computeHashForFile:fileUrl];
                    if ([obj[@"contentHash"] isEqualToString:contentHash]) {
                        obj[@"isVerifiy"] = @"1";
                    } else {
                        obj[@"isVerifiy"] = @"0";
                    }
                    obj[@"savePath"] = [fileUrl path];
                    self.fileDict[key] = obj;
                    self.downloadCount += 1;
                }
            }
        }];
        if (self.downloadCount == [self.fileDict.allKeys count]) {
            [self downloadFinished];
        }
    }];
}

- (void)downloadFinished {
    NSLog(@"download finished");
    NSLog(@"current file dict value:%@",self.fileDict);
    __block NSInteger verifiyCount = 0;
    [self.fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj[@"isVerifiy"] isEqualToString:@"1"]) {
            verifiyCount += 1;
        }
    }];
    if (verifiyCount == [self.fileDict count]) {
        NSLog(@"all file verifiy success");
        [self downloadFileArchiver];
    }
}

- (void)downloadFileArchiver {
    [self.fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *unzipPath = [CodePullUtil createDir:obj[@"fileNameHash"]];
        BOOL success = [SSZipArchive unzipFileAtPath:obj[@"savePath"] toDestination:unzipPath];
        if (success) {
            NSLog(@"解压成功--%@",unzipPath);
        } else {
            NSLog(@"archive failed");
        }
    }];
}

#pragma mark - 下载的Bundle合并

- (void)mergeDownloadBundle {
    NSString *newBundlePosition = [CodePullUtil createDir:@"ReactBundle"];
    NSLog(@"new bundle position :%@",newBundlePosition);
    NSError *error = nil;
    BOOL copyResult = false;
    for (NSString *key in [self.fileDict allKeys]) {
        NSDictionary *dict = self.fileDict[key];
        if (dict.count > 0) {
            NSString *position = [NSString stringWithFormat:@"/%@",dict[@"fileNameHash"]];
            NSString *unzipPath = [[CodePullUtil getApplicationSupportDirectory] stringByAppendingString:position];
            copyResult = [CodePullUtil copyEntriesInFolder:unzipPath destFolder:newBundlePosition error:&error];
        }
    }
    if (copyResult) {
        NSLog(@"文件拷贝成功");
        NSString *originPath = [newBundlePosition stringByAppendingString:@"/main.ios.jsbundle"];
        NSString *patchPath = [newBundlePosition stringByAppendingString:@"/main.ios.jsbundle.patch"];
        NSString *desthPath = [[self getApplicationSupportDirectory] stringByAppendingString:@"/ReactBundle/newBundle.jsbundle"];
        NSLog(@"patch文件中的路径:%@",desthPath);
        BOOL result = [BSDiffPatch beginPatch:patchPath origin:originPath toDestination:desthPath];
        if (result) {
            NSLog(@"差异包合并成功");
        } else {
            NSLog(@"差异包合并失败");
        }
    }
}

#pragma mark - 创建文件夹

- (void)createDir {
    NSString *newBundlePosition = [CodePullUtil createDir:@"ReactBundle"];
    for (NSInteger i = 1; i <= 9; i++) {
        NSString *name = [NSString stringWithFormat:@"%ld.0.0", (long)i];
        NSString *subPath = [CodePullUtil createSubDir:newBundlePosition subDir:name];
        NSLog(@"%ld---创建文件夹 :%@",(long)i,subPath);
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSMutableArray *files = [CodePullUtil allSubDirsInFolder:newBundlePosition error:&error];
    NSLog(@"所有的文件夹子目录:%@",files);
//    NSArray *contents = [manager contentsOfDirectoryAtPath:newBundlePosition error:nil];
//    for (NSInteger i = 0; i < [contents count]; i++) {
//        NSString *path = [newBundlePosition stringByAppendingPathComponent:contents[i]];
//        NSError *error;
//        NSDictionary *dict = [manager attributesOfItemAtPath:path error:&error];
//        if (error == nil) {
//            NSLog(@"%@的属性字典:%@",contents[i],dict);
//        }
//    }
    [files sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return obj1 <= obj2;
    }];
    NSLog(@"排序之后的文件数组:%@",files);
}

@end
