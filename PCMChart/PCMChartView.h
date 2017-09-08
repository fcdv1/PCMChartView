//
//  PCMChartView.h
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundTrack.h"

@interface PCMChartView : UIView

-(void) drawPCMChartWithSoundTrack:(SoundTrack *)soundTrack;

@end
