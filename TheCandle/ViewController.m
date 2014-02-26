//
//  ViewController.m
//  TheCandle
//
//  Created by Ken Tominaga on 2013/12/24.
//  Copyright (c) 2013年 Tommy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //      カメラクラスを初期化
    _cameraManager = CameraManager.new;
    //   _cameraManager.delegate = self;
    
    //      プレビューレイヤを設定
    [_cameraManager setPreview:_previewView];
    [_cameraManager flipCamera];
    
    againButton.hidden = YES;
    
    [self start];
}

//      回転禁止
- (BOOL)shouldAutorotate {
    
	return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)takePhoto{
    [_cameraManager takePhoto:^(UIImage *image, NSError *error) {
        _captureview.image = image;
        
//        // 画像取得に失敗した場合
//        if (image == nil) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                            message:@"ERROR"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//            
//            // 画像がない場合は、ここで終わり
//            return;
//        }
        
        //画像をフォトアルバムに保存する（tagetImageメソッドが呼び出される）
        UIImageWriteToSavedPhotosAlbum(
                                       image, // 保存する画像
                                       self, // 呼び出されるメソッドを持っているクラス（今回はself（自分自身））
                                       //@selector(targetImage:didFinishSavingWithError:contextInfo:), // 呼び出されるメソッド
                                       nil,
                                       NULL); // 呼び出されるメソッドに渡したいもの（今回はなし）
    }];
    
    imageView.image = [UIImage imageNamed:@"FinishedView.png"];
    [self.view bringSubviewToFront:_captureview];
    
    againButton.hidden = NO;
    
}

////画像保存時に呼ばれるメソッド
//-(void)targetImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)context{
//    
//    // 保存失敗時
//    if(error){
//        // アラートの初期化
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:@"Failed to save"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        // アラートの表示
//        [alert show];
//    }
//    
//    // 保存成功時
//    else{
//        // アラートの初期化
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:@"Saved"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        // アラートの表示
//        [alert show];
//    }
//}

-(IBAction)again:(NSTimer *)timer{
    againButton.hidden = YES;
    
    imageView.image = [UIImage imageNamed:@"MainView.png"];
    
    [self.view sendSubviewToBack:_captureview];
    
    [self start];
}

static void AudioInputCallback(
                               void* inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumberPacketDescriptions,
                               const AudioStreamPacketDescription *inPacketDescs) {
}

- (void)start {
    AudioStreamBasicDescription dataFormat;
    dataFormat.mSampleRate = 44100.0f;
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    dataFormat.mBytesPerPacket = 2;
    dataFormat.mFramesPerPacket = 1;
    dataFormat.mBytesPerFrame = 2;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mReserved = 0;
    
    AudioQueueNewInput(&dataFormat,AudioInputCallback,(__bridge void *)(self),CFRunLoopGetCurrent(),kCFRunLoopCommonModes,0,&queue);
    AudioQueueStart(queue, NULL);
    
    UInt32 enabledLevelMeter = true;
    AudioQueueSetProperty(queue,kAudioQueueProperty_EnableLevelMetering,&enabledLevelMeter,sizeof(UInt32));
    
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(updateVolume:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)updateVolume:(NSTimer *)timer {
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(queue,kAudioQueueProperty_CurrentLevelMeterDB,&levelMeter,&levelMeterSize);
    
    NSLog(@"mPeakPower=%0.9f", levelMeter.mPeakPower);
    NSLog(@"mAveragePower=%0.9f", levelMeter.mAveragePower);
    
    if (levelMeter.mPeakPower <= -100.0f) {
        [timer invalidate];
        NSLog(@"てすと");
        [self start];
    }
    
    if (levelMeter.mPeakPower >= -10.0f) {
        [self takePhoto];
        [timer invalidate];
        levelMeter.mAveragePower = -60.0f;
        levelMeter.mPeakPower = -60.0f;
    }
}

//-(void)fire{
//    [_cameraManager takePhoto:^(UIImage *image, NSError *error) {
//        _captureview.image = image;
//        
//        //        // 画像取得に失敗した場合
//        //        if (image == nil) {
//        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//        //                                                            message:@"ERROR"
//        //                                                           delegate:nil
//        //                                                  cancelButtonTitle:@"OK"
//        //                                                  otherButtonTitles:nil];
//        //            [alert show];
//        //
//        //            // 画像がない場合は、ここで終わり
//        //            return;
//        //        }
//        
//        //画像をフォトアルバムに保存する（tagetImageメソッドが呼び出される）
//        UIImageWriteToSavedPhotosAlbum(
//                                       image, // 保存する画像
//                                       self, // 呼び出されるメソッドを持っているクラス（今回はself（自分自身））
//                                       //@selector(targetImage:didFinishSavingWithError:contextInfo:), // 呼び出されるメソッド
//                                       nil,
//                                       NULL); // 呼び出されるメソッドに渡したいもの（今回はなし）
//    }];
//    
//    imageView.image = [UIImage imageNamed:@"FinishedView.png"];
//    [self.view bringSubviewToFront:_captureview];
//    
//    againButton.hidden = NO;
//    
//}
@end