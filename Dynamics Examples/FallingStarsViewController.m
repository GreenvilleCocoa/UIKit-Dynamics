//
//  FallingStarsViewController.m
//  Dynamics Examples
//
//  Created by Ryan Poolos on 7/7/14.
//  Copyright (c) 2014 Frozen Fire Studios, Inc. All rights reserved.
//

#import "FallingStarsViewController.h"

@interface FallingStarsViewController () <UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collisions;

@end

@implementation FallingStarsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Falling Stars"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    [self setGravity:[[UIGravityBehavior alloc] initWithItems:nil]];
    [self.gravity setMagnitude:0.5];
    
    self.collisions = [[UICollisionBehavior alloc] initWithItems:nil];
    [self.collisions setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-1024.0, 0.0, -2024.0, 0.0)];
    [self.collisions setCollisionDelegate:self];
    
    
    [self setAnimator:[[UIDynamicAnimator alloc] initWithReferenceView:self.view]];
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collisions];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Spawn a new star every 15 frames
    [NSTimer scheduledTimerWithTimeInterval:15.0/60.0 target:self selector:@selector(createNewStarAtRandomPoint) userInfo:nil repeats:YES];
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    UIView *starView = (UIView *)item;
    
    CGRect rect = CGRectMake(0.0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), 2024.0);
    
    if (CGRectContainsRect(rect, starView.frame)) {
        [self starDidFallOffscreen:starView];
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
    UIView *starView = (UIView *)item;
    
    CGRect rect = CGRectMake(0.0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), 2024.0);
    
    if (CGRectContainsRect(rect, starView.frame)) {
        [self starDidFallOffscreen:starView];
    }
}

#pragma mark - Dragging

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    UIView *starView = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.gravity removeItem:starView];
        [self.collisions removeItem:starView];
        
        [starView setCenter:[gesture locationInView:starView.superview]];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint originalCenter = starView.center;
        
        CGPoint translation = [gesture translationInView:self.view];
        [gesture setTranslation:CGPointZero inView:self.view];
        
        CGPoint newCenter = CGPointMake(translation.x + originalCenter.x, translation.y + originalCenter.y);
        
        [starView setCenter:newCenter];
        [self.animator updateItemUsingCurrentState:starView];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self.gravity addItem:starView];
        [self.collisions addItem:starView];
        
        CGPoint velocity = [gesture velocityInView:self.view];
        
        CGFloat angle = atan2(velocity.y, velocity.x);
        CGFloat magnitude = sqrt(pow(velocity.x, 2.0) + pow(velocity.y, 2.0));
        
        UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[starView] mode:UIPushBehaviorModeInstantaneous];
        [push setAngle:angle magnitude:magnitude / 100.0];
        [self.animator addBehavior:push];
    }
}

#pragma mark - Stars

- (void)createNewStarAtRandomPoint
{
    [self createNewStarAtPoint:CGPointMake(arc4random() % (int)CGRectGetWidth(self.view.bounds), - 128.0)];
}

- (void)createNewStarAtPoint:(CGPoint)point
{
    UIImageView *starView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star"]];
    [starView setCenter:point];
    
    [self.view addSubview:starView];
    
    // Add gravity to star
    [self.gravity addItem:starView];
    
    // Add collisions to star
    [self.collisions addItem:starView];
    
    // Add gesture to star
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [starView addGestureRecognizer:pan];
    
    [starView setUserInteractionEnabled:YES];
}

- (void)starDidFallOffscreen:(UIView <UIDynamicItem> *)star
{
    [self.gravity removeItem:star];
    [star removeFromSuperview];
}

@end
