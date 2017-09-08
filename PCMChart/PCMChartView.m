
//
//  PCMChartView.m
//  PCMChart
//
//  Created by CIA on 2017/9/7.
//  Copyright © 2017年 CIA. All rights reserved.
//

#import "PCMChartView.h"
#import <CorePlot.h>

#define KPCMAmplitudePlotIdentifer @"KPCMAmplitudePlotIdentifer"

@interface PCMChartView()<CPTPlotSpaceDelegate,CPTPlotDataSource>
@property (nonatomic, strong) CPTXYGraph *plotGraph;
@property (nonatomic, strong) CPTGraphHostingView *plotHostingView;
@property (nonatomic, strong) SoundTrack *soundTrack;

//为了让Y轴上能显示出来需要处理一下
@property (nonatomic, assign) float yRatio;

@end


@implementation PCMChartView

-(void) drawPCMChartWithSoundTrack:(SoundTrack *)soundTrack{
    self.soundTrack = soundTrack;
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    hostingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:hostingView];
    self.plotHostingView = hostingView;
    
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostingView.bounds];
    self.plotGraph = graph;
    self.plotHostingView.hostedGraph = self.plotGraph;
    graph.defaultPlotSpace.allowsUserInteraction = YES;

    

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.plotGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:0] length:[NSNumber numberWithFloat:100]];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:-200] length:[NSNumber numberWithFloat:400]];
    
    self.plotGraph.paddingBottom = 0;
    self.plotGraph.paddingLeft = 10;
    self.plotGraph.paddingRight = 10;
    self.plotGraph.paddingTop = 0;
    
    self.plotGraph.plotAreaFrame.paddingLeft = 40;
    self.plotGraph.plotAreaFrame.paddingRight = 30;
    self.plotGraph.plotAreaFrame.paddingTop = 30;
    self.plotGraph.plotAreaFrame.paddingBottom = 20;
    
    self.plotGraph.plotAreaFrame.plotArea.delegate = self;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.plotGraph.axisSet;
    
    CPTColor *grayColor = [CPTColor colorWithCGColor:[UIColor colorWithWhite:0x99/255.0 alpha:1].CGColor];
    CPTColor *clearColor = [CPTColor colorWithCGColor:[UIColor clearColor].CGColor];
    
    CPTMutableLineStyle *axixLineStyle = [[CPTMutableLineStyle alloc] init];
    axixLineStyle.lineColor = grayColor;
    axixLineStyle.lineWidth = 1;
    
    CPTMutableLineStyle *clearAxixLineStyle = [[CPTMutableLineStyle alloc] init];
    clearAxixLineStyle.lineColor = clearColor;
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = grayColor;
    axisTextStyle.fontSize = 10;
    axisTextStyle.fontName = [UIFont systemFontOfSize:15].fontName;
    axisTextStyle.textAlignment = NSTextAlignmentCenter;
    
    CPTMutableLineStyle *axisGridLineStyle = [[CPTMutableLineStyle alloc] init];
    axisGridLineStyle.lineColor = [CPTColor colorWithCGColor:[UIColor colorWithWhite:0xee/255.0 alpha:1].CGColor];
    axisGridLineStyle.lineWidth = 1;
    
    
    //基本上大部分的频率是在1k以下的，所以这个地方设置为10
    self.yRatio = 1;
    if (soundTrack.bitPerSample == 8) {
        self.yRatio = 10;
    } else if (soundTrack.bitPerSample == 16){
        self.yRatio = 10;
    } else if (soundTrack.bitPerSample == 32){
        self.yRatio = 10;
    }
    
    CPTXYAxis *x = axisSet.xAxis;
    x.orthogonalPosition = 0;
    x.tickDirection = CPTSignPositive;
    x.axisLineStyle = axixLineStyle;
    x.majorTickLineStyle = axixLineStyle;
    x.minorTickLineStyle = axixLineStyle;
    x.majorGridLineStyle = axisGridLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    x.titleTextStyle = axisTextStyle;
    x.labelTextStyle = axisTextStyle;
    x.title = @"采样点";
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle = axixLineStyle;
    y.majorGridLineStyle = axisGridLineStyle;
    y.majorTickLineStyle = clearAxixLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalPosition = @0;
    y.titleTextStyle = axisTextStyle;
    y.labelTextStyle = axisTextStyle;
    y.title = [NSString stringWithFormat:@"振幅倍率（%.1f）",self.yRatio];
    y.titleOffset = 25;

    self.plotGraph.axisSet.axes = @[x, y];
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = KPCMAmplitudePlotIdentifer;
    
    // Make the data source line use curved interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plot.identifier;
    
    if ( [identifier isEqualToString:KPCMAmplitudePlotIdentifer] ) {
        numRecords = self.soundTrack.soundSampleCount;
    }
    return numRecords;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)plot.identifier;
    
    if ( [identifier isEqualToString:KPCMAmplitudePlotIdentifer] ) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            return @(index);
        } else {
            float value = self.soundTrack.soundAmplitudeDatas[index] / self.yRatio;
            return @(value);
        }
    }
    
    return num;
}


@end
