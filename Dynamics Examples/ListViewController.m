//
//  ListViewController.m
//  Dynamics Examples
//
//  Created by Ryan Poolos on 7/7/14.
//  Copyright (c) 2014 Frozen Fire Studios, Inc. All rights reserved.
//

#import "ListViewController.h"
#import "FallingStarsViewController.h"

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *viewControllers;
}

@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewControllers = @[[[FallingStarsViewController alloc] init]];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    UIViewController *viewController = viewControllers[indexPath.row];
    
    [cell.textLabel setText:viewController.title];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = viewControllers[indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
