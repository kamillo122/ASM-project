;   @title: Zad 1
;   @version: x86
;   @author: Kamilo
;   @date: 

.486 ; ustawienie zbioru instrukcji na procesor intel 80486, czyli programujemy na 32 bitowej architekturze
.model flat, stdcall ; ustawienie modelu pamięci i wywołań funkcji na standard z języka C
.stack 1024 ; wielkość stosu; domyślnie to 1024 bajty w Windows

include winapi.inc ; dołączenie pliku nagłówkowego zawierającego definicje funkcji z WinApi
.const 
	err1 BYTE "Blad otwarcia pliku.", 0
	err2 BYTE "Blad odczytu pliku.", 0
	err3 BYTE "Blad alokacji pamieci.", 0
	txt1 db "Brak argumentow.", 0
	txt2 db "Blad otwarcia pliku.", 0
	txt3 db "Blad odczytu pliku.", 0
	txt4 db "Blad alokacji pamieci.", 0
	txt5 db "Blad zapisu pliku.", 0
	txt6 db "TOO MANY ARGS!.", 0
	newLine DWORD 0ah, 0dh, 0 ; nowa linia - \r\n = 0x0d 0x0a [LE]

.data?
	writeBytes dd ?
.data
	fName DWORD 0 ; nazwa pliku w UTF-16
	hFile DWORD 0 ; uchwyt pliku
	fSize DWORD 0 ; wielkość pliku
	fBuff DWORD 0 ; buffor na tekst z pliku
	hInstance DWORD 0 ; uchwyt okna konsoli
	argv DWORD 0 ; pierwszy argument na liście
	argc DWORD 0 ; liczba argumentów

.code

main proc ; początek procedury (funkcji)
		INVOKE AllocConsole ; konsola już na nas czeka, Panie
		INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; potrzebujemy jej uchwytu (ID)
		mov hInstance, eax ; uchwyt umieszczamy w bloku pamięci hInstance

		; TODO: zad 1

		INVOKE GetCommandLineW
		INVOKE CommandLineToArgvW,eax,OFFSET argc
			mov argv,eax
			mov ebx, argc

		.IF ebx == 2
			mov edi, argv
			add edi, 4
			mov eax,[edi]
			mov ebx, eax
			
		;READ FILE HERE
		INVOKE CreateFileW, ebx, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_ARCHIVE, 0
		mov hFile, eax ; uchwyt do pliku

		.IF eax == INVALID_HANDLE_VALUE ; nie można otworzyć pliku
			INVOKE WriteConsole, hInstance, ADDR err1, (LENGTHOF err1) - 1, 0, 0 ; wypisz błąd w konsoli
			INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0 ; wypisz znak nowej linii w konsoli
			jmp @end ; skocz do etykiety @end ; goto
		.ENDIF

		INVOKE GetFileSize, hFile, 0 ; określ wielkość pliku
		mov fSize, eax ; zapisz ją w komórce pamięci fSize

		; zarezerwuj stronę pamięci, aby wczytać plik
		INVOKE VirtualAlloc, 0, eax, MEM_COMMIT, PAGE_READWRITE

		.IF eax == 0 ; błąd alokacji pamięci
			INVOKE WriteConsole, hInstance, ADDR err3, (LENGTHOF err3) - 1, 0, 0 ; wypisz błąd w konsoli
			INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0 ; wypisz znak nowej linii w konsoli
		.ELSE
			mov fBuff, eax ; brak błędów - w eax zwrócono początek strony pamięci

			INVOKE ReadFile, hFile, eax, fSize, 0, 0 ; wczytaj plik do wcześniej zarezerwowanej "strony"

			.IF eax == -1 ; błąd odczytu pliku
				INVOKE WriteConsole, hInstance, ADDR err2, (LENGTHOF err2) - 1, 0, 0 ; wypisz błąd w konsoli
				INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0 ; wypisz znak nowej linii w konsoli
			.ELSE
				INVOKE WriteConsoleW, hInstance, fBuff, fSize, 0, 0 ; wypisz zawartość pliku na ekranie
			.ENDIF
		.ENDIF

		INVOKE VirtualFree, fBuff, ADDR fSize, MEM_RELEASE ; zwolnij strony pamięci 
		INVOKE CloseHandle, hFile ; zamknij plik

		;READ FILE HERE END
		.ELSEIF ebx > 3
		INVOKE WriteConsole, hInstance, ADDR txt6,(LENGTHOF txt6) - 1, 0, 0
		

		.ELSEIF ebx == 3
		mov edi, argv
		add edi, 4
		mov eax,[edi]
		mov ebx, eax
		;CREATE FILE HERE
		INVOKE CreateFileW, ebx, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0
		mov hFile, eax ; uchwyt do pliku
		mov edi, argv
		add edi, 8
		mov eax,[edi]
		mov ebx, eax
		INVOKE lstrlenW, ebx
		mov ecx, 2
		mul ecx
		INVOKE WriteFile, hFile, ebx, eax, offset writeBytes,0
		.IF eax == 0
			INVOKE WriteConsole, hInstance, ADDR txt5,(LENGTHOF txt5) - 1, 0, 0
		.ENDIF
		INVOKE CloseHandle, hFile
		.ELSE
		INVOKE WriteConsole, hInstance, ADDR txt1,(LENGTHOF txt1) - 1, 0, 0
		.ENDIF	

		@end:
		INVOKE FreeConsole ; uwolnić konsolę!
		INVOKE ExitProcess, 0 ; zakończ proces z kodem 0
main endp ; koniec procedury main
END main ; ustaw procedurę (funkcje) startową oraz koniec programu
