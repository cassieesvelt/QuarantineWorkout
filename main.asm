;Quarantine home workout
;Contributors: Cassie Esvelt, Jeremy Knight


.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitProcess:DWORD
INCLUDE Irvine32.inc


Workout STRUCT
; variables : workoutType - what kind of workout it is, ex. "abs"
;             intensity - same as difficuty, easy, medium or hard. dictates number of reps
;             exerciseNames - what each exercise in the workout is called. ex. "Crunches"
;             reps - how many reps to do of each exercise
;----------------------------------------------------------------------------------------------
	workoutType DWORD ?     ; each of these is storing the address of the BYTE string
	intensity   DWORD ?
	exercise1 DWORD ?
    exercise2 DWORD ?
    exercise3 DWORD ?
	reps1 WORD ?
    reps2 WORD ?
    reps3 WORD ?
Workout ENDS


.data
    workout1 Workout <>                 ; these are the workout objects used by the program.
    sun Workout <>
    mon Workout <>
    tue Workout <>
    thu Workout <>
    fri Workout <>
    sat Workout <>

;----------------------------------------------strings for user interaction---------------------------------
    UserChoices DWORD 3 dup (?) ; 3 elements
    prompt1 BYTE "Quarantine Workout! ", 0
    prompt2 BYTE "What level do you want? Type 1 for easy, 2 for medium, 3 for hard: ", 0
    prompt3 BYTE "Do you want a single workout, or a daily schedule? Type 1 for single, 2 for schedule: ",0
    prompt4 BYTE "What kind of workout? Type 1 for abs, 2 for legs, and 3 for arms: ", 0
    intensity1 BYTE "easy",0
    intensity2 BYTE "medium",0
    intensity3 BYTE "hard",0
    
    pushups BYTE "Pushups: ",0
    dips BYTE "Dips: ", 0
    burpees BYTE "Burpees: ", 0
    lunges BYTE "Lunges(per leg): ", 0
    squats BYTE "Squats: ", 0
    situps BYTE "Sit ups: ", 0
    planks BYTE "Planks, seconds to hold for: ", 0

    abWorkout BYTE "time to lose that ab-stract belly!", 0
    armWorkout BYTE "You'll be able to join the arm-y after this workout!", 0
    legWorkout BYTE "No more twig legs!", 0
    intensitySetTo BYTE "Intensity set to: ", 0

    monday BYTE "----Monday------------------------------",0
    tuesday BYTE "----Tuesday-----------------------------",0
    wednesday BYTE "----Wednesday---------------------------",0
    thursday BYTE "----Thursday----------------------------",0
    friday BYTE "----Friday------------------------------",0
    saturday BYTE "----Saturday----------------------------",0
    sunday BYTE "----Sunday------------------------------",0
    rest BYTE " You should rest today. Do some stretches!",0

;------------------------------------Excersises: reps set to the easiest level in hex---------------
    Npushups WORD 000Ah                          ;10 pushups
    Ndips WORD 000Ah                             ;10 dips     
    Nburpees WORD 0005h                          ;5 burpees
    Nlunges WORD 000Ah                           ;10 lunges
    Nsquats WORD 000Ah                           ;10 squats
    Nsitups WORD 0014h                           ;20 situps
    Nplanks WORD 000Fh                           ;15 second planks
;---------------------------------------------------------------------------------------------------------
.code
main proc
    call Clrscr
    call UserInput                              ; gets the user's preferences for the workout
    mov eax, 0
    cmp eax, UserChoices + TYPE UserChoices     ; see if they picked a workout type. if they didn't, they want a schedule
    jnz singleWorkout
    
        call WorkoutPlan                        ; give user a week of workouts!

    jmp final                                   ; go to end of main

    singleWorkout:                              ; go here of the user wants only one workout
   
        mov edi, OFFSET workout1                ; move workout1 address to edi which is then used by generateWorkout and PrintWorkout
        call GenerateWorkout                    ; generate a workout!
        call PrintWorkout                       ; print the workout just generated

    final:
    call crlf
    call waitMsg

invoke ExitProcess, 0
main ENDP

