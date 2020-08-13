// @taubaland
// The Square.
// Big sister, opinionated on her pulsewidth, but reasonable.

{
    arg out, hz=440, amp=0.02, amplag=0.02, hzlag=0.01;
    var amp_, hz_;
    amp_ = Lag.ar(K2A.ar(amp), amplag);
    hz_ = Lag.ar(K2A.ar(hz), hzlag);
    Out.ar(out, (Pulse.ar(hz_, 0.5) * amp_).dup);
}
