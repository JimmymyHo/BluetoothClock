//
//  snfsdk.h
//  snfsdk
//
//  Created by Arne Hennig on 5/8/13.
//  Copyright (c) 2013 sticknfind. All rights reserved.
//

#import <Foundation/Foundation.h>
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif
#import <MapKit/MKMapView.h>

@class LeDeviceManager;
@class LeDevice;

@protocol LeDeviceManagerDelegate <NSObject>

- (void)        leDeviceManager: (LeDeviceManager *) mgr didAddNewDevice:(LeDevice*) dev;
//  called on discovery of a new device
- (NSArray *)   retrieveStoredDeviceUUIDsForLeDeviceManager:(LeDeviceManager *)mgr;
- (id)          leDeviceManager: (LeDeviceManager *) mgr valueForDeviceUUID: (CFUUIDRef) uuid key:(NSString *)key;
- (void)        leDeviceManager: (LeDeviceManager *) mgr setValue: (id) value forDeviceUUID: (CFUUIDRef) uuid key:(NSString *)key;

@end


@interface LeDeviceManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic,strong) NSMutableArray *devList;
@property (nonatomic)        CBCentralManager *btmgr;
@property (nonatomic,strong) id <LeDeviceManagerDelegate> delegate;

- (id)      initWithSupportedDevices: (NSArray *) devCls delegate: (id <LeDeviceManagerDelegate>) del;
- (void)    startScan;
- (void)    stopScan;

@end

@interface LeDevice : NSObject <CBPeripheralDelegate>

+ (BOOL) canHandlePeripheral: (CBPeripheral*) peripheral advertisementData: (NSDictionary *)advertisementData;
+ (NSArray *)   scanUUIDs;
+ (NSUUID *)    deviceTypeUUID;
- (id)   initWithPeripheral: (CBPeripheral *) _peripheral mgr: (LeDeviceManager *) __mgr;
- (void) handleAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void) didConnect;
- (void) didDisconnectWithError: (NSError *) error;
- (void) didFailToConnectWithError: (NSError *) error;
- (void) didSendConnectCommand;
- (void) sendDiscoverServiceCommand;
- (void) didDiscoverAllServices;
- (void) invalidateCharacteristics;

@property (nonatomic,strong)	CBPeripheral                *peripheral;
@property (nonatomic,strong)    NSString                    *name;
@property (nonatomic)           CFUUIDRef                   peripheralUUID;
@property (nonatomic)           LeDeviceManager             *mgr;
@property (nonatomic,readonly)  NSString                    *deviceDescription;
@property (nonatomic,readonly)  BOOL                        isConnected;
@property (nonatomic,readonly)  BOOL                        shouldBeConnected;
@property (nonatomic,readonly)	int                         rssi;

@property (nonatomic,readonly) int                          fwloadState;                /* internal state when updating firmware */
@property (nonatomic,readonly) float                        fwloadProgress;             /* firmware loading progress */


- (void) disconnect;
- (void) connect;

@end


@class LeSnfDevice;

@protocol LeSnfDeviceDelegate

/*
 called when a broadcast from the device is received that contains data set by the user.
 */
- (void)        leSnfDevice:(LeSnfDevice *)dev didUpdateBroadcastData: (NSData *) data;

/*
 called when a broadcast from the device is received.
 */
- (void)        didDiscoverLeSnfDevice: (LeSnfDevice *) dev;

/*
 called to request firmware update data.
 if a valid firmware image is given and the version is newer than the one on the device,
 an update will happen on the next connection.
 */
- (NSData *)    firmwareDataForLeSnfDevice: (LeSnfDevice *) dev;

/*
 called when the connection state of a device changes.
 */
- (void)        leSnfDevice: (LeSnfDevice *) dev didChangeState: (int) state;

/*
 called to request an authentication key for the given device during connection.
 if the authentication feature was enabled on that device and the key does
 not match the device key, the connection will fail.
 */
- (NSData *)    authenticationKeyforLeSnfDevice:(LeSnfDevice *)dev;

/*
 Update of the estimated distance from the device.
 */
//- (void)        leSnfDevice:(LeSnfDevice *)dev didUpdateDistanceEstimate: (float) distance;

/*
 Update of the battery level (0 to 100) from the device.
 */
//- (void)        leSnfDevice:(LeSnfDevice *)dev didUpdateBatteryLevel: (int) level;

/*
 Update of the temperature from the device.
 */
//- (void)        leSnfDevice:(LeSnfDevice *)dev didUpdateTemperature: (int) temp;

/*
 called when broadcast data was set
 */
- (void)        didSetBroadcastDataForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success;

/*
 called when broadcast key was set
 */
- (void)        didSetBroadcastKeyForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success;

/*
 called when broadcast data was read
 */
-  (void)       didReadBroadcastData: (NSDictionary *) dict forLeSnfDevice: (LeSnfDevice *) dev;

/*
 called when broadcast key was set
 */
