//
//  RecordingViewController.m
//  BCamera
//
//  Created by UTOUU on 17/2/24.
//  Copyright © 2017年 王朝晖. All rights reserved.
//

#import "RecordingViewController.h"

@interface RecordingViewController ()

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) UIView *leftEyeView;
@property (nonatomic, strong) UIView *rightEyeView;
@property (nonatomic, strong) UIView *mouthView;
@property (nonatomic, strong) UIView *faceView;

@property (strong, nonatomic) UIView *maskView;

@property (strong, nonatomic) CameraRecorder *recorder;
@property (strong, nonatomic) ProgressBar *progressBar;
@property (strong, nonatomic) DeleteButton *deleteButton;
@property (strong, nonatomic) UIButton *okButton;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *flashButton;

@property (assign, nonatomic) BOOL initalized;
@property (assign, nonatomic) BOOL isProcessingData;

@end

@implementation RecordingViewController

- (void)btnEnabled:(BOOL)enabled {
    self.closeButton.userInteractionEnabled  = enabled;
    self.switchButton.userInteractionEnabled = enabled;
    self.okButton.userInteractionEnabled     = enabled;
    self.flashButton.userInteractionEnabled  = enabled;
    self.deleteButton.userInteractionEnabled = enabled;
}

#pragma mark - CameraRecorderDelegate
- (void)didStartCurrentRecording:(NSURL *)fileURL
{
    NSLog(@"正在录制视频: %@", fileURL);
    [self.progressBar addProgressView];
    [_progressBar stopShining];
    
    [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
    
    [self btnEnabled:NO];
}

- (void)didFinishCurrentRecording:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDuration:(CGFloat)totalDuration error:(NSError *)error
{
    if (error)
    {
        NSLog(@"录制视频错误:%@", error);
    }
    NSLog(@"录制视频完成: %@", outputFileURL);
    
    [_progressBar startShining];
    self.isProcessingData = NO;
    
    [self btnEnabled:YES];
}

- (void)didRemoveCurrentVideo:(NSURL *)fileURL totalDuration:(CGFloat)totalDuration error:(NSError *)error
{
    if (error) {
        NSLog(@"删除视频错误: %@", error);
    }
    NSLog(@"删除了视频: %@", fileURL);
    NSLog(@"现在视频长度: %f", totalDuration);
    
    [self btnEnabled:YES];
    
    [self changeOKButtonImage:totalDuration];
    
    if ([_recorder getVideoCount] > 0)
    {
        [_deleteButton setStyle:DeleteButtonStyleNormal];
    }else
    {
        [_deleteButton setStyle:DeleteButtonStyleDisable];
    }
}
- (void)doingCurrentRecording:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDuration:(CGFloat)totalDuration
{
    [_progressBar setLastProgressToWidth:videoDuration / MAX_VIDEO_DUR * _progressBar.frame.size.width];
    
    [self changeOKButtonImage:videoDuration + totalDuration];
}

- (void)didRecordingMultiVideosSuccess:(NSArray *)outputFilesURL
{
    NSLog(@"RecordingMultiVideosSuccess: %@", outputFilesURL);
    
    NSString *success = GBLocalizedString(@"Success");
    ProgressBarDismissLoading(success);
    
    self.isProcessingData = NO;
}

//录制成功
- (void)didRecordingVideosSuccess:(NSURL *)outputFileURL
{
    [self btnEnabled:YES];
    NSLog(@"didRecordingVideosSuccess: %@", outputFileURL);
    
    NSString *success = GBLocalizedString(@"Success");
    ProgressBarDismissLoading(success);
    
    self.isProcessingData = NO;
}

//录制失败
- (void)didRecordingVideosError:(NSError*)error;
{
    [self btnEnabled:YES];
    NSLog(@"didRecordingVideosError: %@", error.description);
    
    NSString *failed = GBLocalizedString(@"Failed");
    ProgressBarDismissLoading(failed);
    
    self.isProcessingData = NO;
}

- (void)didTakePictureSuccess:(NSString *)outputFile
{
    NSLog(@"didTakePictureSuccess: %@", outputFile);
}

- (void)didTakePictureError:(NSError*)error
{
    NSLog(@"didTakePictureError: %@", error.description);
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 页面person时的过度页面
    self.maskView = [self getMaskView];
    [self.view addSubview:_maskView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    if (_initalized)
    {
        return;
    }
    
    [self initRecorder];
    
    if (![CaptureToolKit createVideoFolderIfNotExist])
    {
        [CaptureToolKit createVideoFolderIfNotExist];
    }
    
    [self initProgressBar];
    [self initRecordButton];
    [self initDeleteButton];
    [self initOKButton];
    [self initTopLayout];
    [self hideMaskView];
    
    self.initalized = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRecordingAppDelegate)name:@"STOP_RECORD" object:nil];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOP_RECORD" object:nil];
}
- (void)stopRecordingAppDelegate {
    [self stopRecording];
    [_recordButton setImage:[UIImage imageNamed:@"icon_paishe"] forState:UIControlStateNormal];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

- (void)initRecorder
{
    self.recorder = [[CameraRecorder alloc] init];
    _recorder.delegate = self;
    _recorder.previewLayer.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [self.view.layer addSublayer:_recorder.previewLayer];
}

- (void)initProgressBar
{
    self.progressBar = [ProgressBar getInstance];
    [CaptureToolKit setView:_progressBar toOriginY:0];
    [self.view insertSubview:_progressBar belowSubview:self.view];
    [_progressBar startShining];
}

- (void)initRecordButton
{
    //录制按钮
    self.recordButton = [[UIButton alloc]init];
    [_recordButton setImage:[UIImage imageNamed:@"icon_paishe"] forState:UIControlStateNormal];
    [_recordButton setImage:[UIImage imageNamed:@"icon_paishe_down"] forState:UIControlStateHighlighted];
    [CaptureToolKit setView:_recordButton toSizeWidth:[UIImage imageNamed:@"icon_paishe"].size.width];
    [CaptureToolKit setView:_recordButton toSizeHeight:[UIImage imageNamed:@"icon_paishe"].size.height];
    [CaptureToolKit setView:_recordButton toOrigin:CGPointMake((self.view.frame.size.width/2) - ([UIImage imageNamed:@"icon_paishe"].size.width/2), self.view.frame.size.height - 100 *(([[UIScreen mainScreen] bounds].size.width / 375)))];
    [self.view insertSubview:_recordButton belowSubview:self.view];
#pragma mark 录制长按
    // Tap Gesture
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(longPressGestureRecognized:)];
    gesture.minimumPressDuration = 0.3;
    [_recordButton addGestureRecognizer: gesture];
}

