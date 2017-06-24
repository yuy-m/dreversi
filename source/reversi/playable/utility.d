module reversi.playable.utility;

import reversi.board.iboard;

import std.typecons;

auto getCanPutStone(in IReversiBoard rb)
{
    Tuple!(int, int, Stone)[] ls;

    foreach(x; 0..rb.fieldWidth)
        foreach(y; 0..rb.fieldWidth)
            if(rb.canPutStone(x, y))
            {
                import std.stdio;
                //writefln("(%s,%s)", x, y);
                ls ~= tuple(x, y, rb.turn);
            }

    return ls;
}

int countCanPutStone(in IReversiBoard rb)
{
    int cnt = 0;

    foreach(x; 0..rb.fieldWidth)
        foreach(y; 0..rb.fieldWidth)
            if(rb.canPutStone(x, y))
                ++cnt;

    return cnt;
}

auto x(in Tuple!(int,int, Stone) p) pure nothrow
{
    return p[0];
}

auto y(in Tuple!(int,int, Stone) p) pure nothrow
{
    return p[1];
}


class PosVal
{
    immutable int x;
    immutable int y;
    int val;

pure:
    this(in int x, in int y) nothrow
    {
        this.x = x;
        this.y = y;
        val = 0;
    }

    int opCmp(in PosVal rval) const nothrow
    {
        if(this.val > rval.val)
            return 1;
        else if(this.val < rval.val)
            return -1;
        return 0;
    }

    override string toString() const
    {
        import std.format;
        return "(%s,%s)".format(x,y);
    }
}

void sort(T)(ref T[] ls) pure nothrow
{
    T tmp;
    foreach(i ; 1..ls.length)
    {
        tmp = ls[i];
        if(ls[i-1] > tmp)
        {
            int j = i;
            do{
                ls[j] = ls[j-1];
                --j;
            }while(j > 0 && ls[j-1] > tmp);
            ls[j] = tmp;
        }
    }
}

auto getCanPutPosVal(in IReversiBoard rb)
{
    PosVal[] ls;

    foreach(x; 0..rb.fieldWidth)
        foreach(y; 0..rb.fieldWidth)
            if(rb.canPutStone(x, y))
                ls ~= new PosVal(x, y);

    return ls;
}

