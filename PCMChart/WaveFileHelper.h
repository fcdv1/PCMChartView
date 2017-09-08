//
//  WaveFileHelper.h
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaveFileHelper : NSObject


+(NSData *) findFrequench:(int *)frequency channelCount:(int*)channelCount bitPerChannel:(int*)bitPerChannel withWaveData:(NSData *)waveData;

@end
