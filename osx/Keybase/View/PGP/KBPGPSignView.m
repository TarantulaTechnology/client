//
//  KBPGPSignView.m
//  Keybase
//
//  Created by Gabriel on 3/27/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "KBPGPSignView.h"

#import "KBRPC.h"
#import "KBStream.h"
#import "KBPGPOutputView.h"
#import "KBPGPSigner.h"
#import "KBPGPSignFooterView.h"
#import "KBWork.h"
#import "KBPGPTextView.h"

@interface KBPGPSignView ()
@property KBPGPTextView *textView;
@property KBPGPSignFooterView *footerView;
@property KBPGPSigner *signer;
@end

@implementation KBPGPSignView

- (void)viewInit {
  [super viewInit];

  GHWeakSelf gself = self;
  _textView = [[KBPGPTextView alloc] init];
  _textView.view.editable = YES;
  _textView.view.textContainerInset = CGSizeMake(10, 10);
  _textView.onChange = ^(KBTextView *textView) {
    if (gself.onSign) gself.onSign(gself, nil, KBRSignModeClear);
  };
  [self addSubview:_textView];

  _footerView = [[KBPGPSignFooterView alloc] init];
  _footerView.detached.hidden = YES;
  _footerView.clearSign.state = NSOnState;
  _footerView.signButton.targetBlock = ^{ [gself sign]; };
  [self addSubview:_footerView];

  self.viewLayout = [YOBorderLayout layoutWithCenter:_textView top:nil bottom:@[_footerView] insets:UIEdgeInsetsZero spacing:0];
}

- (void)setData:(NSData *)data {
  [_textView setText:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] style:KBTextStyleDefault options:KBTextOptionsMonospace alignment:NSLeftTextAlignment lineBreakMode:NSLineBreakByClipping];
}

- (void)sign {
  _signer = [[KBPGPSigner alloc] init];
  KBRPgpSignOptions *options = [[KBRPgpSignOptions alloc] init];
  options.mode = _footerView.clearSign.state == NSOnState ? KBRSignModeClear : KBRSignModeAttached;
  options.binaryIn = NO;
  options.binaryOut = NO;

  NSString *str = _textView.text;

  if (str.length == 0) {
    [KBActivity setError:KBMakeError(-1, @"Nothing to sign") sender:self];
    return;
  }

  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) {
    [KBActivity setError:KBMakeError(-1, @"We had a problem trying to encode the text into data") sender:self];
    return;
  }
  KBReader *reader = [KBReader readerWithData:data];
  KBWriter *writer = [KBWriter writer];
  KBStream *stream = [KBStream streamWithReader:reader writer:writer label:arc4random()];

  [KBActivity setProgressEnabled:YES sender:self];
  [_signer signWithOptions:options streams:@[stream] client:self.client sender:self completion:^(NSArray *works) {
    [KBActivity setProgressEnabled:NO sender:self];
    KBWork *work = works[0];
    NSError *error = [work error];
    if ([KBActivity setError:error sender:self]) return;
    KBStream *stream = [work output];

    if ([self.navigation setError:error sender:self]) return;

    if (self.onSign) {
      self.onSign(self, stream.writer.data, options.mode);
    } else {
      [self _sign:stream.writer.data];
    }
  }];
}

- (void)_sign:(NSData *)data {
  KBPGPOutputView *outputView = [[KBPGPOutputView alloc] init];
  NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  [outputView setText:text wrap:NO];
  [self.navigation pushView:outputView animated:YES];
}

@end

