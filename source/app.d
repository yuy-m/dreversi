import std.stdio;

import reversi.playable.game.controler;

import dlangui;

mixin APP_ENTRY_POINT;

extern(C) int UIAppMain(string[] args)
{
    return (new Controler()).start();
}
