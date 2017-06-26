import std.stdio;
import std.datetime;

import reversi.playable.players;
import reversi.board.boards;
import reversi.playable.evaluate;

import dlangui;

mixin APP_ENTRY_POINT;

extern(C) int UIAppMain(string[] args)
{
    auto g = new Game();
    return g.start();
}

class Game
{
    Window window;
    CanvasWidget canvas;
    HorizontalLayout layout1;
    Button reset_btn;
    Button pass_btn;

    IReversiBoard rb;
    IPlayer black, white;
    IPlayer now_player;

    StopWatch sw;

    int turn_cnt;
    int offset_x, offset_y;
    immutable cell_width = 30;

    import std.typecons;
    Tuple!(int, int)[] toFlipStones;

    void reset(in dstring str)
    {
        if(rb is null)
            rb = createReversi;

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
            now_player = white;
            rb.reset;
            turn_cnt = 0;
            nextTurn;
        };

        auto text = (new TextWidget)
                   .text = str;
        layout.addChild(text);

        auto reset_btn1 = new Button;
        reset_btn1.text = "black Human, white Human";
        reset_btn1.addOnClickListener(delegate bool(Widget src)
        {
            black = null;
            white = null;
            res.close;
            return true;
        });
        layout.addChild(reset_btn1);

        auto reset_btn2 = new Button;
        reset_btn2.text = "black Human, white Computer";
        reset_btn2.addOnClickListener(delegate bool(Widget src)
        {
            black = null;
            white = negascoutPlayer!9;
            res.close;
            return true;
        });
        layout.addChild(reset_btn2);

        auto reset_btn3 = new Button;
        reset_btn3.text = "black Computer, white Human";
        reset_btn3.addOnClickListener(delegate bool(Widget src)
        {
            black = negascoutPlayer!9;
            white = null;
            res.close;
            return true;
        });
        layout.addChild(reset_btn3);

        /+auto reset_btn4 = new Button;
        reset_btn4.text = "black Computer, white Computer";
        reset_btn4.addOnClickListener(delegate bool(Widget src)
        {
            black = negascoutPlayer!10;
            white = negascoutPlayer!10;
            res.close;
            return true;
        });
        layout.addChild(reset_btn4); +/

