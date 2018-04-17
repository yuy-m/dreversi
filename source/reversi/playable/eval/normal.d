module reversi.playable.eval.normal;

import reversi.board.iboard;
import reversi.playable.utility;


public int normaleval(bool print = false)(in IReversiBoard rb)
{
    immutable black_stone  = rb.countBlack;
    immutable white_stone = rb.countWhite;
    immutable all_stone = black_stone + white_stone;

    if(all_stone == N)
    {
        //石数
        if(rb.turn.isBlack)
            return ((black_stone - white_stone) << 9);
        else
            return ((white_stone - black_stone) << 9);
    }
    else
    {
        //位置評価
        immutable val1 = poseval(rb);

        //着手可能数
        immutable val2 = countCanPutStone(rb);

        //石数
        immutable val3 =
            rb.turn.isBlack
          ? black_stone - white_stone
          : white_stone - black_stone;

        // 確定石
        int val4 = confirmstoneeval(rb);

        //集計
        if(all_stone < N / 4)
            return val1 << 4//8
                 + val2 << 5//9
                 - val3 << 2//7
                 + val4 << 1;
        else if(all_stone < N / 2)
            return val1 << 4//7
                 + val2 << 5//9
                 - val3 << 2//5
                 + val4 << 3;
        else if(all_stone < N * 3 / 4)
            return val1 << 2//3
                 + val2 << 3//9
                 + val3 << 3//6
                 + val4 << 4;
        else
            return val1 << 1//1
                 + val2 << 2//4
                 + val3 << 5//10
                 + val4 << 4;
    }
}

public int normaleval(bool print = false)(in ulong me, in ulong you)
out(r){
    import std.stdio;
    stderr.writeln(r);
}
body{
    import reversi.board.model.bit.bitmodel;

    immutable my_stone  = me.countBit;
    immutable your_stone = you.countBit;
    immutable all_stone = my_stone + your_stone;

    if(all_stone == N)
    {
        //石数
        return (my_stone - your_stone) << 9;
    }
    else
    {
        //位置評価
        immutable val1 = poseval(me, you);
        //stderr.write("1");

        //着手可能数
        immutable val2 = {
            int cnt = 0;
            foreach(x; 0..N)
                foreach(y; 0..N)
                    if(BitReversiModel.getFlipPattern(me, you, x, y))
                        ++cnt;
            return cnt;
        }();
        //stderr.write("2");

        //石数
        immutable val3 = my_stone - your_stone;
        //stderr.write("3");

        // 確定石
        int val4 = confirmstoneeval(me, you);
        //stderr.write("4");

        //集計
        if(all_stone < N / 4)
            return val1 << 4//8
                 + val2 << 5//9
                 - val3 << 2//7
                 + val4 << 1;
        else if(all_stone < N / 2)
            return val1 << 4//7
                 + val2 << 5//9
                 - val3 << 2//5
                 + val4 << 3;
        else if(all_stone < N * 3 / 4)
            return val1 << 2//3
                 + val2 << 3//9
                 + val3 << 3//6
                 + val4 << 4;
        else
            return val1 << 1//1
                 + val2 << 2//4
                 + val3 << 5//10
                 + val4 << 4;
    }
}

private:

immutable int[][] point = [
    [ 15,-15, 0,-1,-1, 0,-15, 15],
    [-15,-17,-3,-3,-3,-3,-17,-15],
    [  0, -3, 0,-1,-1, 0, -3,  0],
    [ -1, -3,-1,-1,-1,-1, -3, -1],
    [ -1, -3,-1,-1,-1,-1, -3, -1],
    [  0, -3, 0,-1,-1, 0, -3,  0],
    [-15,-17,-3,-3,-3,-3,-17,-15],
    [ 15,-15, 0,-1,-1, 0,-15, 15]
];

int poseval(in IReversiBoard rb)
{
    immutable width = rb.fieldWidth;

    int val1 = 0;

    void addVal1(in int x, in int y)
    {
        if(rb.isMyStone(x, y))
            val1 += point[x][y];
        else if(rb.isYourStone(x, y))
            val1 -= point[x][y];
    }

    foreach(i ; 2 .. width - 2)
    {
        addVal1(0, i);
        addVal1(1, i);
        addVal1(width - 1, i);
        addVal1(width - 2, i);
        addVal1(i, 0);
        addVal1(i, 1);
        addVal1(i, width - 1);
        addVal1(i, width - 2);
        /+
            if(rb.isMyStone(0, i))
                val1 += point[0][i];
            else if(rb.isYourStone(0, i))
                val1 -= point[0][i];

            if(rb.isMyStone(1, i))
                val1 += point[1][i];
            else if(rb.isYourStone(1, i))
                val1 -= point[1][i];

            if(rb.isMyStone(width - 1, i))
                val1 += point[width - 1][i];
            else if(rb.isYourStone(width - 1, i))
                val1 -= point[width - 1][i];

            if(rb.isMyStone(width - 2, i))
                val1 += point[width - 2][i];
            else if(rb.isYourStone(width - 2, i))
                val1 -= point[width - 2][i];
        +/

        foreach(j ; 2..width - 2)
            addVal1(i, j);
    }

    //隅評価
    val1 += cornerVal!(
            0, 0,
            1, 0,
            0, 1,
            1, 1
        )(rb);
    val1 += cornerVal!(
            width - 1, 0,
            width - 2, 0,
            width - 1, 1,
            width - 2, 1
        )(rb);
    val1 += cornerVal!(
            0, width - 1,
            0, width - 2,
            1, width - 1,
            1, width - 2
        )(rb);
    val1 += cornerVal!(
            width - 1, width - 1,
            width - 1, width - 2,
            width - 2, width - 1,
            width - 2, width - 2
        )(rb);

    return val1;
}


