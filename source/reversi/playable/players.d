module reversi.playable.players;

public import reversi.playable.playermanager;
public import reversi.playable.iplayer;
import reversi.playable.algo.human;
import reversi.playable.algo.random;
import reversi.playable.algo.negascout;

IPlayer humanPlayer()
{
    return new Human();
}

IPlayer randomPlayer()
{
    return new Random();
}


IPlayer negascoutPlayer(int depth = 9)()
{
    return new NegaScout!depth();
}
