


//
//  SoundTrackHelper.m
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import "SoundTrackHelper.h"
#import "WaveFileHelper.h"

@implementation SoundTrackHelper

+(NSArray <SoundTrack *> *)getSoundTracksWithWaveFile:(NSString *)waveFilePath{
    int frequency,channelCount,bitPerChanel;
    NSData *waveData = [NSData dataWithContentsOfFile:waveFilePath];
    NSData *pcmData = [WaveFileHelper findFrequench:&frequency channelCount:&channelCount bitPerChannel:&bitPerChanel withWaveData:waveData];
    if (pcmData) {
        return [self getSoundTracksWithPCMData:pcmData frequencey:frequency channelCount:channelCount bitPerChannel:bitPerChanel];
    }
    return nil;
}

+(NSArray <SoundTrack *> *)getSoundTracksWithPCMData:(NSData *)pcmData frequencey:(int)frequency channelCount:(int)channelCount bitPerChannel:(int)bitPerChannel{
    int bytePerChannel = bitPerChannel/8;
    int bytePerSample = bytePerChannel * channelCount;
    long sampleCount = (long)pcmData.length / bytePerSample;
    if (channelCount > 2 || channelCount == 0) {
        return nil;
    }
    if (bitPerChannel != 8 && bitPerChannel != 16 && bitPerChannel != 32) {
        return nil;
    }
    
    NSMutableArray *tracks = [NSMutableArray new];
    if (channelCount == 1) {
        SoundTrack *left = [SoundTrack new];
        left.trackType = KSoundTrackTypeLeft;
        left.maxAmplitude = pow(2, bitPerChannel) - 1;
        left.frequency = frequency;
        left.soundSampleCount = sampleCount;
        left.soundAmplitudeDatas = malloc(sizeof(long) * sampleCount);
        left.bitPerSample = bitPerChannel;
        [tracks addObject:left];
        for (int i = 0; i < sampleCount; i++) {
            long value = 0;
            if (bitPerChannel == 8) {
                value = ((int8_t *)pcmData.bytes)[i];
            } else if (bitPerChannel == 16){
                value = ((int16_t *)pcmData.bytes)[i];
            } else if (bitPerChannel == 32){
                value = ((int32_t *)pcmData.bytes)[i];
            }
            left.soundAmplitudeDatas[i] = value;
        }
    } else if (channelCount == 2){
        SoundTrack *left = [SoundTrack new];
        left.trackType = KSoundTrackTypeLeft;
        left.maxAmplitude = pow(2, bitPerChannel) - 1;
        left.frequency = frequency;
        left.soundSampleCount = sampleCount;
        left.bitPerSample = bitPerChannel;
        left.soundAmplitudeDatas = malloc(sizeof(long) * sampleCount);
        [tracks addObject:left];
        SoundTrack *right = [SoundTrack new];
        right.trackType = KSoundTrackTypeRight;
        right.maxAmplitude = pow(2, bitPerChannel) - 1;
        right.frequency = frequency;
        right.soundSampleCount = sampleCount;
        right.bitPerSample = bitPerChannel;
        right.soundAmplitudeDatas = malloc(sizeof(long) * sampleCount);
        [tracks addObject:right];
        for (long i = 0; i < sampleCount; i++) {
            long leftValue = 0;
            long rightValue = 0;
            if (bitPerChannel == 8) {
                leftValue = ((int8_t *)pcmData.bytes)[i * 2];
                rightValue = ((int8_t *)pcmData.bytes)[i * 2 + 1];
            } else if (bitPerChannel == 16){
                leftValue = ((int16_t *)pcmData.bytes)[i * 2];
                rightValue = ((int16_t *)pcmData.bytes)[i * 2 + 1];
            } else if (bitPerChannel == 32){
                leftValue = ((int32_t *)pcmData.bytes)[i * 2];
                rightValue = ((int32_t *)pcmData.bytes)[i * 2 + 1];
            }
            left.soundAmplitudeDatas[i] = leftValue;
            right.soundAmplitudeDatas[i] = rightValue;
        }
    }
    return tracks;
}

@end
