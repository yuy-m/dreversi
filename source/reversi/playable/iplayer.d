module reversi.playable.iplayer;

public import reversi.board.iboard;

interface IPlayer
{
    bool getMove(in IReversiBoard rb, out int x, out int y)
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
