module reversi.board.model.bit.bitmodel;

import reversi.board.iboard;
import reversi.board.model.base;
import std.typecons;
import std.stdio;
import std.conv;

class BitReversiModel : ReversiBase
{
private:
    alias hist_t = Tuple!(ulong, "black", ulong, "white", Stone, "turn");
    ulong black_field_;
    ulong white_field_;
    hist_t[] history;

    invariant()
    {
        assert(checkConsistency);
        //assert(countAll <= fieldSize);
    }

    bool checkConsistency() const pure nothrow
    {
        return checkConsistency_(black_field_, white_field_);
    }
    static bool checkConsistency_(in ulong a, in ulong b) pure nothrow
    {
        return (a & b) == 0L;
    }
    unittest{
        assert(!checkConsistency_(0x000000000000000FL, 0x000000000000000FL));
        assert(checkConsistency_(0x0000F00000000000L, 0x0000000000F00000L));
    }

protected:
    override void opIndexAssign(in Stone s, in int x, in int y) pure nothrow
    {
        assert(isInField(x, y));
        final switch(s)
        {
        case Stone.black:
            black_field_ |= mask(x, y);
            white_field_ &= ~mask(x, y);
            break;
        case Stone.white:
            black_field_ &= ~mask(x, y);
            white_field_ |= mask(x, y);
            break;
        case Stone.none:
            black_field_ &= ~mask(x, y);
            white_field_ &= ~mask(x, y);
            break;
        }
    }

public:
    static ulong mask(in int x, in int y) pure nothrow
    {
        return 1L << (x + y * fieldWidth);
    }
    unittest{
        assert((0x55AA55AA55AA55AAL & mask(3, 1)) == 0x0000000000000000L);
        assert((0x55AA55AA55AA55AAL & mask(5, 4)) == 0x0000002000000000L);
    }
    static ulong maskedField(in ulong field, in int x, in int y) pure nothrow
    {
        return field & mask(x, y);
    }

    ulong maskedBlack(in int x, in int y) const pure nothrow
    {
        return maskedField(black_field_, x, y);
    }
    ulong maskedWhite(in int x, in int y) const pure nothrow
    {
        return maskedField(white_field_, x, y);
    }

    override void reset()
    {
        turn = Stone.black;
        black_field_ = 0L;
        white_field_ = 0L;
        this[N/2 - 1, N/2 - 1] = Stone.white;
        this[N/2    , N/2 - 1] = Stone.black;
        this[N/2 - 1, N/2    ] = Stone.black;
        this[N/2    , N/2    ] = Stone.white;
        history = null;
    }

    ulong black_field() const pure nothrow @property
    {
        return black_field_;
    }
    ulong white_field() const pure nothrow @property
    {
        return white_field_;
    }
    ulong myField() const pure nothrow
    {
        final switch(turn)
        {
        case Stone.black: return black_field_;
        case Stone.white: return white_field_;
        case Stone.none:  assert(0);
        }
    }
    ulong yourField() const pure nothrow
    {
        final switch(turn)
        {
        case Stone.black: return white_field_;
        case Stone.white: return black_field_;
        case Stone.none:  assert(0);
        }
    }

    override Stone opIndex(in int x, in int y) const pure nothrow
    {
        assert(isInField(x, y));

        if(maskedBlack(x, y))
        {
            assert(!maskedWhite(x, y), x.to!string~","~y.to!string);
            return Stone.black;
        }

        if(maskedWhite(x, y))
        {
            assert(!maskedBlack(x, y), x.to!string~","~y.to!string);
            return Stone.white;
        }

        return Stone.none;
    }

    override int countStone(in Stone stone) const pure nothrow
    {
        final switch(stone)
        {
        case Stone.black:
            return black_field_.countBit;
        case Stone.white:
            return white_field_.countBit;
        case Stone.none:
            return (~(black_field_ | white_field_)).countBit;
        }
    }

    override protected bool canPutStoneRev(in int x, in int y) const pure nothrow
    {
        return getFlipPattern(turn.rev, x, y) != 0L;
    }

    override bool canPutStone(in int x, in int y) const pure nothrow
    {
        return getFlipPattern(turn, x, y) != 0L;
    }

    ulong getFlipPattern(in Stone s, in int x, in int y) const pure nothrow
    {
        final switch(s)
        {
        case Stone.black:
            return getFlipPattern(black_field_, white_field_, x, y);
        case Stone.white:
            return getFlipPattern(white_field_, black_field_, x, y);
        case Stone.none:
            assert(0);
        }
    }

