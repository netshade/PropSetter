//
//  PropSetterManager.m
//  PropSetter
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

//

#import "PropSetterManager.h"
#import "PropSetter.h"
#import "PropSetterError.h"

@interface PropSetterInvocationRecord : NSObject
{
	SEL selector;
	id target;
}

@property(readwrite, retain) id target;
@property(readwrite, assign) SEL selector;

@end

@implementation PropSetterInvocationRecord

@synthesize target;
@synthesize selector;


-(void) dealloc {
	[target release];
	[super dealloc];
}

@end



@implementation PropSetterManager

+(id) manager {
	static PropSetterManager * inst;
	@synchronized([PropSetterManager class]){
		if(!inst){
			inst = [[PropSetterManager alloc] init];
		}
	}
	return inst;
}

-(id) init {
	if(self = [super init]){
		selectors = [[NSMutableDictionary alloc] init];
		observed = [[NSMutableArray alloc] init];
		keypaths = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) dealloc {
	[keypaths release];
	[selectors release];
	[observed release];
	[super dealloc];
}

-(void) addSelectorFromString:(NSString *)str withTarget:(id)target andSelector:(SEL)selector {
	PropSetterSelector * sel = [[PropSetter sharedInstance] selectorFromString:str];
	[self addSelector:sel withTarget:target andSelector:selector];
}

-(void) addSelector:(PropSetterSelector *)sel withTarget:(id)target andSelector:(SEL)selector {
	PropSetterInvocationRecord * rec = [[PropSetterInvocationRecord alloc] init];
	[rec setTarget:target];
	[rec setSelector:selector];
	[self addSelector:sel withValue:rec];
	[rec release];
}

-(void) addSelectorFromString:(NSString *)str withValue:(id)val {
	PropSetterSelector * sel = [[PropSetter sharedInstance] selectorFromString:str];
	[self addSelector:sel withValue:val];
}

-(void) addSelector:(PropSetterSelector *)sel withValue:(id)val {
	@synchronized(self){
		[selectors setObject:val forKey:sel];
		[keypaths addObjectsFromArray:[[sel clause] affectedKeypaths]];
	}
}

-(void) addSelectorsFromDictionary:(NSDictionary *)d {
	for(id o in d){
		if([o isKindOfClass:[PropSetterSelector class]]){
			[self addSelector:o withValue:[d objectForKey:o]];
		} else if([o isKindOfClass:[NSString class]]){
			[self addSelectorFromString:o withValue:[d objectForKey:o]];
		} else {
			PropSetterRuntimeError(@"Cannot add selector with object %@, it must be either a PropSetterSelector or NSString", o);
		}
	}
}

-(void) addSelectorsFromPlist:(NSString *)filename {
	NSDictionary * d = [[NSDictionary alloc] initWithContentsOfFile:filename];
	[self addSelectorsFromDictionary:d];
	[d release];
}

-(void) reset {
	@synchronized(self){
		for(id o in observed){
			[self stopObservingObject:o];
		}
		[observed removeAllObjects];
		[selectors removeAllObjects];
		[keypaths removeAllObjects];
	}
}

-(void) beginObservingObject:(id)o {
	@synchronized(self){
		[observed addObject:o];
	}
	for(NSString * p in keypaths){
		[o addObserver:self forKeyPath:p options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
	}
	[self applyRulesToObject:o];
}

-(void) stopObservingObject:(id)o {
	for(NSString * p in keypaths){
		[o removeObserver:self forKeyPath:p];
	}
	@synchronized(self){
		[observed removeObject:o];
	}
}

-(void) applyRulesToObject:(id)o {
	PropSetter * s = [PropSetter sharedInstance];
	for(PropSetterSelector * sel in selectors){
		id v = [selectors objectForKey:sel];
		if([v isKindOfClass:[PropSetterInvocationRecord class]]){
			[s setValueforObject:o usingSelector:sel withTarget:[v target] andSelector:[v selector]];
		} else {
			[s setValue:v forObject:o usingSelector:sel];
		}
	}
}

-(void) applyRulesToAllObjects {
	for(id o in observed){
		[self applyRulesToObject:o];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self applyRulesToObject:object];
}

@end
