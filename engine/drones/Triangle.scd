// @taubaland
// The Triangle.
// Little brother to Sine.

{
    arg hz=440, amp=0.02, amplag=0.02, hzlag=0.01;
    var amp_, hz_;
    amp_ = Lag.ar(K2A.ar(amp), amplag);
    hz_ = Lag.ar(K2A.ar(hz), hzlag);
    (LFTri.ar(hz_) * amp_).dup;
}