int cornerVal(
    int p1_x, int p1_y,
    int p2_x, int p2_y,
    int p3_x, int p3_y,
    int p4_x, int p4_y
)
(in IReversiBoard rb)
{
    int val = 0;

    if(rb.isMyStone(p1_x, p1_y))
    {
        val += point[0][0];
    }
    else if(rb.isYourStone(p1_x, p1_y))
    {
        val -= point[0][0];
    }
    else // if(rb.isNoStone(p1_x, p1_y))
    {
        if(rb.isMyStone(p2_x, p2_y))
            val += point[1][0];
        else if(rb.isYourStone(p2_x, p2_y))
            val -= point[1][0];

        if(rb.isMyStone(p3_x, p3_y))
            val +=point[0][1];
        else if(rb.isYourStone(p3_x, p3_y))
            val -= point[0][1];

        if(rb.isMyStone(p4_x, p4_y))
            val += point[1][1];
        else if(rb.isYourStone(p4_x, p4_y))
            val -= point[1][1];
    }
    return val;
}

int confirmstoneeval(in IReversiBoard rb)
{
    immutable width = rb.fieldWidth;
    int val4 = 0;

    if(rb.isMyStone(0, 0))
    {
        for(int x = 1; rb.isInField(x) && rb.isMyStone(x, 0); ++x)
            ++val4;
        for(int y = 1; rb.isInField(y) && rb.isMyStone(0, y); ++y)
            ++val4;
    }
    else if(rb.isYourStone(0, 0))
    {
        for(int x = 1; rb.isInField(x) && rb.isYourStone(x, 0); ++x)
            --val4;
        for(int y = 1; rb.isInField(y) && rb.isYourStone(0, y); ++y)
            --val4;
    }

    if(rb.isMyStone(width - 1, 0))
    {
        for(int x = width - 2; rb.isInField(x) && rb.isMyStone(x, 0); --x)
            ++val4;
        for(int y = 1; rb.isInField(y) && rb.isMyStone(width - 1, y); ++y)
            ++val4;
    }
    else if(rb.isYourStone(width - 1, 0))
    {
        for(int x = width - 2; rb.isInField(x) && rb.isYourStone(x, 0); --x)
            --val4;
        for(int y = 1; rb.isInField(y) && rb.isYourStone(width - 1, y); ++y)
            --val4;
    }

    if(rb.isMyStone(0, width - 1))
    {
        for(int x = 1; rb.isInField(x) && rb.isMyStone(x, width - 1); ++x)
            ++val4;
        for(int y = width - 2; rb.isInField(y) && rb.isMyStone(0, y); --y)
            ++val4;
    }
    else if(rb.isYourStone(0, width - 1))
    {
        for(int x = 1; rb.isInField(x) && rb.isYourStone(x, width - 1); ++x)
            --val4;
        for(int y = width - 2; rb.isInField(y) && rb.isYourStone(0, y); --y)
            --val4;
    }

    if(rb.isMyStone(width - 1, width - 1))
    {
        for(int x = width - 2; rb.isInField(x) && rb.isMyStone(x, width - 1); --x)
            ++val4;
        for(int y = width - 2; rb.isInField(y) && rb.isMyStone(width - 1, y); --y)
            ++val4;
    }
    else if(rb.isYourStone(width - 1, width - 1))
    {
        for(int x = width - 2; rb.isInField(x) && rb.isYourStone(x, width - 1); --x)
            --val4;
        for(int y = width - 2; rb.isInField(y) && rb.isYourStone(width - 1, y); --y)
            --val4;
    }
    return val4;
}


