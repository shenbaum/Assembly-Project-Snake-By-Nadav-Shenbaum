;*******************************************************************************************************************
;                                              Snake Game By                                                       *
;                                                  Nadav                                                           *
;*******************************************************************************************************************
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
;---------- Snake X & Y ----------
x_snake dw 270 dup (160)
y_snake dw 190 dup (160)
len_snake dw 5

;---------- Apple X & Y ----------
x_apple dw 100
y_apple dw 100

x_apple_suggest dw 100
y_apple_suggest dw 100
;---------- Variable For The Direction Of The Snake ----------
dir db 4

;---------- Draw Colors ----------
DrawColor db 0

;---------- The Main Variables That Save The X & Y Directions ----------
draw_x dw 0
draw_y dw 0

;---------- All The Messages ----------
score_msg db "SCORE: $"
start1_msg db "FIRST ASSEMBLY PROJECT $"
start2_msg db "SNAKE GAME - BY NADAV $"
enter_msg db "START THE GAME - ENTER $"
exit_screen_msg  db "EXIT THE GAME - E KEY $"
restart_msg db "RESTART THE GAME - R KEY $"
LoseScreen_msg db "YOU LOST $"

EasyMode_msg db "EASY - 1 $"
NormalMode_msg db "NORMAL - 2 $"
HardMode_msg db "HARD - 3 $"
ChooseLevel_msg db "CHOOSE THE LEVEL: $"

;---------- Score Numbers ----------
score_num db 48
score_num_2 db 48

;---------- Delay ----------
time_aux db 0
time_counter db 0
snake_speed db 0

;---------- Square ----------
line_counter db 0
square_counter db 0
Square_Size dw 10

;---------- Limit X & Y ----------
x_limit dw 0
y_limit dw 0
LimitCounter dw 0

;---------- ? ----------
wordVar dw 0
GameEnded db 0
appleVar db 0
; --------------------------
CODESEG

;---------- Printing To The Screen ----------
proc PrintWord
	push ax
	push bx
	push cx
	push dx

	mov ax, [wordVar]
	mov di, 10
	mov cx, 0
	mov bx, 10
	divideLoopB:
	mov dx, 0
	div bx
	push dx
	inc cx
	cmp ax, 0
	jne DivideLoopB
	CreateStringLoopB:
	pop dx
	add dx, 30h
	mov [di], dl
	inc di
	dec cx
	cmp cx, 0
	jne CreateStringLoopB
	mov dl, 24h
	mov [di], dl
	mov dx, 100
	mov ah, 09h
	int 21

	pop dx
	pop cx
	pop bx
	pop ax
ret
endp PrintWord

;---------- Drawing A Pixel ----------
proc pixel
	mov cx, [draw_x]
	mov dx, [draw_y]
	mov al, [DrawColor]
	mov ah, 0Ch
	int 10h
ret
endp pixel

;---------- Drawing A Line ----------
proc line
	push [draw_x]
	mov cx, [Square_Size]
	line_loop:
	push cx
	call pixel
	inc [draw_x]
	pop cx
	loop line_loop
	pop [draw_x]
ret
endp line

;---------- Drawing A Square ----------
proc square
	push [draw_y]
	mov cx, [Square_Size]
	square_loop:
	push cx
	call line
	inc [draw_y]
	pop cx
	loop square_loop
	pop [draw_y]
ret
endp square

;---------- Moving The Snake ----------
proc move_snake
	mov cx, [len_snake]
	dec cx
	update_loop:
	mov bx, cx
	shl bx, 1
	mov ax, [x_snake + bx - 2]
	mov [x_snake + bx], ax
	mov ax, [y_snake + bx - 2]
	mov [y_snake + bx], ax
	loop update_loop
ret
endp move_snake

;---------- Generate New Location For The Apple ----------
proc NewAppleLoc
	NewLocLoop:
	
	mov ax, 40h
	mov es, ax  
	mov ax, [es:6Ch]
    xor ax, 101101b
	mov cx, 29
    mov dx, 0
    div cx
    add dx, 2
    mov ax, dx
    mov cx, 10
    mul cx
	mov [x_apple_suggest], ax
	
	mov ax, [es:6Ch]
    xor ax, 110010b
	mov cx, 14
    mov dx, 0
    div cx
	add dx, 5
    mov ax, dx
    mov cx, 10
    mul cx
	mov [y_apple_suggest], ax
	
	call AppleSpawnOnSnake
	
	cmp [appleVar], 1
	je NewLocLoop
	
	push [x_apple_suggest]
	pop [x_apple]
	push [y_apple_suggest]
	pop [y_apple]
	
