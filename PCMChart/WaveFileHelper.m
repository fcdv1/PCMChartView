
//
//  WaveFileHelper.m
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import "WaveFileHelper.h"

@implementation WaveFileHelper

+(NSData *) findFrequench:(int *)frequency channelCount:(int*)channelCount bitPerChannel:(int*)bitPerChannel withWaveData:(NSData *)waveData{
    if (waveData.length < 30) {
        return nil;
    }
    
    if (*(uint32_t *)(&((unsigned char *)waveData.bytes)[8]) != 0x45564157) {
        //只有wave格式的才可以
        return nil;
    }
    
    if (*(uint32_t *)(&((unsigned char *)waveData.bytes)[12]) != 0x20746d66) {
        //没有FMT
        return nil;
    }
    
    *channelCount = *(uint16_t *)(&((unsigned char *)waveData.bytes)[0x16]);
    *frequency = *(uint32_t *)(&((unsigned char *)waveData.bytes)[0x18]);
    *bitPerChannel = *(uint16_t *)(&((unsigned char *)waveData.bytes)[0x22]);
    
    //开始寻找data trunk
    uint32_t nextTrakLocation = 0x14 + *(uint32_t *)(&((unsigned char *)waveData.bytes)[0x10]);
    BOOL findData = NO;
    while (nextTrakLocation < waveData.length) {
        if (*(uint32_t *)(&((unsigned char *)waveData.bytes)[nextTrakLocation]) == 0x61746164) {
            //data
            findData = YES;
            uint32_t dataLength = *(uint32_t *)(&((unsigned char *)waveData.bytes)[nextTrakLocation + 4]);
            NSData *subData = [waveData subdataWithRange:NSMakeRange(nextTrakLocation + 8, dataLength)];
            return subData;
        }
        
        nextTrakLocation += *(uint32_t *)(&((unsigned char *)waveData.bytes)[nextTrakLocation + 4]);
    }
    return nil;
}

@end
