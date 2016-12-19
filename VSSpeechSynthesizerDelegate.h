#import  <foundation/foundation.h>

@protocol VSSpeechSynthesizerDelegate <NSObject>
@optional
-(void)speechSynthesizerDidStartSpeaking:(id)speechSynthesizer;
-(void)speechSynthesizer:(id)synthesizer didFinishSpeaking:(BOOL)speaking withError:(id)error;
-(void)speechSynthesizerDidPauseSpeaking:(id)speechSynthesizer;
-(void)speechSynthesizerDidContinueSpeaking:(id)speechSynthesizer;
-(void)speechSynthesizer:(id)synthesizer willSpeakRangeOfSpeechString:(NSRange)speechString;
@end

