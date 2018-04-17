module reversi.playable.move;

class Move
{
    immutable int x;
    immutable int y;
    this(in int x, in int y)
    {
        this.x = x;
        this.y = y;
    }
}