//FLUTEOSC Odette - implemented by Alessia Milo
//This sketch works with the sketch Mouse2DFluteOSC.pde at this address //https://www.dropbox.com/s/s87tt9dqwil50o3/Mouse2DFluteOSC.zip
//Boot the server
//execute the Synth
//check the sound working with test
//execute the OSCDef
//run the Processing sketch
//move the Mouse

s.boot;
NetAddr.localAddr;  // check for address, in case rewrite in Processing


// 3) =========  Waveguide flute  ==========





// Waveguide flute based upon Hans Mikelson's Csound slide flute (ultimately derived from Perry Cook's)

// STK slide flute physical model.  SuperCollider port by John E. Bower, who kindly allowed for the

// flute's inclusion in this tutorial.


// Please note that this instrument remains buggy. It's best used in lower registers ( alto or bass

// flute range ).  Intonation and tuning gets off as you go higher, especially above 72.midicps.

// This is a work in progress.  Please feel free to contribute any corrections via the sc-users

// list or by emailing me directly.  Thanks!



(
SynthDef("waveguideFlute", { arg scl = 0.2, pch = 72, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4,

ifeedbk2 = 0.4, dur = 1, gate = 1, amp = 2;

var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;

var poly, signalOut, ifqc;

var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;

var fdbckArray;

sr = SampleRate.ir;

cr = ControlRate.ir;

block = cr.reciprocal;

ifqc = pch.midicps;

// noise envelope

kenv1 = EnvGen.kr(Env.new(

[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )

);

// overall envelope

kenv2 = EnvGen.kr(Env.new(

[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: 2

);

// vibrato envelope

kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

// create air flow and vibrato

aflow1 = LFClipNoise.ar( sr, kenv1 );

kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;

afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

fdbckArray = LocalIn.ar( 1 );

aflute1 = fdbckArray;

asum2 = asum1 + ( aflute1 * ifeedbk1 );

//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );

ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

apoly = ax - ( ax.cubed );

asum3 = apoly + ( aflute1 * ifeedbk2 );

avalue = LPF.ar( asum3, 2000 );


aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

fdbckArray = [ aflute1 ];

LocalOut.ar( fdbckArray );

signalOut = avalue;


//OffsetOut.ar( 0, [ signalOut * kenv2, signalOut * kenv2 ] );  leave one signal for the new synth, not two

OffsetOut.ar( 0, [ signalOut * kenv2] );

}).add;



)


s.sendMsg("/s_new", "waveguideFlute", -1, 0, 0, "amp", 1.0, "dur", 1.9, "ipress", 0.88, "ibreath", 0.00536, "ifeedbk1", 0.38, "ifeedbk2", 0.41, "pch", 60 );

s.meter;
s.plotTree;

/*f = Synth('waveguideFlute', [-1, 0, 0, "amp", 0.5, "dur", msg[2], "ipress", 0.88, "ibreath", 0.00536, "ifeedbk1", 0.38, "ifeedbk2", 0.41, "pch", 60 ]);*/


// synth from OSC receiver. trigger synth and pan listening to processing
(
OSCdef ('waveguideFlute', {

	arg msg;

	l = Synth('waveguideFlute', [\amp, 0.05+(msg[2]/2), \dur, 1.2-msg[2], \ipress, 0.85, \ibreath, 0.00536, \ifeedbk1, 0.41, \ifeedbk2, 0.41, \pch, 65+(2*msg[1]+(msg[5]*12)), \doneaction, 2 ]).set;

	r = Synth('waveguideFlute', [\amp, 0.05+(msg[4]/2), \dur, 1.2-msg[4], \ipress, 0.85, \ibreath, 0.00536, \ifeedbk1, 0.41, \ifeedbk2, 0.41, \pch, 66+(2*msg[3]+(msg[6]*12)), \doneaction, 2 ]).set;

	{[l.ar(msg[2]/10) , r.ar(msg[4]/10)]}.release;   //decrease the signal level to avoid clipping

}, "kinect");


// another way to receive the message
// OSCdef ('waveguideFlute', {
// 	arg msgx;
//
// 	s.sendMsg("/s_new", "waveguideFlute", -1, 0, 0, "amp", 0.05+(msgx[2]/2), "dur", 1-msgx[2], "ipress", 0.85, "ibreath", 0.00536, "ifeedbk1", 0.41, "ifeedbk2", 0.41, "pch", 85+(2*msgx[1]) );
//
// }, "kinect");

)



OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting on




)
)kinect");

)



OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting on




)
)