import reversi.board.model.bit.bitmodel;
int poseval(in ulong me, in ulong you)
{
    immutable width = N;

    int val1 = 0;

    bool isMyStone(in int x, in int y)
    {
        return BitReversiModel.maskedField(me, x, y) != 0L;
    }
    bool isYourStone(in int x, in int y)
    {
        return BitReversiModel.maskedField(you, x, y) != 0L;
    }

    void addVal1(in int x, in int y)
    {
        if(isMyStone(x, y))
            val1 += point[x][y];
        else if(isYourStone(x, y))
            val1 -= point[x][y];
    }

    foreach(i ; 2 .. width - 2)
    {
        addVal1(0, i);
        addVal1(1, i);
        addVal1(width - 1, i);
        addVal1(width - 2, i);
        addVal1(i, 0);
        addVal1(i, 1);
        addVal1(i, width - 1);
        addVal1(i, width - 2);

        foreach(j ; 2..width - 2)
            addVal1(i, j);
    }

    //隅評価
    val1 += cornerVal!(
            0, 0,
            1, 0,
            0, 1,
            1, 1
        )(me, you);
    val1 += cornerVal!(
            width - 1, 0,
            width - 2, 0,
            width - 1, 1,
            width - 2, 1
        )(me, you);
    val1 += cornerVal!(
            0, width - 1,
            0, width - 2,
            1, width - 1,
            1, width - 2
        )(me, you);
    val1 += cornerVal!(
            width - 1, width - 1,
            width - 1, width - 2,
            width - 2, width - 1,
            width - 2, width - 2
        )(me, you);

    return val1;
}


int cornerVal(
    int p1_x, int p1_y,
    int p2_x, int p2_y,
    int p3_x, int p3_y,
    int p4_x, int p4_y
)
(in ulong me, in ulong you)
{
    bool isMyStone(in int x, in int y)
    {
        return BitReversiModel.maskedField(me, x, y) != 0L;
    }
    bool isYourStone(in int x, in int y)
    {
        return BitReversiModel.maskedField(you, x, y) != 0L;
    }

    int val = 0;

    if(isMyStone(p1_x, p1_y))
    {
        val += point[0][0];
    }
    else if(isYourStone(p1_x, p1_y))
    {
        val -= point[0][0];
    }
    else
    {
        if(isMyStone(p2_x, p2_y))
            val += point[1][0];
        else if(isYourStone(p2_x, p2_y))
            val -= point[1][0];

        if(isMyStone(p3_x, p3_y))
            val +=point[0][1];
        else if(isYourStone(p3_x, p3_y))
            val -= point[0][1];

        if(isMyStone(p4_x, p4_y))
            val += point[1][1];
        else if(isYourStone(p4_x, p4_y))
            val -= point[1][1];
    }
    return val;
}

int confirmstoneeval(in ulong me, in ulong you)
{
    bool isMyStone(in int x, in int y) pure nothrow
    {
        return BitReversiModel.maskedField(me, x, y) != 0L;
    }
    bool isYourStone(in int x, in int y) pure nothrow
    {
        return BitReversiModel.maskedField(you, x, y) != 0L;
    }
    static bool isInField(in int x) pure nothrow
    {
        return x >= 0 && x < N;
    }

    immutable width = N;
    int val4 = 0;

    if(isMyStone(0, 0))
    {
        for(int x = 1; isInField(x) && isMyStone(x, 0); ++x)
            ++val4;
        for(int y = 1; isInField(y) && isMyStone(0, y); ++y)
            ++val4;
    }
    else if(isYourStone(0, 0))
    {
        for(int x = 1; isInField(x) && isYourStone(x, 0); ++x)
            --val4;
        for(int y = 1; isInField(y) && isYourStone(0, y); ++y)
            --val4;
    }

    if(isMyStone(width - 1, 0))
    {
        for(int x = width - 2; isInField(x) && isMyStone(x, 0); --x)
            ++val4;
        for(int y = 1; isInField(y) && isMyStone(width - 1, y); ++y)
            ++val4;
    }
    else if(isYourStone(width - 1, 0))
    {
        for(int x = width - 2; isInField(x) && isYourStone(x, 0); --x)
            --val4;
        for(int y = 1; isInField(y) && isYourStone(width - 1, y); ++y)
            --val4;
    }

    if(isMyStone(0, width - 1))
    {
        for(int x = 1; isInField(x) && isMyStone(x, width - 1); ++x)
            ++val4;
        for(int y = width - 2; isInField(y) && isMyStone(0, y); --y)
            ++val4;
    }
    else if(isYourStone(0, width - 1))
    {
        for(int x = 1; isInField(x) && isYourStone(x, width - 1); ++x)
            --val4;
        for(int y = width - 2; isInField(y) && isYourStone(0, y); --y)
            --val4;
    }

    if(isMyStone(width - 1, width - 1))
    {
        for(int x = width - 2; isInField(x) && isMyStone(x, width - 1); --x)
            ++val4;
        for(int y = width - 2; isInField(y) && isMyStone(width - 1, y); --y)
            ++val4;
    }
    else if(isYourStone(width - 1, width - 1))
    {
        for(int x = width - 2; isInField(x) && isYourStone(x, width - 1); --x)
            --val4;
        for(int y = width - 2; isInField(y) && isYourStone(width - 1, y); --y)
            --val4;
    }
    return val4;
}


