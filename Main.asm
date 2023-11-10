.686
.model flat
extern _ExitProcess@4 : PROC
extern __write : PROC ; (dwa znaki podkre�lenia)
extern __read : PROC ; (dwa znaki podkre�lenia)
public _main


.data
    tekst db 10, 'Wpisz liczbe dwudziestkowa i kliknij Enter', 10
    koniec db ?
    znaki db 12 dup(?)
    dwadziescia db 20
    num1 dd 0
    tysiac dd 1000
    wynik db 13 dup('.')
    ile dd 2
.code


wczytaj_do_EAX_20 PROC
; wczytywanie liczby szesnastkowej z klawiatury � liczba po
; konwersji na posta� binarn� zostaje wpisana do rejestru EAX
; po wprowadzeniu ostatniej cyfry nale�y nacisn�� klawisz
; Enter
push ebx
push ecx
push edx
push esi
push edi
push ebp
; rezerwacja 12 bajt�w na stosie przeznaczonych na tymczasowe
; przechowanie cyfr szesnastkowych wy�wietlanej liczby
sub esp, 12 ; rezerwacja poprzez zmniejszenie ESP
mov esi, esp ; adres zarezerwowanego obszaru pami�ci
push dword PTR 10 ; max ilo�� znak�w wczytyw. liczby
push esi ; adres obszaru pami�ci
push dword PTR 0; numer urz�dzenia (0 dla klawiatury)
call __read ; odczytywanie znak�w z klawiatury
; (dwa znaki podkre�lenia przed read)
add esp, 12 ; usuni�cie parametr�w ze stosu
mov ile,eax
cmp ile,2
jz jedna
mov eax, 20 ; pierszy mnoznik
jmp exit
jedna:
mov eax, 1 ; pierszy mnoznik
exit:
mov ebx, 0
pocz_konw:
mov dl, [esi] ; pobranie kolejnego bajtu
inc esi ; inkrementacja indeksu
cmp dl, 10 ; sprawdzenie czy naci�ni�to Enter
je gotowe ; skok do ko�ca podprogramu
; sprawdzenie czy wprowadzony znak jest cyfr� 0, 1, 2 , ..., 9
cmp dl, '0'
jb pocz_konw ; inny znak jest ignorowany
cmp dl, '9'
ja sprawdzaj_dalej
sub dl, '0' ; zamiana kodu ASCII na warto�� cyfry
dopisz:
push eax
mul dx

add bx, ax 
pop eax
div dwadziescia
jmp pocz_konw ; skok na pocz�tek p�tli konwersji
; sprawdzenie czy wprowadzony znak jest cyfr� A, B, ..., F
sprawdzaj_dalej:
cmp dl, 'A'
jb pocz_konw ; inny znak jest ignorowany
cmp dl, 'J'
ja sprawdzaj_dalej2
sub dl, 'A' - 10 ; wyznaczenie kodu binarnego
jmp dopisz
; sprawdzenie czy wprowadzony znak jest cyfr� a, b, ..., f
sprawdzaj_dalej2:
cmp dl, 'a'
jb pocz_konw ; inny znak jest ignorowany
cmp dl, 'j'
ja pocz_konw ; inny znak jest ignorowany
sub dl, 'a' - 10
jmp dopisz
gotowe:
mov eax,ebx
; zwolnienie zarezerwowanego obszaru pami�ci
add esp, 12
pop ebp
pop edi
pop esi
pop edx
pop ecx
pop ebx
ret
wczytaj_do_EAX_20 ENDP


wyswietl_EAX PROC;konwersja na liczbe w postaci dziesietnej i wyswietlenie jej
pusha

mov esi, 10 ; indeks w tablicy 'znaki'
mov ebx, 10 ; dzielnik r�wny 10
konwersja:
mov edx, 0 ; zerowanie starszej cz�ci dzielnej
div ebx ; dzielenie przez 10, reszta w EDX,
; iloraz w EAX
add dl, 30H ; zamiana reszty z dzielenia na kod
; ASCII
mov znaki [esi], dl; zapisanie cyfry w kodzie ASCII
dec esi ; zmniejszenie indeksu
cmp eax, 0 ; sprawdzenie czy iloraz = 0
jne konwersja ; skok, gdy iloraz niezerowy
; wype�nienie pozosta�ych bajt�w spacjami i wpisanie
; znak�w nowego wiersza
wypeln:
or esi, esi
jz wyswietl ; skok, gdy ESI = 0
mov byte PTR znaki [esi], 20H ; kod spacji
dec esi ; zmniejszenie indeksu
jmp wypeln
wyswietl:
mov byte PTR znaki [0], 0AH ; kod nowego wiersza
mov byte PTR znaki [11], 0AH ; kod nowego wiersza
; wy�wietlenie cyfr na ekranie

mov eax,13;do 12 elementowej tablicy dok�adamy znak '.' 
mov esi,0;indeks tablicy znaki
mov edi,0;indeks tablicy wynik

ptlx:
cmp edi,8;miejsce wstawienia znaku'.'
jz next
mov dl,znaki[esi]
inc esi
mov wynik[edi],dl
inc edi
jmp dalej1
next:
inc edi
dalej1:
cmp edi,12
jnz ptlx
cmp wynik[7],' ';znak spacji na 7 pozycji onacza ze wynik niejszy od 1 
jnz zakoncz
mov wynik[7],'0';przed znakiem '.' nalezy wstawic '0'
zakoncz:
push dword PTR 12 ; liczba wy�wietlanych znak�w
push dword PTR OFFSET wynik ; adres wy�w. obszaru
push dword PTR 1; numer urz�dzenia (ekran ma numer 1)
call __write ; wy�wietlenie liczby na ekranie
add esp, 12 ; usuni�cie parametr�w ze stosu

popa
ret
wyswietl_EAX ENDP

wyswietl_tekst PROC

    push ebp
    mov ebp,esp
    push (offset koniec) - (offset tekst) ; liczba znak�w wy�wietlanego tekstu
    push dword PTR OFFSET tekst ; po�o�enie obszaru
    ; ze znakami
    push dword PTR 1 ; uchwyt urz�dzenia wyj�ciowego
    call __write ; wy�wietlenie znak�w
    ; (dwa znaki podkre�lenia _ )
       add esp, 12 ; usuni�cie parametr�w ze stosu
    ; zako�czenie wykonywania programu

    pop ebp
    RET

wyswietl_tekst ENDP

dzielenie PROC


push ebp
mov ebp,esp
push ebx
push edx

    mov ebx,[ebp+12];dzielnik do ebx
    mov eax,[ebp+8];dzielna wczytana z pamieci do eax
    mul tysiac
    mov edx,0;starsza czesc rejstru EDX:EAX zerowana 
    div ebx

pop edx
pop ebx
pop ebp

RET
dzielenie ENDP

_main:

    call wyswietl_tekst

    call wczytaj_do_EAX_20
    mov num1,eax
    call wyswietl_tekst
    
    call wczytaj_do_EAX_20

    push eax ;dzielnik
    push num1 ;dzielna
   
    call dzielenie

    call wyswietl_EAX

    push dword PTR 0 ; kod powrotu programu
    call _ExitProcess@4
END




