module reversi.playable.game.model;

import std.typecons;
import std.stdio;
import std.parallelism;
import core.sync.rwmutex;

import reversi.board.boards;
import reversi.playable.game.imodel;


class ReversiGameModel : AbstractModel
{
private:
    IReversiBoard rb;
    PlayerManager pm;
    int turn_cnt;

    bool thinking;

    Task!(run, void delegate())* cpu_task;

    ReadWriteMutex m;

public:
    override bool canPutStone(in int x, in int y)
    { synchronized(m.reader) return rb.canPutStone(x, y); }
    override Stone turn()
    { synchronized(m.reader) return rb.turn; }
    override Stone opIndex(in int x, in int y)
    { synchronized(m.reader) return rb[x, y]; }
    override int countBlack()
    { synchronized(m.reader) return rb.countBlack; }
    override int countWhite()
    { synchronized(m.reader) return rb.countWhite; }
    override int countAll()
    { synchronized(m.reader) return rb.countAll; }
    override Stone getPredominance()
    { synchronized(m.reader) return rb.getPredominance; }

    override bool needInputMove()
    {
        synchronized(m.reader)
            return pm
            .now(
                rb) is null;
    }
    override int turnCnt()
    {
        return turn_cnt;
    }

    override Tuple!(int, int)[] toFlipStones(in int x, in int y)
    {
        Tuple!(int, int)[] to_flip_stones;
        synchronized(m.reader)
            to_flip_stones = rb.getToFlipStones(x, y);
        if(to_flip_stones.length > 0)
            to_flip_stones ~= Tuple!(int, int)(x, y);
        return to_flip_stones;
    }
    override int eval()
    {
        import reversi.playable.evaluate;
        synchronized(m.reader)
            return reversi.playable.evaluate.eval(rb);
    }

    this()
    {
        rb = createReversi;
        m = new ReadWriteMutex(ReadWriteMutex.Policy.PREFER_WRITERS);
        reset(new PlayerManager(null, null));
    }

    override void reset(PlayerManager pm)
    {
        assert(pm !is null);

        synchronized(m.writer)
            rb.reset;
        this.pm = pm;
        turn_cnt = 1;
        thinking = false;
        if(cpu_task !is null)
            cpu_task.yieldForce;

        onTurnChange;
        if(!needInputMove)
        {
            invokeCPU();
        }
    }


    override bool requestMove(in Move move)
    {
        if(needInputMove && !thinking)
        {
            thinking = true;
            if(invokeMove(move))
            {
                changeTurn();

                if(needInputMove || rb.isFinished)
                {
                    thinking = false;
                }
                else
                {
                    invokeCPU();
                }
                return true;
            }
            thinking = false;
        }
        return false;
    }

private:
    void changeTurn()
    {
        stderr.writeln(turnCnt);
        ++turn_cnt;
        onTurnChange();
        if(rb.isFinished)
        {
            onFinished;
        }
    }

    bool invokeMove(in Move move)
    {
        synchronized(m.writer)
        {
            if(move is null)
            {
                stderr.writeln("pass");
                rb.pass;
                stderr.writeln(rb);
                return true;
            }
            else if(rb.canPutStone(move.x, move.y))
            {
                stderr.writefln("put (%s,%s)", move.x, move.y);
                rb.putStone(move.x, move.y);
                stderr.writeln(rb);
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    void invokeCPU()
    {
        thinking = true;
        //cpu_task = task({
            while(!needInputMove && !rb.isFinished)
            {
                stderr.write("thinking...");
                const move = pm.getMove(rb);
                stderr.writeln("finish.");

                invokeMove(move);
                changeTurn();
            }
            thinking = false;
        //});
        //cpu_task.executeInNewThread;
    }
}

