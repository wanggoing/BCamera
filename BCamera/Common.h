//
//  Common.h
//  BCamera
//
//  Created by UTOUU on 17/2/24.
//  Copyright © 2017年 王朝晖. All rights reserved.
//

#ifndef Common_h
#define Common_h

// Progress Bar
#define ProgressBarShowLoading(_Title_) [SNLoading showWithTitle:_Title_]
#define ProgressBarDismissLoading(_Title_) [SNLoading hideWithTitle:_Title_]
#define ProgressBarUpdateLoading(_Title_, _DetailsText_) [SNLoading updateWithTitle:_Title_ detailsText:_DetailsText_]

#import "SNLoading.h"

#endif /* Common_h */

/**
 * 录制时长
 */
#define MIN_VIDEO_DUR 5.0f
#define MAX_VIDEO_DUR 30.0f
/**
 * ProgressBar
 */
#define BAR_H 2
#define BAR_MARGIN 2

#define INDICATOR_W 2
#define INDICATOR_H 2

#define TIMER_INTERVAL .8f
/**
 * 中英文转
 */
#define CURR_LANG ([[NSLocale preferredLanguages] objectAtIndex: 0])
static inline NSString* GBLocalizedString(NSString *translation_key)
{
    NSString * string = NSLocalizedString(translation_key, nil );
    if (![CURR_LANG isEqual:@"en"] && ![CURR_LANG hasPrefix:@"zh-Hans"])
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        string = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    
    return string;
}
