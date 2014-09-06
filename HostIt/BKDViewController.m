//
//  BKDViewController.m
//  BoxKitDemo
//
//  Created by Cristian Filipov on 6/13/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "BKDViewController.h"
#import "BOXDevice.h"
#import "BKDDeviceViewController.h"

@interface BKDCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation BKDCell

@end

@interface BKDViewController () <UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *devices;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BKDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.devices = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak typeof(self) wself = self;
    [BOXDevice findDevices:^(BOXDevice *device, BOOL *stop, NSError *error) {
        BOOL isVisible = wself.isViewLoaded && wself.view.window;
        
        if (![wself.devices containsObject:device]) {
            [wself.devices addObject:device];
        }
        [wself.tableView reloadData];
        
        // Stop scanning when this view controller isn't visible
        *stop = !isVisible;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }

    UIViewController *destinationViewController = [segue destinationViewController];

    if ([destinationViewController isKindOfClass:[UINavigationController class]]) {
        destinationViewController =
        [(UINavigationController *)destinationViewController topViewController];
    }

    if ([destinationViewController isKindOfClass:[BKDDeviceViewController class]]) {
        BKDDeviceViewController *deviceVC = (BKDDeviceViewController *)destinationViewController;
        deviceVC.device = self.devices[selectedIndexPath.row];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOXDevice *device = self.devices[indexPath.row];
    BKDCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BKDCell" forIndexPath:indexPath];
    cell.colorView.backgroundColor = device.deviceColor;
    cell.nameLabel.text = device.name;
    if (device.IsConnectable) {
        cell.nameLabel.textColor = [UIColor blackColor];
    }
    else {
        cell.nameLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

@end
