//
//  KBPGPOutputView.h
//  Keybase
//
//  Created by Gabriel on 3/23/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KBAppDefines.h"
#import "KBContentView.h"
#import "KBPGPOutputFooterView.h"

@interface KBPGPOutputView : KBContentView

@property (readonly) KBPGPOutputFooterView *footerView;

- (void)setText:(NSString *)text wrap:(BOOL)wrap;

- (void)setData:(NSData *)data armored:(BOOL)armored;

- (void)setPgpSigVerification:(KBRPgpSigVerification *)pgpSigVerification;

- (void)clear;

@end
