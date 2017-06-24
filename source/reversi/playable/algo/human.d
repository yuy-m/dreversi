module reversi.playable.algo.human;

public import reversi.playable.iplayer;
import reversi.playable.utility;
import std.stdio;
import std.string : chomp;
import std.conv : to, ConvException;

class Human : IPlayer
{
    override bool getMove(in IReversiBoard rb, out int x, out int y)
    {
        candidates(rb);

        while(true)
        {
            x = input(rb, "x");
            if(x == -1)
                return false;

            y = input(rb, "y");
            if(y == -1)
                return false;

            if(rb.canPutStone(x, y))
                return true;

            writeln("Cannot put there.");
        }

        assert(0);
    }

    void candidates(in IReversiBoard rb) const
    {
        writeln("candidates:");
        const ps = getCanPutStone(rb);
        if(ps.length == 0)
            writeln("    nothing.");
        else
        {
            foreach(i; 0..ps.length / 2)
            {
                writefln(
                    "    (%s, %s), (%s, %s)",
                    ps[i][0] + 1, ps[i][1] + 1, ps[i + 1][0] + 1, ps[i + 1][1] + 1
                );
            }
            if(ps.length % 2 != 0)
                writefln("    (%s, %s)", ps[$ - 1][0] + 1, ps[$ - 1][1] + 1);
        }
    }

    int input(in IReversiBoard rb, in string str)
        {
            while(true)
            {
                write(str, " = ");
                stdout.flush;
                immutable s = readln.chomp;
                if(s == "pass" || s == "p")
                    return -1;
                else if(s == "quit" || s == "q")
                    throw new Exception("Quit Reversi Game.");

                try{
                    immutable n = s.to!int - 1;
                    if(rb.isInField(n))
                        return n;

                    writeln("Out of field.");

                } catch(ConvException e) {
                    writeln("Input number.");
                }
            }
        }
}
