uses GraphABC;
const
  Board_size = 2;
  Player_O = 'O';
  Player_X = 'X';
  Size = 200;
  Sx = 1200;
  Sy = 70;
type
  Board= array [0..Board_size, 0..Board_size] of char;
var
  bestmove: integer;
   Board1: array [0..Board_size, 0..Board_size] of char;
  Player1: boolean;
  vsComputer: boolean;
  depth: integer:= 3;
  isMaximizingPlayer : boolean;
  state: Board;
  score: integer;
function EvaluateGameState(state: Board): integer;
var
  i, j, countX, countO: integer;
begin
  for i := 0 to 2 do begin
    countX := 0;
    countO := 0;
    for j := 0 to 2 do begin
      if state[i, j] = 'X' then
        countX := countX + 1
      else if state[i, j] = 'O' then
        countO := countO + 1;
    end;
    if countX = 3 then
      ExitCode := 10
    else if countO = 3 then
      ExitCode := -10;
  end;
  for i := 0 to 2 do begin
    countX := 0;
    countO := 0;
    for j := 0 to 2 do begin
      if state[j, i] = 'X' then
        countX := countX + 1
      else if state[j, i] = 'O' then
        countO := countO + 1;
    end;
    if countX = 3 then
      ExitCode := 10
    else if countO = 3 then
     ExitCode := -10;
  end;
  if ((state[0,0] = 'X') and (state[1,1] = 'X') and (state[2,2] = 'X')) or
     ((state[2,0] = 'X') and (state[1,1] = 'X') and (state[0,2] = 'X')) then
   ExitCode := 10;
  if ((state[0,0] = 'O') and (state[1,1] = 'O') and (state[2,2] = 'O')) or
     ((state[2,0] = 'O') and (state[1,1] = 'O') and (state[0,2] = 'O')) then
    ExitCode := -10;
  ExitCode := 0;
end;
function Minimax(state: Board; depth: integer; isMaximizingPlayer: boolean): integer;
var
  score, bestScore, bestMove, i, j: integer;
begin
  score := EvaluateGameState(state);
  if score = 10 then
   ExitCode := (score - depth)
  else if score = -10 then
   ExitCode := (score + depth)
  else if depth = 0 then
    ExitCode := 0;
  if isMaximizingPlayer then begin
    bestScore := -1000;
    bestMove := -1;
    for i := 0 to 2 do begin
      for j := 0 to 2 do begin
        if state[i, j] = ' ' then begin
          state[i, j] := 'X';
          score := Minimax(state, depth - 1, not isMaximizingPlayer);
          if score > bestScore then begin
            bestScore := score;
            bestMove :=  i * Board_size + j;
          end;
          state[i, j] := ' ';
        end;
      end;
    end;
    if bestMove <> -1 then
      state[bestMove div 3 + 1, bestMove mod 3 + 1] := 'X';
    ExitCode := bestScore;
  end
  else begin
    bestScore := 1000;
    bestMove := -1;
    for i := 0 to 2 do begin
      for j := 0 to 2 do begin
        if state[i, j] = ' ' then begin
          state[i, j] := 'O';
          score := Minimax(state, depth - 1, not isMaximizingPlayer);
          if score < bestScore then begin
            bestScore := score;
            bestMove :=  i * Board_size + j;
          end;
          state[i, j] := ' ';
        end;
      end;
    end;
    if bestMove <> -1 then
      state[bestMove div 3 + 1, bestMove mod 3 + 1] := 'O';
    ExitCode := bestScore;
  end;
end;
procedure Draw();
  procedure Draw_O(i, j: integer);
  begin
    SetPenColor(clMagenta);
    SetPenWidth(6);
    var size2 := Size div 2;
    DrawCircle((i + 1) * Size - size2, (j + 1) * Size - size2, Round(size2 * 0.7));
  end;

  procedure Draw_X(i, j: integer);
    procedure RLine(x, y, x1, y1: real):=Line(Round(x), Round(y), Round(x1), Round(y1));

  begin
    SetPenColor(clMaroon);
    SetPenWidth(6);
    var size2 := Size div 2 * 0.3;
    var cx1 := i * Size + size2;
    var cy1 := j * Size + size2;
    var cx2 := (i + 1) * Size - size2;
    var cy2 := (j + 1) * Size - size2;
    RLine(cx1, cy1, cx2, cy2);
    RLine(cx1, cy2, cx2, cy1);
  end;

  begin
    ClearWindow(clLightBlue);
    if Player1 then SetWindowCaption('Ходит игрок') else SetWindowCaption('Ходит компьютер');
    for var i := 0 to Board_size do
      for var j := 0 to Board_size do
      begin
        SetPenColor(clMintCream);
        SetPenWidth(2);
        DrawRectangle(i * Size, j * Size, (i + 1) * Size, (j + 1) * Size);
        if Board1[i, j] = Player_O then Draw_O(i, j)
        else if Board1[i, j] = Player_X then Draw_X(i, j); 
      end;
    Redraw();
  end;

