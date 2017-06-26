module reversi.playable.playermanager;

import reversi.board.iboard;
import reversi.playable.iplayer;

class PlayerManager
{
    IPlayer black;
    IPlayer white;

    this(IPlayer black, IPlayer white)
    {
        this.black = black;
        this.white = white;
    }

    Move getMove(in IReversiBoard rb)
    {
        final switch(rb.turn)
        {
        case Stone.black:
            return black.getMove(rb);
        case Stone.white:
            return white.getMove(rb);
        case Stone.none:
            assert(0);
        }
    }
}
