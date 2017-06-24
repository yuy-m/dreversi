module reversi.board.stone;

enum Stone : byte
{
    none, black, white
}

immutable eachStone = [Stone.none, Stone.black, Stone.white];


pure:
nothrow:
Stone rev(in Stone s)
{
    final switch(s)
    {
    case Stone.none: return Stone.none;
    case Stone.black: return Stone.white;
    case Stone.white: return Stone.black;
    }
}

string symbol(in Stone s)
{
    final switch(s)
    {
    case Stone.none: return ".";
    case Stone.black: return "o";
    case Stone.white: return "x";
    }
}

bool isBlack(in Stone s)
{
    return s == Stone.black;
}

bool isWhite(in Stone s)
{
    return s == Stone.white;
}

bool isNone(in Stone s)
{
    return s == Stone.none;
}
