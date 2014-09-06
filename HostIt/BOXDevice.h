//
//  BOXDevice.h
//  BoxKitBeta
//
//  Created by Cristian Filipov on 6/13/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
@import UIKit;
#endif

@class BOXDevice;

@protocol BOXDeviceDelegate <NSObject>

@required

/**
 Indicates the user must press the multifunction button to complete the authentication process. If authentication is not completed within 30 seconds, the device will disconnect.
 */
- (void)boxDeviceRequiresAuthentication:(BOXDevice *)device;

@optional

/**
 Invoked when the multifunction button (the round button) is pressed once. 
 
 NOTE: If the device is not BR/EDR paired or if it is in low power mode, then this event will not be captured.
 */
- (void)boxDeviceDidPressMultifunctionButton:(BOXDevice *)device;

/**
 Invoked when on a long-press of the multifunction button.
 
 NOTE: If the device is not BR/EDR paired or if it is in low power mode, then this event will not be captured.
 */
- (void)boxDeviceDidLongPressMultifunctionButton:(BOXDevice *)device;

/**
 Invoked when the minus (volume down) button is pressed.
 
 NOTE: If it is in low power mode, then this event will not be captured.
 */
- (void)boxDeviceDidPressMinusButton:(BOXDevice *)device;

/**
 Invoked when the plus (volume up) button is pressed.
 
 NOTE: If it is in low power mode, then this event will not be captured.
 */
- (void)boxDeviceDidPressPlusButton:(BOXDevice *)device;

/**
 Invoked when the device becomes the audio route and when the device stops being the audio route. Use the `isCurrentAudioRoute` property to determine the current status.
 */
- (void)boxDeviceDidChangeAudioRouteStatus:(BOXDevice *)device;

/**
 Invoked when the device is connected.
 */
- (void)boxDeviceDidConnect:(BOXDevice *)device;

/**
 Invoked after the device has been disconnected.
 
 @param error If the device was disconnected due to an error, this will be non-nil.
 */
- (void)boxDevice:(BOXDevice *)device didDisconnectWithError:(NSError *)error;

@end

@interface BOXDevice : NSObject

/**
 Scan for nearby devices using Bluetooth LE.
 
 @param callback Called once per device found.
 */
+ (void)findDevices:(void (^)(BOXDevice *device, BOOL *stop, NSError *error))callback;

/**
 The delegate will receive messages for various device events such as connect/disconnect and button press.
 */
@property (nonatomic, weak) id<BOXDeviceDelegate> delegate;

/**
 The friendly name of the device.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 A unique identifier representing the specific device.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 If YES, the an auth key for this device exists. This does not necessarily mean the auth key is valid.
 */
@property (nonatomic, readonly, assign) BOOL hasAuthKey;

/**
 Is YES, then the device is the current audio route output.
 */
@property (nonatomic, readonly, assign) BOOL isCurrentAudioRoute;

/**
 If YES, then the device is connected over LE and will accept commands.
 */
@property (nonatomic, assign, readonly) BOOL isConnected;

/**
 If NO, then another central might be connected to the device.
 */
@property (nonatomic, assign, readonly) BOOL IsConnectable;

/**
 If YES, then AVRCP events such as play/plause, volume up, volume down, etc... are consumed.
 
 When events are consumed, the default action for the event will not take place.
 */
@property (nonatomic, assign) BOOL shouldConsumeEvents;

/**
 Connect to the device using Bluetooth LE.

 @param callback Called on connection success or failure.
 */
- (void)connect:(void (^)(NSError *error))callback;

/**
 Disconnect from the device.
 */
- (void)disconnect;

/**
 Perform a warm reboot. The BLE connection will be lost.

 @param quiet If YES, then no startup/reconnection tones will be played (a shutdown tone is never played).
 */
- (void)rebootQuietly:(BOOL)quiet;

/**
 Power off the device. The BLE connection will be lost.
 */
- (void)powerOff;

typedef NS_ENUM(NSInteger, BOXAVRCP) {
    kBOXAVRCPPlayPause,
    kBOXAVRCPVolumeUp,
    kBOXAVRCPVolumeDown
};

/**
 Send an AVRCP command from the device. This method has no effect if shouldConsumeEvents is YES.
 
 For example, `[device sendAVRCP:kBOXAVRCPPlayPause];` will send a play/pause command to iOS as if the play/pause button was pressed.
 */
- (void)sendAVRCP:(BOXAVRCP)cmd;

#if TARGET_OS_IPHONE
/**
 * Returns a UIColor that corresponds to the device's physical appearance
 */
- (UIColor *)deviceColor;
#endif

/**
 Put the mini jambox into pairing mode. To complete pairing with iOS you will need to use Settings.app.
 */
- (void)startPairingMode;

@end
