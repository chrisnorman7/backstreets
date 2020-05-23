/// Provides menu-related hotkeys.
library menu;

import '../commands/command_context.dart';

void moveUp(CommandContext ctx) => ctx.book.moveUp();

void moveDown(CommandContext ctx) => ctx.book.moveDown();

void activateSpace(CommandContext ctx) => ctx.book.activate();

void activateEnter(CommandContext ctx) => ctx.book.activate();

void activateRightArrow(CommandContext ctx) => ctx.book.activate();

void cancelEscape(CommandContext ctx) => ctx.book.cancel();

void cancelLeftArrow(CommandContext ctx) => ctx.book.cancel();
