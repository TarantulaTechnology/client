//
//  KBPGPSignAppView.m
//  Keybase
//
//  Created by Gabriel on 4/27/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "KBPGPSignAppView.h"

#import "KBPGPSignView.h"
#import "KBPGPOutputView.h"

@interface KBPGPSignAppView ()
@property KBPGPSignView *signView;
@property KBPGPOutputView *outputView;
@end

@implementation KBPGPSignAppView

- (void)viewInit {
  [super viewInit];

//  KBSplitView *view = [[KBSplitView alloc] init];
//  view.dividerRatio = 0.5; // -500; // Enough for 64 monospace characters in output view
//  [self addSubview:view];

  GHWeakSelf gself = self;
  _signView = [[KBPGPSignView alloc] init];
  _signView.onSign = ^(KBPGPSignView *view, NSData *data, KBRSignMode mode) {
    if (data) {
      NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      [gself.outputView setText:text wrap:NO]; // wrap = (mode & KBRSignModeClear)
      [view.navigation pushView:gself.outputView animated:YES];
      [gself.navigation pushView:gself.outputView animated:YES];
    } else {
      [gself.outputView clear];
    }
  };
  [self addSubview:_signView];

  _outputView = [[KBPGPOutputView alloc] init];
  _outputView.footerView.closeButton.hidden = YES;

//  [view setLeftView:_signView];
//  [view setRightView:_outputView];
//  self.viewLayout = [YOLayout fill:view];
  self.viewLayout = [YOLayout fill:_signView];
}

- (void)setClient:(KBRPClient *)client {
  [super setClient:client];
  _signView.client = client;
}

@end