//
//  KBOpenglView4_0.m
//  KBOpengl
//
//  Created by chengshenggen on 6/6/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBOpenglView4_0.h"
#import <CoreMotion/CoreMotion.h>
#import <GLKit/GLKit.h>

@interface KBOpenglView4_0 ()

@property(nonatomic,strong)UIButton *testButton;

@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)KBMotionView *motionView;

@property(nonatomic,strong)CMMotionManager *motionManager;
@property(nonatomic,assign)CGFloat time;

@property(nonatomic,assign)CGPoint *firstPoint;

@end

@implementation KBOpenglView4_0

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.motionView];
        [self addSubview:self.bottomView];
        _time = 10;
        [self startDeviceMotion];
    }
    return self;
}

-(void)render{
    
}



#pragma mark - private methods
- (void)startDeviceMotion {
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    _motionManager.gyroUpdateInterval = 1.0f / 60;
    _motionManager.showsDeviceMovementDisplay = YES;
    
    
    
    //欧拉角
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        if (motion.attitude) {
            
            float degress_x = GLKMathRadiansToDegrees(motion.attitude.roll);
            
            
//            (degress_x/90.0) * ;
            
            
            NSLog(@"degress_x :%f",degress_x);
            _bottomView.center = CGPointMake(_bottomView.center.x,self.frame.size.height-(degress_x/90.0)*0.5*self.frame.size.height);
            if (CGRectIntersectsRect(_bottomView.frame, _motionView.frame)) {
                NSLog(@"CGRectIntersectsRect");
            }
        }
    }];
    
    //重力感应、
    /*
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        CGFloat dx,dy;
        if (fabs(motion.gravity.x) <0.05) {
            dx = 0;
        }else{
            dx = motion.gravity.x;
        }
        if (fabs(motion.gravity.y) <0.05) {
            dy = 0;
        }else{
            dy = motion.gravity.y;
        }
        
        _motionView.center =  CGPointMake(0.5*dx*_time+_motionView.center.x, 0.5*-(dy)*_time+_motionView.center.y);
        CGRect frame = _motionView.frame;
        if (frame.origin.x <0) {
            frame.origin.x = 0;
        }
        if (frame.origin.y<0) {
            frame.origin.y = 0;
        }
        if (frame.origin.x > self.frame.size.width-frame.size.width) {
            frame.origin.x = self.frame.size.width-frame.size.width;
        }
        if (frame.origin.y > self.frame.size.height-frame.size.height) {
            frame.origin.y = self.frame.size.height-frame.size.height;
        }
        _motionView.frame = frame;
        
        if (CGRectIntersectsRect(_bottomView.frame, frame)) {
            NSLog(@"CGRectIntersectsRect");
        }
        
        
    }];*/

    
}

-(void)stopDeviceMotion{
    [_motionManager stopDeviceMotionUpdates];
}

-(UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 40)];
        _bottomView.backgroundColor = [UIColor redColor];
        
    }
    return _bottomView;
}

-(KBMotionView *)motionView{
    if (_motionView == nil) {
        _motionView = [[KBMotionView alloc] init];
        _motionView.frame = CGRectMake(0, 0, 100, 100);

    }
    return _motionView;
}

@end


@interface KBMotionView ()

@end

@implementation KBMotionView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}


@end

