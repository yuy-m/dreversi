module reversi.playable.cuigame;

import std.stdio;
import std.datetime;

import reversi.board.boards;
import reversi.playable.players;
import reversi.playable.evaluate;

Stone play(bool print = true)(IPlayer black, IPlayer white)
{
    auto rb = createReversi();
    auto pm = new PlayerManager(black, white);

    static if(print)
        write(rb);

    auto turn = rb.turn.rev;

    for(int turn_cnt = 1; ; ++turn_cnt)
    {
        static if(print)
        {
            writeln;
            writefln("Turn %d, %s('%s') turn", turn_cnt, rb.turn, rb.turn.symbol);
        }

        int x, y;

        StopWatch sw;

        sw.start();
        immutable notpass = pm.getMove(rb, x, y);
        sw.stop();

        if(notpass)
        {
            rb.putStone(x, y);
            static if(print)
            {
                write(rb);
                writefln("put at (%s, %s).", x + 1, y + 1);
            }
        }
        else
        {
            rb.pass;
            static if(print)
            {
                write(rb);
                writeln("pass.");
            }
        }

        static if(print)
        {
            writefln("b:%2s, w:%2s, all:%2s.", rb.countBlack, rb.countWhite, rb.countAll);
            writefln("%s point of %s('%s')", eval(rb), rb.turn, rb.turn.symbol);
            writefln("time %s [ms]", sw.peek().msecs);
        }

        if(rb.isFinished)
            break;
    }

    static if(print)
    {
        final switch(rb.getPredominance)
        {
        case Stone.black: writeln("Black('o') Win."); break;
        case Stone.white: writeln("White('x') Win."); break;
        case Stone.none: writeln("Draw."); break;
        }
    }
    return rb.getPredominance;
}

