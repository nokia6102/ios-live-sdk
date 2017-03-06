# 又拍云 iOS 直播 SDK(动态库) 使用说明         
***注: 从4.0.0 版本之后 SDK 改为了动态库形式.***


## 1 SDK 概述     

此 `SDK` 包含推流和拉流两部分，支持美颜滤镜、水印、连麦等全套直播功能。                
此 `SDK` 中的播放器、采集器、推流器均可单独使用。        


基于此 `SDK` 结合 __upyun__ 直播平台可以快速构建直播应用。

[UPYUN 直播平台自主配置流程](http://docs.upyun.com/live/) 

  
## 2 SDK使用说明

### 2.1 运行环境和兼容性

```UPLiveSDKDll.framework``` 支持 `iOS 8` 及以上系统版本；     
支持 `ARMv7`，`ARM64` 架构。请使用真机进行开发和测试。     

```UPLiveSDKDll.framework``` 接口支持 Swift 3 调用，参考 [DemoSwift3](http://test86400.b0.upaiyun.com/iossdk/UPLiveSDkDemoSwift3.zip) 。 

### 2.2 安装使用说明

	
#### 手动安装方法：

直接将 `UPLiveService`文件夹拖拽到目标工程目录。

```
//文件结构：

UPLiveService 文件夹
├── GPUImage                 //视频处理依赖第三方库 GPUImage  
├── UPAVCapturer             //UPAVCapturer 音视频采集模块, 直播接口。
└── UPLiveSDKDll.framework   //framework 包含播放器`UPAVPlayer`和推流器`UPAVStreamer`

```

#### 2.3 工程设置：     

```TARGET -> Build Settings -> Enable bitcode```： 设置为 NO  			


```TARGET -> General -> Embedded Binaries```： 添加选择 UPLiveSDKDll.framework



***注: 如果需要 app 退出后台仍然不间断推流直播，需要设置 ```TARGET -> Capabilities -> Backgroud Modes:ON    √ Audio, AirPlay,and Picture in Picture```***	



#### 2.4 工程依赖：

`AVFoundation.framework`

`QuartzCore.framework`

`OpenGLES.framework`

`AudioToolbox.framework`

`VideoToolbox.framework`

`Accelerate.framework`

`libbz2.1.0.tbd`

`libiconv.tbd`

`libz.tbd`

`CoreMedia.framework`

`CoreTelephony.framework`

`SystemConfiguration.framework`

`libc++.tbd`

`CoreMotion.framework`



***注: 此 `SDK` 已经包含 `FFMPEG 3.0` , 不建议自行再添加 `FFMPEG` 库 , 如有特殊需求, 请联系我们***       


## 3 功能特性

### 3.1 推流端功能特性 （采集器 ＋ 推流器）


* 音频编码：`AAC` 

* 视频编码：`H.264`

* 支持音频，视频硬件编码

* 推流协议：`RTMP`

* 支持前后置摄像头切换

* 支持目标码率设置		

* 支持拍摄帧频设置

* 支持美颜滤镜

* 支持横屏拍摄

* 支持单音频推流

* 支持静音推流	

* 支持连麦推流



### 3.2 播放端功能特性 （播放器）

* 支持播放直播源和点播源，支持播放本地视频文件。

* 支持视频格式：`HLS`, `RTMP`, `FLV`，`mp4` 等视频格式 
	
* 播放器支持单音频流播放，支持 speex 解码，可以配合浏览器 Flex 推流的播放 

* 低延时直播体验，配合又拍云推流 `SDK` 及 `CDN` 分发, 可以达到全程直播稳定在 `2-3` 秒延时

* 支持设置窗口大小和全屏设置

* 支持音量调节，静音设置

* 支持亮度调整

* 支持缓冲大小设置，缓冲进度回调

* 支持自动音画同步调整


## 4 SDK下载
Demo 下载: `https://github.com/upyun/ios-live-sdk`


## 5 使用示例 

### 5.1 推流使用示例 UPAVCapturer

使用__拍摄和推流__功能需要引入头文件  `#import "UPAVCapturer.h"`  

`UPAVCapturer` 是采集器，采集处理后的数据会利用 `UPAVStreamer` 进行推流；

	
	
__注:__ ``UPLiveSDKDll.framework``中的推流器 `UPAVStreamer`也可以单独使用。`UPAVStreamer`可以配合任何采集器来推流原始的或者经过编码压缩的音视频数据。


1.设置视频预览视图:  

```
   UIViewContentMode previewContentMode = UIViewContentModeScaleAspectFit;
   self.videoPreview = [[UPAVCapturer sharedInstance] previewWithFrame:CGRectMake(0, 0, width, height) 
   contentMode:previewContentMode];
   self.videoPreview.backgroundColor = [UIColor blackColor];
   [self.view insertSubview:self.videoPreview atIndex:0];

```

2.设置推流地址

```
	NSString *rtmpPushUrl = @"rtmp://host/liveapp/streamid";
	[UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;

```

3.开启和关闭  

```
	//开启视频采集并推流到 rtmpPushUrl
	[[UPAVCapturer sharedInstance] start];

	//关闭视频采集，停止推流
	[[UPAVCapturer sharedInstance] stop];

```


### 5.2 拉流使用示例 UPAVPlayer

使用 ```UPAVPlayer``` 需要引入头文件 ```#import <UPLiveSDKDll/UPAVPlayer.h>```

`UPAVPlayer` 使用接口类似 `AVFoundation` 的 `AVPlayer` 。

完整的使用代码请参考 `demo` 工程。

     

1.设置播放地址

```
    //初始化播放器，设置播放地址
    _player = [[UPAVPlayer alloc] initWithURL:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];

    //设置播放器画面尺寸
    [_player setFrame:[UIScreen mainScreen].bounds];
    
    //将播放器画面添加到 UIview上展示
    [self.view insertSubview:_player.playView atIndex:0];

```

2.连接、播放、暂停、停止、seek  

```
- (void)connect;//连接文件或视频流。
- (void)play;//开始播放。如果流文件未连接会自动连接视频流。
- (void)pause;//暂停播放。直播流无法暂停。
- (void)stop;//停止播放且关闭视频流。
- (void)seekToTime:(CGFloat)position;//seek 到固定播放点。直播流无法 seek。

```




__[注]__  如果需要在产品中正式使用连麦功能，请联系申请 ``` rtc appid ```, 可以参考 ``` README_rtc.md ``` 熟悉连麦直播流程。



## 6 版本历史 

__4.0.0  改为动态库，连麦功能完善。 建议更新 2017.02.06__  


* 修改为动态库，以避免 ffmpeg 冲突       
* 集成连麦模块，支持三人连麦的详细 demo    
* 修复自动重连，来电打断等 bug 
* __[注意]__ 需要新添加几个系统依赖（用于连麦功能，参考: _工程依赖_）     
* __[注意]__ 需要添加 Embedded Binaries（动态库，参考: _工程设置_）

  

     			       
__3.1 三人连麦: 2016.12.08__  			

__3.0 支持直播连麦__  __更新建议: 建议更新, 2016.11.10__                   

__2.9 增加动态码率__  __更新建议: 建议更新, 2016.11.3__

* 增加 动态码率功能 (开启方法: `[UPAVCapturer sharedInstance].openDynamicBitrate = YES`)
* bug fix

__2.8 增加新推流分辨率,修复BUG__  __更新建议: 可以更新, 2016.10.27__

* 增加 960X540 推流分辨率,
* 修复推流状态回调不及时的 BUG 

__2.7 增加直播混音功能__  __更新建议: 建议更新, 2016.10.14__

* 播放器新加实时播放 `PCM` 数据的接口，可用于混音或者音频可视化
* 音频采集模块升级为 `AudioGraph` 实现，新加混音接口, 可实现类似映客的唱歌功能
* `Swift` 适配, 可以在 `Swift` 工程直接使用 `UPLiveSDKDll.framework`.
* __[注意]__  `UPAVPlayerDelegate`、`UPAVStreamerDelegate`、`UPAVCapturerDelegate` 方法名变动.
* bug fix 

__2.6 bug 修复__  __更新建议: 建议更新, 2016.9.22__

__2.5 降噪功能优化__   __更新建议: 非强制性, 如果对环境噪音要求比较高的可以更新__

__2.4 降噪功能__

__2.3 单音频推流__

__2.2 采集部分以源码展示__        

* 采集模块开源（包含音视频采集，GpuImage 处理，混音相关代码）


__2.1 包尺寸显著减小；支持后台推流；支持浏览器 Flex 推流的播放__

__1.0.4 分析统计，拆分 UPAVStreamer__
 	
__1.0.3 点播支持__

__1.0.2 性能优化，添加美颜滤镜__
 	
__1.0.1 基本的直播推流器和播放器；__  
 
## 7 反馈与建议

 邮箱：<livesdk@upai.com>
 
 QQ: `3392887145`
 


