//
//  PropSetterParser.m
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

#import "PropSetterParser.h"
#import "selector_grammar.h"

#import "PropSetterError.h"
#import "PropSetterIdentifier.h"
#import "PropSetterObjectWithValue.h"
#import "PropSetterValue.h"
#import "PropSetterSelfReference.h"
#import "PropSetterProperty.h"
#import "PropSetterExpression.h"
#import "PropSetterClause.h"
#import "PropSetterSelector.h"
#import "PropSetterOperator.h"



@implementation PropSetterParserGenerator

+(id) shared {
	static PropSetterParserGenerator * gen;
	if(!gen){
		gen = [[PropSetterParserGenerator alloc] init];
	}
	return gen;
}

-(id) init {
	if(self = [super init]){
		grammar = [[NSString alloc] initWithCString:(const char *)selector_grammar length:selector_grammar_len];
		factory = [[PKParserFactory alloc] init];
	}
	return self;
}

-(void) dealloc {
	[grammar release];
	[factory release];
	[super dealloc];
}

-(PKParser *) parserForAssembler:(id)assembler {
	return [factory parserFromGrammar:grammar assembler:assembler];
}


@end


@implementation PropSetterParser

@synthesize debug;

-(id) init {
	if(self = [super init]){
		/*
		NSString * g = [[NSString alloc] initWithCString:(const char *)selector_grammar length:selector_grammar_len];
		parser = [[PKParserFactory factory] parserFromGrammar:g assembler:self];
		[g release];  */
		debug = NO;
		parser = [[[PropSetterParserGenerator shared] parserForAssembler:self] retain];
	}
	return self;
}

-(void) dealloc {
	PKReleaseSubparserTree(parser);
	[parser release];
	[super dealloc];
}

-(PropSetterSelector *) selectorFromExpression:(NSString *)sel {
	currentState = PropSetterParserStateSelector;
	PropSetterSelector * selector = [parser parse:sel];
	currentState = PropSetterParserStateNone;
	if(![selector className]){
		PropSetterRuntimeError(@"Parse error for selector %@", sel);
	} else {
	}	
	currentState = PropSetterParserStateNone;
	return selector;
}




- (void)debugMatch:(NSString *)token withAssembly:(PKAssembly *)a {
	if(debug){
		NSLog(@"Matched %@: %@", token, [a stack]);
	} 
}

- (void)didMatchSelectorExpr:(PKAssembly *)a {
	[self debugMatch:@"selectorExpr" withAssembly:a];
	PropSetterSelector * sel = [[[PropSetterSelector alloc] init] autorelease];
	id obj = [a pop];
	PropSetterClause * cl = nil;
	PropSetterIdentifier * nm = nil;
	PropSetterProperty * pr = nil;
	while(obj){
		if([obj isKindOfClass:[PropSetterClause class]]){
			cl = obj;
		} else if([obj isKindOfClass:[PropSetterIdentifier class]]){
			nm = obj;
		} else if([obj isKindOfClass:[PropSetterProperty class]]){
			pr = obj;
		} else {
			PropSetterRuntimeError(@"Unknown token for selector: %@", obj);
		}		
		obj = [a pop];
	}
	[sel setProperty:pr];
	[sel setClassName:[nm name]];
	[sel setClause:cl];
	[a push:sel];
	
}

- (void)didMatchClassName:(PKAssembly *) a {
	[self debugMatch:@"className" withAssembly:a];
	NSString * className = [[a pop] stringValue];
	if(currentState != PropSetterParserStateSelector){
		PropSetterRuntimeError(@"Cannot specify a class name (%@) when parsing a value", className);
	} else {
		PropSetterIdentifier * ident = [[[PropSetterIdentifier alloc] init] autorelease];
		[ident setName:className];
		[a push:ident];
	}
}

- (void)didMatchClause:(PKAssembly *) a{
	[self debugMatch:@"clause" withAssembly:a];
	PropSetterClause * cl = [[[PropSetterClause alloc] init] autorelease];
	while(TRUE){
		id obj = [[a stack] lastObject];
		if([obj isKindOfClass:[PropSetterExpression class]]){
			[cl insertExpression:[a pop]];
		} else {
			break;
		}
	}
	[a push:cl];
}


-(void) didMatchComparisonExpr:(PKAssembly *)a{
	[self debugMatch:@"comparisonExpr" withAssembly:a];
	id<PropSetterObjectWithValue> r = [a pop];
	PropSetterOperator * tok = [a pop];
	id<PropSetterObjectWithValue> l = [a  pop];
	PropSetterExpression * e = [[[PropSetterExpression alloc] init] autorelease];
	[e setLvalue:l];
	[e setRvalue:r];
	[e setOp:tok];
	[a push:e];
}

-(void) didMatchExpr:(PKAssembly *)a {
	[self debugMatch:@"expr" withAssembly:a];
	id obj = [[a stack] lastObject];
	if([obj conformsToProtocol:@protocol(PropSetterObjectWithValue)]){
		id<PropSetterObjectWithValue> l = [a pop];
		PropSetterExpression * e = [[[PropSetterExpression alloc] init] autorelease];		
		[e setLvalue:l];
		[a push:e];
	} 
}

