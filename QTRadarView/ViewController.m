//
//  ViewController.m
//  QTRadarView
//
//  Created by QT on 2020/12/7.
//

#import "ViewController.h"

#import "QTRadarView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    QTRadarView *radarView = [[QTRadarView alloc] init];
    
    radarView.frame = CGRectMake(0, 200*kWidthScale, main_Width, 600*kWidthScale);
    
    NSMutableArray *tempArr = [NSMutableArray array];
    
    //可以任意改变多边形
//    for (NSInteger i = 0; i < 8; i++) {
    for (NSInteger i = 0; i < 6; i++) {
    //for (NSInteger i = 0; i < 5; i++) {
        
        QTRadarModel *model = [QTRadarModel new];
        
        model.name = [NSString stringWithFormat:@"维度%zd",i+1];
        model.total = @"100";
        model.my = [NSString stringWithFormat:@"%d", arc4random() % 100];
        
        [tempArr addObject:model];
    }
    
    radarView.modelArr = tempArr.copy;
    
    [self.view addSubview:radarView];
}


@end
