//
//  SoundTrackHelper.h
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundTrack.h"

@interface SoundTrackHelper : NSObject

+(NSArray <SoundTrack *> *)getSoundTracksWithWaveFile:(NSString *)waveFilePath;

+(NSArray <SoundTrack *> *)getSoundTracksWithPCMData:(NSData *)pcmData frequencey:(int)frequency channelCount:(int)channelCount bitPerChannel:(int)bitPerChannel;


@end
