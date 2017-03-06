//
//  CameraRecorder.h
//  BCamera
//
//  Created by UTOUU on 17/2/24.
//  Copyright © 2017年 王朝晖. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "CaptureToolKit.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol CameraRecorderDelegate <NSObject>

@optional
- (void)didStartCurrentRecording:(NSURL *)fileURL;

- (void)didFinishCurrentRecording:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDuration:(CGFloat)totalDuration error:(NSError *)error;

- (void)doingCurrentRecording:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDuration:(CGFloat)totalDuration;

- (void)didRemoveCurrentVideo:(NSURL *)fileURL totalDuration:(CGFloat)totalDuration error:(NSError *)error;

@required
/**
 录制多个视频片段成功

 @param outputFilesURL Array * <Steing *>
 */
- (void)didRecordingMultiVideosSuccess:(NSArray *)outputFilesURL;
/**
 录制视频成功

 @param outputFileURL 导出路径
 */
- (void)didRecordingVideosSuccess:(NSURL *)outputFileURL;
/**
 录制视频错误

 @param error error
 */
- (void)didRecordingVideosError:(NSError*)error;
/**
 获取视频截图

 @param outputFile 导出路径
 */
- (void)didTakePictureSuccess:(NSString *)outputFile;

/**
 获取视频截图失败

 @param error error
 */
- (void)didTakePictureError:(NSError*)error;

@end

@interface CameraRecorder : NSObject <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, weak) id<CameraRecorderDelegate> delegate;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (CGFloat)getTotalVideoDuration;
- (NSUInteger)getVideoCount;

- (void)deleteLastVideo;
- (void)deleteAllVideo;

- (void)startRecordingToOutputFileURL:(NSURL *)fileURL;
- (void)stopCurrentVideoRecording;
- (void)endVideoRecording;

- (BOOL)isTorchOn;
- (BOOL)isFrontCamera;

- (BOOL)isCameraSupported;
- (BOOL)isFrontCameraSupported;
- (BOOL)isTorchSupported;

- (void)switchCamera;
- (void)openTorch:(BOOL)open;

- (void)focusInPoint:(CGPoint)touchPoint;

@end


