module reversi.playable.iplayer;

public import reversi.board.iboard;
public import reversi.playable.move;

interface IPlayer
{
    Move getMove(in IReversiBoard rb)
    /+out(r){
        if(r)
        {
            assert(
                rb.canPutStone(x, y),
                "Cannot put there."
            );
        }
    }+/;
}
