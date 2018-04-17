module reversi.playable.game.guiview;

import std.experimental.logger;
import std.stdio;

import dlangui;

import reversi.playable.game.iview;
import reversi.playable.players;

class GUIReversiGameView : AbstractView
{
public:
    this(IModel model)
    {
        this.model = model;
        is_started = false;
        model.addOnTurnChangeListener((in IModel model){
            log("turn change");
            invalidate;
        });
        model.addOnFinishedListener((in Stone s){
            log("finish");
            final switch(s)
            {
            case Stone.black: reset("Black Win."); break;
            case Stone.white: reset("White Win."); break;
            case Stone.none:  reset("Draw."); break;
            }
        });
    }

    override int start()
    {
        if(is_started)
            return 1;

        is_started = true;
        scope(exit)
            is_started = false;

        createMainWindow;
        reset("start");
        return Platform.instance.enterMessageLoop();
    }

private:
    Window window;
    CanvasWidget canvas;
    HorizontalLayout layout1;
    Button reset_btn;
    Button pass_btn;

    IModelReader model;

    int clicked_x, clicked_y;
    bool is_started;

    int offset_x, offset_y;
    immutable cell_width = 30;

    void createMainWindow()
    {
        Platform.instance.uiLanguage = "en";
        Platform.instance.uiTheme = "theme_default";

        window = Platform.instance.createWindow("A Reversi Game by Dlang", null);
        window.onClose = delegate()
        {
            onClosed();
        };

        layout1 = new HorizontalLayout;
        layout1.layoutWidth(FILL_PARENT)
               .layoutHeight(FILL_PARENT);
        window.mainWidget = layout1;

        canvas = new CanvasWidget("canvas");
        canvas.layoutWidth(30 + cell_width * 8)
              .layoutHeight(30 + cell_width * 8);
        canvas.onDrawListener = &onDrawListener;
        layout1.addChild(canvas);
        canvas.mouseEvent = &mouseEvent;

        auto layout2 = new VerticalLayout();
        layout2.layoutWidth(FILL_PARENT)
               .layoutHeight(FILL_PARENT)
               .alignment(20);
        layout1.addChild(layout2);

        reset_btn = new Button;
        reset_btn.text = "reset";
        reset_btn.addOnClickListener(delegate bool(Widget src)
        {
            reset("restart");
            return true;
        });
        layout2.addChild(reset_btn);

        pass_btn = new Button;
        pass_btn.text = "pass";
        pass_btn.addOnClickListener(delegate bool(Widget src)
        {
            onInputMove(null);
            return true;
        });
        layout2.addChild(pass_btn);

        window.show;
    }

    void reset(in dstring str)
    {
        PlayerManager pm;
        canvas.enabled = false;
        reset_btn.enabled = false;
        pass_btn.enabled = false;

        auto res = Platform.instance.createWindow("A Reversi Game by Dlang", window);
        auto layout = new VerticalLayout();
        res.mainWidget = layout;
        res.onClose = delegate()
        {
            canvas.enabled = true;
            reset_btn.enabled = true;
            pass_btn.enabled = true;
            invalidate;
            if(pm is null)
                window.close;
            else
                onReset(pm);
        };

        auto text = (new TextWidget)
                   .text = str;
        layout.addChild(text);

        auto reset_btn1 = new Button;
        reset_btn1.text = "black Human, white Human";
        reset_btn1.addOnClickListener(delegate bool(Widget src)
        {
            pm = new PlayerManager(null, null);
            res.close;
            return true;
        });
        layout.addChild(reset_btn1);

        auto reset_btn2 = new Button;
        reset_btn2.text = "black Human, white Computer";
        reset_btn2.addOnClickListener(delegate bool(Widget src)
        {
            pm = new PlayerManager(null, negascoutPlayer!9);
            res.close;
            return true;
        });
        layout.addChild(reset_btn2);

        auto reset_btn3 = new Button;
        reset_btn3.text = "black Computer, white Human";
        reset_btn3.addOnClickListener(delegate bool(Widget src)
        {
            pm = new PlayerManager(negascoutPlayer!9, null);
            res.close;
            return true;
        });
        layout.addChild(reset_btn3);

        /+auto reset_btn4 = new Button;
        reset_btn4.text = "black Computer, white Computer";
        reset_btn4.addOnClickListener(delegate bool(Widget src)
        {
            pm = new PlayerManager(negascoutPlayer!9, negascoutPlayer!9);
            res.close;
            return true;
        });
        layout.addChild(reset_btn4); // +/

        res.show;
    }

