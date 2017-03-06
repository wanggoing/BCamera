
#import <UIKit/UIKit.h>

typedef enum
{
    ProgressBarProgressStyleNormal,
    ProgressBarProgressStyleDelete,
} ProgressBarProgressStyle;

@interface ProgressBar : UIView

+ (ProgressBar *)getInstance;

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style;
- (void)setLastProgressToWidth:(CGFloat)width;

- (void)deleteLastProgress;
- (void)addProgressView;

- (void)stopShining;
- (void)startShining;

@end
