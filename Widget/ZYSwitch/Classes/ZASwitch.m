//
//  ZASwitch.m
//  swtichBtn
//
//  Created by ZhuoApp on 2017/3/29.
//  Copyright © 2017年 ZhuoApp. All rights reserved.
//

#import "ZASwitch.h"
#import <objc/message.h>

#define SWITCHBTN_HEIGHT 36
#define SWITCHBTN_RATIO  1.75          /*按钮比例*/
#define ANIMATION_DURATION 0.2

#define  DEFAULT_OFF_COLOR  [UIColor colorWithRed:194.0/255.0f green:195.0/255.0f blue:196.0/255.0f alpha:1.0f]
#define  DEFAULT_ON_COLOR  [UIColor colorWithRed:75.0/255.0f green:161.0/255.0f blue:245.0/255.0f alpha:1.0f]

#define TAG_ON_VIEW 200
#define TAG_OFF_VIEW 201

@interface ZASwitch ()
{
    CGPoint _panPrePoint;
    BOOL _selected;
}

@property (nonatomic , strong) UIImageView * iconView;   /*icon视图*/
@property (nonatomic , assign) BOOL isAnimation;    /*是否正在动画*/
@property (nonatomic , strong) UIView * backgroundView;  /*滑动背景视图*/
@property (nonatomic , strong) UIView * bottomView ;     /*底部区域视图*/

@property (nonatomic , strong) NSMutableArray * targetActionArr;              /*对象和触发方法*/

@end

@implementation ZASwitch
#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self initProperty];
        
        [self initWidget];
    }
    return self;
}

-(void)initProperty{
    self.isOn = YES;
    
    _onColor = DEFAULT_ON_COLOR;
    _offColor = DEFAULT_OFF_COLOR;
   
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapSwitch)];
    [self addGestureRecognizer:tap];
}

- (void)initWidget{
    
    _bottomView = ({
        UIView * frameView = [[UIView alloc]initWithFrame:CGRectMake(3, 6, self.bounds.size.width - 6, self.bounds.size.height - 12)];
        frameView.tag = 100;
        [frameView.layer masksToBounds];
        frameView.clipsToBounds = YES;
        frameView.layer.cornerRadius = frameView.bounds.size.height * 0.5 + 0.5;
        [self addSubview:frameView];
        
        frameView;
    });
    
    
    _backgroundView = ({
        UIView * backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2 * (_bottomView.bounds.size.width), _bottomView.bounds.size.height)];
        backgroundView.center = CGPointMake(CGRectGetMaxX(_bottomView.frame) - _bottomView.frame.size.height * 0.5, _bottomView.bounds.size.height * 0.5 );
        [_bottomView addSubview:backgroundView];
        //加载滑动色块
        for (int i = 0; i < 2; i ++) {
            UIView * colorView = [[UIView alloc]initWithFrame:CGRectMake(backgroundView.bounds.size.width * 0.5 * i, 0, backgroundView.bounds.size.width, backgroundView.bounds.size.height)];
            [backgroundView addSubview:colorView];
            
            if (i == 0) {
                colorView.tag = TAG_ON_VIEW;
                colorView.backgroundColor = _onColor;
            }
            else{
                colorView.tag = TAG_OFF_VIEW;
                colorView.backgroundColor = _offColor;
            }
        }
        backgroundView;
    });
    
    //加阴影
    UIImageView * shadowImageView = [[UIImageView alloc]initWithFrame:_bottomView.frame];
    shadowImageView.image = [UIImage imageNamed:@"switch_btn_shadow"];
    [self addSubview:shadowImageView];
    
    //加载滑动图标
    _iconView = ({
        UIImage * icon = [UIImage imageNamed:@"switch_btn_icon"];
        UIImageView * iconView = [[UIImageView alloc]initWithImage:icon];
        iconView.userInteractionEnabled = YES;
        CGFloat ratio = iconView.bounds.size.width / iconView.bounds.size.height;
        iconView.bounds = CGRectMake(0, 0, SWITCHBTN_HEIGHT * ratio * 1.1 , SWITCHBTN_HEIGHT * 1.1);
        
        iconView.center = CGPointMake(CGRectGetMaxX(_bottomView.frame) - _bottomView.frame.size.height * 0.5, self.bounds.size.height * 0.5 + 2);
        [self addSubview:iconView];
        
        //添加滑动手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanSwitch:)];
        [iconView addGestureRecognizer:pan];
        
        iconView;
    });
    
    //NSLog(@"backviewCenter:%@----iconViewCenter%@",[NSValue valueWithCGPoint:_backgroundView.center],[NSValue valueWithCGPoint:_iconView.center]);
}
#pragma mark - 重写设置方法

-(void)setFrame:(CGRect)frame{
    
    frame = CGRectMake(frame.origin.x, frame.origin.y, SWITCHBTN_HEIGHT * SWITCHBTN_RATIO ,  SWITCHBTN_HEIGHT);
    
    [super setFrame:frame];
}

-(void)setBounds:(CGRect)bounds{
    
    bounds = CGRectMake(0, 0, SWITCHBTN_HEIGHT * SWITCHBTN_RATIO ,  SWITCHBTN_HEIGHT);
    
    [super setBounds:bounds];
}

