//
//  SoundTrack.h
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    //左声道
    KSoundTrackTypeLeft,
    //右声道
    KSoundTrackTypeRight,
} SoundTrackType;


@interface SoundTrack : NSObject

//声道标示
@property (nonatomic, assign) SoundTrackType trackType;

//音频振幅数据
@property (nonatomic, assign) long *soundAmplitudeDatas;

//声音样本数量
@property (nonatomic, assign) long soundSampleCount;

//最大振幅
@property (nonatomic, assign) int maxAmplitude;

//采样精度
@property (nonatomic, assign) int bitPerSample;

//采样频率
@property (nonatomic, assign) int frequency;




@end
