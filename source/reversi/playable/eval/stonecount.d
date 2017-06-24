module reversi.playable.eval.stonecount;

import reversi.board.iboard;


int evalStoneCount(in IReversiBoard rb)
{
    immutable black_stone  = rb.countBlack;
    immutable white_stone = rb.countWhite;

    if(rb.turn.isBlack)
            return black_stone - white_stone;
        else
            return white_stone - black_stone;

}
