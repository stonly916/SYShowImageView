//
//  SYShowImageView.m
//
//  Created by whg on 17/3/20.
//

#import "SYShowImageView.h"

@interface SYShowImageView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageview;

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIImageView *scrollImageview;
@property (nonatomic, strong) UIView *showBackView;

@end

@implementation SYShowImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImageView *imgView = [UIImageView new];
    imgView.clipsToBounds = YES;
    imgView.contentMode = self.contentMode;;
    [self addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.imageview = imgView;
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:tap];
}

- (void)tapClick
{
    UIViewController *vc = [self topViewController];
    [vc.view endEditing:YES];
    [self showImageView];
}

//获得顶层ViewController
- (UIViewController *)topViewController
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

- (void)showImageView
{
    if (!self.showBackView) {
        UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backView.backgroundColor = black_color;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissClick)];
        [backView addGestureRecognizer:tap];
        
        self.showBackView = backView;
        
        //1添加 UIScrollView
        //设置 UIScrollView的位置与屏幕大小相同
        _scrollview = [[UIScrollView alloc]initWithFrame:backView.frame];
        [backView addSubview:_scrollview];
        
        UIImageView  *imageview = [UIImageView new];
        UIImage *img = [self originImage:self.image scaleToSize:backView.size];
        imageview.image = img;
        imageview.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        self.scrollImageview = imageview;
        
        [_scrollview addSubview:self.scrollImageview];
        //设置UIScrollView的滚动范围和图片的真实尺寸一致
        _scrollview.contentSize = self.scrollImageview.size;
        _scrollview.bounces = YES;
        //设置代理scrollview的代理对象
        _scrollview.delegate = self;
        //设置最大伸缩比例
        _scrollview.maximumZoomScale = 2.0;
        //设置最小伸缩比例
        _scrollview.minimumZoomScale = 0.5;
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self.showBackView];
    _scrollview.zoomScale = 1.0;
    self.scrollImageview.center = self.showBackView.center;
}

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scrollImageview;
}

//中心点缩放
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    self.scrollImageview.center = self.showBackView.center;
}

- (void)dismissClick
{
    [self.showBackView removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageview.contentMode = self.contentMode;
    if (!self.imageview.image) {
        self.imageview.image = self.image;
    }
}

- (UIImage*)originImage:(UIImage *)image scaleToSize:(CGSize)size
{
    CGFloat scale = image.scale;
    CGSize oSize = image.size;
    CGSize fSize = CGSizeMake(oSize.width/scale, oSize.height/scale);
    //限制宽度
    if (fSize.width > size.width) {
        fSize.width = size.width;
        fSize.height = fSize.width/oSize.width * oSize.height;
    }
    //限制高度
    if (fSize.height > size.height) {
        fSize.height = size.height;
        fSize.width = fSize.height/oSize.height * oSize.width;
    }
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(fSize, NO, [UIScreen mainScreen].scale);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, fSize.width, fSize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end
