//
//  BLEManager.m
//  Kohler
//
//  Created by Akshay on 11/9/17.
//  Copyright © 2017 Akshay. All rights reserved.
//

#import "BLEManager.h"
#import "TransferService.h"

@implementation BLEManager
static BLEManager *singletonObject = nil;


+ (id) sharedInstance
{
    if (! singletonObject) {
        
        singletonObject = [[BLEManager alloc] init];
    }
    return singletonObject;
}

- (id)init
{
    if (! singletonObject) {
        
        singletonObject = [super init];
        // Uncomment the following line to see how many times is the init method of the class is called
        // NSLog(@"%s", __PRETTY_FUNCTION__);
        if (!self.centralManager) {
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        }
        if (!self.data) {
            // And somewhere to store the incoming data
            self.data = [[NSMutableData alloc] init];
        }
    }
    return singletonObject;
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan:(NSString *)serviceUUID
{
    
//    @[@"FFF0",@"FFE0",@"BEEF",@"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"]
    
    //    NSLog(@"%@",[CBUUID UUIDWithString:serviceUUID]);

    //    @[[CBUUID UUIDWithString:serviceUUID]]
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}

-(void)stopScan
{
    NSLog(@"Stopped Scanning");
    [self.centralManager stopScan];
}



#pragma mark - Central Methods



/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{    
    if ([self.bledelegate respondsToSelector:@selector(centralManagerDidUpdateState:)]){
        [self.bledelegate centralManagerDidUpdateState:central];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{    
    if ([self.bledelegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]){
        [self.bledelegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([self.bledelegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]){
        [self.bledelegate centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    if ([self.bledelegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
        [self.bledelegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
    }
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID_FLUSH]]];
    
    if ([self.bledelegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
        [self.bledelegate centralManager:central didConnectPeripheral:peripheral];
    }
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if ([self.bledelegate respondsToSelector:@selector(peripheral:didDiscoverServices:)]) {
        [self.bledelegate peripheral:peripheral didDiscoverServices:error];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([self.bledelegate respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)]) {
        [self.bledelegate peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
    }
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self.bledelegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]) {
        [self.bledelegate peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self.bledelegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
        [self.bledelegate peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([self.bledelegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
        [self.bledelegate centralManager:central didDisconnectPeripheral:peripheral error:error];
    }
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (self.discoveredPeripheral.state!=CBPeripheralStateConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    
    
    //    if (self.discoveredPeripheral.services != nil) {
    //        for (CBService *service in self.discoveredPeripheral.services) {
    //            if (service.characteristics != nil) {
    //                for (CBCharacteristic *characteristic in service.characteristics) {
    //                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
    //                        if (characteristic.isNotifying) {
    //                            // It is notifying, so unsubscribe
    //                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
    //
    //                            // And we're done.
    //                            return;
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}




- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID forServiceUUID:(CBUUID *)serviceUUID inPeripheral:(CBPeripheral *)peripheral {
    
    CBCharacteristic *returnCharacteristic  = nil;
    for (CBService *service in peripheral.services) {
        
        if ([service.UUID isEqual:serviceUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                if ([characteristic.UUID isEqual:characteristicUUID]) {
                    
                    returnCharacteristic = characteristic;
                }
            }
        }
    }
    return returnCharacteristic;
}

@end
