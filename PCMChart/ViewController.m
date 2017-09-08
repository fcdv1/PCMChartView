//
//  ViewController.m
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import "ViewController.h"
#import "WaveFileHelper.h"
#import "SoundTrackHelper.h"
#import "WAVFilePakage.h"
#import "PCMChartView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //int frequency,channelCount,bitPerChanel;
    //NSData *waveData = [NSData dataWithContentsOfFile:@"/Users/CIA/Desktop/wav文件分析/testWav.wav"];
    //NSData *pcmData = [WaveFileHelper findFrequench:&frequency channelCount:&channelCount bitPerChannel:&bitPerChanel withWaveData:waveData];
    
//    SoundTrack *track = [SoundTrack new];
//    track.maxAmplitude = 65535;
//    track.bitPerSample = 16;
//    [((PCMChartView *)self.view) drawPCMChartWithSoundTrack:track];
    
    NSArray *tracks = [SoundTrackHelper getSoundTracksWithWaveFile:[[NSBundle mainBundle] pathForResource:@"Device_Select" ofType:@"wav"]];
    [((PCMChartView *)self.view) drawPCMChartWithSoundTrack:tracks[0]];
    
 //  [self testSpliteFile];

}

-(void) testSpliteFile{
    //源文件数据长度 0x21a7010 byte， 双声道，采样44.1k，位深16
    //则最终样本个数为0x21a7010 / 4 = 0x869c04 = 8821764
    NSArray *tracks = [SoundTrackHelper getSoundTracksWithWaveFile:[[NSBundle mainBundle] pathForResource:@"testWav" ofType:@"wav"]];
    for (SoundTrack *track in tracks) {
        unsigned char *waveBuffer = NULL;
        int waveBufferlength = 0;
        
        //这个地方要注意了，我知道源文件的采样频率是16位，所以才可以这么搞
        int16_t *buffer = malloc(sizeof(int16_t) * track.soundSampleCount);
        for (int i = 0; i < track.soundSampleCount; i++) {
            buffer[i] = track.soundAmplitudeDatas[i];
        }
        generateWaveBuffer((unsigned char *)buffer,(uint32_t)track.soundSampleCount * 2, track.frequency, 1, track.bitPerSample, &waveBuffer, &waveBufferlength);
        NSData *data = [NSData dataWithBytes:waveBuffer length:waveBufferlength];
        NSString *homePath = @"/Users/CIA/Desktop/wav文件分析";
       // homePath = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
        if (track.trackType == KSoundTrackTypeLeft) {
            [data writeToFile:[NSString stringWithFormat:@"%@/left.wav",homePath] atomically:YES];
        } else {
            [data writeToFile:[NSString stringWithFormat:@"%@/right.wav",homePath] atomically:YES];
        }
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
