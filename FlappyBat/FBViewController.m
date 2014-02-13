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

@implementation FBViewController

#define FBBirdStartingFrame CGRectMake(100, CGRectGetMidY([[self view] frame])-25, 50, 50)

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
    [background setImage:[UIImage imageNamed:@"large.jpg"]];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    [[self view] addSubview:background];
    
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
    
    [self startTimers];
}

#define FBPipeDelay 1.8

-(void)startTimers {
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self setDisplayLink:link];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:FBPipeDelay target:self selector:@selector(addNewBar:) userInfo:nil repeats:YES];
    [self setBlockTimer:timer];
}

#define FBDownardBatAcceleration 15
#define FBSidewaysVelocity -120

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
        
        if ([block tag] == 0 && CGRectGetMinX([block frame]) < CGRectGetMinX([[self bat] frame])) {
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

-(void)incrementCount {
    NSInteger current = [[[[self counterLabel] attributedText] string] intValue];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSStrokeColorAttributeName: [UIColor blackColor],
                                 NSStrokeWidthAttributeName: @(-2)};
    NSAttributedString *attrib = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i", current+1] attributes:attributes];
    
    [[self counterLabel] setAttributedText:attrib];
}

#define FBHoleHeight 130
#define FBTopAndBottomPadding 50

-(void)addNewBar:(NSTimer *)timer {
    NSInteger possibleHoleLocationRange = CGRectGetHeight([[self view] frame])-FBHoleHeight-2*FBTopAndBottomPadding;
    NSInteger holeTop = arc4random()%possibleHoleLocationRange + FBTopAndBottomPadding;
    
    UIImageView *newTopBar = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth([[self view] frame]), 0, 50, holeTop)];
    [newTopBar setImage:[[UIImage imageNamed:@"pipe_upside_down.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 20, 0)]];
    [newTopBar setTag:1];
    
    CGFloat holeBottom = holeTop+FBHoleHeight;
    UIImageView *newBottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth([[self view] frame]), holeBottom, 50, CGRectGetHeight([[self view] frame])-holeBottom)];
    [newBottomBar setImage:[[UIImage imageNamed:@"pipe.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 0, 0, 0)]];
    
    [[self view] insertSubview:newTopBar belowSubview:[self counterLabel]];
    [[self view] insertSubview:newBottomBar belowSubview:[self counterLabel]];
    
    [[self blocks] addObject:newTopBar];
    [[self blocks] addObject:newBottomBar];
}

#define FBTapUpwardBatVelocity -5.5

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBatVelocity:FBTapUpwardBatVelocity];
}

-(void)failed {
    [[self blockTimer] invalidate];
    [self setBlockTimer:nil];
    
    [[self displayLink] invalidate];
    [self setDisplayLink:nil];
    
    [self performSelector:@selector(startOver) withObject:nil afterDelay:1];
}

-(void)startOver {
    [[self counterLabel] setAttributedText:nil];
    
    for (UIView *block in [self blocks]) {
        [block removeFromSuperview];
    }
    [[self blocks] removeAllObjects];
    
    [[self bat] setFrame:FBBirdStartingFrame];
    
    [self setBatVelocity:0];
    
    [self startTimers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
