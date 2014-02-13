//
//  FBViewController.m
//  FlappyBat
//
//  Created by Jake Heiser on 2/11/14.
//  Copyright (c) 2014 jakeheiser. All rights reserved.
//

#import "FBViewController.h"

@interface FBViewController ()

@end

//#define FBUpwardBatVelocity -5.5
#define FBDownardBatAcceleration 15
#define FBHoleHeight 130
#define FBSidewaysVelocity -120
#define FBPipeDelay 1.8

#define FBBirdStartingFrame CGRectMake(100, CGRectGetMidY([[self view] frame])-25, 50, 50)

@implementation FBViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
    [background setImage:[UIImage imageNamed:@"large.jpg"]];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    [[self view] addSubview:background];

    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMidY([[self view] frame])-90, CGRectGetWidth([[self view] frame]), 50)];
    [startLabel setText:@"Tap to start!"];
    [startLabel setTextColor:[UIColor whiteColor]];
    [startLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [startLabel setTextAlignment:NSTextAlignmentCenter];
    [[self view] addSubview:startLabel];
    [self setStartLabel:startLabel];
    
    UIImageView *bird = [[UIImageView alloc] initWithFrame:FBBirdStartingFrame];
    [bird setContentMode:UIViewContentModeScaleAspectFit];
    [bird setAnimationImages:@[[UIImage imageNamed:@"bat0.png"],
                               [UIImage imageNamed:@"bat1.png"],
                               [UIImage imageNamed:@"bat2.png"],
                               [UIImage imageNamed:@"bat3.png"]]];
    [bird setAnimationDuration:0.7];
    [bird startAnimating];
    [[self view] addSubview:bird];
    [self setBat:bird];
    
    UILabel *counter = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth([[self view] frame]), 80)];
    [counter setTextAlignment:NSTextAlignmentCenter];
    [counter setFont:[UIFont systemFontOfSize:80.0f]];
    [[self view] addSubview:counter];
    [self setCounterLabel:counter];
    
    [self setBlocks:[NSMutableArray array]];
}

-(void)startTimers {
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self setDisplayLink:link];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:FBPipeDelay target:self selector:@selector(addNewBar:) userInfo:nil repeats:YES];
    [self setBlockTimer:timer];
}

-(void)tick:(CADisplayLink *)link {
    self.batVelocity += [link duration]*FBDownardBatAcceleration;
    
    [[self bat] setFrame:CGRectOffset([[self bat] frame], 0, [self batVelocity])];
    
    UIView *removeBlock = nil;
    for (UIView *block in [self blocks]) {
        [block setFrame:CGRectOffset([block frame], [link duration]*FBSidewaysVelocity, 0)];
        
        if (CGRectIntersectsRect([[self bat] frame], [block frame])) {
            [self failed];
            break;
        }
        
        if ([block tag] == 0 && CGRectGetMinX([block frame]) > CGRectGetMinX([[self bat] frame]) && CGRectGetMinX([block frame]) < CGRectGetMaxX([[self bat] frame])) {
            [block setTag:1];
            [self incrementCount];
        }
        
        if (CGRectGetMaxX([block frame]) < 0)
            removeBlock = block;
    }
    if (removeBlock) {
        [removeBlock removeFromSuperview];
        [[self blocks] removeObject:removeBlock];
    }
    
    if (CGRectGetMaxY([[self bat] frame]) >= CGRectGetHeight([[self view] frame])) {
        [self failed];
    }
}

-(void)incrementCount {//NSStrokeColorAttributeName
    NSInteger current = [[[[self counterLabel] attributedText] string] intValue];
    NSAttributedString *attrib = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i", current+1] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSStrokeColorAttributeName: [UIColor blackColor]}];

    [[self counterLabel] setAttributedText:attrib];
}

-(void)addNewBar:(NSTimer *)timer {
    NSInteger topAndBottomPadding = 50;
    NSInteger possibleHoleTops = CGRectGetHeight([[self view] frame])-FBHoleHeight-2*topAndBottomPadding;
    NSInteger middlePoint = arc4random()%possibleHoleTops + topAndBottomPadding;
    
    UIImageView *newTopBar = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth([[self view] frame]), 0, 50, middlePoint)];
    [newTopBar setImage:[[UIImage imageNamed:@"pipe_upside_down.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 20, 0)]];
    [newTopBar setTag:1];
    
    CGFloat bottomTop = middlePoint+FBHoleHeight;
    UIImageView *newBottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth([[self view] frame]), bottomTop, 50, CGRectGetHeight([[self view] frame])-bottomTop)];
    [newBottomBar setImage:[[UIImage imageNamed:@"pipe.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 0, 0, 0)]];
    
    [[self view] insertSubview:newTopBar belowSubview:[self counterLabel]];
    [[self view] insertSubview:newBottomBar belowSubview:[self counterLabel]];

    [[self blocks] addObject:newTopBar];
    [[self blocks] addObject:newBottomBar];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![[self startLabel] isHidden]) {
        [[self startLabel] setHidden:YES];
        [self startTimers];
    }
    
    [self setBatVelocity:FBUpwardBatVelocity];
}

-(void)failed {
    [[self counterLabel] setAttributedText:nil];
    
    [[self blockTimer] invalidate];
    [self setBlockTimer:nil];
    
    [[self displayLink] invalidate];
    [self setDisplayLink:nil];
    
    [self performSelector:@selector(startOver) withObject:nil afterDelay:1];
}

-(void)startOver {
    for (UIView *block in [self blocks]) {
        [block removeFromSuperview];
    }
    [[self blocks] removeAllObjects];
    
    [[self bat] setFrame:FBBirdStartingFrame];
    
    [[self startLabel] setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
