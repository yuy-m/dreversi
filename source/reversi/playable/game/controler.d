module reversi.playable.game.controler;

import reversi.playable.game.iview;
import reversi.playable.game.imodel;
import reversi.playable.game.guiview;
import reversi.playable.game.model;

import std.stdio;
class Controler
{
private:
    IView view;
    IModel model;

public:
    auto start()
    {
        model = new ReversiGameModel;

        view = new GUIReversiGameView(model);
        view.addOnResetListener((PlayerManager pm){
            if(pm is null)
                return false;
            model.reset(pm);
            return true;
        });
        view.addOnInputMoveListener((in Move m){
            stderr.write("requesing...");
            if(model.requestMove(m))
            {
                stderr.writeln("accepted.");
                return true;
            }
            else
            {
                stderr.writeln("rejected.");
                return false;
            }
        });
        view.addOnClosedListener((){
            model.reset(new PlayerManager(null, null));
        });
        try return view.start;
        catch(Exception e)
        {
            stderr.writeln(e);
            assert(0);
        }
        catch(Error e)
        {
            stderr.writeln(e);
            assert(0);
        }
    }
}
