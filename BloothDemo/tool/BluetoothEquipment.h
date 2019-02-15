//
//  BluetoothEquipment.h
//  BloothDemo
//
//  Created by ayong on 2018/10/16.
//  Copyright © 2018年 ayong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


#define PERIPHERAL_NAME @"HuXinJia"

#define PERIPHERAL_CBUUID @"0x180D"

@interface BluetoothEquipment : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

@property(nonatomic,strong)CBCentralManager* centralManager;

@property(nonatomic,strong)CBPeripheral* myPeripheral;

@property(nonatomic,strong)CBCharacteristic* lockUnlockCharacteristic;//上锁和解锁的characteristic

@property(nonatomic,strong)CBCharacteristic* readPowerCharacteristic;//电量的characteristic

-(void)initCentralManager;//初始化中心设备管理器

-(void)setLockInstruction:(NSString*)lockInstruction;//传入上锁指令

-(void)setUnlockInstruction:(NSString *)unlockInstruction;//传入解锁指令


@end
