// @infinitedigits
// THX
// http://earslap.com/article/recreating-the-thx-deep-note.html
{
    arg hz,amp;
    var numVoices = 12;
    var fundamentals = ({rrand(100.0, 500.0)}!numVoices).sort.reverse;
    var finalPitches =  (numVoices.collect({|nv| hz*(2**((nv/2).round-3)); }));
    var sweepFactors = ({rrand(0.2,2)}!numVoices);
    var voices=(1..numVoices-1).collect({|numTone|
        var initRandomFreq = fundamentals[numTone] + LFNoise2.kr(0.5, 6 * (numVoices - (numTone + 1)));
        var destinationFreq = finalPitches[numTone] + LFNoise2.kr(0.1, (numTone / 2));
        var sweepFactor = sweepFactors[numTone];
        var sweepEnv = amp;
        var freq = ((1 - (sweepEnv**sweepFactor)) * initRandomFreq) + ((sweepEnv**sweepFactor) * destinationFreq);
        Pan2.ar(
            BLowPass.ar(Saw.ar(freq), freq * 6, 0.6),
            rrand(-0.6, 0.6),
            ((1 - (1/(numTone + 1)))**4) +0.4
        ) / numVoices
    });
    Mix.ar(voices)/10;
}
