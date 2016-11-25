//
//  ViewController.m
//  GZPieChartView_2
//
//  Created by armada on 2016/11/25.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import "ViewController.h"

#import "GZPieChartView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSArray *portions = @[@"100",@"100",@"200"];
    NSArray *colors = @[[UIColor greenColor],[UIColor yellowColor],[UIColor cyanColor]];
    NSArray *values = @[@"10%",@"10%",@"0个",@"2个"];
    
    GZPieChartView *pieChartView = [[GZPieChartView alloc]initWithFrame:CGRectMake(0, 0, 400, 300) portions:portions portionColors:colors radius:70 lineWidth:15 values:values];
    
    pieChartView.center = self.view.center;
    
    [self.view addSubview:pieChartView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
