module reversi.board.model.array.arraymodel;

import reversi.board.iboard;
import reversi.board.model.array.arraymodelbase;
import reversi.board.stone;

import std.stdio;
import std.conv : to;
import std.typecons;


class ArrayReversiModel : ArrayReversiModelBase
{
private:
    Tuple!(const int, const int, const Stone)[][] diffs;

public:

    override void restore()
    {
        if(lengthSave == 0)
            throw new Exception("pop error");

        foreach(i, const d; diffs[$-1])
        {
            this[d[0], d[1]] = d[2];
        }

        diffs = diffs[0..$-1];

        pass();
        /+stderr.writeln("restore");
        stderr.writeln(this);
        if(readln!="\n")throw new Exception("");
        +/
    }

    override int lengthSave() const pure nothrow
    {
        return diffs.length;
    }

    override bool canPutStoneRev(in int x, in int y) const
    {
        return _canPutStone(x, y, turn.rev);
    }

    override bool canPutStone(in int x, in int y) const
    {
        return _canPutStone(x, y, turn);
    }

    bool _canPutStone(in int x, in int y, in Stone stone) const
    {
        if(!this[x, y].isNone)
            return false;

        if(canPut!("hor"  )(x, y, stone))
            return true;
        if(canPut!("ver"  )(x, y, stone))
            return true;
        if(canPut!("diag" )(x, y, stone))
            return true;
        if(canPut!("diagr")(x, y, stone))
            return true;

        return false;
    }

    override int countObtainStoneWhenPut(in int x, in int y) const pure nothrow
    {
        assert(0, "Not supported");
    }

    override Tuple!(int,int)[] getToFlipStones(in int x, in int y) const
    {
        assert(0, "Not supported");
    }

    override IReversiBoard dup()
    {
        auto new_rb = new typeof(this);
        foreach(x; 0..N)
            foreach(y; 0..N)
                new_rb[x, y] = this[x, y];

        new_rb.turn = this.turn;
        new_rb.diffs = this.diffs.dup;
        return new_rb;
    }

    override void putStone(in int x, in int y)
    {
        putStone!false(x, y);
    }
    override void putStoneWithSave(in int x, in int y)
    {
        //stderr.writeln(turn.symbol);
        putStone!true(x, y);
        /+stderr.writeln("put");
        stderr.writeln(this);
        if(readln!="\n")throw new Exception("");
        +/
    }


private:
    void putStone(bool save)(in int x, in int y)
    {
        if(!this[x, y].isNone)
            throw new CannotPutException("("~x.to!string~","~y.to!string~") A stone already exists.");

        static if(save)
            ++diffs.length;

        debug enum PRINT = false;
        debug static if(PRINT)stderr.write(x,",",y);

        bool is_put = false;
        if(put!("hor"  , save)(x, y))
        {
            debug static if(PRINT)stderr.write("h");
            is_put = true;
        }
        if(put!("ver"  , save)(x, y))
        {
            debug static if(PRINT)stderr.write("v");
            is_put = true;
        }
        if(put!("diag" , save)(x, y))
        {
            debug static if(PRINT)stderr.write("d");
            is_put = true;
        }
        if(put!("diagr", save)(x, y))
        {
            debug static if(PRINT)stderr.write("r");
            is_put = true;
        }
        static if(PRINT)stderr.writeln;

        if(!is_put)
        {
            static if(save)
                --diffs.length;
            debug static if(PRINT) stderr.writeln(this, turn.symbol);
            throw new CannotPutException("("~x.to!string~","~y.to!string~") No stone flips.");
        }
        else
        {
            static if(save)
                diffs[$-1] ~= tuple(x, y, cast(const)this[x, y]);
            this[x, y] = turn;

            pass();
        }
    }

    bool canPut(string dir)(in int x, in int y, in Stone stone) const
    if(dir == "hor" || dir == "ver" || dir == "diag" || dir == "diagr")
    {
        static if(dir == "hor")
            return _canPut!("x + i", "y"    , "x + j", "y"    )(x, y, stone);
        else static if(dir == "ver")
            return _canPut!("x"    , "y + i", "x"    , "y + j")(x, y, stone);
        else static if(dir == "diag")
            return _canPut!("x + i", "y + i", "x + j", "y + j")(x, y, stone);
        else static if(dir == "diagr")
            return _canPut!("x + i", "y - i", "x + j", "y - j")(x, y, stone);
        else
            static assert(0);
    }

    bool _canPut(string px1, string py1, string px2, string py2)
    (in int x, in int y, in Stone stone) const
    {
        static immutable really_put = false;
        static immutable save = false;
        mixin(sss);
    }

    bool put(string dir, bool save)(in int x, in int y)
    if(dir == "hor" || dir == "ver" || dir == "diag" || dir == "diagr")
    {
        static if(dir == "hor")
            return _put!("x + i", "y"    , "x + j", "y"    ,save)(x, y);
        else static if(dir == "ver")
            return _put!("x"    , "y + i", "x"    , "y + j", save)(x, y);
        else static if(dir == "diag")
            return _put!("x + i", "y + i", "x + j", "y + j", save)(x, y);
        else static if(dir == "diagr")
            return _put!("x + i", "y - i", "x + j", "y - j", save)(x, y);
        else
            static assert(0);
    }

    bool _put(string px1, string py1, string px2, string py2, bool save)(in int x, in int y)
    {
        static immutable really_put = true;
        immutable stone = turn;
        mixin(sss);
    }
}

string sss()()
{
    return q{
        static if(really_put)
        {
            bool changed = false;
        }

        for(int i = 1; ; ++i)
        {
            immutable s = getStone(mixin(px1), mixin(py1));
            if(s.isNone)
            {
                break;
            }
            else if(s == stone)
            {
                if(i > 1)
                {
                    static if(!really_put)
                    {
                        return true;
                    }
                    else
                    {
                        changed = true;
                        foreach(j; 1..i)
                        {
                            static if(save)
                            {
                                diffs[$-1] ~= tuple(cast(const)(mixin(px2)), cast(const)(mixin(py2)), cast(const)this[mixin(px2), mixin(py2)]);
                            }
                            this[mixin(px2), mixin(py2)] = stone;
                        }
                    }
                }
                break;
            }
        }

        for(int i = -1; ; --i)
        {
            immutable s = getStone(mixin(px1), mixin(py1));
            if(s.isNone)
            {
                break;
            }
            else if(s == stone)
            {
                if(i < -1)
                {
                    static if(!really_put)
                    {
                        return true;
                    }
                    else
                    {
                        changed = true;
                        foreach(j; i+1..0)
                        {
                            static if(save)
                            {
                                diffs[$-1] ~= tuple(cast(const)(mixin(px2)), cast(const)(mixin(py2)), cast(const)this[mixin(px2), mixin(py2)]);
                            }
                            this[mixin(px2), mixin(py2)] = stone;
                        }
                    }
                }
                break;
            }
        }

        static if(really_put)
            return changed;
        else
            return false;
    };
}
