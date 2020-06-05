//
//  ViewController.m
//  CASpringAnimationDemo
//
//  Created by Xx on 2020/6/5.
//  Copyright © 2020 Xx. All rights reserved.
//

#import "ViewController.h"
#import "SpringTopView.h"
#import "SpringTableView.h"
#import "UIView+JKFrame.h"

#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#define IPHONE_X \
({BOOL isPhoneX = NO;\
    if (@available(iOS 11.0, *)) {\
        isPhoneX = StatusBarHeight > 20.0;\
    }\
    (isPhoneX);})

/**
 *导航栏高度
 */
#define NavigationHeight (IPHONE_X ? 88 : 64)

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SpringTopView     *topView;
@property (nonatomic, strong) UIView            *navigationView;
@property (nonatomic, strong) SpringTableView   *tableView;
@property (nonatomic, assign) CGPoint           offset;
@property (nonatomic, assign) CGFloat           tableView_offset_y;
@property (nonatomic, assign) CGFloat           headerViewH;
@property (nonatomic, assign) BOOL              needAnimation;
@property (nonatomic, assign) NSInteger         enterTimes;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    

    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    _enterTimes++;
    
    if (_enterTimes == 1) {
        [self startAnimation];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    
    self.navigationController.navigationBarHidden = YES;
    
    _enterTimes = 0;

    self.headerViewH = 250;
    [self setupSubviews];
}

- (void)setupSubviews {
    
    _topView = [[SpringTopView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.headerViewH)];
    [self.view addSubview:_topView];
    
    _tableView = [[SpringTableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 55;
    _tableView.contentInset = UIEdgeInsetsMake(self.headerViewH - 34 , 0, 10, 0);
    [self.view addSubview:_tableView];
    [_tableView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
    
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, NavigationHeight)];
    _navigationView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_navigationView];
    _navigationView.alpha = 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

#pragma mark - KVODelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"panGestureRecognizer.state"]) {

        if (self.tableView.panGestureRecognizer.state == UIGestureRecognizerStateEnded && _needAnimation) {

            CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"position.y"];
            NSLog(@"%@ \n %@",NSStringFromCGRect(self.tableView.layer.frame), NSStringFromCGPoint(self.tableView.contentOffset));
            
            CGFloat endY= self.tableView.layer.position.y;
            CGFloat startY = 20 * (1 -(self.headerViewH+self.tableView.contentOffset.y)/34) + endY;
            springAnimation.fromValue = @(startY);
            springAnimation.toValue = @(endY);

            //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大 Defaults to one
            springAnimation.mass = 1;
            //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快 Defaults to 100
            springAnimation.stiffness = 800;
            //阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快 Defaults to 10
            springAnimation.damping = 10;
            //初始速率，动画视图的初始速度大小 Defaults to zero
            //速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
            springAnimation.initialVelocity = 25;

            //估算时间 返回弹簧动画到停止时的估算时间，根据当前的动画参数估算
            NSLog(@"====%f",springAnimation.settlingDuration);
//            springAnimation.duration = springAnimation.settlingDuration;
            springAnimation.duration = MAXFLOAT;

            //removedOnCompletion 默认为YES 为YES时，动画结束后，恢复到原来状态
            springAnimation.removedOnCompletion = NO;
            //    springAnimation.fillMode = kCAFillModeBoth;

            [self.tableView.layer addAnimation:springAnimation forKey:@"springAnimation"];
        }
    }else{

        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //获取偏移量
    self.offset = scrollView.contentOffset;
    
    if (self.offset.y < 0) {
        _topView.hidden = NO;
        if (self.offset.y < - self.headerViewH) {
            
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -self.headerViewH);
            _topView.jk_top = 0;
            _needAnimation = YES;
        } else if (self.offset.y >= -(self.headerViewH - 34)) {

            //让topview 以1/2的速度跟随collectionview滑动
            _topView.jk_top = -((self.headerViewH - 34) + (self.offset.y)) > 0 ? 0 : (-((self.headerViewH - 34) + (self.offset.y)))*0.5;
            _needAnimation = NO;
        }else {
            _topView.jk_top = -((self.headerViewH - 34) + (self.offset.y)) > 0 ? 0 : (-((self.headerViewH - 34) + (self.offset.y)))*0.5;
            _needAnimation = YES;
        }
    } else {
        
        //因为collectionview背景色是透明的  为了防止从cell的缝隙中看到topview  在collectionview划出屏幕时隐藏掉
        _topView.hidden = YES;
    }
    
    self.navigationView.alpha = (self.offset.y + (_headerViewH - 34))/ (_headerViewH - 34 - NavigationHeight);

    self.tableView_offset_y = self.offset.y + (self.headerViewH - 34);
    NSLog(@"tableView_offset_y = %lf",self.tableView_offset_y);
    NSLog(@"tableView_offset_y / KK_SafeAreaTopHeight = %lf",self.tableView_offset_y/NavigationHeight);

    NSLog(@"offset.y = %lf",self.offset.y);
    
}

#pragma mark - PrivateMethod
//首次进入时手动开启动画
- (void)startAnimation {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.duration = 1;
    animation.fromValue = @(self.tableView.layer.position.y);
    animation.toValue = @(self.tableView.layer.position.y + 34);
    animation.repeatCount = 0;
    animation.removedOnCompletion = NO;
    [animation setBeginTime:0.0];
    
    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"position.y"];
                NSLog(@"%@ \n %@",NSStringFromCGRect(self.tableView.layer.frame), NSStringFromCGPoint(self.tableView.contentOffset));

    CGFloat endY= self.tableView.layer.position.y;
    CGFloat startY = 34 + endY;
    
    springAnimation.fromValue = @(startY);
    springAnimation.toValue = @(endY);

    //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大 Defaults to one
    springAnimation.mass = 1;
    //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快 Defaults to 100
    springAnimation.stiffness = 800;
    //阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快 Defaults to 10
    springAnimation.damping = 10;
    //初始速率，动画视图的初始速度大小 Defaults to zero
    //速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
    springAnimation.initialVelocity = 25;

    //估算时间 返回弹簧动画到停止时的估算时间，根据当前的动画参数估算
    NSLog(@"====%f",springAnimation.settlingDuration);
    springAnimation.duration = MAXFLOAT;
    //removedOnCompletion 默认为YES 为YES时，动画结束后，恢复到原来状态
    springAnimation.removedOnCompletion = NO;
    //    springAnimation.fillMode = kCAFillModeBoth;
    [springAnimation setBeginTime:1];
    
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    aniGroup.duration = MAXFLOAT;
    aniGroup.animations = @[animation,springAnimation];
    aniGroup.repeatCount = 0;
    [self.tableView.layer addAnimation:aniGroup forKey:@"basicAnimation"];
}

//因为topView是被tableView盖着的所以想要topView的按钮响应事件需要调用testHit
//这里需要tableView重写touchesBegan方法  实现点击事件透传
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    if (CGRectContainsPoint(CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.headerViewH-34),point)) {
        [self.topView hitTest:CGPointMake(point.x, point.y+self.tableView_offset_y*0.5) withEvent:event];
    }
}

@end