    static ulong getFlipPattern(in ulong me, in ulong you, in int x, in int y) pure nothrow
    {
        if((x < 0 || x >= N || y < 0 || y >= N) || (me | you) & mask(x, y))
            return 0L;

        ulong rev = 0L;

        void each(string op, ulong se)() pure nothrow
        {
            ulong se = you & se;    // 横移動のための番人
            ulong m2, m3, m4, m5, m6;
            ulong m1 = mixin("mask(x, y)"~op);  // pos : 着手箇所

            if( (m1 & se) != 0L ) {
                if( ((m2 = mixin("m1"~op)) & se) == 0L  )
                {
                    if( (m2 & me) != 0L )  // 1個だけ返す場合
                        rev |= m1;
                }
                else if( ((m3 = mixin("m2"~op)) & se) == 0L )
                {
                    if( (m3 & me) != 0L )  // 2個返す場合
                        rev |= m1 | m2;
                }
                else if( ((m4 = mixin("m3"~op)) & se) == 0L )
                {
                    if( (m4 & me) != 0L )  // 3個返す場合
                        rev |= m1 | m2 | m3;
                }
                else if( ((m5 = mixin("m4"~op)) & se) == 0L )
                {
                    if( (m5 & me) != 0L )  // 4個返す場合
                        rev |= m1 | m2 | m3 | m4;
                }
                else if( ((m6 = mixin("m5"~op)) & se) == 0L )
                {
                    if( (m6 & me) != 0L )  // 5個返す場合
                        rev |= m1 | m2 | m3 | m4 | m5;
                }
                else
                {
                    if( ((mixin("m6"~op)) & me) != 0L )  // 6個返す場合
                        rev |= m1 | m2 | m3 | m4 | m5 | m6;
                }
            }
        }

        each!("<<1", 0x7e7e7e7e7e7e7e7e); // 右
        each!(">>1", 0x7e7e7e7e7e7e7e7e); // 左
        each!(">>8", 0x00ffffffffffff00); // 上
        each!("<<8", 0x00ffffffffffff00); // 下
        each!(">>9", 0x007e7e7e7e7e7e00); // 左上
        each!(">>7", 0x007e7e7e7e7e7e00); // 右上
        each!("<<7", 0x007e7e7e7e7e7e00); // 左下
        each!("<<9", 0x007e7e7e7e7e7e00); // 右下
        return rev;
    }

    override int countObtainStoneWhenPut(in int x, in int y) const pure nothrow
    {
        return getFlipPattern(turn, x, y).countBit;
    }

    override Tuple!(int,int)[] getToFlipStones(in int x, in int y) const
    {
        immutable r = getFlipPattern(turn, x, y);
        Tuple!(int, int)[] ret;
        foreach(x_; 0..N)
            foreach(y_; 0..N)
                if(r & mask(x_, y_))
                    ret ~= tuple(x_, y_);
        return ret;
    }

    override bool isMyStone(in int x, in int y) const pure nothrow
    {
        return isOnesStone(turn, x, y);
    }
    override bool isYourStone(in int x, in int y) const pure nothrow
    {
        return isOnesStone(turn.rev, x, y);
    }
    bool isOnesStone(in Stone s, in int x, in int y) const pure nothrow
    {
        final switch(s)
        {
        case Stone.black:
            return maskedBlack(x, y) != 0L;
        case Stone.white:
            return maskedWhite(x, y) != 0L;
        case Stone.none:
            return false;
        }
    }
    override bool isNoStone(in int x, in int y) const pure nothrow
    {
        return !((black_field_ | white_field_) & mask(x, y));
    }

    override void putStone(in int x, in int y)
    {
        immutable rev = getFlipPattern(turn, x, y);
        if(rev == 0L)
            throw new CannotPutException("cannot put at ("~x.to!string~", "~y.to!string~")");

        final switch(turn)
        {
        case Stone.black:
            black_field_ ^= mask(x, y) | rev;
            white_field_ ^= rev;
            break;
        case Stone.white:
            white_field_ ^= mask(x, y) | rev;
            black_field_ ^= rev;
            break;
        case Stone.none:
            assert(0);
        }
        pass();
    }
    override void putStoneWithSave(in int x, in int y)
    {
        auto hist = hist_t(black_field_, white_field_, turn);
        putStone(x, y);
        history ~= hist;
    }

    override void restore()
    {
        if(history.length == 0)
            throw new Exception("pop error");

        black_field_ = history[$-1].black;
        white_field_ = history[$-1].white;
        turn = history[$-1].turn;
        history = history[0..$-1];
    }
    override int lengthSave() const pure nothrow
    {
        return history.length;
    }

    override IReversiBoard dup()
    {
        auto rb = new BitReversiModel;
        rb.black_field_ = black_field_;
        rb.white_field_ = white_field_;
        rb.turn = turn;
        return rb;
    }
}
unittest{
    import reversi.basic;
    import reversi.board.boards;

    auto rb1 = createArrayReversi;
    auto rb2 = createBitReversi;

    auto a = randomPlayer;

    while(!rb1.isFinished)
    {
        int x, y;
        if(a.getMove(rb1, x, y))
        {
            rb1.putStone(x, y);
            rb2.putStone(x, y);
        }
        else
        {
            rb1.pass();
            rb2.pass();
        }

        assert(rb1 == rb2);

        if(a.getMove(rb1, x, y))
        {
            rb1.putStone(x, y);
            rb2.putStone(x, y);
        }
        else
        {
            rb1.pass();
            rb2.pass();
        }

        assert(rb1 == rb2);
    }
}

int countBit(in ulong v) pure nothrow
{
    ulong c = v;
    c = ( c & 0x55555555_55555555)
      + ((c & 0xAAAAAAAA_AAAAAAAA) >> 1);
    c = ( c & 0x33333333_33333333)
      + ((c & 0xCCCCCCCC_CCCCCCCC) >> 2);
    c = ( c & 0x0F0F0F0F_0F0F0F0F)
      + ((c & 0xF0F0F0F0_F0F0F0F0) >> 4);
    c = ( c & 0x00FF00FF_00FF00FF)
      + ((c & 0xFF00FF00_FF00FF00) >> 8);
    c = ( c & 0x0000FFFF_0000FFFF)
      + ((c & 0xFFFF0000_FFFF0000) >> 16);
    c = ( c & 0x00000000_FFFFFFFF)
      + ((c & 0xFFFFFFFF_00000000) >> 32);

    return cast(int)c;
}
unittest{
    assert(0x0000000000000000L.countBit == 0);
    assert(0xFFFFFFFFFFFFFFFFL.countBit == 64);
    assert(0x00010000100A0070L.countBit == 7);
    assert(0x0123456789ABCDEFL.countBit == 32);
}
