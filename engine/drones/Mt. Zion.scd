// @license
// Thee rusted satellites gather + sing.
{
    arg out, hz=55.1, amp=0.02, amplag=0.02, hzlag=0.01;
    var amp_ = Lag.ar(K2A.ar(amp), amplag);
    var hz_ = Lag.ar(K2A.ar(hz), hzlag);
    var voiceCount = 5;
    var baseNote = hz_.cpsmidi.round;
    var noteDetune = (baseNote - hz_.cpsmidi).abs;
    var maxAmp = amp_ / voiceCount;
    
    var rand = ({|sampleFreq=1, mul=1, add=0, lag=0.5|
        Latch.ar(WhiteNoise.ar(mul, add), Dust.ar(sampleFreq)).lag(lag)
    });
    
    var voices = (1..voiceCount).collect({ |index|
        Pan2.ar(
        Pulse.ar(
            rand.(0.2, noteDetune, baseNote, 2).midicps * index,
            rand.(0.5, 0.5, 1.5)
        ),
        rand.(0.3),
        rand.(0.1, maxAmp)
        );
    });
    Out.ar(out, Mix.ar(voices));
}
