//
//  BLEManager.h
//  Kohler
//
//  Created by Akshay on 11/9/17.
//  Copyright © 2017 Akshay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//#import "BaseViewController.h"


@protocol BLEManagerDelegate <NSObject>

@optional

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error;

@end



@interface BLEManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic,assign)id<BLEManagerDelegate>bledelegate;

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;

+ (id) sharedInstance;

- (void)scan:(NSString *)serviceUUID;
-(void)stopScan;
- (void)cleanup;

@end