ret
endp NewAppleLoc

;---------- Checking If Snake On Apple ----------
proc SnakeOnApple
    mov ax, [y_snake]
	mov cx, [x_snake]
	
	cmp ax, [y_apple]
	je test_x_values
	jmp pos_not_equal
	
    test_x_values:
	
    cmp cx, [x_apple]
	je pos_equal
    jmp pos_not_equal
	
    pos_equal:
	
	inc [len_snake]
	
	call ChangeScore
	call NewAppleLoc
	
	push [x_apple]
    pop [draw_x]
    push [y_apple]
    pop [draw_y]
    mov [DrawColor], 2
	call square
	jmp pos_not_equal
	
	pos_not_equal:
ret
endp SnakeOnApple

;---------- Change The Score ----------
proc ChangeScore

	cmp [score_num], 57
	jne ScoreIsNotNine
	mov [score_num], 48
	inc [score_num_2]
	call BackGroundInf
	jmp ScoreUpdated

	ScoreIsNotNine:
	inc [score_num]
	call BackGroundInf
	
	ScoreUpdated:
ret
endp ChangeScore

;---------- Checking If Apple Spawn On Snake ----------
proc AppleSpawnOnSnake
	mov [appleVar], 0
	mov cx, [len_snake]

	checkingTheApple:

	mov bx, cx
	dec bx
	
	shl bx, 1
	mov ax, [x_apple_suggest]
	cmp ax, [x_snake + bx]
	jne AppleIsClear

	mov ax, [y_apple_suggest]
	cmp ax, [y_snake + bx]
	jne AppleIsClear

	mov [appleVar], 1

	AppleIsClear:
	loop checkingTheApple
ret
endp AppleSpawnOnSnake

;---------- Checking If Snake Head Moved On His Body ----------
proc CheckBodyColl

	cmp [dir], 4
	je SnakeNotMoving

	mov cx, [len_snake]
	dec cx	
	
	checkingTheHead:
	
	mov bx, cx
	shl bx, 1
	mov ax, [x_snake]
	cmp ax, [x_snake + bx]
	jne SnakeHeadIsClear
	
	mov ax, [y_snake]
	cmp ax, [y_snake + bx]
	jne SnakeHeadIsClear
	
	mov ax, 13h
	int 10h
	mov [dir], 4
	call LoseScreen
	
	SnakeHeadIsClear:
	loop checkingTheHead
	SnakeNotMoving:
ret
endp CheckBodyColl

;---------- Show The Score ----------
proc BackGroundInf

;-- the "SCORE" --

	mov dl, 4
    mov dh, 2
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset score_msg
    int 21h
	
;-- the "SNAKE" --
	
	mov dl, 17
    mov dh, 2
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset start2_msg
    int 21h

;-- the first nuumber --

	mov  dl, 11   ;Column
	mov  dh, 2    ;Row
	mov  bh, 0
	mov  ah, 02h
	int  10h

	mov  al, [score_num]
	mov  bl, 15
	mov  bh, 0
	mov  ah, 0Eh
	int  10h

;--the second number--

	mov  dl, 10   ;Column
	mov  dh, 2    ;Row
	mov  bh, 0
	mov  ah, 02h
	int  10h

	mov  al, [score_num_2]
	mov  bl, 15
	mov  bh, 0
	mov  ah, 0Eh
	int  10h
ret
endp BackGroundInf

;---------- Limits ----------
proc limits

;-- uper limit --
	push [draw_x]
	push [draw_y]
	mov bl, [DrawColor]
    
    mov [y_limit], 40

	mov ax, [x_limit]
	mov [draw_x], ax
	
	mov ax, [y_limit]
	mov [draw_y], ax
	
	mov [DrawColor], 15
	
	DrawUperLimit:
	call square
	add [draw_x], 10
	inc [LimitCounter]
	
	cmp [LimitCounter], 31
	jb DrawUperLimit
	
	mov [DrawColor], bl
	pop [draw_y]
	pop [draw_x]
    mov [LimitCounter], 0
    mov [y_limit], 0
    mov [x_limit], 0
    