UserInput proc
; recieves: userInput (ReadDec)
; returns: Filled array called UserChoices
;---------------------------------------------------------------
    mov esi, OFFSET UserChoices ; esi points at UserChoices
    
    mov edx, OFFSET prompt1 
    call WriteString                ; print quarentine workout
    call crlf
    mov edx, OFFSET prompt2 
    call WriteString                ; print asking for intensity
    call ReadDec                    ; take in user's choice
    mov [esi], eax                  ; move the number from readDec into dereferenced esi pointer, pointing to UserChoices
    call crlf
    mov edx, OFFSET prompt3         ; asking for workout or schedule
    call WriteString
    call ReadDec                    ; take in user's choice
    call crlf
    cmp eax, 1                      ; if the user picked 2, skip to end. else keep going
    jne endofprog

        mov edx, OFFSET prompt4     
        call WriteString                ; ask for workout type
        call ReadDec
        mov [esi + TYPE UserChoices], eax  ; move next user choice to second spot in UserChoices 
        call crlf

    endofprog:
    ret
UserInput ENDP

GenerateWorkout PROC
; Recieves: the UserChoices from UserInput
; Returns: A workout generated from the choices that is stored in a workout class object
;----------------------------------------------------------------------------------------------
    
    mov ebx, 1                                      ; using ebx to compare with

    cmp ebx,UserChoices                             ; compare first user choice with 1
    jne L2                                          ; if not equal to 1, jump to L2 loop
        mov eax, OFFSET intensity1
        mov (Workout PTR [edi]).intensity, eax          ; move "easy" to workout.intensity
    jmp next

    L2: 
        add ebx, 1                                      ; ebx = 2
        cmp ebx,UserChoices                             ; compare first user choice with 2
        jne L3                                          ; if not equal to 2, jump to L3 loop
        mov eax, OFFSET intensity2
        mov (Workout PTR [edi]).intensity, eax          ; move "medium" to workout.intensity
    jmp next

    L3:
        mov eax, OFFSET intensity3
        mov (Workout PTR [edi]).intensity, eax          ; move "hard" to workout.intensity
    jmp next

    next:
    mov ebx, 1                              
    cmp ebx,UserChoices + TYPE UserChoices          ; compare if userchoice2 = 1
    jne fillLegs                                    ; if not, skip to next part if the user chose 2 or 3
    
    ;----------------- filling ab exercises--------------
        mov eax, OFFSET abWorkout               ; if the user did chose 1,(abs) make workoutType abs
        mov (Workout PTR [edi]).workoutType, eax           
        mov eax, OFFSET planks                  ; move planks into the exercise1
        mov (Workout PTR [edi]).exercise1, eax         
        mov ax, Nplanks                         ; move number of planks into reps1
        mov (Workout PTR [edi]).reps1,ax
        mov eax, OFFSET situps                  ; move situps into excercise2
        mov (Workout PTR [edi]).exercise2, eax
        mov ax, Nsitups                         ; move number of situps into reps2
        mov (Workout PTR [edi]).reps2,ax
        mov eax, OFFSET burpees                 ; move burpees into excercise3
        mov (Workout PTR [edi]).exercise3, eax
        mov ax, Nburpees                        ; move number of burpees into reps3
        mov (Workout PTR [edi]).reps3,ax
    jmp last
    ;----------------- filling leg exercises--------------
    fillLegs:                               ; this is for if the user chose 2(legs)
        add ebx,1
        cmp ebx,UserChoices + TYPE UserChoices        ; make sure the userchoice = 2
        jne fillArms                            ; if not, go to arms
        mov eax, OFFSET legWorkout
        mov (Workout PTR [edi]).workoutType, eax
        mov eax, OFFSET lunges              
        mov (Workout PTR [edi]).exercise1, eax
        mov ax, Nlunges
        mov (Workout PTR [edi]).reps1,ax
        mov eax, OFFSET squats
        mov (Workout PTR [edi]).exercise2, eax
        mov ax, Nsquats
        mov (Workout PTR [edi]).reps2,ax
        mov eax, OFFSET burpees
        mov (Workout PTR [edi]).exercise3, eax
        mov ax, Nburpees
        mov (Workout PTR [edi]).reps3,ax
    jmp last
    ;----------------- filling arm exercises--------------
    fillArms:
        mov eax, OFFSET armWorkout
        mov (Workout PTR [edi]).workoutType, eax
        mov eax, OFFSET pushups              
        mov (Workout PTR [edi]).exercise1, eax
        mov ax, Npushups
        mov (Workout PTR [edi]).reps1,ax
        mov eax, OFFSET dips
        mov (Workout PTR [edi]).exercise2, eax
        mov ax, Ndips
        mov (Workout PTR [edi]).reps2,ax
        mov eax, OFFSET burpees
        mov (Workout PTR [edi]).exercise3, eax
        mov ax, Nburpees
        mov (Workout PTR [edi]).reps3,ax

    last:

    ret
