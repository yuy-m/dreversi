module reversi.playable.eval.stonepos;

import reversi.board.iboard;

immutable int[][] val_table = [
    [ 30, -12,   0,  -1,  -1,  0, -12, 30],
    [-12, -15,  -3,  -3,  -3, -3, -15,-12],
    [  0,  -3,   0,  -1,  -1,  0,  -3,  0],
    [ -1,  -3,  -1,  -1,  -1, -1,  -3, -1],
    [ -1,  -3,  -1,  -1,  -1, -1,  -3, -1],
    [  0,  -3,   0,  -1,  -1,  0,  -3,  0],
    [-12, -15,  -3,  -3,  -3, -3, -15,-12],
    [ 30, -12,   0,  -1,  -1,  0, -12, 30]
];

int evalStonePos(in IReversiBoard rb)
{
    int val = 0;

    foreach(x; 0..rb.fieldWidth)
        foreach(y; 0..rb.fieldWidth)
            val += val_table[x][y] * rb[x, y];

    return val;
}
