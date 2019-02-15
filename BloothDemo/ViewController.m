//
//  ViewController.m
//  BloothDemo
//
//  Created by ayong on 2018/10/15.
//  Copyright © 2018年 ayong. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothEquipment.h"

@interface ViewController ()

@property (nonatomic, strong) BluetoothEquipment *bluetoothEquipment;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.bluetoothEquipment = [[BluetoothEquipment alloc] init];
    [self.bluetoothEquipment initCentralManager];
}

#pragma mark -

//设置子视图
- (void)setUpSubview{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
    
    
