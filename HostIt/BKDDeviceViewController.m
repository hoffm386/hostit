//
//  BKDDeviceViewController.m
//  BoxKitDemo
//
//  Created by Cristian Filipov on 6/13/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "BKDDeviceViewController.h"
#import "BOXDevice.h"

@interface BKDDeviceViewController () <BOXDeviceDelegate>

@property (weak, nonatomic) IBOutlet UIButton *multifunctionButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UISwitch *consumeEventSwitch;
@property (weak, nonatomic) IBOutlet UIView *blockingView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isAudioRouteSegment;

@property (nonatomic, strong) UIAlertView *authAlert;

@end

@implementation BKDDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.device.delegate = self;
    self.title = self.device.name;
    self.consumeEventSwitch.onTintColor = self.device.deviceColor;
    [[UIApplication sharedApplication] delegate].window.tintColor = self.device.deviceColor;

    __weak typeof(self) wself = self;
    [self.device connect:^(NSError *error) {
        if (!error) {
            if (wself.authAlert) {
                [wself.authAlert dismissWithClickedButtonIndex:0 animated:YES];
                wself.authAlert = nil;
            }
            wself.blockingView.alpha = 0.0;
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.device.IsConnectable) {
        [[[UIAlertView alloc] initWithTitle:@"Not Connectable"
                                    message:@"Can not connect to this device. Perhaps someone else is already connected?"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
}

- (IBAction)onConsumeEventsSwitchChanged:(UISwitch *)sender
{
    self.device.shouldConsumeEvents = sender.isOn;
}

- (IBAction)onPlayButtonPressed:(id)sender
{
    [self.device sendAVRCP:kBOXAVRCPPlayPause];
}

- (IBAction)onMinusButtonPressed:(id)sender
{
    [self.device sendAVRCP:kBOXAVRCPVolumeDown];
}

- (IBAction)onPlusButtonPressed:(id)sender
{
    [self.device sendAVRCP:kBOXAVRCPVolumeUp];
}

- (IBAction)onPairButtonPressed:(id)sender
{
    [self.device startPairingMode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.device disconnect];
}

#pragma mark BOXDeviceDelegate

- (void)boxDeviceRequiresAuthentication:(BOXDevice *)device
{
    self.authAlert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"Please press the round button to authenticate"
                              delegate:nil
                     cancelButtonTitle:nil
                     otherButtonTitles:nil];
    [self.authAlert show];
}

- (void)boxDeviceDidPressMultifunctionButton:(BOXDevice *)device
{
    if (self.device.shouldConsumeEvents) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Volume Change Alert"
                                                        message:@"Someone attempted to play/pause the music"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self pulseButton:self.multifunctionButton];
    }
}

- (void)boxDeviceDidLongPressMultifunctionButton:(BOXDevice *)device
{
    if (self.device.shouldConsumeEvents) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Volume Change Alert"
                                                        message:@"Someone attempted to play/pause the music"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self pulseButton:self.multifunctionButton];
    }
}

- (void)boxDeviceDidPressMinusButton:(BOXDevice *)device
{
    if (self.device.shouldConsumeEvents) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Volume Change Alert"
                                                        message:@"Someone attempted to lower the volume"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self pulseButton:self.minusButton];
    }
    
}

- (void)boxDeviceDidPressPlusButton:(BOXDevice *)device
{
    if (self.device.shouldConsumeEvents) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Volume Change Alert"
                                                        message:@"Someone attempted to increase the volume"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self pulseButton:self.plusButton];
    }
}

- (void)boxDeviceDidChangeAudioRouteStatus:(BOXDevice *)device
{
    [self updateDisplay];
}

- (void)boxDevice:(BOXDevice *)device didDisconnectWithError:(NSError *)error
{
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Disconnected"
                                    message:[NSString stringWithFormat:@"Disconnected from %@ ", device.name]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }

    [self.navigationController popViewControllerAnimated:YES];
    [self updateDisplay];
}

- (void)boxDeviceDidConnect:(BOXDevice *)device
{
    [self updateDisplay];
}

- (void)boxDevicePowerStateDidChange:(BOXDevice *)device
{
    [self updateDisplay];
}

#pragma mark Private

- (void)pulseButton:(UIButton *)button
{
    button.highlighted = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.highlighted = NO;
    });
}

- (void)updateDisplay
{
    self.isAudioRouteSegment.selectedSegmentIndex = (self.device.isCurrentAudioRoute ? 1 : 0);
    [self.consumeEventSwitch setOn:self.device.shouldConsumeEvents animated:NO];
}


@end
