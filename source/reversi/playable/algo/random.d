module reversi.playable.algo.random;

public import reversi.playable.iplayer;
import reversi.playable.utility;


class Random : IPlayer
{
    override bool getMove(in IReversiBoard rb, out int x, out int y)
    {
        import std.random;
        const ls = rb.getCanPutStone();
        if(ls.length == 0)
            return false;

        immutable n = uniform(0, ls.length);

        x = ls[n][0];
        y = ls[n][1];
        return true;
    }
}