;-- buttom limit --
    push [draw_x]
	push [draw_y]
	mov bl, [DrawColor]
    
    mov [y_limit], 190

	mov ax, [x_limit]
	mov [draw_x], ax
	
	mov ax, [y_limit]
	mov [draw_y], ax
	
	mov [DrawColor], 15
	
	DrawButtomLimit:
	call square
	add [draw_x], 10
	inc [LimitCounter]
	
	cmp [LimitCounter], 31
	jb DrawButtomLimit
	
	mov [DrawColor], bl
	pop [draw_y]
	pop [draw_x]
    mov [LimitCounter], 0
    mov [y_limit], 0
    mov [x_limit], 0
    
;-- left limit --
	push [draw_x]
	push [draw_y]
	mov bl, [DrawColor]
    
    mov [y_limit], 40

	mov ax, [x_limit]
	mov [draw_x], ax
	
	mov ax, [y_limit]
	mov [draw_y], ax
	
	mov [DrawColor], 15
	
	DrawLeftLimit:
	call square
	add [draw_y], 10
	inc [LimitCounter]
	
	cmp [LimitCounter], 15
	jb DrawLeftLimit
	
	mov [DrawColor], bl
	pop [draw_y]
	pop [draw_x]
    mov [LimitCounter], 0
    mov [y_limit], 0
    mov [x_limit], 0
    
;-- right limit --
	push [draw_x]
	push [draw_y]
	mov bl, [DrawColor]
    
    mov [y_limit], 40
    mov [x_limit], 310

	mov ax, [x_limit]
	mov [draw_x], ax
	
	mov ax, [y_limit]
	mov [draw_y], ax
	
	mov [DrawColor], 15
	
	DrawRightLimit:
	call square
	add [draw_y], 10
	inc [LimitCounter]
	
	cmp [LimitCounter], 16
	jb DrawRightLimit
	
	mov [DrawColor], bl
	pop [draw_y]
	pop [draw_x]
    mov [LimitCounter], 0
    mov [y_limit], 0
    mov [x_limit], 0
	
ret
endp limits

;---------- Start Screen ----------
proc MenuScreen

;---------- Showing All The Start Screen Messages On The Screen ----------
;-- the "SNAKE GAME.." --

    mov dl, 5
    mov dh, 6
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
	mov dx, offset start2_msg
	int 21h

;-- the "ENTER" --

    mov dl, 5
    mov dh, 8
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset enter_msg
    int 21h

	mov dl, 5
    mov dh, 4
    mov bh, 0
    mov ah, 02h
    int 10h
   
;-- the "FIRST PROJECT..." --
   
    mov ah, 09h
    mov dx, offset start1_msg
    int 21h

;-- the "EXIT" --

	mov dl, 5
    mov dh, 10
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset exit_screen_msg
    int 21h
	
	nothing_was_pressed:
	
	mov ah, 1h
	int 16h
	
	cmp al, 'e'
	jne StartScreen_loop
	call ExitGame
   
   	StartScreen_loop:
   
    mov ah, 0h
    int 16h
    cmp al, 13
    je enter_button_pressed
    jmp nothing_was_pressed
    enter_button_pressed:
ret
endp MenuScreen

;---------- Choosing Level Screen ----------
proc ChooseLevel
	mov ax, 13h
	int 10h
	
;-- ""Choose Level"" --

	mov dl, 5
    mov dh, 6
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset ChooseLevel_msg
    int 21h
	
;-- EASY MODE --

	mov dl, 5
    mov dh, 8
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset EasyMode_msg
    int 21h
	
;-- NORMAL MODE --
	
	mov dl, 5
    mov dh, 10
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset NormalMode_msg
    int 21h
	
;-- HARD MODE --
	
	mov dl, 5
    mov dh, 12
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset HardMode_msg
    int 21h

    DidntGetLevel:
	
	mov ah, 0h
	int 16h
	
	cmp al, '1'
	jne EazyMode
	mov [snake_speed], 3
	jmp PlayerSelectLevel
	EazyMode:
	
	cmp al, '2'
	jne NormalMode
	mov [snake_speed], 2
	jmp PlayerSelectLevel
	NormalMode:
	
	cmp al, '3'
	jne HardMode
	mov [snake_speed], 1
	jmp PlayerSelectLevel
	HardMode:
	
    jmp DidntGetLevel
	PlayerSelectLevel:
ret
endp ChooseLevel

