module reversi.playable.eval.evals;

import reversi.board.iboard;
import reversi.playable.eval.stonecount;
import reversi.playable.eval.stonepos;


int evals(in IReversiBoard rb)
{
    if(rb.isFinished)
        return evalStoneCount(rb);
    else
        return evalStonePos(rb);
}
