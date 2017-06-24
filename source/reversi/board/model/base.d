module reversi.board.model.base;

import std.typecons;
import reversi.board.iboard;

import std.conv : to;

abstract class ReversiBase : IReversiBoard
{
private:
    Stone _turn;

protected:
    void turn(in Stone turn) @property
    {
        assert(!turn.isNone, "Not set turn to none");
        _turn = turn;
    }
    abstract void opIndexAssign(in Stone s, in int x, in int y);
    alias N = fieldWidth;


public:
    // static immutable int N = 8;

    this()
    {
        reset();
    }

    override void reset()
    {
        turn = Stone.black;

        foreach(i; 0..N)
            foreach(j; 0..N)
                this[i, j] = Stone.none;

        this[N/2 - 1, N/2 - 1] = Stone.white;
        this[N/2 - 1, N/2    ] = Stone.black;
        this[N/2    , N/2 - 1] = Stone.black;
        this[N/2    , N/2    ] = Stone.white;
    }

    override final int opCmp(Object rb_)
    {
        auto rb = cast(IReversiBoard)rb_;

        switch(this.turn)
        {
        case Stone.black:
            if(rb.turn.isBlack)
                break;
            else
                return 1;
        case Stone.white:
            if(rb.turn.isBlack)
                return -1;
            else
                break;
        default: assert(0);
        }

        foreach(y; 0..N)
        {
            foreach(x; 0..N)
            {
                final switch(this[x, y])
                {
                case Stone.black:
                    if(rb[x, y].isBlack)
                        break;
                    else
                        return 1;
                case Stone.white:
                    if(rb[x, y].isWhite)
                        break;
                    else
                        return -11;
                case Stone.none:
                    if(rb[x, y].isNone)
                        break;
                    else if(rb[x, y].isBlack)
                        return -1;
                    else if(rb[x, y].isWhite)
                        return 1;
                }
            }
        }

        return 0;
    }

    override final bool opEquals(Object rb_)
    {
        auto rb = cast(IReversiBoard)rb_;

        if(this.turn != rb.turn)
            return false;

        foreach(x; 0..N)
            foreach(y; 0..N)
                if(this[x, y] != rb[x, y])
                    return false;

        return true;
    }

    override final size_t toHash() nothrow @trusted
    {
        size_t ret = 0;
        size_t d = 0;
        foreach(x; 0..N / 2)
        {
            foreach(y; 0..N)
            {
                ret += this[x, y] * d;
                d *= 3;
            }
        }

        d = 0;
        foreach(x; N / 2..N)
        {
            foreach(y; 0..N)
            {
                ret += this[x, y] * d;
                d *= 3;
            }
        }

        ret += turn * d;

        return ret;
    }

    override final Stone turn() const pure nothrow @property
    {
        return _turn;
    }

    override abstract Stone opIndex(in int x, in int y) const nothrow;

    override final int countBlack() const
    {
        return countStone(Stone.black);
    }
    override final int countWhite() const
    {
        return countStone(Stone.white);
    }
    override int countAll() const
    out(r){
        assert(r == countBlack + countWhite);
    }
    body{
        return fieldSize - countStone(Stone.none);
    }
    abstract int countStone(in Stone stone) const;

    override Stone getPredominance() const
    {
        immutable b = countBlack();
        immutable w = countWhite();
        if(b > w)
            return Stone.black;
        if(b < w)
            return Stone.white;
        return Stone.none;
    }
    override bool isFinished() const
    {
        if(countAll == N * N)
            return true;

        foreach(x; 0..N)
            foreach(y; 0..N)
                if(canPutStone(x, y) || canPutStoneRev(x, y))
                    return false;
        return true;
    }

    protected abstract bool canPutStoneRev(in int x, in int y) const;
    override abstract bool canPutStone(in int x, in int y) const;
    override abstract int countObtainStoneWhenPut(in int x, in int y) const;
    override abstract Tuple!(int,int)[] getToFlipStones(in int x, in int y) const;

    override abstract bool isMyStone(in int x, in int y) const;
    override abstract bool isYourStone(in int x, in int y) const;
    override abstract bool isNoStone(in int x, in int y) const;

    override final bool isInField(in int x) const pure nothrow
    {
        return x >= 0 && x < N;
    }

    override final bool isInField(in int x, in int y) const pure nothrow
    {
        return isInField(x) && isInField(y);
    }

    override abstract void putStone(in int x, in int y);
    override abstract void putStoneWithSave(in int x, in int y);
    override abstract void restore();
    override abstract int lengthSave() const;

    override void pass()
    {
        turn = turn.rev;
    }

    override abstract IReversiBoard dup();

    override string toString() const
    {
        string ret = " ";
        foreach(i; 1..N+1)
            ret ~= " " ~ i.to!string;

        ret ~= "\n";

        foreach(y; 0..N)
        {
            ret ~= (y + 1).to!string ~ " ";
            foreach(x; 0..N)
            {
                ret ~= this[x, y].symbol ~ " ";
            }
            ret ~= (y + 1).to!string ~ "\n";
        }

        ret ~= " ";

        foreach(i; 1..N+1)
            ret ~= " " ~ i.to!string;

        return ret ~ "\n";
    }
}
