
#import "ProgressBar.h"
#import "CaptureToolKit.h"

@interface ProgressBar ()

@property (strong, nonatomic) NSMutableArray *progressViewArray;

@property (strong, nonatomic) UIView *barView;
@property (strong, nonatomic) UIImageView *progressIndicator;

@property (strong, nonatomic) NSTimer *shiningTimer;

@end

@implementation ProgressBar

+ (ProgressBar *)getInstance
{
    ProgressBar *progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, BAR_H)];
    return progressBar;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    self.autoresizingMask = UIViewAutoresizingNone;
    self.progressViewArray = [[NSMutableArray alloc] init];
    
    // BarView
    _barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, BAR_H)];
    [self addSubview:_barView];
    
    // Indicator
    _progressIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_W, INDICATOR_H)];
    _progressIndicator.backgroundColor = [UIColor greenColor];
    [self addSubview:_progressIndicator];
}

- (UIView *)getProgressView
{
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, BAR_H)];
    progressView.backgroundColor = [UIColor whiteColor];
    progressView.autoresizesSubviews = YES;
    return progressView;
}

- (void)refreshIndicatorPosition
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView)
    {
        _progressIndicator.center = CGPointMake(0, self.frame.size.height / 2);
        return;
    }
    
    _progressIndicator.center = CGPointMake(MIN(lastProgressView.frame.origin.x + lastProgressView.frame.size.width, self.frame.size.width - _progressIndicator.frame.size.width / 2 + 2), self.frame.size.height / 2);
}

- (void)onTimer:(NSTimer *)timer
{
    [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
        _progressIndicator.alpha = 0;
    } completion:^(BOOL finished)
    {
        [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
            _progressIndicator.alpha = 1;
        }];
    }];
}

#pragma mark - method
- (void)startShining
{
    self.shiningTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)stopShining
{
    [_shiningTimer invalidate];
    self.shiningTimer = nil;
    _progressIndicator.alpha = 1;
}

- (void)addProgressView
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    CGFloat newProgressX = 0.0f;
    
    if (lastProgressView)
    {
        CGRect frame = lastProgressView.frame;
        frame.size.width -= 1;
        lastProgressView.frame = frame;
        
        newProgressX = frame.origin.x + frame.size.width + 1;
    }
    
    UIView *newProgressView = [self getProgressView];
    [CaptureToolKit setView:newProgressView toOriginX:newProgressX];
    
    [_barView addSubview:newProgressView];
    
    [_progressViewArray addObject:newProgressView];
}

- (void)setLastProgressToWidth:(CGFloat)width
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView)
    {
        return;
    }
    
    [CaptureToolKit setView:lastProgressView toSizeWidth:width];
    [self refreshIndicatorPosition];
}

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView)
    {
        return;
    }
    
    switch (style)
    {
        case ProgressBarProgressStyleDelete:
        {
            lastProgressView.backgroundColor = [UIColor redColor];
            _progressIndicator.hidden = YES;
        }
            break;
        case ProgressBarProgressStyleNormal:
        {
            lastProgressView.backgroundColor = [UIColor clearColor];
            _progressIndicator.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)deleteLastProgress
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView)
    {
        return;
    }
    
    [lastProgressView removeFromSuperview];
    [_progressViewArray removeLastObject];
    
    _progressIndicator.hidden = NO;
    
    [self refreshIndicatorPosition];
}

@end