- (void)initDeleteButton
{
    if (_isProcessingData)
    {
        return;
    }
    
    self.deleteButton = [DeleteButton getInstance];
    [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
    [CaptureToolKit setView:_deleteButton toSizeWidth:[UIImage imageNamed:@"publish_icon_delete_normal-1"].size.width];
    [CaptureToolKit setView:_deleteButton toSizeHeight:[UIImage imageNamed:@"publish_icon_delete_normal-1"].size.height];
    [CaptureToolKit setView:_deleteButton toOrigin:CGPointMake(65*([[UIScreen mainScreen] bounds].size.width/375), self.view.frame.size.height - _deleteButton.frame.size.height - 100*([[UIScreen mainScreen] bounds].size.width/375))];
    [_deleteButton addTarget:self action:@selector(pressDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint center = _deleteButton.center;
    center.y = _recordButton.center.y;
    _deleteButton.center = center;
    
    [self.view insertSubview:_deleteButton belowSubview:self.view];
}


- (void)initOKButton
{
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [CaptureToolKit setView:_okButton toSizeWidth:[UIImage imageNamed:@"publish_icon_sure_normal"].size.width];
    [CaptureToolKit setView:_okButton toSizeHeight:[UIImage imageNamed:@"publish_icon_sure_disabled"].size.height];
    [CaptureToolKit setView:_okButton toOrigin:CGPointMake(_recordButton.center.x + 80*([[UIScreen mainScreen] bounds].size.width/375), self.view.frame.size.height)];
    [_okButton addTarget:self action:@selector(pressOKButton) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint center = _okButton.center;
    center.y = _recordButton.center.y;
    _okButton.center = center;
    [self.view insertSubview:_okButton belowSubview:self.view];
}
- (void)changeOKButtonImage:(CGFloat)duration{
    if (duration >= MIN_VIDEO_DUR) {
        //完成按钮
        _okButton.enabled = YES;
        [_okButton setUserInteractionEnabled:YES];
        [_okButton setImage:[UIImage imageNamed:@"publish_icon_sure_normal"] forState:UIControlStateNormal];
        [_okButton setImage:[UIImage imageNamed:@"publish_icon_sure_disabled"] forState:UIControlStateHighlighted];
    }else{
        _okButton.enabled = NO;
        [_okButton setUserInteractionEnabled:NO];
        [_okButton setImage:nil forState:UIControlStateNormal];
    }
}
- (void)initTopLayout
{
    // 关闭
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setFrame:CGRectMake(0, 20, 44, 44)];
    [_closeButton setImage:[UIImage imageNamed:@"icon_close_normal"] forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"icon_close_disabled"] forState:UIControlStateDisabled];
    [_closeButton setImage:[UIImage imageNamed:@"icon_close_selected"] forState:UIControlStateSelected];
    [_closeButton setImage:[UIImage imageNamed:@"icon_close_selected"] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(pressCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
    // 前后摄像头转换
    _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_switchButton setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 44 * 2, 20, 44, 44)];
    [_switchButton setImage:[UIImage imageNamed:@"icon_shoot_normal"] forState:UIControlStateNormal];
    [_switchButton setImage:[UIImage imageNamed:@"icon_shoot_disabled"] forState:UIControlStateDisabled];
    [_switchButton setImage:[UIImage imageNamed:@"icon_shoot_selected"] forState:UIControlStateSelected];
    [_switchButton setImage:[UIImage imageNamed:@"icon_shoot_selected"] forState:UIControlStateHighlighted];
    [_switchButton addTarget:self action:@selector(pressSwitchButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_switchButton];
    
    // 闪光灯
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashButton setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 44, 20, 44, 44)];
    [_flashButton setImage:[UIImage imageNamed:@"publish_icon_light_normal"] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"publish_icon_light_selected"] forState:UIControlStateHighlighted];
    [_flashButton setImage:[UIImage imageNamed:@"publish_icon_light_selected"] forState:UIControlStateSelected];
    [_flashButton setImage:[UIImage imageNamed:@"publish_icon_light_disabled"] forState:UIControlStateDisabled];
    [_flashButton addTarget:self action:@selector(pressFlashButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];
    _flashButton.enabled = _recorder.isTorchSupported;
    _flashButton.enabled = !([_recorder isFrontCameraSupported] && [_recorder isFrontCamera]);
}

//关闭页面
- (void)pressCloseButton
{
    if ([_recorder getVideoCount] > 0)
    {
        NSString *cancel = GBLocalizedString(@"NO");
        NSString *abandon = GBLocalizedString(@"YES");
        NSString *cancelVideoHint = GBLocalizedString(@"CancelVideoHint?");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:cancelVideoHint message:nil delegate:self cancelButtonTitle:abandon otherButtonTitles:cancel, nil];
        [alertView show];
    }
    else
    {
        [self dropTheVideo];
    }
}
//切换摄像头
- (void)pressSwitchButton
{
    _switchButton.selected = !_switchButton.selected;
    
    // 换成前摄像头
    if (_recorder.isFrontCamera)
    {
        [_recorder openTorch:NO];
        _flashButton.selected = NO;
        _flashButton.enabled = YES;
    }
    else
    {
        _flashButton.enabled = NO;
    }
    [_recorder switchCamera];
}