;---------- Lose Screen ----------
proc LoseScreen

	mov ax, 13h
	int 10h
	
	DrawingLoseScreen:
	mov dl, 16
    mov dh, 5
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset LoseScreen_msg
    int 21h

	mov dl, 8
    mov dh, 10
    mov bh, 0
    mov ah, 02h
    int 10h
   
    mov ah, 09h
    mov dx, offset restart_msg
    int 21h

	mov [len_snake], 5
	mov [score_num], 48
	mov [score_num_2], 48
	mov [x_apple], 100
	mov [y_apple], 100
	mov [x_snake], 10100000b
	mov [y_snake], 1100100b

	mov ah, 0h
	int 16h

	cmp al, 'r'
	je restart_game
	jmp DrawingLoseScreen
	restart_game:
	mov [GameEnded], 1
	mov [dir], 4
ret
endp LoseScreen

;---------- Exit Game ----------
proc ExitGame
	mov ax, 4c00h
	int 21h
	mov ax, 13h
	int 10h
ret
endp ExitGame

    start:
    mov ax, @data
    mov ds, ax
; --------------------------
mov ax, 13h
int 10h
call MenuScreen

restarting_game:

call ChooseLevel

mov ax, 13h
int 10h
	mov [GameEnded], 0
   
	push [x_apple]
    pop [draw_x]
    push [y_apple]
    pop [draw_y]
    mov [DrawColor], 2
	call square
   
	call BackGroundInf
   
    push [x_snake]
    pop [draw_x]
    push [y_snake]
    pop [draw_y]
    mov [DrawColor], 13
	call square
	
	call limits

;--movement--

	first:

	call limits

    mov ah, 1h
    int 16h
    jz EndGetInput
    mov ah, 0h
    int 16h

    cmp al, 'w'
    jne SkipUpInput
	cmp [dir], 2
	je EndGetInput
    mov [dir], 0
    jmp EndGetInput
    SkipUpInput:

    cmp al, 'a'
    jne SkipLeftInput
	cmp [dir], 3
	je EndGetInput
    mov [dir], 1
    jmp EndGetInput
    SkipLeftInput:

    cmp al, 's'
    jne SkipDownInput
	cmp [dir], 0
	je EndGetInput
    mov [dir], 2
    jmp EndGetInput
    SkipDownInput:

    cmp al, 'd'
    jne SkipRightInput
	cmp [dir], 1
	je EndGetInput
    mov [dir], 3
    jmp EndGetInput
    SkipRightInput:
	
	cmp al, 'e'
	jne EndGetInput
	call ExitGame

    EndGetInput:
	
;-- Delay --
    mov ah, 2ch
    int 21h
    cmp dl, [time_aux]
    je first
    mov [time_aux], dl
	mov bh, 0h
	mov bl, [snake_speed]
    inc [time_counter]
    cmp [time_counter], bl
    jne first
    mov [time_counter], 0
   
;-- Clear --
	mov bx, [len_snake]
	shl bx, 1
    push [x_snake + bx - 2]
    pop [draw_x]
    push [y_snake + bx - 2]
    pop [draw_y]
    mov [DrawColor], 0
	call square

	call move_snake

    cmp [dir], 0
    jne SkipUpMove
    sub [y_snake], 10
    jmp EndMove
    SkipUpMove:

    cmp [dir], 1
    jne SkipLeftMove
    sub [x_snake], 10
    jmp EndMove
    SkipLeftMove:

    cmp [dir], 2
    jne SkipDownMove
    add [y_snake], 10
    jmp EndMove
    SkipDownMove:

    cmp [dir], 3
    jne SkipRightMove
    add [x_snake], 10
    jmp EndMove
    SkipRightMove:

    EndMove:
    push [x_snake]
    pop [draw_x]
    push [y_snake]
    pop [draw_y]
    mov [DrawColor], 13
    call square
	
	call CheckBodyColl
    call limits
	call SnakeOnApple
	
	cmp [GameEnded], 1
	jne CheckSnakeLimits
	jmp restarting_game
	
	CheckSnakeLimits:
	cmp [y_snake], 40
	jg CheckNum2
	call LoseScreen
    
    CheckNum2:
    cmp [y_snake], 190
    jl CheckNum3
    call LoseScreen
    
    CheckNum3:
    cmp [x_snake], 0
    jg CheckNum4
    call LoseScreen
    
    CheckNum4:
    cmp [x_snake], 310
    jl GameIsntEnd
    call LoseScreen

	GameIsntEnd:
    jmp first

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start