- (void)       didSetBroadcastRateForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success;

/*
 called when alert was set
 */
- (void)       didEnableAlertForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success;

/*
 called when connection loss alert was set
 */
- (void)       didEnableConnectionLossAlertForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success;

/*
 called when connection pairing rssi was set
 */
- (void)       didSetPairingRssiForLeSnfDevice: (LeSnfDevice *) dev success: (BOOL) success;

/*
 called when temperature calibration was set
 */
-  (void)      didSetTemperatureCalibrationForLeSnfDevice:(LeSnfDevice *) dev success: (BOOL) success;

/*
 called when temperature log was read
 */
-  (void)       didReadTemperatureLog: (NSArray *) log forLeSnfDevice: (LeSnfDevice *) dev;

@end

enum LE_DEVICE_STATE
{
    LE_DEVICE_STATE_DISCONNECTED=0,
    LE_DEVICE_STATE_CONNECTING,
    LE_DEVICE_STATE_CONNECTED,
    LE_DEVICE_STATE_UPDATING_FIRMWARE
};

@interface LeSnfDevice : LeDevice

@property (readonly)            BOOL                            distanceMeasurementEnabled; /* status of distance measurement enable */
@property (nonatomic,readonly)  enum LE_DEVICE_STATE            state;                      /* status of connection to device */
@property (nonatomic,strong)    id <LeSnfDeviceDelegate>        delegate;                   /* the delegate */
@property (nonatomic,readonly)  uint32_t                        swRevision;                 /* software revision on the device side */

@property (nonatomic,readonly)  int                             batteryLevel;       /* battery level, range 0 to 100 (%) */
@property (nonatomic,readonly)  float                           temperature;        /* temperature in deg C */
@property (nonatomic,readonly)  float                           temperatureRaw;     /* uncalibrated temperature in deg C */
@property (nonatomic)           NSArray *                       temperatureCalibrationValues;   /* raw temperature values at -10,10,30,40,50 deg C  */
@property (nonatomic,strong)    NSMutableArray *                temperatureLog;     /* temperature log data */
@property (nonatomic,readonly)  int                             buttonCounter;      /* counter inrements every time the device is tapped */
@property (nonatomic,readonly)  float                           distanceEstimate;   /* estimated distance */


@property (nonatomic,readonly)  int                             connectionCounter;
@property (nonatomic,readonly)  int                             connectionSuccessCounter;


/*  
    Flags for enabling dynamic data in broadcast packets
    The data is put in the order shown below.
*/

#define LeSnfDeviceBroadcastDynTemperature          0x01        /* include 1 signed byte for temperature in deg C */
#define LeSnfDeviceBroadcastDynBatteryLevel         0x02        /* include 1 byte for battery level in % */
#define LeSnfDeviceBroadcastDynButtonCounter1       0x04        /* include 1 byte for number of taps */
#define LeSnfDeviceBroadcastDynButtonCounter2       0x08        /* include 2 bytes for number of taps */
#define LeSnfDeviceBroadcastDynButtonCounter4       0x0C        /* include 4 bytes for number of taps */



/*
 Sets the broadcast data.
 dynData contains flags that enable the replacement of sections in the given data with dynamically created data
 like battery level or temperature.
 dynOfs is the offset at which the insertion of the dynamic data takes place.
 
 The device can transmit up to 4 different broadcast messages, identified by the index (0 to 3).
 Calling with nil as data will disable the broadcast message.
 
 The user is responsible for implementing a way of differentiating among the different broadcast messages on reception.

 The maximum data length is 29 Bytes.
 
 */
- (BOOL) setBroadcastData: (NSData *)data atIndex: (int) index dynData: (int) dyn dynOfs: (int) dynofs;

/*
 Sets the broadcast data with encryption.
 The encryptionRange section of the data will be encrypted with the key at keyIndex and randomlength bytes of random data as IV during each broadcast.
 The random data will be appended at the end of the given range, and will overwrite any data at those positions.
 */
- (BOOL) setEncryptedBroadcastData: (NSData *)data atIndex: (int) index dynData: (int) dyn dynOfs: (int) dynofs keyIndex: (int) kidx encryptionRange: (NSRange) encr randomLength: (int) rlen;


/*
 setup to broadcast as an apple iBeacon
 */
- (BOOL) setIBeaconBroadcastDataAtIndex: (int) index proximityUUID: (NSUUID *) proximityUUID major:(uint16_t)major minor:(uint16_t)minor signalAt1m: (int8_t) signal;


/*
 Sets one of the 128 bit AES encryption keys for encrypting broadcasts.
 */
- (BOOL) setBroadcastKey: (NSData *) key atIndex: (int) index;


/*
 Initiates a readback of broadcast data set at a given index
 */
- (BOOL) readBroadcastDataAtIndex: (int) index;

