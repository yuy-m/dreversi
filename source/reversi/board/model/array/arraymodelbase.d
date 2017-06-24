module reversi.board.model.array.arraymodelbase;

import reversi.board.model.base;
import reversi.board.stone;

import std.typecons;
import std.conv : to;

abstract class ArrayReversiModelBase : ReversiBase
{
private:
    Stone[N+2][N+2] _field;

protected:
    override final void opIndexAssign(in Stone s, in int x, in int y) pure nothrow
    {
        assert(
            isInField(x, y),
            "Out of field ("~x.to!string~","~y.to!string~")"
        );
        _field[y + 1][x + 1] = s;
    }

    final Stone getStone(in int x, in int y) const pure nothrow
    {
        return _field[y + 1][x + 1];
    }

public:

    override final Stone opIndex(in int x, in int y) const pure nothrow
    {
        assert(
            isInField(x, y),
            "Out of field ("~x.to!string~","~y.to!string~")"
        );
        return _field[y + 1][x + 1];
    }

    override final int countStone(in Stone stone) const pure nothrow
    {
        int cnt = 0;
        foreach(x; 0..N)
            foreach(y; 0..N)
                if(this[x, y] == stone)
                    ++cnt;
        return cnt;
    }

    override final bool isMyStone(in int x, in int y) const pure nothrow
    {
        return this[x, y] == turn;
    }
    override final bool isYourStone(in int x, in int y) const pure nothrow
    {
        return this[x, y] == turn.rev;
    }
    override final bool isNoStone(in int x, in int y) const pure nothrow
    {
        return this[x, y] == Stone.none;
    }

    override abstract int countObtainStoneWhenPut(in int x, in int y) const;
    override abstract Tuple!(int,int)[] getToFlipStones(in int x, in int y) const;

    override abstract void putStone(in int x, in int y);
    override abstract void putStoneWithSave(in int x, in int y);
    override abstract void restore();
    override abstract int lengthSave() const;

    import reversi.board.iboard;
    override abstract IReversiBoard dup();
}
