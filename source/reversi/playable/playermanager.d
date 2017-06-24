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

    bool getMove(in IReversiBoard rb, out int x, out int y)
    {
        final switch(rb.turn)
        {
        case Stone.black:
            return black.getMove(rb, x, y);
        case Stone.white:
            return white.getMove(rb, x, y);
        case Stone.none:
            assert(0);
        }
    }
}
