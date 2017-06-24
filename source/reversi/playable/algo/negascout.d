module reversi.playable.algo.negascout;

import std.stdio;
public import reversi.playable.iplayer;
import reversi.board.iboard;
import reversi.board.model.bit.bitmodel;
import reversi.playable.utility;
import reversi.playable.evaluate;

immutable HASH = 0;//false;

class NegaScout(int DEPTH = 3, int HASH_DEPTH = DEPTH) : IPlayer
if(DEPTH >= HASH_DEPTH)
{
    override bool getMove(in IReversiBoard rb, out int x, out int y)
    {
        stdout.flush;
            return cpu(rb, x, y, DEPTH, 10);
    }

private:

    static bool cpu(in IReversiBoard rb, out int x, out int y, in int depth, in int last_depth)
    {
        import std.algorithm : min;
        immutable not_pass = {
            if(auto rbb = cast(BitReversiModel)rb)
                return iddfs(rbb, x, y, min(depth, rb.fieldSize - rb.countAll));
            else
                return iddfs(cast()rb, x, y, min(depth, rb.fieldSize - rb.countAll));
        }();

        return not_pass && rb.canPutStone(x, y);
    }

    static bool iddfs(IReversiBoard rb, out int x, out int y, in int max_depth)
    {
        auto pvs = getCanPutPosVal(rb);
        if(pvs.length == 0)
            return false;

        //HashValue hv_tmp;

        int depth = max_depth % 3;

        for( ; depth <= max_depth ; depth += 3)
        {
            try rb.putStoneWithSave(pvs[0].x, pvs[0].y);
            catch(CannotPutException e)
            {
                stderr.writeln(e);
                assert(0, "Ahah?");
            }

            int max_val = -negascout(rb, int.min, int.max, false, depth-1);
            rb.restore;

            x = pvs[0].x;
            y = pvs[0].y;

            int alpha = max_val;
            pvs[0].val = max_val;

            foreach(ref p; pvs[1..$])
            {
                try rb.putStoneWithSave(p.x, p.y);
                catch(CannotPutException e)
                {
                    stderr.writeln(e);
                    assert(0, "Uhah?");
                }
                p.val = -negascout(rb, -alpha-1, -alpha, false, depth-1);//NullWindowSearch

                if(p.val > alpha) //通常探索
                {
                    alpha = p.val;

                    p.val = -negascout(rb, int.min, -alpha, false, depth-1);

                    if(p.val > alpha)
                        alpha = p.val;
                }
                rb.restore;

                if(p.val > max_val)
                {
                    max_val = p.val;
                    x = p.x;
                    y = p.y;
                }
            }

            sort(pvs); //move ordering
        }
        return true;
    }

    static if(HASH)
    {
        import std.typecons;
        alias hash_t = Tuple!(int, int); // alpha, beta
        static  hash_t[IReversiBoard][int] hash = null;

        static const(hash_t*) getHash(IReversiBoard rb, in int depth, in int alpha, in int beta)
        {
            if(const p_ = depth in hash)
                return rb in *p_;
            return null;
        }

        static void setHash(IReversiBoard rb, in int depth, in int alpha, in int beta)
        {
            hash[depth][rb] = Tuple!(int, int)(alpha, beta);
            /+if(auto p_ = depth in hash)
            {
                if(rb !in *p_)
                    assert(0);
                else
                    (*p_)[rb] = tuple(alpha, beta);
            }
            else
                hash[depth][rb] = tuple(alpha, beta);
            +/
        }
    }

    import std.functional;
    static if(0)
        alias negascout = memoize!negascout_;
    else
        alias negascout = negascout_;

    public static int negascout_(IReversiBoard rb, int alpha, int beta, in bool pass, in int depth)
    {
        if(depth <= 0)
            return eval(rb);

        int max_val = int.min;

        static if(HASH)
        {
            import std.algorithm;
            int upper;
            int lower;
            if(const p = getHash(rb, depth, alpha, beta))
            {
                lower = (*p)[0];
                upper = (*p)[1];
                if(lower >= beta)
                {
                    return lower;
                }
                if(upper <= alpha || lower == upper)
                {
                    return upper;
                }
                alpha = max(alpha, lower);
                beta = min(beta, upper);
                //return *p;
            }
            else
            {
                lower = typeof(lower).min;
                upper = typeof(upper).max;
            }

            if(depth >  DEPTH - HASH_DEPTH)
            {
                scope(success)
                {
                    if(max_val <= alpha)
                        setHash(rb, depth, lower, max_val);
                    else if(max_val >= beta)
                        setHash(rb, depth, max_val, upper);
                    else
                        setHash(rb, depth, max_val, max_val);
                }
            }
        }


        bool is_put = false;

        foreach(x; 0..rb.fieldWidth)
        {
            foreach(y; 0..rb.fieldWidth)
            {
                try rb.putStoneWithSave(x, y); //盤面展開
                catch(CannotPutException e)
                    continue;
                catch(Exception e)
                    assert(0);

                if(is_put)
                {
                    //NullWindowSearch
                    int val = -negascout(rb, -alpha-1, -alpha, false, depth-1);

                    if(val >= beta)
                    {
                        rb.restore;
                        return val; //枝刈
                    }

                    if(val > alpha) //通常探索
                    {
                        alpha = val;

                        val = -negascout(rb, -beta, -alpha, false, depth-1);

                        if(val >= beta)
                        {
                            rb.restore;
                            return val; //枝刈
                        }
                        if(val > alpha)
                            alpha = val;
                    }

                    rb.restore;

                    if(val > max_val)
                        max_val = val;
                }
                else
                {
                    is_put = true;

                    max_val = -negascout(rb, -beta, -alpha, false, depth-1);

                    rb.restore;

                    if(max_val >= beta)
                        return max_val; //枝刈

                    if(max_val > alpha)
                        alpha = max_val;
                }
            }
        }

        if(is_put)
        {
            return max_val;
        }
        else //置けない
        {
            if(pass)
            {
                return eval(rb);
            }
            else
            {
                rb.pass();
                max_val = -negascout(rb, -beta, -alpha, true, depth-1);
                rb.pass();
                return max_val;
            }
        }
    }


    static bool iddfs(BitReversiModel rb, out int x, out int y, in int max_depth)
    {
        auto pvs = getCanPutPosVal(rb);
        if(pvs.length == 0)
            return false;

        int depth = max_depth % 3;

        for( ; depth <= max_depth ; depth += 3)
        {
            bool is_put = false;

            try rb.putStoneWithSave(pvs[0].x, pvs[0].y);
            catch(CannotPutException e)
            {
                stderr.writeln(e);
                assert(0, "Ahah?");
            }

            int max_val = -negascout(rb.myField, rb.yourField, int.min, int.max, false, depth-1);
            rb.restore;

            x = pvs[0].x;
            y = pvs[0].y;

            int alpha = max_val;
            pvs[0].val = max_val;

            foreach(ref p; pvs[1..$])
            {
                try rb.putStoneWithSave(p.x, p.y);
                catch(CannotPutException e)
                {
                    stderr.writeln(e);
                    assert(0, "Uhah?");
                }
                p.val = -negascout(rb.myField, rb.yourField, -alpha-1, -alpha, false, depth-1);//NullWindowSearch

                if(p.val > alpha) //通常探索
                {
                    alpha = p.val;

                    p.val = -negascout(rb.myField, rb.yourField, int.min, -alpha, false, depth-1);

                    if(p.val > alpha)
                        alpha = p.val;
                }
                rb.restore;

                if(p.val > max_val)
                {
                    max_val = p.val;
                    x = p.x;
                    y = p.y;
                }
            }

            sort(pvs); //move ordering
        }
        return true;
    }

    public static int negascout_(in ulong me, in ulong you, int alpha, int beta, in bool pass, in int depth)
    {
        if(depth <= 0)
            return eval(me, you);

        int max_val = int.min;

        static if(HASH)
        {
            import std.algorithm;
            int upper;
            int lower;
            if(const p = getHash(rb, depth, alpha, beta))
            {
                lower = (*p)[0];
                upper = (*p)[1];
                if(lower >= beta)
                {
                    return lower;
                }
                if(upper <= alpha || lower == upper)
                {
                    return upper;
                }
                alpha = max(alpha, lower);
                beta = min(beta, upper);
                //return *p;
            }
            else
            {
                lower = typeof(lower).min;
                upper = typeof(upper).max;
            }

            if(depth >  DEPTH - HASH_DEPTH)
            {
                scope(success)
                {
                    if(max_val <= alpha)
                        setHash(rb, depth, lower, max_val);
                    else if(max_val >= beta)
                        setHash(rb, depth, max_val, upper);
                    else
                        setHash(rb, depth, max_val, max_val);
                }
            }
        }


        bool is_put = false;

        foreach(x; 0..N)
        {
            foreach(y; 0..N)
            {
                immutable rev = BitReversiModel.getFlipPattern(me, you, x, y);
                if(rev == 0L)
                    continue;

                immutable new_me = me ^ (BitReversiModel.mask(x, y) | rev);
                immutable new_you = you ^ rev;

                if(is_put)
                {
                    //NullWindowSearch
                    int val = -negascout(new_you, new_me, -alpha-1, -alpha, false, depth-1);

                    if(val >= beta)
                    {
                        return val; //枝刈
                    }

                    if(val > alpha) //通常探索
                    {
                        alpha = val;

                        val = -negascout(new_you, new_me, -beta, -alpha, false, depth-1);

                        if(val >= beta)
                        {
                            return val; //枝刈
                        }
                        if(val > alpha)
                            alpha = val;
                    }

                    if(val > max_val)
                        max_val = val;
                }
                else
                {
                    is_put = true;

                    max_val = -negascout(new_you, new_me, -beta, -alpha, false, depth-1);

                    if(max_val >= beta)
                        return max_val; //枝刈

                    if(max_val > alpha)
                        alpha = max_val;
                }
            }
        }

        if(is_put)
        {
            return max_val;
        }
        else //置けない
        {
            if(pass)
            {
                return eval(me, you);
            }
            else
            {
                max_val = -negascout(you, me, -beta, -alpha, true, depth-1);
                return max_val;
            }
        }
    }
}

