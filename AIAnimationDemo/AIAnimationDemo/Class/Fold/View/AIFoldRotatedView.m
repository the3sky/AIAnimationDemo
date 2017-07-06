//
//  AIFoldRotatedView.m
//  AIAnimationDemo
//
//  Created by 艾泽鑫 on 2017/7/3.
//  Copyright © 2017年 艾泽鑫. All rights reserved.
//

#import "AIFoldRotatedView.h"
#import "UIImage+ImageEffects.h"
@interface AIFoldRotatedView ()<CAAnimationDelegate>

@property(nonatomic,weak)UIImageView *backView;
@property(nonatomic,weak)UIImageView *faceView;
@end
@implementation AIFoldRotatedView

- (instancetype)initWithFrame:(CGRect)frame Image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        //背景
        UIImageView *backView        = [[UIImageView alloc]initWithFrame:self.bounds];
        backView.image               = [image blurImage];
        self.backView                = backView;
        //前景
        UIImageView *faceImageView   = [[UIImageView alloc]initWithFrame:self.bounds];
        self.faceView                = faceImageView;
        faceImageView.image          = image;
        faceImageView.contentMode    = UIViewContentModeScaleToFill;
        
        [self addSubview:backView];
        [self addSubview:faceImageView];
        
    }
    return self;
}

/**
 折叠动画
 
 @param timing 节奏
 @param from 开始
 @param to 结束
 @param duration 持续时长
 @param delay 延时
 */
- (CABasicAnimation*)foldingAnimationTiming:(NSString *)timing from:(CGFloat)from to:(CGFloat)to duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay  {
    CABasicAnimation *rotateAnimation     = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotateAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:timing];
    rotateAnimation.fromValue             = @(from);
    rotateAnimation.toValue               = @(to);
    rotateAnimation.duration              = duration;
    rotateAnimation.delegate              = self;
    rotateAnimation.fillMode              = kCAFillModeForwards;
    rotateAnimation.removedOnCompletion   = NO;
    rotateAnimation.beginTime             = CACurrentMediaTime() + delay;
    return rotateAnimation;
}

/**
 旋转180度

 @param duration 持续时长
 @param delay 延时
 */
- (void)foldingAnimationMI_PWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {

    CABasicAnimation *animation1Layer          = [self foldingAnimationTiming:kCAMediaTimingFunctionEaseIn from:0 to:M_PI_2 duration:duration * .5 delay:delay ];
    [animation1Layer setValue:@"foldstarAnimation" forKey:@"name"];
    [self.layer addAnimation:animation1Layer forKey:@"animation1"];
}

- (void)rotatedXWithAngle:(CGFloat)angle {
    CATransform3D allTransoform   = CATransform3DIdentity;
    CATransform3D rotateTransform = CATransform3DMakeRotation(angle, 1., 0., 0.);
    allTransoform                 = CATransform3DConcat(allTransoform, rotateTransform);
    allTransoform                 = CATransform3DConcat(allTransoform, [self transform3d]);
    self.layer.transform          = allTransoform;
}

- (CATransform3D)transform3d {
    CATransform3D transform     = CATransform3DIdentity;
    transform.m34               = 2.5 / -2000;
    return transform;
}

#pragma mark -CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *name = [anim valueForKey:@"name"];
    if ([name isEqualToString:@"foldstarAnimation"]) {
        // 让faceview到最前面来
        [self bringSubviewToFront:self.backView];
        CABasicAnimation *foldendAnimation          = [self foldingAnimationTiming:kCAMediaTimingFunctionEaseOut from:M_PI_2 to:M_PI duration:1. delay:0 ];
        [foldendAnimation setValue:@"foldendAnimation" forKey:@"name"];
        [self.layer addAnimation:foldendAnimation forKey:nil];
        
    }else if([name isEqualToString:@"foldendAnimation"]){ //折叠完成
//        [self.layer removeAllAnimations];
        [self rotatedXWithAngle:0.];
        if (self.delegate && [self.delegate respondsToSelector:@selector(foldRotatedView:animationDidStop:finished:)]) {
            [self.delegate foldRotatedView:self animationDidStop:anim finished:flag];
        }else {
            AILog(@"未设置代理");
        }
    }
}


@end