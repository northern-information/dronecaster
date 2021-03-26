// @cfdrake
{
    arg hz, amp;
    Splay.ar(Array.fill(5, { |i|
        BPF.ar(
        Saw.ar(hz * i + SinOsc.kr(0.1 * i, 0, 0.5)),
        100 + (i * 100) + SinOsc.kr(0.05 * i, mul: 100),
        2
        )
    }), 1) * amp;
}
