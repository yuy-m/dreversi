module reversi.playable.algo.random;

public import reversi.playable.iplayer;
import reversi.playable.utility;


class Random : IPlayer
{
    override Move getMove(in IReversiBoard rb)
    {
        import std.random;
        const ls = rb.getCanPutStone();
        if(ls.length == 0)
            return null;

        immutable n = uniform(0, ls.length);

        return new Move(ls[n][0], ls[n][1]);
    }
}

