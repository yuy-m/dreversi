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
    return g.mainProc(Stone.black);
}

class Game
{
    Window window;
    CanvasWidget canvas;

    IReversiBoard rb;
    IPlayer cpu = negascoutPlayer!10;
    Stone plr_color;

    StopWatch sw;

    int turn;
    int offset_x, offset_y;
    immutable cell_width = 30;

    int clicked_x = -1, clicked_y = -1;

    import std.typecons;
    Tuple!(int, int)[] toFlipStones;

    auto mainProc(in Stone s)
    {
        rb = createReversi;
        turn = 1;
        plr_color = s;

        Platform.instance.uiLanguage="en";
        Platform.instance.uiTheme="theme_default";

        window = Platform.instance.createWindow("A Reversi Game by Dlang", null);

        auto layout1 = new HorizontalLayout();
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

        auto reset_btn = new Button;
        reset_btn.text = "reset";
        reset_btn.addOnClickListener(delegate bool(Widget src)
        {
            rb.reset;
            turn = 1;
            return true;
        });
        layout2.addChild(reset_btn);

        auto pass_btn = new Button;
        pass_btn.text = "pass";
        pass_btn.addOnClickListener(delegate bool(Widget src)
        {
            if(rb.turn == plr_color)
            {
                rb.pass;
                nextTurn;
            }
            return true;
        });
        layout2.addChild(pass_btn);

        window.show;
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
                else if(rb.canPutStone(x, y))
                {
                    buf.drawFrame(
                        Rect(
                            offset_x + cell_width * x + 5, offset_y + cell_width * y + 5,
                            offset_x + cell_width * (x + 1) - 3,
                            offset_y + cell_width * (y + 1) - 3
                        ), 0x00FF00,
                        Rect(2,2,2,2), 0xFFFFFF
                    );
                }
            }
        }

        foreach(s; toFlipStones)
        {
            buf.drawFrame(
                Rect(
                    offset_x + cell_width * s[0] + 5, offset_y + cell_width * s[1] + 5,
                    offset_x + cell_width * (s[0] + 1) - 3,
                    offset_y + cell_width * (s[1] + 1) - 3
                ), 0x00FF00,
                Rect(2,2,2,2), 0x00FF00
            );
        }

        import std.format;
        canvas.font.drawText(buf,
            offset_x, offset_y + cell_width * N + 10,
            "turn %2s, %s"d.format(turn, rb.turn), 0x000000
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
            "%s [ms]"d.format(sw.peek().msecs), 0x000000
        );
    }

    bool mouseEvent(Widget src, MouseEvent e)
    {
        import reversi.playable.utility;

        toFlipStones = null;
        if(rb.turn != plr_color)
            return true;

        int get(in int offset, in int p)
        {
            import std.math;
            return cast(int)floor((cast(double)p - offset) / cell_width);
        }
        clicked_x = get(offset_x, e.x);
        clicked_y = get(offset_y, e.y);

        toFlipStones = rb.getToFlipStones(clicked_x, clicked_y);
        canvas.invalidate();

        if(e.action == MouseAction.ButtonUp)
        {
            stderr.writef("clicked (%s,%s) => (%s,%s)...",
                e.x, e.y, clicked_x, clicked_y);

            if(rb.canPutStone(clicked_x, clicked_y))
            {
                sw.stop;
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
            auto t = new TextWidget();
            final switch(rb.getPredominance)
            {
            case Stone.black:
                stderr.writeln("Black Win.");
                t.text = "Black Win.";
                break;
            case Stone.white:
                stderr.writeln("White Win.");
                t.text = "White Win.";
                break;
            case Stone.none:
                stderr.writeln("Draw.");
                t.text = "Draw.";
                break;
            }
            res.mainWidget = t;
            res.show;
        }
    }

    void nextTurn()
    {
        stderr.writeln("next");
        toFlipStones = null;
        ++turn;
        stderr.writeln(rb);
        canvas.invalidate();
        check();

        int x, y;
        sw.reset;
        sw.start;
        if(cpu.getMove(rb, x, y))
        {
            sw.stop;
            rb.putStone(x, y);
            stderr.writefln("put (%s,%s)", x, y);
        }
        else
        {
            sw.stop;
            rb.pass;
            stderr.writeln("pass");
        }
        ++turn;
        stderr.writeln(rb);
        canvas.invalidate();
        check();

        sw.reset;
        sw.start;
    }
}



/+import std.stdio;

void main()
{
    play(randomPlayer, negascoutPlayer!10);

    version(none){
        int[Stone] cnt;
        foreach(i; 0..30)
        {
            stderr.writef("%3d...", i);
            ++cnt[play!false(negascoutPlayer!7, randomPlayer)];
            stderr.writeln("fin.");
        }

        writefln("%(%s %s\n%)", cnt);
    }
}+/
