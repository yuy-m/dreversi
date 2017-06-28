module reversi.playable.playermanager;

import reversi.board.iboard;
import reversi.playable.iplayer;

class PlayerManager
{
private:
    IPlayer black_;
    IPlayer white_;

public:
    this(IPlayer black, IPlayer white)
    {
        this.black_ = black;
        this.white_ = white;
    }

    const(IPlayer) now(in IReversiBoard rb) const
    {
        final switch(rb.turn)
        {
        case Stone.black: return black_;
        case Stone.white: return white_;
        case Stone.none:  assert(0);
        }
    }

    Move getMove(in IReversiBoard rb)
    {
        final switch(rb.turn)
        {
        case Stone.black: return black_.getMove(rb);
        case Stone.white: return white_.getMove(rb);
        case Stone.none:  assert(0);
        }
    }
}
