



//
//  TestAmplitudeViewController.m
//  PCMChart
//
//  Created by CIA on 2017/9/8.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import "TestAmplitudeViewController.h"
@import AVFoundation;

@interface TestAmplitudeViewController ()<AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSData *origalData;
@property (strong, nonatomic) NSData *playData;

@property (assign, nonatomic) float currentRate;
@property (strong, nonatomic) AVAudioRecorder *recorder;

@property (strong, nonatomic) NSData *recordData;

@end

@implementation TestAmplitudeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   self.origalData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testWav" ofType:@"wav"]];
    self.currentRate = 1;
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    //2.设置  录音参数
    //音频格式
    setting[AVFormatIDKey] =@(kAudioFormatLinearPCM);
    //音频采样率
    setting[AVSampleRateKey] =@(22050);
    //音频通道数
    setting[AVNumberOfChannelsKey] =@(2);
    //线性音频的位深度
    setting[AVLinearPCMBitDepthKey] =@(16);
    //音频编码质量
    setting[AVEncoderAudioQualityKey] =@(AVAudioQualityHigh);
    
    NSString *saveFile = [NSString stringWithFormat:@"/Users/CIA/Desktop/record.wav"];
    self.recorder=[[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:saveFile] settings:setting error:nil];
    self.recorder.delegate = self;
}

- (IBAction)alplitudeSliderChange:(UISlider *)sender {
    self.currentRate = sender.value;
    self.titleLabel.text = [NSString stringWithFormat:@"振幅变动倍率（%.1f）",sender.value];
    
}

-(NSData *)getWaveDataWithRate:(float)rate{
    //这个源文件是双声道，16位的
    int beginLocation = 0x2a;
    if (self.recordData) {
        beginLocation = 0xffc; //录音的数据从这里开始的
        self.playData = [self deepCopyData:self.recordData];
    } else {
         self.playData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testWav" ofType:@"wav"]];
    }
    int dataLength = *((uint32_t *)(self.playData.bytes + beginLocation));
    int sampleCount = dataLength/2;
    int16_t *beginAddress = (int16_t *)(self.playData.bytes + beginLocation + 4);
    int value = 0;
    int over = 0;
    for (int i = 0; i < sampleCount; i++) {
        value = beginAddress[i];
        value *= rate;
        if (value > 32700) {
            value = 32700;
            over += 1;
        } else if (value < -32700){
            value = -32700;
            over += 1;
        }
        beginAddress[i] = value;
    }
    [self.playData writeToFile:@"/Users/CIA/Desktop/音乐扩大振幅.wav" atomically:YES];
    return self.playData;
}

-(NSData *)deepCopyData:(NSData *)data{
    void *copyedData = malloc(data.length);
    memcpy(copyedData, data.bytes, data.length);
    return [NSData dataWithBytes:copyedData length:data.length];
}

- (IBAction)playButtonPressed:(id)sender {
    if (self.player) {
        [self.player pause];
    }
    
    NSData *playData = [self getWaveDataWithRate:self.currentRate];
    self.player = [[AVAudioPlayer alloc] initWithData:playData error:nil];
    [self.player play];
}

#pragma mark - 录音
- (IBAction)recordButtonPressed:(UIButton *)sender {
    [self.player stop];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.recorder record];
}
- (IBAction)recordFinish:(UIButton *)sender {
    [self.recorder stop];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
}

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    self.recordData = [NSData dataWithContentsOfFile:@"/Users/CIA/Desktop/record.wav"];

}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    NSLog(@"出错了");
}


@end