    void onDrawListener(CanvasWidget canvas, DrawBuf buf, Rect rc)
    {
        try{
        immutable N = 8;
        offset_x = rc.left + 20;
        offset_y = rc.top + 20;
        buf.fill(0xFFFFFF);

        foreach(i; 0..N+1)
        {
            buf.drawLine(
                Point(offset_x                 , offset_y + cell_width * i),
                Point(offset_x + cell_width * N, offset_y + cell_width * i),
                0x000000
            );
            buf.drawLine(
                Point(offset_x + cell_width * i, offset_y                 ),
                Point(offset_x + cell_width * i, offset_y + cell_width * N),
                0x000000
            );
        }

        foreach(x; 0..N)
        {
            foreach(y; 0..N)
            {
                if(model[x, y].isBlack)
                {
                    buf.drawFrame(
                        Rect(
                            offset_x + cell_width * x + 2, offset_y + cell_width * y + 2,
                            offset_x + cell_width * (x + 1),
                            offset_y + cell_width * (y + 1)
                        ), 0xFFFFFFFF,
                        Rect(3,3,3,3), 0x00000000
                    );
                }
                else if(model[x, y].isWhite)
                {
                    buf.drawFrame(
                        Rect(
                            offset_x + cell_width * x + 5, offset_y + cell_width * y + 5,
                            offset_x + cell_width * (x + 1) - 3,
                            offset_y + cell_width * (y + 1) - 3
                        ), 0x00000000,
                        Rect(2,2,2,2), 0xFFFFFFFF
                    );
                }
                else if(model.needInputMove && model.canPutStone(x, y))
                {
                    buf.fillRect(
                        Rect(
                            offset_x + cell_width * x + 10,
                            offset_y + cell_width * y + 10,
                            offset_x + cell_width * (x + 1) - 8,
                            offset_y + cell_width * (y + 1) - 8
                        ), 0x00FF00
                    );
                }
            }
        }

        if(model.needInputMove)
        {
            foreach(s; model.toFlipStones(clicked_x, clicked_y))
            {
                buf.drawFrame(
                    Rect(
                        offset_x + cell_width * s[0] + 5,
                        offset_y + cell_width * s[1] + 5,
                        offset_x + cell_width * (s[0] + 1) - 3,
                        offset_y + cell_width * (s[1] + 1) - 3
                    ), 0x00FF00,
                    Rect(2,2,2,2), model.turn.isBlack? 0x000000: 0xFFFFFF
                );
            }
        }

        import std.format;
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 10,
            "turn %2s, %s"d.format(model.turnCnt, model.turn), 0x000000
        );
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 25,
            "black × %2s, white × %2s, all × %2s"d.format(
                model.countBlack, model.countWhite, model.countAll),
            0x000000
        );
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 40,
            "%s point of %s"d.format(model.eval, model.turn), 0x000000
        );
        if(!model.needInputMove)
        {
            canvas.font.drawText(buf,
                offset_x, offset_y + cell_width * N + 55,
                "computer is thinking..."d, 0x000000
            );
        }
        }
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
        catch(Throwable e)
        {
            stderr.writeln(e);
            assert(0);
        }
    }

    bool mouseEvent(Widget src, MouseEvent e)
    {
        invalidate;
        int get(in int offset, in int p)
        {
            import std.math : floor;
            return cast(int)floor((cast(double)p - offset) / cell_width);
        }
        clicked_x = get(offset_x, e.x);
        clicked_y = get(offset_y, e.y);

        if(e.action == MouseAction.ButtonUp)
        {
            // stderr.writef("clicked (%s,%s) => (%s,%s)...",
            //    e.x, e.y, clicked_x, clicked_y);
            onInputMove(new Move(clicked_x, clicked_y));
        }
        return true;
    }

    void invalidate()
    {
        window.invalidate();
    }

}