//
//  ViewController.h
//  TheCandle
//
//  Created by Ken Tominaga on 2013/12/24.
//  Copyright (c) 2013年 Tommy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController <CameraManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *againButton;
    
    AudioQueueRef queue;
    //NSTimer *timer;
}

@property CameraManager*            cameraManager;  //   カメラマネージャクラス
@property IBOutlet UIImageView*     previewView;    //   プレビューを配置するビュー
@property IBOutlet UIImageView*     captureview;    //   キャプチャ後のイメージ

-(void)start;
-(void)takePhoto;
@end
