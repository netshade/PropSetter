//
//  PropSetter.h
//  PropSetter
//
//
// Copyright (c) 2010 StarMedia
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.


#import <Foundation/Foundation.h>
#import "PropSetterParser.h"
#import "PropSetterTypes.h"

@interface PropSetter : NSObject<PropSetterOperatorCustomDelegate> {
	BOOL debug;
	NSMutableDictionary * customOperators;
}

@property(readwrite, assign) BOOL debug;

+(id) sharedInstance;

-(PropSetterSelector *) selectorFromString:(NSString *)s;

-(void) addTarget:(id)target andSelector:(SEL)selector forCustomOperator:(NSString *)name;
-(void) addDelegate:(id<PropSetterOperatorCustomDelegate>)del forCustomOperator:(NSString *)name;

-(NSArray *) objectsFromArray:(NSArray *)a matchingSelector:(PropSetterSelector *)selector;
-(NSArray *) setValue:(id)value forObjectsInArray:(NSArray *)a matchingSelector:(PropSetterSelector *)selector;
-(NSArray *) setValueforObjectsInArray:(NSArray *)a matchingSelector:(PropSetterSelector *)selector withTarget:(id)target andSelector:(SEL)sel;
-(BOOL) setValueforObject:(id)object usingSelector:(PropSetterSelector *)selector withTarget:(id)target andSelector:(SEL)sel;
-(BOOL) setValue:(id)value forObject:(id)object usingSelector:(PropSetterSelector *)selector;
-(BOOL) doesSelector:(PropSetterSelector *)selector matchObject:(id)object;
-(id) valueOfSelector:(PropSetterSelector *)selector forObject:(id)object;

-(NSArray *) objectsFromArray:(NSArray *)a matchingString:(NSString *)s;
-(NSArray *) setValue:(id)value forObjectsInArray:(NSArray *)a matchingString:(NSString *)s;
-(NSArray *) setValueforObjectsInArray:(NSArray *)a matchingString:(NSString *)s withTarget:(id)target andSelector:(SEL)sel;
-(BOOL) setValueforObject:(id)object usingString:(NSString *)s withTarget:(id)target andSelector:(SEL)sel;
-(BOOL) setValue:(id)value forObject:(id)object usingString:(NSString *)s;
-(BOOL) doesString:(NSString *)s matchObject:(id)object;
-(id) valueOfString:(NSString *)s forObject:(id)object;




@end