        res.show;
    }

    auto start()
    {
        Platform.instance.uiLanguage="en";
        Platform.instance.uiTheme="theme_default";

        window = Platform.instance.createWindow("A Reversi Game by Dlang", null);

        layout1 = new HorizontalLayout;
        layout1.layoutWidth(FILL_PARENT)
               .layoutHeight(FILL_PARENT);
        window.mainWidget = layout1;

        canvas = new CanvasWidget("canvas");
        canvas.layoutWidth(30+cell_width*8)
              .layoutHeight(30+cell_width*8);
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
            stderr.writeln("click");
            if(now_player is null)
            {
                rb.pass;
                nextTurn;
            }
            return true;
        });
        layout2.addChild(pass_btn);

        window.show;
        reset("");
        return Platform.instance.enterMessageLoop();
    }

    void onDrawListener(CanvasWidget canvas, DrawBuf buf, Rect rc)
    {
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
                if(rb[x, y].isBlack)
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
                else if(rb[x, y].isWhite)
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
                else if(now_player is null && rb.canPutStone(x, y))
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

        if(now_player is null)
        {
            foreach(s; toFlipStones)
            {
                buf.drawFrame(
                    Rect(
                        offset_x + cell_width * s[0] + 5,
                        offset_y + cell_width * s[1] + 5,
                        offset_x + cell_width * (s[0] + 1) - 3,
                        offset_y + cell_width * (s[1] + 1) - 3
                    ), 0x00FF00,
                    Rect(2,2,2,2), rb.turn.isBlack? 0x000000: 0xFFFFFF
                );
            }
        }

        import std.format;
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 10,
            "turn %2s, %s"d.format(turn_cnt, rb.turn), 0x000000
        );
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 25,
            "black × %2s, white × %2s, all × %2s"d.format(
                rb.countBlack, rb.countWhite, rb.countAll),
            0x000000
        );
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 40,
            "%s point of %s"d.format(eval(rb), rb.turn), 0x000000
        );
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 55,
            "%s [ms]"d.format(time), 0x000000
        );
    }

    bool mouseEvent(Widget src, MouseEvent e)
    {
        toFlipStones = null;
        if(now_player !is null)
            return true;

        int get(in int offset, in int p)
        {
            import std.math;
            return cast(int)floor((cast(double)p - offset) / cell_width);
        }
        immutable clicked_x = get(offset_x, e.x);
        immutable clicked_y = get(offset_y, e.y);

        toFlipStones = rb.getToFlipStones(clicked_x, clicked_y);
        if(toFlipStones.length > 0)
            toFlipStones ~= Tuple!(int, int)(clicked_x, clicked_y);

        invalidate();

        if(e.action == MouseAction.ButtonUp)
        {
            stderr.writef("clicked (%s,%s) => (%s,%s)...",
                e.x, e.y, clicked_x, clicked_y);

            if(rb.canPutStone(clicked_x, clicked_y))
            {
                sw.stop;
                time = sw.peek().msecs;
                rb.putStone(clicked_x, clicked_y);
                stderr.writeln("put");
                nextTurn;
            }
            else
            {
                stderr.writeln("ng");
            }

        }
        return true;
    }

    void check()
    {
        if(rb.isFinished)
        {
            auto res = Platform.instance.createWindow("Result", window);
            dstring str;
            final switch(rb.getPredominance)
            {
            case Stone.black:
                str = "Black Win.";
                break;
            case Stone.white:
                str = "White Win.";
                break;
            case Stone.none:
                str = "Draw.";
                break;
            }
            stderr.writeln(str);
            reset(str);
        }
    }

    void invalidate()
    {
        window.invalidate();
    }

    long time;
    bool thinking = false;

    void nextTurn()
    {
        if(thinking)
            return;

        changeTurn();
        if(now_player)
        {
            import std.parallelism;
            stderr.write("computer thinking...");
            thinking = true;

            task({
                sw.reset;
                sw.start;
                while(now_player !is null && !rb.isFinished)
                {
                    auto m = now_player.getMove(rb);
                    sw.stop;
                    time = sw.peek.msecs;

                    if(m)
                    {
                        stderr.writeln("bbb");
                        rb.putStone(m.x, m.y);
                        stderr.writefln("put (%s,%s)", m.x, m.y);
                    }
                    else
                    {
                        rb.pass;
                        stderr.writeln("pass");
                    }
                    stderr.writeln("aaa");

                    changeTurn();
                    sw.reset;
                    sw.start;
                    thinking = false;
                }
            }).executeInNewThread;
        }
    }

    void changeTurn()
    {
        stderr.writeln("next");
        toFlipStones = null;
        pass_btn.enabled = now_player !is null;

        ++turn_cnt;
        now_player = rb.turn.isBlack? black: white;

        stderr.writeln(rb);
        invalidate();

        check();
    }

    /+void think()
    {
        stderr.write("computer thinking...");

        StopWatch s;
        int x, y;
        s.start;
        immutable np = now_player.getMove(rb, x, y);
        s.stop;
        time = s.peek().msecs;
        if(np)
        {
            rb.putStone(x, y);
            stderr.writefln("put (%s,%s)", x, y);
        }
        else
        {
            rb.pass;
            stderr.writeln("pass");
        }
        changeTurn();
        sw.reset;
        sw.start;
    }+/

    /+void nextTurn()
    {
        changeTurn();

        while(now_player)
        {
            int x, y;
            stderr.write("computer thinking...");
            sw.reset;
            sw.start;
            immutable np = now_player.getMove(rb, x, y);
            sw.stop;
            time = sw.peek().msecs;
            if(np)
            {
                rb.putStone(x, y);
                stderr.writefln("put (%s,%s)", x, y);
            }
            else
            {
                rb.pass;
                stderr.writeln("pass");
            }
            changeTurn();
        }

        sw.reset;
        sw.start;
    }// +/

}



// +/

/+void main()
{
    import reversi.basic;
    //play(randomPlayer, negascoutPlayer!10);

    version(all)
    {
        int[Stone] cnt;
        foreach(i; 0..40)
        {
            stderr.writef("%3d...", i);
            ++cnt[play!false(negascoutPlayer!6, randomPlayer)];
            stderr.writeln("fin.");
        }

        writefln("%(%s %s\n%)", cnt);
    }
} // +/