GenerateWorkout ENDP

PrintWorkout proc
; Recieves: workout class object that contains workout options
; returns: output of the workout into the terminal
;--------------------------------------------------------------------------------------
   
    call crlf

    mov eax, (Workout PTR [edi]).intensity               ; ex now holds the address of the intensity setting

    .IF eax == OFFSET intensity1                         ;easy workout conditional
        mov ebx, 0001h                                                  ;set ebx to an intesity of *1
    .ELSEIf eax == OFFSET intensity2                     ;medium workout conditional
        mov ebx, 0002h                                                  ;set ebx to an intesity of *2
    .ELSEIf eax == OFFSET intensity3                     ;hard workout conditional
        mov ebx, 0005h                                                  ;set ebx to an intensity of *5
    .ELSE
        mov edx, OFFSET prompt1                         ;if all else fails, this will print Quarantine workout!
    .ENDIF

    mov eax, 0              ;IMPORTANT: this is so mul works correctly because when you move reps to ax,
                            ; you can't have any numbers in the top portion of the register
                            ; because mul is using the full eax register, not just ax.

    mov edx, (Workout PTR [edi]).workoutType           ; Prints workout greeting
    call WriteString
    call crlf
    mov edx, OFFSET intensitySetTo                     ;prints setting of intensity
    call WriteString
    mov edx, (Workout PTR [edi]).intensity             ; printing out intensity
    call WriteString
    call crlf
    call crlf                                          ;not quite done with this part... -Jeremy
        
    mov edx, (Workout PTR [edi]).exercise1             ;print exercise1
    call WriteString
    mov ax,(Workout PTR [edi]).reps1                   ;put number of excersises into ax
    mul ebx                                            ;multiply ebx (intesity level) to eax
    call WriteDec         
    call crlf

    mov edx, (Workout PTR [edi]).exercise2             ;print exercise2
    call WriteString
    mov ax,(Workout PTR [edi]).reps2                   ;put number of excersises into ax
    mul ebx                                            ;multiply ebx (intesity level) to eax
    call WriteDec         
    call crlf

    mov edx, (Workout PTR [edi]).exercise3             ;print exercise3
    call WriteString
    mov ax,(Workout PTR [edi]).reps3                   ;put number of excersises into ax
    mul ebx                                            ;multiply ebx (intesity level) to eax
    call WriteDec         
    call crlf

    ret
PrintWorkout ENDP

WorkoutPlan PROC
; Recieves: workout intensity level
; Returns: A workout generated from the choices that is stored in a workout class object
;----------------------------------------------------------------------------------------------

mov UserChoices + TYPE UserChoices, 1                   ; move abs to the second spot in user choice so generate workout prints abs
mov edi, OFFSET sun                                     ; the first day is sunday
call GenerateWorkout                                    ; generate a sunday workout
mov edx, OFFSET sunday
call WriteString
call PrintWorkout
call crlf

mov UserChoices + TYPE UserChoices, 2                   ; continue for next 6 days in the week, the next day is leg day
mov edi, OFFSET mon
call GenerateWorkout
mov edx, OFFSET monday
call WriteString
call PrintWorkout
call crlf

mov UserChoices + TYPE UserChoices, 3
mov edi, OFFSET tue
call GenerateWorkout
mov edx, OFFSET tuesday
call WriteString
call PrintWorkout
call crlf

mov edx, OFFSET wednesday                               ; wednesday is rest day, so there is generateWorkout
call WriteString
call crlf
call crlf
mov edx, OFFSET rest
call WriteString
call crlf
call crlf

mov UserChoices + TYPE UserChoices, 1
mov edi, OFFSET thu
call GenerateWorkout
mov edx, OFFSET thursday
call WriteString
call PrintWorkout
call crlf

mov UserChoices + TYPE UserChoices, 2
mov edi, OFFSET fri
call GenerateWorkout
mov edx, OFFSET friday
call WriteString
call PrintWorkout
call crlf

mov UserChoices + TYPE UserChoices, 3
mov edi, OFFSET sat
call GenerateWorkout
mov edx, OFFSET saturday
call WriteString
call PrintWorkout
call crlf


ret
WorkoutPlan ENDP
END main