-(BOOL)isSelected{
    
    return _isOn;
}

-(void)setSelected:(BOOL)selected{
    
    self.isOn = selected;
}

-(void)setOnColor:(UIColor *)onColor{
    
    UIView * onView = [self viewWithTag:TAG_ON_VIEW];
    if (onView) {
        onView.backgroundColor = onColor;
    }
    
    _onColor = onColor;
}

-(void)setOffColor:(UIColor *)offColor{
    UIView * offView = [self viewWithTag:TAG_OFF_VIEW];
    if (offView) {
        offView.backgroundColor = offColor;
    }
    _offColor = offColor;
}

-(void)setIsOn:(BOOL)isOn animated:(BOOL)animated{
    
    _isOn = isOn;
    
    [self handleAnimation:animated];
}

-(void)setIsOn:(BOOL)isOn{
    
    [self setIsOn:isOn animated:NO];
}

-(void)setStatusChangedBlock:(SwitchBtnStatusDidChangedBlock)block{
    
    _statusBlock = [block copy];
}

-(NSMutableArray *)targetActionArr{
    if (!_targetActionArr) {
        _targetActionArr = [NSMutableArray arrayWithCapacity:1];
    }
    return _targetActionArr;
}

#pragma mark - 手势事件
-(void)didTapSwitch{
    if (!self.isAnimation) {
        
        _isOn = !_isOn;
        [self handleAnimation:YES];
    }
}

-(void)didPanSwitch:(UIPanGestureRecognizer *)pan{
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"拖动开始");
        _panPrePoint = [pan locationInView:_bottomView];
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint  panPoint = [pan locationInView:_bottomView];
        ////NSLog(@"拖动中%@",[NSValue valueWithCGPoint:panPoint]);
        CGFloat diff = panPoint.x - _panPrePoint.x;
        _panPrePoint = panPoint;
        
        if (_backgroundView.center.x + diff < CGRectGetMinX(_bottomView.frame) + _bottomView.frame.size.height * 0.5){
            diff = CGRectGetMinX(_bottomView.frame) + _bottomView.frame.size.height * 0.5 - _backgroundView.center.x;
        }
        else if(_backgroundView.center.x + diff > CGRectGetMaxX(_bottomView.frame) - _bottomView.frame.size.height * 0.5) {
            diff = CGRectGetMaxX(_bottomView.frame) - _bottomView.frame.size.height * 0.5 - _backgroundView.center.x;
        }
        
        CGPoint backViewCenter =CGPointMake(_backgroundView.center.x + diff , _backgroundView.center.y);
        CGPoint iconVIewCenter = CGPointMake(_backgroundView.center.x + diff, _iconView.center.y);
        
        _backgroundView.center = backViewCenter;
        _iconView.center = iconVIewCenter;
    }
    else if (pan.state == UIGestureRecognizerStateEnded){
        //NSLog(@"拖动结束");
        
        self.isOn = _iconView.center.x > self.bounds.size.width * 0.5 ;
        [self handleAnimation:YES];
    }
}


#pragma mark - 动画效果
-(void)handleAnimation:(BOOL)animated{
    
    UIView * frameView = _bottomView;
    
    CGPoint backViewCenter;
    CGPoint iconVIewCenter;
    if (self.isOn) {
        backViewCenter = CGPointMake(CGRectGetMaxX(frameView.frame) - frameView.frame.size.height * 0.5, _backgroundView.center.y);
        iconVIewCenter = CGPointMake(backViewCenter.x, _iconView.center.y);
    }
    else{
        backViewCenter = CGPointMake(CGRectGetMinX(frameView.frame) + frameView.frame.size.height * 0.5, _backgroundView.center.y);
        iconVIewCenter = CGPointMake(backViewCenter.x, _iconView.center.y);
    }
    
    if (animated) {
        self.isAnimation = YES;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            
            _backgroundView.center = backViewCenter;
            _iconView.center = iconVIewCenter;
        } completion:^(BOOL finished) {
            
            self.isAnimation = NO;
            [self handleCallBack];
        }];
    }
    else{
        _backgroundView.center = backViewCenter;
        _iconView.center = iconVIewCenter;
        
    }
}

- (void)handleCallBack{
    
    if (_statusBlock) {
        _statusBlock(self);
    }
    if (_delegate && [_delegate respondsToSelector:@selector(switchBtnStatuChanged:)]) {
        [_delegate switchBtnStatuChanged:self];
    }
    if (self.targetActionArr.count != 0) {
        
        for (NSDictionary * targetActionDict in self.targetActionArr) {
            
            id target = [targetActionDict objectForKey:@"target"];
            NSString * selStr = [targetActionDict objectForKey:@"action"];
            SEL sel = NSSelectorFromString(selStr);
            //                    IMP imp = [target methodForSelector:sel];
            //                    void (*func)(id,SEL,id) = (void *)imp;
            //                    func(target,sel,self);
            
            ((void(*)(id,SEL,id))objc_msgSend)(target ,sel,self);
        }
    }
}

#pragma mark - 重写添加target方法
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    
    NSString * actionStr = NSStringFromSelector(action);
    
    NSDictionary * targetActionDict = @{@"target":target,@"action":actionStr};
    [self.targetActionArr addObject:targetActionDict];
}

@end
