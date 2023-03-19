;   @title: Zad 1
;   @version: x86
;   @author: kamilo
;   @date: 

.486 ; ustawienie zbioru instrukcji na procesor intel 80486, czyli programujemy na 32 bitowej architekturze
.model flat, stdcall ; ustawienie modelu pamięci i wywołań funkcji na standard z języka C
.stack 1024 ; wielkość stosu; domyślnie to 1024 bajty w Windows

include winapi.inc ; dołączenie pliku nagłówkowego zawierającego definicje funkcji z WinApi

.const
	err1 BYTE 'Too many args'
	err2 BYTE 'Memory allocating error'
	err3 BYTE 'Cannot open file'
	err4 BYTE 'Error while reading file'
	err5 BYTE 'Error while save file'

	newLine DWORD 0ah, 0dh, 0; nowa linia

.data
	hInstance DWORD 0 ; uchwyt okna konsoli
	hFile DWORD 0
	hBuff DWORD 0
	fSize DWORD 0
	fBuff DWORD 0
	argv DWORD 0
	argc DWORD 0
	writeBytes DWORD 0

.code

	main proc ; początek procedury (funkcji)
		INVOKE AllocConsole ; konsola już na nas czeka, Panie
		INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; potrzebujemy jej uchwytu (ID)
		mov hInstance, eax ; uchwyt umieszczamy w bloku pamięci hInstance

		; TODO: zad 1

		INVOKE GetCommandLineW
		INVOKE CommandLineToArgvW, eax, OFFSET argc
		mov argv, eax
		mov ebx, argc

		.IF ebx == 2
			mov edi, argv
			add edi, 4
			mov eax, [edi]
			mov ebx, eax
			INVOKE CreateFileW, ebx, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_ARCHIVE, 0
			mov hFile, eax

			.IF eax==INVALID_HANDLE_VALUE
				invoke WriteConsole, hInstance, ADDR err3, (LENGTHOF err3) - 1, 0, 0
				INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0
				jmp @end
			.ENDIF

			INVOKE GetFileSize, hFile, 0
			mov fSize, eax

			INVOKE VirtualAlloc, 0, eax, MEM_COMMIT, PAGE_READWRITE

			.IF eax == 0
				INVOKE WriteConsole, hInstance, ADDR err2, (LENGTHOF err2) - 1, 0, 0
				INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0
			.ELSE
				mov hBuff, eax
				INVOKE ReadFile, hFile, eax, fSize, 0, 0

				.IF eax == -1
					INVOKE WriteConsole, hInstance, ADDR err4, (LENGTHOF err4) - 1, 0, 0
					INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0
				.ELSE
					INVOKE WriteConsoleW, hInstance, fBuff, fSize, 0, 0
				.ENDIF
			.ENDIF

			INVOKE VirtualFree, fBuff, ADDR fSize, MEM_RELEASE ; zwolnij strony pamięci 
			INVOKE CloseHandle, hFile ; zamknij plik
		.ELSEIF ebx == 3
			mov edi, argv
			add edi, 4
			mov eax, [edi]
			mov ebx, eax

			INVOKE CreateFileW, ebx, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0
			mov hFile, eax
			.IF eax == INVALID_HANDLE_VALUE
				INVOKE WriteConsole, hInstance, ADDR err3, (LENGTHOF err3) - 1, 0, 0
				INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0
				jmp @end
			.ELSE
				mov edi, argv
				add edi, 8
				mov eax, [edi]
				mov ebx, eax
				INVOKE lstrlenW, ebx
				mov ecx, 2
				mul ecx

				INVOKE WriteFile, hFile, ebx, eax, OFFSET writeBytes, 0

				.IF eax == 0
					INVOKE WriteConsole, hInstance, ADDR err5, (LENGTHOF err5) - 1, 0, 0
					INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0
				.ENDIF

				INVOKE CloseHandle, hFile
			.ENDIF
		.ELSE 
			INVOKE WriteConsole, hInstance, ADDR err1, (LENGTHOF err1) - 1, 0, 0
			INVOKE WriteConsole, hInstance, OFFSET newLine, 2, 0, 0
		.ENDIF
		@end:
			INVOKE FreeConsole
			INVOKE ExitProcess, 0

		INVOKE FreeConsole ; uwolnić konsolę!
		INVOKE ExitProcess, 0 ; zakończ proces z kodem 0
	main endp ; koniec procedury main
END main ; ustaw procedurę (funkcje) startową oraz koniec programu
