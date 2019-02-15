//
//  BluetoothEquipment.m
//  BloothDemo
//
//  Created by ayong on 2018/10/16.
//  Copyright © 2018年 ayong. All rights reserved.
//

#import "BluetoothEquipment.h"
#import <UIKit/UIKit.h>
#import "UIView+TraverseViewController.h"


@interface BluetoothEquipment ()

@property (nonatomic, copy) NSString *cbUUID;

@end

@implementation BluetoothEquipment 
//传入上锁指令
- (void)setLockInstruction:(NSString *)lockInstruction{
    
    if (_lockUnlockCharacteristic) {
        NSData* lockValue = [self dataWithString:lockInstruction];
        NSLog(@"上锁的指令lockValue= %@",lockValue);
        [_myPeripheral writeValue:lockValue forCharacteristic:_lockUnlockCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//传入解锁指令
-(void)setUnlockInstruction:(NSString *)unlockInstruction{
    
    if (_lockUnlockCharacteristic) {
        NSData* unlockValue = [self dataWithString:unlockInstruction];
        NSLog(@"解锁的指令unlockValue= %@",unlockValue);
        [_myPeripheral writeValue:unlockValue forCharacteristic:_lockUnlockCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//初始化中心设备管理器

- (void)initCentralManager{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
}

#pragma mark -CBCentralManagerDelegate

//创建完成CBCentralManager对象之后会回调的代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");//设备类型位置
            break;
        case CBManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");//设备初始化中
            break;
        case CBManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");//设备未授权
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
            UIAlertView *alterView=[[UIAlertView alloc]initWithTitle:@"亲，请打开蓝牙哦" message:@"打开蓝牙摇一摇，优惠就会出现哦~" delegate:self cancelButtonTitle:@"好的。" otherButtonTitles: nil];
            [alterView show];

        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开始
            //如果想自动扫描，在此处开始扫描即可
//            self.cbUUID = @"9F5975D7-EE73-369E-97C6-123D3C5D7127";
            [self.centralManager scanForPeripheralsWithServices:self.cbUUID options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
            
//            if (self.cbUUID) {
//               [self.centralManager scanForPeripheralsWithServices:<#(nullable NSArray<CBUUID *> *)#> options:<#(nullable NSDictionary<NSString *,id> *)#>]
//            }else{
//
//            }
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    
}


//执行扫描的动作之后，如果扫描到外设了，就会自动回调下面的协议方法了

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"******* peripheral.name = %@\n peripheral.identifier =  %@\n RSSI =  %@\n d = %f fm \n",peripheral.name, peripheral.identifier,RSSI,[self calcDistByRSSI:[RSSI intValue]]);
    //根据名字有选择性地连接蓝牙设备
    if([peripheral.name isEqualToString:PERIPHERAL_NAME]){
        _myPeripheral = peripheral;
        _myPeripheral.delegate = self;
        self.cbUUID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        [self.centralManager connectPeripheral:peripheral
                                       options:@{
                                                 CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
                                                 CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
                                                 CBConnectPeripheralOptionNotifyOnNotificationKey: @YES
                                                 }];
    }
    
    
    //CBConnectPeripheralOptionNotifyOnConnectionKey：如果应用被挂起时，连接某设备成功，系统给予连接成功提示。
    //CBConnectPeripheralOptionNotifyOnDisconnectionKey：如果应用被挂起时，设备连接断开，系统给予设备断开提示。
    //CBConnectPeripheralOptionNotifyOnNotificationKey:如果应用被挂起时，从设备接收到的所有信息通知，系统给予提示。

}

//计算距离
- (float)calcDistByRSSI:(int)rssi
{
    int iRssi = abs(rssi);
    float power = (iRssi-59)/(10*2.0);
    return pow(10, power);
}


//如果连接成功，就会回调下面的协议方法了
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //停止中心管理设备的扫描动作，要不然在你和已经连接好的外设进行数据沟通时，如果又有一个外设进行广播且符合你的连接条件，那么你的iOS设备也会去连接这个设备（因为iOS BLE4.0是支持一对多连接的），导致数据的混乱。
    [_centralManager stopScan];
    //一次性读出外设的所有服务
    [_myPeripheral discoverServices:nil];
    
    //    此时只是蓝牙层连接成功，尚未发现设备服务，不可以进行读写指令操作。此处不能算是真正意义上的连接成功状态。
    //    在该方法内寻找设备对应的服务
    
    //寻找指定UUID的Service
//    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"指定服务UUID"]]];
    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"" message:@"连接成功。。。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alterView show];

}

//掉线
//连接的外设断开连接时调用  断开连接成功回调
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"掉线");
    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"" message:@"掉线了。。。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alterView show];
    [self.centralManager connectPeripheral:self.myPeripheral options:nil];

}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外设失败");
    UIAlertView *alterView=[[UIAlertView alloc]initWithTitle:@"" message:@"连接外设失败" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alterView show];
    [self.centralManager connectPeripheral:self.myPeripheral options:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    
}

#pragma mark -CBPeripheralDelegate
//一旦我们读取到外设的相关服务UUID就会回调下面的方法

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //到这里，说明你上面调用的  [_peripheral discoverServices:nil]; 方法起效果了，我们接着来找找特征值UUID
    NSLog(@"发现服务");
    for (CBService *s in [peripheral services]) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
    UIAlertView *alterView=[[UIAlertView alloc]initWithTitle:@"" message:@"发现服务" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alterView show];
}

//如果我们成功读取某个特征值UUID，就会回调下面的方法

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    if (error){
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics){
        //找到想要的特征值
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        NSData *data = [self dataWithString:@"5ibody"];
        //写入数据时根据硬件的读写权限不同，选择回调类型 CBCharacteristicWriteWithResponse = 0, CBCharacteristicWriteWithoutResponse,
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
    
    
    //获取Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        //读取
        [peripheral readValueForCharacteristic:characteristic];
        //订阅
        [self.myPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

//向peripheral中写入数据后的回调函数     //写入的成功性 与是否有回调有关
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"写入失败");
    }else{
        NSLog(@"write value success(写入成功) : %@", characteristic);
    }
}

//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral readRSSI];
    NSNumber *rssi = [peripheral RSSI];
    //读取BLE4.0设备的电量
    NSData* data = characteristic.value;
    NSString* value = [self hexadecimalString:data];
    NSLog(@"didUpdateValueForCharacteristic(读取到的) : %@, data : %@, value : %@", characteristic, data, value);
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];

}

//订阅回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"订阅失败");
    }else{
        NSLog(@"订阅成功");
    }
    
}


//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"didUpdateValueForDescriptor uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

//将传入的NSData类型转换成NSString并返回

- (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

//将传入的NSString类型转换成ASCII码并返回

- (NSData*)dataWithString:(NSString *)string{
    unsigned char *bytes = (unsigned char *)[string UTF8String];
    NSInteger len = string.length;
    return [NSData dataWithBytes:bytes length:len];
}

@end