//闪光灯
- (void)pressFlashButton
{
    _flashButton.selected = !_flashButton.selected;
    [_recorder openTorch:_flashButton.selected];
}

- (void)pressDeleteButton
{
    if (_deleteButton.style == DeleteButtonStyleNormal)
    {
        // 第一次按下删除按钮
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
        [_deleteButton setButtonStyle:DeleteButtonStyleDelete];
    }
    else if (_deleteButton.style == DeleteButtonStyleDelete)
    {
        // 第二次按下删除按钮
        [self deleteLastVideo];
        [_progressBar deleteLastProgress];
        
        if ([_recorder getVideoCount] > 0)
        {
            [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        }
        else
        {
            [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
        }
    }
}

- (void)pressOKButton
{
    if (_isProcessingData)
    {
        return;
    }
    // Progress bar
    NSString *title = GBLocalizedString(@"Processing");
    ProgressBarDismissLoading(title);
    
    [_recorder endVideoRecording];
    self.isProcessingData = YES;
}

//- (UIImage*)capturePicture
//{
//    UIImage *image = [_recorder capturePicture];
//    
//    UIView *flashView = [[UIView alloc] initWithFrame: _recorder.previewLayer.frame];
//    [flashView setBackgroundColor:[UIColor whiteColor]];
//    [flashView setAlpha:0.f];
//    [[[self view] window] addSubview:flashView];
//    
//    [UIView animateWithDuration:.4f animations:^{
//        [flashView setAlpha:1.f];
//        [flashView setAlpha:0.f];
//    } completion:^(BOOL finished) {
//        [flashView removeFromSuperview];
//    }];
//    return image;
//}

// 放弃本次视频，并且关闭页面
- (void)dropTheVideo
{
    [_recorder deleteAllVideo];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
// 删除最后一段视频
- (void)deleteLastVideo
{
    if ([_recorder getVideoCount] > 0)
    {
        [_recorder deleteLastVideo];
    }
}
- (void)hideMaskView
{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.maskView.frame;
        frame.origin.y = self.maskView.frame.size.height;
        self.maskView.frame = frame;
    }];
}

- (UIView *)getMaskView
{
    UIView *maskView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    maskView.backgroundColor = [UIColor whiteColor];
    return maskView;
}

#pragma mark - Tap Gesture
- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *) gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self startRecording];
            [_recordButton setImage:[UIImage imageNamed:@"icon_paishe_down"] forState:UIControlStateNormal];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self stopRecording];
            [_recordButton setImage:[UIImage imageNamed:@"icon_paishe"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}
#pragma mark - Video Recording
- (void)startRecording
{
    if (_isProcessingData) {
        return;
    }
    
    if (_deleteButton.style == DeleteButtonStyleDelete)
    {
        // 取消删除
        [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleNormal];
        return;
    }
    
    self.isProcessingData = YES;
    NSString *filePath = [CaptureToolKit getVideoSaveFilePathString];
    [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
}

- (void)stopRecording
{
    if (!_isProcessingData)
    {
        return;
    }
    [_recorder stopCurrentVideoRecording];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self dropTheVideo];
    }
}

@end
