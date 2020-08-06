// @cfdrake
{
    arg out, hz=440, amp=0.02, amplag=0.02, hzlag=0.01;
    var amp_, hz_;
    amp_ = Lag.ar(K2A.ar(amp), amplag);
    hz_ = Lag.ar(K2A.ar(hz), hzlag);
    Out.ar(out, Splay.ar(Array.fill(5, { |i|
        BPF.ar(
        Saw.ar(hz_ * i + SinOsc.kr(0.1 * i, 0, 0.5)),
        100 + (i * 100) + SinOsc.kr(0.05 * i, mul: 100),
        2
        )
    }), 1) * amp_);
}
