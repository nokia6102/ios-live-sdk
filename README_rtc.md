###iOS 直播 SDK 连麦功能介绍


连麦模块 ```UPRtcSDK.framework``` 作为一个直播组件（采集器、推流器、连麦模块、播放器）可以自由组合到直播 sdk 中。

####一 . 集成连麦模块：
__Step1:__ 将 UPRtcSDK.framework 拖拽到 UPLiveService 文件夹。		

```
UPLiveService
│
├── UPAVCapturer
│   ├── Class
│   │   ├── UPAudioCapture.h
│   │   ├── UPAudioCapture.m
│   │   ├── UPAudioGraph.h
│   │   ├── UPAudioGraph.m
│   │   ├── UPVideoCapture.h
│   │   ├── UPVideoCapture.m
│   ├── UPAVCapturer.h   //进行直播的所有接口，包括连麦接口
│   └── UPAVCapturer.m
├── UPLiveSDK.framework
└── UPRtcSDK.framework   //连麦模块 framework
```


__Step2:__ 在 UPAVCapturer.h 文件里面引入头文件 ```#import <UPRtcSDK/RtcManager.h>```



__Step3:__ 直播SDk及连麦功能依赖的系统库

```
AVFoundation.framework       // 直播SDk 需要依赖
QuartzCore.framework         // 直播SDk 需要依赖
OpenGLES.framework           // 直播SDk 需要依赖
AudioToolbox.framework       // 直播SDk 需要依赖
VideoToolbox.framework       // 直播SDk 需要依赖
Accelerate.framework         // 直播SDk 需要依赖
libbz2.1.0.tbd               // 直播SDk 需要依赖
libiconv.tbd                 // 直播SDk 需要依赖
libz.tbd                     // 直播SDk 需要依赖
CoreMedia.framework          // 连麦功能 需要依赖 
CoreTelephony.framework      // 连麦功能 需要依赖
SystemConfiguration.framework// 连麦功能 需要依赖
libc++.tbd                   // 连麦功能 需要依赖
```


####二 . 直播连麦的流程逻辑：
__普通直播流程：__
采集器（采集、音视频处理） － 推流器（编码、压缩）－ 播放器（解码、播放）

__直播连麦流程：__	

__主播端：__ 采集器（采集、音视频处理）－连麦模块（视频对话、合图） － 推流器（编码、压缩）－ 播放器（解码‘播放）
__观众端：__ 采集器（采集、音视频处理）－连麦模块（视频对话）

####三. 连麦接口介绍：
连麦作为一个普通模块通过接口与直播 SDK 的其他模块衔接。直播模块与连麦模块的数据传递可以查看 ```UPAVCapturer.m``` 文件里面 ```RtcManager``` 的使用情况。这一部分都是源码实现的。
连麦功能相关接口只有三个：

```
//UPAVCapturer.h

- (void)rtcInitWithAppId:(NSString *)aapid;//初始化rtc模块

- (void)rtcConnect:(NSString *)channelId;// 连麦到某一个频道（房间）

- (void)rtcClose;//退出连麦
```


####四. 主播连麦和观众端连麦的区别和联系：
主播连麦和观众端连麦都是使用 ```UPAVCapturer```。
主播连麦和观众端连麦最大区别是：连麦模块回调出的数据是否需要压缩推流。主播客户端需要将连麦合图之后的数据压缩推流给观众看。而观众端连麦不需要。
所以具体的：主播端使用 ```UPAVCapturer``` 的连麦接口时候不需要做任何特殊修改，具体使用代码参考 ```UPLiveSDKDemo／UPLiveStreamerLivingVC.m``` 中的连麦操作。
观众端连麦，因为不需要推流，所以在使用 ```UPAVCapturer``` 连麦时候需要注意两个地方：

```
//观众端连麦不需要 rtmp 推流，所以不要设置 outStreamPath。
//[UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;

//同时关闭 UPAVCapturer 推流开关。
[UPAVCapturer sharedInstance].streamingOn = NO;
```

观众端连麦代码参考：```UPLiveSDKDemo／UPLivePlayerVC.m```

####五. 备注：
1.连麦 AppID：可以对等理解为直播服务中的 bucket name。需要联系后台获取这个 AppID。
2.连麦 channelId 可以对等于直播流id 或者房间号。加入同一个channelId 就是相互连麦。 
3.如果连麦功需要其他设置，比如连麦窗口设置可以在 ```UPAVCapturer.m``` 自行修改。
4.暂时按照一对一连麦设计。连麦的控制（发起、允许、选人、踢人、一对一限制等）需要 app服务器业务层自行处理。