function Won(ch: char): boolean;
var
  count: byte;
begin
  Result := false;
  for var i := 0 to Board_size do
  begin
    count := 0;
    for var j := 0 to Board_size do
      if Board1[i, j] = ch then Inc(count);//Inc(count) увеличивает count на 1
    if count = 3 then Result := true;
  end;
  
  if not Result then
  begin
    for var i := 0 to Board_size do
    begin
      count := 0;
      for var j := 0 to Board_size do
        if Board1[j, i] = ch then Inc(count);
      if count = 3 then Result := true;
    end;
    
    if not Result then
    begin
      count := 0;
      for var i := 0 to Board_size do
        if Board1[i, i] = ch then Inc(count);
      if count = 3 then Result := true;
      
      if not Result then
      begin
        count := 0;
        for var i := 0 to Board_size do
          if Board1[Board_size - i, i] = ch then Inc(count);
        if count = 3 then Result := true;
      end;
    end;
  end;
end;

function IsFull(): boolean;
begin
  Result := true;
  for var i := 0 to Board_size do
    for var j := 0 to Board_size do
      if (Board1[i, j] <> Player_O) and (Board1[i, j] <> Player_X) then
      begin
        Result := false;
        break;
      end;
end;

procedure MouseDown(x, y, mb: integer);
  procedure ShowWinner(s: string; c: Color);
  begin
    SetWindowCaption('Результат игры');
    Sleep(5000);
    SetWindowSize(Sx, Sy);
    CenterWindow();
    ClearWindow(clLightBlue);
    SetFontSize(16);
    SetFontStyle(fsBold);
    SetFontColor(c);
    DrawTextCentered(0, 0, Sx, Sy, s);
    Redraw();
    Sleep(5000);
    Halt();
  end;
var
  i, j: integer;
  winnerExists: boolean;
begin
  i := x div Size;
  j := y div Size;
  if (Board1[i, j] <> Player_O) and (Board1[i, j] <> Player_X) then
  begin
    if Player1 then
      Board1[i, j] := Player_O
    else
      Board1[i, j] := Player_X;
    Draw();
    winnerExists := Won(PLayer_O) or Won(PLayer_X);
    if winnerExists then
      if Player1 then
        ShowWinner('Игрок победил!', clBlack)
      else
        ShowWinner('Компьютер победил!', clBlack);
    if IsFull() and not winnerExists then
      ShowWinner('Ничья!', clOrange);
   Player1 := not Player1;
    begin
      x:= Minimax(state, depth, isMaximizingPlayer);
      y:= Minimax(state, depth, isMaximizingPlayer);
      repeat
        i := x div Size;
        j := y div Size;
      until (Board1[i, j] <> Player_O) and (Board1[i, j] <> Player_X);
      if Player1 then
        Board1[i, j] := Player_O
      else
        Board1[i, j] := Player_X;
      Draw();
      winnerExists := Won(PLayer_O) or Won(PLayer_X);
      if winnerExists then
        if Player1 then
          ShowWinner('Игрок первый победил!', clBlack)
        else
          ShowWinner('Компьютер победил!', clBlack);
      if IsFull() and not winnerExists then
        ShowWinner('Ничья!', clOrange);
      Player1 := not Player1;
    end;
  end;
end;
begin
  var Size2 := Size * 3;
  SetWindowIsFixedSize(true);
  SetWindowSize(Size2, Size2);
  CenterWindow();
  LockDrawing();
  vsComputer := true;
  Player1 := true;
  for var i := 0 to Board_size do
    for var j := 0 to Board_size do
      Board1[i, j] := ' ';
  Draw();
  OnMouseDown := MouseDown;
end.