//
//  PMViewController.m
//  PMLinkLabel
//
//  Created by paperman on 09/04/2022.
//  Copyright (c) 2022 paperman. All rights reserved.
//

#import "PMViewController.h"
#import <PMLinkLabel/PMLinkLabel.h>

@interface PMViewController ()

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    PMLinkLabel *ll = [[PMLinkLabel alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:ll];
    
    [ll setText:@"我已阅读并同意《隐私政策一》《隐私政策二》《隐私政策三》"];
    [ll setTextColor:[UIColor colorWithRed:0.463 green:0.463 blue:0.463 alpha:1.000]];
    [ll setLinkColor:[UIColor colorWithRed:0.910 green:0.325 blue:0.322 alpha:1.000]];
    [ll setHighlightedLinkBackgroundColor:[UIColor lightGrayColor]];
    [ll setFont:[UIFont systemFontOfSize:16]];

    [ll setLinkRange:[ll.text rangeOfString:@"《隐私政策一》"] tapHandler:^{
        NSLog(@"PMLOG 《隐私政策一》");
    }];
    [ll setLinkRange:[ll.text rangeOfString:@"《隐私政策二》"] tapHandler:^{
        NSLog(@"PMLOG 《隐私政策二》");
    }];
    [ll setLinkRange:[ll.text rangeOfString:@"《隐私政策三》"] tapHandler:^{
        NSLog(@"PMLOG 《隐私政策三》");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
