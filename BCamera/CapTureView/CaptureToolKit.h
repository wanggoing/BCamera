//
//  CaptureToolKit.h
//  Confessions
//
//  Created by UTOUU on 16/7/5.
//  Copyright © 2016年 com.utouu.Confessions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CaptureToolKit : NSObject

+ (void)setView:(UIView *)view toSizeWidth:(CGFloat)width;
+ (void)setView:(UIView *)view toSizeHeight:(CGFloat)height;
+ (void)setView:(UIView *)view toOriginX:(CGFloat)x;
+ (void)setView:(UIView *)view toOriginY:(CGFloat)y;
+ (void)setView:(UIView *)view toOrigin:(CGPoint)origin;

/**
 create outPutPathFile

 @return YES/NO
 */
+ (BOOL)createVideoFolderIfNotExist;
/**
 获取保存视频路径

 @return Path
 */
+ (NSString *)getVideoSaveFilePathString;
/**
 获取合并视频路径

 @return Path
 */
+ (NSString *)getVideoMergeFilePathString;

@end