/*
 Sets the 128 bit authentication key.
 If set, the device will only connect to previously paired clients and those that provide the
 given key during connection.
 
 To allow any device to connect using that key, also set the pairingRssi to a low enough value
 as it will still limit the range for any new connection.
 
 The feature is is only enabled for stickers with OEM firmware.
 */
- (BOOL) setAuthenticationKey: (NSData *) authkey;

/*
 Sets the number of broadcast data transmissions per second.
 The rate will change to the rate2 after timeout seconds.
 
 The range for the rate is from 0.1Hz to 100Hz.
 The setting will affect the power usage / battery life when not connected.
 Use low rates to save battery life.
 
 The minimum timeout value is 1.
 */
- (BOOL) setBroadcastRate: (float) rate timeout: (float) timeout rate2: (float) rate2;

/*
 Enables the measurement of rssi based distance.
 */
- (BOOL) enableDistanceMeasurement: (BOOL) enable;

/*
 Set the number of data transmissions per second (1,2,5 or 10)
 The rate will influence the battery life during connection and the response speed
 of commands sent to the device.
 */
- (BOOL) setConnectionRate: (int) rate;

/*
 minimum required signal strength to allow a connection to a non-paired client.
 by default, the device is set to -60dBm, allowing pairing / initial connection only from close distance.
 
 it can be set to a lower value to allow for more range.
 */
- (BOOL) setPairingRssi: (int) level;


/*
 enables the audible and/or light alert on the device.
 */
- (BOOL) enableAlertSound: (BOOL) snd light: (BOOL) light;

/*
 enables the audible and/or light alert on the device when a connection is lost.
 This can be used as a leash feature.
 The alert will not be activated if the device is disconnected on purpose using
 the disconnect call.
 */
- (BOOL) enableConnectionLossAlertSound: (BOOL) snd light: (BOOL) light;

/*
 initiates a read of the temperature from the device
 */
- (BOOL) readTemperature;

/*
 set the real temperature in deg C to calibrate a device temperature sensor
 */
- (BOOL) setTemperatureCalibration: (float) realTemperature;

/*
 set the temperature difference between board sensor and real temperature in K
 */
- (BOOL) writeTemperatureCalibration;


/*
 initiates a read of the battery level from the device
 */
- (BOOL) readBatteryLevel;

/*
 Decrypts received broadcast data.
 The settings have to match the ones used in setEncryptedBroadcastData.
 */
- (NSData *) decryptBroadcastData: (NSData *) d key: (NSData *) keydata encryptionRange: (NSRange) encr randomLength: (int) rlen;



- (BOOL) setBroadcastDataName: (NSData *)data atIndex: (int) index;
- (BOOL) enableTemperatureLoggingWithInterval: (uint16_t) interval;
- (float) calibratedTemperatureValue: (int16_t) raw_value;
- (BOOL) readTemperatureLog;
- (BOOL) eraseTemperatureLog;
- (void) writeDeviceName: (NSString*) name;

@end


@class LeBlutrackerDevice;
@protocol LeBlutrackerDeviceDelegate

/*
 called when a broadcast from the device is received that contains data set by the user.
 */
- (void)        leBlutrackerDevice:(LeBlutrackerDevice *)dev didUpdateBroadcastData: (NSData *) data;

/*
 called when a broadcast from the device is received.
 */
- (void)        didDiscoverLeBlutrackerDevice: (LeBlutrackerDevice *) dev;

/*
 called to request firmware update data.
 if a valid firmware image is given and the version is newer than the one on the device,
 an update will happen on the next connection.
 */
- (NSData *)    firmwareDataForLeBlutrackerDevice: (LeBlutrackerDevice *) dev;

/*
 called when the connection state of a device changes.
 */
- (void)        leBlutrackerDevice: (LeBlutrackerDevice *) dev didChangeState: (int) state;

/*
 called to request the broadcast encryption key for the given device.
 It is used to decrypt the loacation broadcast.
 */
- (NSData *)    broadcastKeyForLeBlutrackerDevice:(LeBlutrackerDevice *)dev;

/*
 called when key was written to device
 */
- (void)    didWriteBroadcastKeyForLeBlutrackerDevice:(LeBlutrackerDevice *)dev;


@end





@interface LeBlutrackerDevice : LeDevice  <MKAnnotation>
{
    CLLocationCoordinate2D _coord;
}

@property (nonatomic,readonly,copy)	NSString *title;
@property (nonatomic,readonly,copy)	NSString *subtitle;
@property (nonatomic,readonly)	CLLocationCoordinate2D coordinate;

@property (nonatomic, strong)       NSString *svInfo;
@property (nonatomic, strong)       NSString *navInfo;

@property (nonatomic,readonly)  enum LE_DEVICE_STATE                state;                      /* status of connection to device */
@property (nonatomic,strong)    id <LeBlutrackerDeviceDelegate>     delegate;                   /* the delegate */

@property (readonly)            BOOL                                bcKeyEnabled;               /* broadcast key enabled */

- (BOOL) writeBroadcastKey: (NSData *) key;

@end






















