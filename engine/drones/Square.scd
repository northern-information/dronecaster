// @taubaland
// The Square.
// Big sister, opinionated on her pulsewidth, but reasonable.

{
    arg hz, amp;
    (Pulse.ar(hz, 0.5) * amp).dup;
}
