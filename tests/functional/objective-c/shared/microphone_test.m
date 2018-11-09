//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.md file in the project root for full license information.
//

#import "microphone_test.h"

@implementation MicrophoneTest
    

extern NSString *speechKey;
extern NSString *intentKey;
extern NSString *serviceRegion;

+ (void) runAsync
{
    // NSString *intentKey = @"";
    
    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    SPXSpeechRecognizer* speechRecognizer;
    
    speechRecognizer= [[SPXSpeechRecognizer alloc] init:speechConfig];
    NSString *speechRegion = [speechRecognizer.properties getPropertyByName:@"SPEECH-Region"];
    NSLog(@"Property Collection: Region is read from property collection: %@", speechRegion);
    SPXSpeechRecognitionResult *speechResult = [speechRecognizer recognizeOnce];
    NSLog(@"RecognizeOnce: Recognition result %@. Status %ld.", speechResult.text, (long)speechResult.reason);

}

+ (void) runContinuous
{
    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    SPXSpeechRecognizer* speechRecognizer;
    
    speechRecognizer= [[SPXSpeechRecognizer alloc] init:speechConfig];

    __block bool end = false;

    [speechRecognizer addSessionStartedEventHandler: ^ (SPXRecognizer *recognizer, SPXSessionEventArgs *eventArgs) {
//        NSLog(@"Received SessionStarted event. SessionId: %@", eventArgs.sessionId);
    }];
    [speechRecognizer addSessionStoppedEventHandler: ^ (SPXRecognizer *recognizer, SPXSessionEventArgs *eventArgs) {
//        NSLog(@"Received SessionStopped event. SessionId: %@", eventArgs.sessionId);
    }];
    [speechRecognizer addSpeechStartDetectedEventHandler: ^ (SPXRecognizer *recognizer, SPXRecognitionEventArgs *eventArgs) {
//        NSLog(@"Received SpeechStarted event. SessionId: %@ Offset: %d", eventArgs.sessionId, (int)eventArgs.offset);
    }];
    [speechRecognizer addSpeechEndDetectedEventHandler: ^ (SPXRecognizer *recognizer, SPXRecognitionEventArgs *eventArgs) {
 //       NSLog(@"Received SpeechEnd event. SessionId: %@ Offset: %d", eventArgs.sessionId, (int)eventArgs.offset);
        end = true;
    }];
    [speechRecognizer addRecognizedEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
        NSLog(@"Received final result event. SessionId: %@, recognition result:%@. Status %ld.", eventArgs.sessionId, eventArgs.result.text, (long)eventArgs.result.reason);
//        NSLog(@"Received JSON: %@", [eventArgs.result.properties getPropertyByName:@"RESULT-Json"]);
    }];
    [speechRecognizer addRecognizingEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
//        NSLog(@"Received intermediate result event. SessionId: %@, intermediate result:%@.", eventArgs.sessionId, eventArgs.result.text);
    }];
    [speechRecognizer addCanceledEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionCanceledEventArgs *eventArgs) {
//        NSLog(@"Received canceled event. SessionId: %@, reason:%lu errorDetails:%@.", eventArgs.sessionId, (unsigned long)eventArgs.reason, eventArgs.errorDetails);
//        SPXCancellationDetails *details = [SPXCancellationDetails fromResult:eventArgs.result];
//        NSLog(@"Received cancellation details. reason:%lu errorDetails:%@.", (unsigned long)details.reason, details.errorDetails);
    }];
    end = false;
    [speechRecognizer startContinuousRecognition];
    while (end == false)
        [NSThread sleepForTimeInterval:1.0f];
    [speechRecognizer stopContinuousRecognition];
    
    NSLog(@"Finishing recognition");
}
    
+ (void) runTranslation{
    __block bool end = false;
    SPXTranslationRecognizer *translationRecognizer;
    SPXSpeechTranslationConfiguration *translationConfig = [[SPXSpeechTranslationConfiguration alloc] initWithSubscription:speechKey region:serviceRegion];
    [translationConfig setSpeechRecognitionLanguage:@"en-us"];
    [translationConfig addTargetLanguage:@"de"];
    [translationConfig addTargetLanguage:@"zh-Hans"];
    [translationConfig setVoiceName:@"Microsoft Server Speech Text to Speech Voice (de-DE, Hedda)"];

    translationRecognizer = [[SPXTranslationRecognizer alloc] init:translationConfig];

    end = false;
    [translationRecognizer recognizeOnceAsync: ^ (SPXTranslationRecognitionResult *result){
        NSLog(@"RecognizeOnceAsync: Translation result: recognized: %@. Status %ld.", result.text, (long)result.reason);
        for (id lang in [result.translations allKeys]) {
            NSLog(@"RecognizeOnceAsync: Translation result: translated into %@: %@", lang, [result.translations objectForKey:lang]);
        }
        end = true;
    }];
    while (end == false)
        [NSThread sleepForTimeInterval:1.0f];
}

@end
