// @yourname
// your drone name
// how does your drone describe itself

{
    arg hz=440, amp=0.02, amplag=0.02, hzlag=0.01;
    var amp_, hz_, sig;
    amp_ = Lag.ar(K2A.ar(amp), amplag);
    hz_ = Lag.ar(K2A.ar(hz), hzlag);
    
    // << the drone zone >>
    // replace with your drone zone!
    // << end drone zone >>

}