-(void) didMatchSubExpr:(PKAssembly *)a {
	[NSException raise:@"NOT IMPLEMENTED" format:@"Sub expressions are not yet implemented"];
}

-(void)didMatchSelf:(PKAssembly *)a {
	[self debugMatch:@"self" withAssembly:a];
	PropSetterSelfReference * v = [[[PropSetterSelfReference alloc] init] autorelease];
	[a pop];
	[a push:v];
}

- (void)didMatchString:(PKAssembly *)a {
	[self debugMatch:@"string" withAssembly:a];
	PropSetterValue * v = [[[PropSetterValue alloc] init] autorelease];
	NSString * foundString = [[a pop] stringValue];
	NSString * s = [[[NSString alloc] initWithString:foundString] autorelease];
	[v setValue: [s substringWithRange:NSMakeRange(1, [s length] == 2 ? 0 : [s length] - 2)]];
	[a push:v];
}

- (void)didMatchNum:(PKAssembly *)a {
	[self debugMatch:@"num" withAssembly:a];
	PropSetterValue * v = [[[PropSetterValue alloc] init] autorelease];
	CGFloat f = [[a pop] floatValue];
	NSNumber * n = [[[NSNumber alloc] initWithFloat:f] autorelease];
	[v setValue: n];
	[a push:v];
}

-(void) didMatchTrue:(PKAssembly *) a {
	[self debugMatch:@"true" withAssembly:a];
	PropSetterValue * v = [[[PropSetterValue alloc] init] autorelease];
	NSNumber * n = [[[NSNumber alloc] initWithBool:YES] autorelease];
	[v setValue: n];
	[a pop];
	[a push:v];
}

-(void) didMatchFalse:(PKAssembly *) a {
	[self debugMatch:@"false" withAssembly:a];
	PropSetterValue * v = [[[PropSetterValue alloc] init] autorelease];
	NSNumber * n = [[[NSNumber alloc] initWithBool:NO] autorelease];
	[v setValue: n];
	[a pop];
	[a push:v];
}


-(void) didMatchNil:(PKAssembly *) a {
	[self debugMatch:@"nil" withAssembly:a];
	PropSetterValue * v = [[[PropSetterValue alloc] init] autorelease];
	[v setValue: nil];
	[a pop];
	[a push:v];
}


- (void)didMatchProperty:(PKAssembly *) a{
	[self debugMatch:@"property" withAssembly:a];
	id pm = [[a stack] lastObject];
	PropSetterProperty * prop = [[[PropSetterProperty alloc] init] autorelease];
	while(pm && [pm isKindOfClass:[PKToken class]]){
		PropSetterPropertyMember * mem = [[PropSetterPropertyMember alloc] init];
		[mem setName:[pm stringValue]];
		[prop addMember:mem];
		[mem release];
		[a pop];
		pm = [[a stack] lastObject];
	}
	[a push:prop];
}

-(void) didMatchCustomOp:(PKAssembly *) a {
	PKToken * nm = [a pop];
	[a push:[PropSetterOperator customOperatorWithName:[nm stringValue]]];
}


- (void)didMatchEq:(PKAssembly *) a {
	[a pop];
	[a push:[PropSetterOperator operatorWithType:PSCOMPOP_EQ]];
}

-(void) didMatchNe:(PKAssembly *)a {
	[a pop];
	[a push:[PropSetterOperator operatorWithType:PSCOMPOP_NE]];
}

-(void) didMatchLt:(PKAssembly *)a {
	[a pop];
	[a push:[PropSetterOperator operatorWithType:PSCOMPOP_LT]];
}

-(void) didMatchGt:(PKAssembly *)a {
	[a pop];
	[a push:[PropSetterOperator operatorWithType:PSCOMPOP_GT]];
}

-(void) didMatchLte:(PKAssembly *)a {
	[a pop];
	[a push:[PropSetterOperator operatorWithType:PSCOMPOP_LTE]];
}

-(void) didMatchGte:(PKAssembly *)a {
	[a pop];
	[a push:[PropSetterOperator operatorWithType:PSCOMPOP_GTE]];
}

-(void) didMatchContains:(PKAssembly *) a{
	[a pop];
	[a push:[PropSetterOperator operatorWithType:PSCOMPOP_CONTAINS]];
}

-(void) didMatchAnd:(PKAssembly *) a{
	[a pop];
}

-(void) didMatchOr:(PKAssembly *) a {
	[a pop];
}

-(void) didMatchAndSimpleStatement:(PKAssembly *)a {
	[self debugMatch:@"andSimpleStatement" withAssembly:a];
	PropSetterExpression * r = [a pop];
	PropSetterExpression * l = [a pop];
	[l setNext:PSOP_AND];
	[a push:l];
	[a push:r];
}

-(void) didMatchOrAndStatement:(PKAssembly *)a {	
	[self debugMatch:@"orAndStatement" withAssembly:a];
	PropSetterExpression * r = [a pop];
	PropSetterExpression * l = [a pop];
	[l setNext:PSOP_OR];
	[a push:l];
	[a push:r];
}



@end





