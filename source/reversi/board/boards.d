module reversi.board.boards;

import reversi.board.iboard;
import reversi.board.model.array.arraymodel;
import reversi.board.model.bit.bitmodel;

IReversiBoard createReversi()
{
    return new BitReversiModel();
}

IReversiBoard createArrayReversi()
{
    return new ArrayReversiModel();
}

IReversiBoard createBitReversi()
{
    return new BitReversiModel();
}
