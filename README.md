# 又拍云 iOS 直播 SDK(动态库) 使用说明   


__注: 从4.0.0版本之后 SDK 改为了动态库形式.__


## SDK 概述     

此 `SDK` 包含推流和拉流两部分，及美颜滤镜，连麦等全套直播功能；
       

此 `SDK` 中的播放器、采集器、推流器可单独使用。用户可以自主构建直播中某个环节，比如播放器（`UPAVPlayer`）可以与 Web 推流器 Flex 相配合。推流器（`UPAVStreamer`）可以配合系统自带的AVCapture 或者`GPUImage `库提供的采集功能。 


基于此 `SDK` 结合 __upyun__ 直播平台可以快速构建直播应用。

[UPYUN 直播平台自主配置流程](http://docs.upyun.com/live/) 
  
## SDK使用说明

### 运行环境和兼容性

```UPLiveSDKDll.framework``` 支持 `iOS 8` 及以上系统版本； 
	
支持 `ARMv7`，`ARM64` 架构。请使用真机进行开发和测试。

### 安装使用说明

	
#### 手动安装方法：

直接将 `UPLiveService`文件夹拖拽到目标工程目录。

```
//文件结构：

UPLiveService 文件夹
├── GPUImage                 //视频处理依赖第三方库 GPUImage  
├── UPAVCapturer             //UPAVCapturer 音视频采集模块, 直播接口。
└── UPLiveSDKDll.framework   //framework 包含播放器`UPAVPlayer`和推流器`UPAVStreamer`

```

#### 工程设置：     

```TARGET -> Build Settings -> Enable bitcode```： 设置为 NO  			


```TARGET -> General -> Embedded Binaries```： 添加选择 UPLiveSDKDll.framework			



#### 工程依赖：

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



***注意: 此 `SDK` 已经包含 `FFMPEG 3.0` , 不建议自行再添加 `FFMPEG` 库 , 如有特殊需求, 请联系我们***    


## 推流端功能特性 （采集器 ＋ 推流器）


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



## 播放端功能特性 （播放器）

* 支持播放直播源和点播源，支持播放本地视频文件。

* 支持视频格式：`HLS`, `RTMP`, `FLV`，`mp4` 等视频格式 
	
* 播放器支持单音频流播放，支持 speex 解码，可以配合浏览器 Flex 推流的播放 

* 低延时直播体验，配合又拍云推流 `SDK` 及 `CDN` 分发, 可以达到全程直播稳定在 `2-3` 秒延时

* 支持设置窗口大小和全屏设置

* 支持音量调节，静音设置

* 支持亮度调整

* 支持缓冲大小设置，缓冲进度回调

* 支持自动音画同步调整


## SDK下载
Demo 下载: `https://github.com/upyun/ios-live-sdk`

## 推流 SDK 使用示例 UPAVCapturer

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


## 拉流 SDK 使用示例 UPAVPlayer

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




## Q&A

__1.推流、拉流是什么意思？__

推流是指采集端将音视频流推送到直播服务器的过程；	
拉流是指从直播服务器获取音视频数据的过程。

__2.UPLiveSDKDll.framework 中的 UPAVCapturer、UPAVStreamer、UPAVPlayer 作用及之间的关系？__

UPAVPlayer 是播放器，可以播放点播或直播流；		
UPAVStreamer 是推流器，可以将音视频流推到直播服务器上;            
UPAVCapturer 是采集器负责采集录制音视频数据。	
除了 UPAVCapturer 会用到 UPAVStreamer 进行推流外，这三者可以独立使用。     	

__3.可否同时播放两条流？__ 

支持在同一个界面上放置多个 UPAVPlayer 播放器同时播放多个流。同时也可选择任一一条流静音播放。

__4.如何实现秒开，如何优化秒开？__

使用 UPAVPlayer 与又拍云的视频服务基本可以实现开播小于 0.5 秒；         
利用 UPAVPlayer 进行先连接后播放操作，结合适当的 UI 效果也可以改善视频秒开体验。        

__5.如何进行低延时优化？__

又拍云的视频服务基本可以做到直播的全过程延时小于 3 秒。           
同时可以调整 UPAVPlayer 播放器的缓冲大小，来减小播放器本地带来的延时。         

__6.耗电量多少？可否长时间直播？__

耗电量多少与不同机型及网络环境相关。对于 iphone 5s 及以上机型可以长时间推流，也不会感觉到手机发烫。
直播一小时一般电量消耗在 10％ － 20％ 范围之间。

__7.横屏拍摄和屏幕旋转问题怎么解决？__     

对于“横屏拍摄和屏幕旋转”问题的一个关键点：需要区分清楚 UI(设备)的横竖屏与镜头横竖拍摄的区别。并且拍摄开始之后“镜头横竖” 是已经固定了无法更改。具体可参考 demo 的解决方式。    

__8.直播的视频尺寸是否可以自定义？__   

最终的推流视频尺寸取决于两点：        	
	
1) 镜头采集到的图像尺寸。不同设备支持多种不同的拍摄尺寸，一般的 480x360、640x480、1280x720是各种设备及前后镜头支持最广泛的。这个参数可以通过 UPAVCapturer 的 capturerPresetLevel 属性进行修改。            

2) 剪裁图像尺寸。在采集尺寸的基础上可以通过 UPAVCapturer 的 capturerPresetLevelFrameCropRect 属性进行图像剪裁。
例如：选择 640x480 像素的镜头进行拍摄后可以再剪裁为 640x360 全屏比例图片进行直播。 


__9.可不可以仅直播声音不传图像？__     

可以。UPAVCapturer 支持单音频推流，UPAVPlayer支持单音频流的播放。 

__10.如何快速体验和测试直播？__

下载 demo 工程运行后，便可以直接进行直播测试。  

      

__[注]__ 如果需要自主注册直播云服务可以参考：[UPYUN 直播平台自主配置流程](http://docs.upyun.com/live/)       
__[注]__  如果需要在产品中正式使用连麦功能，请联系申请 ``` rtc appid ```, 可以参考 ``` README_rtc.md ``` 熟悉连麦直播流程。



## 版本历史 

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
 
## 反馈与建议

 邮箱：<livesdk@upai.com>
 
 QQ: `3392887145`
 


