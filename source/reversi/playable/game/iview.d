module reversi.playable.game.iview;

public import reversi.playable.move;
public import reversi.playable.playermanager;
public import reversi.playable.game.imodel;

alias reset_lt = bool delegate(PlayerManager);
alias input_lt = bool delegate(in Move);
alias close_lt = void delegate();

interface IView
{
    int start();

    void addOnResetListener(reset_lt);
    void addOnInputMoveListener(input_lt);
    void addOnClosedListener(close_lt);
}

abstract class AbstractView : IView
{
private:
    reset_lt[] reset_listeners;
    input_lt[] input_listeners;
    close_lt[] close_listeners;

protected:
    final bool onReset(PlayerManager pm)
    {
        bool flg = true;
        foreach(l; reset_listeners)
            if(!l(pm))
                flg = false;
        return flg;
    }
    final bool onInputMove(in Move m)
    {
        bool flg = true;
        foreach(l; input_listeners)
            if(!l(m))
                flg = false;
        return flg;
    }
    final void onClosed()
    {
        foreach(l; close_listeners)
            l();
    }

public:
    override abstract int start();

    override final void addOnResetListener(reset_lt listener)
    {
        reset_listeners ~= listener;
    }
    override final void addOnInputMoveListener(input_lt listener)
    {
        input_listeners ~= listener;
    }
    override void addOnClosedListener(close_lt listener)
    {
        close_listeners ~= listener;
    }
}
