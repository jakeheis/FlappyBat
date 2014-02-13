//
//  FBViewController.h
//  FlappyBat
//
//  Created by Jake Heiser on 2/11/14.
//  Copyright (c) 2014 jakeheiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBViewController : UIViewController

@property (strong, nonatomic) UIView *bat;
@property (strong, nonatomic) UILabel *counterLabel;
@property (strong, nonatomic) NSMutableArray *blocks;

@property (assign, nonatomic) CGFloat batVelocity;

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) NSTimer *blockTimer;

@end
