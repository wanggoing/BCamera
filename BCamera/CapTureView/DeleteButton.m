
#import "DeleteButton.h"

@implementation DeleteButton


//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//
//    if (self)
//    {
//        [self initalize];
//    }
//    return self;
//}
//
//- (void)initalize
//{
//    [self setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [self setImage:[UIImage imageNamed:@""] forState:UIControlStateDisabled];
//}

+ (DeleteButton *)getInstance
{
    DeleteButton *deleteButton = [[DeleteButton alloc] init];
    return deleteButton;
}

- (void)setButtonStyle:(DeleteButtonStyle)style
{
    self.style = style;
    switch (style)
    {
            //后退按钮
        case DeleteButtonStyleNormal:
        {
            self.enabled = YES;
            self.userInteractionEnabled = YES;
            [self setImage:[UIImage imageNamed:@"publish_icon_delete_normal-1"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"publish_icon_delete_disabled"] forState:UIControlStateHighlighted];
            
            break;
        }
        case DeleteButtonStyleDisable:
        {
            self.enabled = NO;
            self.userInteractionEnabled = NO;
            [self setImage:nil forState:UIControlStateNormal];
            break;
        }
            //删除按钮
        case DeleteButtonStyleDelete:
        {
            self.enabled = YES;
            self.userInteractionEnabled = YES;
            [self setImage:[UIImage imageNamed:@"publish_icon_delete_Normal"] forState:UIControlStateNormal];
            
            break;
        }
        default:
            break;
    }
}

@end
