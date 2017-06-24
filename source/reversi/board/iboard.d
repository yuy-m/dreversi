module reversi.board.iboard;

import std.typecons;

public import reversi.board.stone;

immutable N = 8;

interface IReversiBoard
{
    alias fieldWidth = N;
    enum fieldSize = N * N;

    int opCmp(Object rb);
    bool opEquals(Object rb);
    size_t toHash() nothrow @trusted;
// pure:
    void pass();

    void putStone(in int x, in int y);
    void putStoneWithSave(in int x, in int y);
    void restore();
    IReversiBoard dup();
    void reset();
const:
// nothrow:

    Stone turn() @property;
    Stone opIndex(in int x, in int y) nothrow;

    int countBlack();
    int countWhite();
    int countAll();

    Stone getPredominance();
    bool isFinished() @property;

    bool canPutStone(in int x, in int y);
    int countObtainStoneWhenPut(in int x, in int y);
    Tuple!(int,int)[] getToFlipStones(in int x, in int y);

    bool isMyStone(in int x, in int y) @property;
    bool isYourStone(in int x, in int y) @property;
    bool isNoStone(in int x, in int y) @property;

    bool isInField(in int x) @property;
    bool isInField(in int x, in int y) @property;

    int lengthSave();

    string toString();
}

class CannotPutException : Exception
{
    this(string msg) pure
    {
        super(msg);
    }
}