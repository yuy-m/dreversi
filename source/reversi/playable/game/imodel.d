module reversi.playable.game.imodel;

import std.typecons;

public import reversi.board.iboard;
public import reversi.playable.iplayer;
public import reversi.playable.playermanager;


alias change_lt = void delegate(in IModel);
alias finish_lt = void delegate(in Stone);
interface IModel : IModelReader
{
    void reset(PlayerManager);

    bool requestMove(in Move);

    void addOnTurnChangeListener(change_lt listener);
    void addOnFinishedListener(finish_lt listener);
}

interface IModelReader
{
    bool canPutStone(in int x, in int y);
    Stone turn();
    Stone opIndex(in int x, in int y);
    int countBlack();
    int countWhite();
    int countAll();
    Stone getPredominance();
    bool needInputMove();
    int turnCnt();
    Tuple!(int, int)[] toFlipStones(in int x, in int y);
    int eval();
}

abstract class AbstractModel : IModel
{
private:
    change_lt[] change_listeners;
    finish_lt[] finish_listeners;

protected:
    final void onTurnChange()
    {
        foreach(l; change_listeners)
            l(this);
    }
    final void onFinished()
    {
        foreach(l; finish_listeners)
            l(getPredominance);
    }

public:
    override abstract bool canPutStone(in int x, in int y);
    override abstract Stone turn();
    override abstract Stone opIndex(in int x, in int y);
    override abstract int countBlack();
    override abstract int countWhite();
    override abstract int countAll();
    override abstract Stone getPredominance();

    override abstract bool needInputMove();
    override abstract int turnCnt();
    override abstract Tuple!(int, int)[] toFlipStones(in int x, in int y);
    override abstract int eval();

    override abstract void reset(PlayerManager);
    override abstract bool requestMove(in Move);

    final void addOnTurnChangeListener(change_lt listener)
    {
        change_listeners ~= listener;
    }

    final void addOnFinishedListener(finish_lt listener)
    {
        finish_listeners ~= listener;
    }
}

