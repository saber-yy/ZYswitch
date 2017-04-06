//
//  ZYViewController.m
//  ZYSwitch
//
//  Created by 502353919@qq.com on 04/06/2017.
//  Copyright (c) 2017 502353919@qq.com. All rights reserved.
//

#import "ZYViewController.h"
#import "ZASwitch.h"
@interface ZYViewController ()

@end

@implementation ZYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ZASwitch * sa =  [[ZASwitch alloc]initWithFrame:CGRectMake(100, 200, 30, 50)];
    [self.view addSubview:sa];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
