format PE GUI 4.0

entry start ; ��������� ����� ����� ���������

include 'win32ax.inc'

; ������ ��� �������������� ������ ��������� � ������ ������� �� ���� ���������
section '.idata' import data readable

	library user32,'USER32.DLL',\
		msvcrt, 'MSVCRT.DLL',\
		kernel32, 'KERNEL32.DLL',\
		shell32, 'SHELL32.DLL'
 
	import user32,\
	       MessageBox, 'MessageBoxA'
 
	import msvcrt,\
	       sprintf, 'sprintf', sscanf, 'sscanf'
 
	import kernel32,\
	       ExitProcess, 'ExitProcess',\
	       GetCommandLine, 'GetCommandLineA'

; ������ ��� ���������� ����������� ����������
.data
	commandLine dd ?
	n dd 0
	string db 256 DUP(?)

.code
	start:
		; ��������� � ������� ��������� ������ ������� �������� ����� � n
		cinvoke GetCommandLine
		mov [commandLine], eax
		cinvoke sscanf,[commandLine],'%*s %d', n

		; � eax ����� ���������� ��������� ����������, ���� ���� ��� ������������, �� ��������� � ������ help
		cmp eax, 0
		je help

		; ��������� � ������������� ���������� (��������� ����������)
		mov ebx, 0 ;����������-������� ���������� ��������� ���������������������� '110'
		mov ecx, 0 ;����������, �������� ���������� ���������� �����, ��������������� ������ �������
		mov edx, 10000000000000000000000000000000b ;���������� ��� ������������ �� �������� ������������� ����� n
		jmp body

		; �������� ���� ������� �� ����� ��� �� ������� �����
		body:
			; ���������, �� ������ �� �� ��� ��� ����, ���� ��, �� ������� ����� (��������� � output)
			cmp edx, 0
			je output

			mov eax, [n] ; �������� �������� n � ����������� ����������
			and eax, edx ; �������� ��������� ��� �����

			cmp ecx, 2 ; �������, ������� �� ������ ������� ����� ������� ���������������������
			je check0 ; ���� ��� ���������� ���� - �������, ��������� ������ ��� �� 0
			jmp check1 ; ����� ��������� ��� �� 1

			; �������� ���� �� 0 (����� ���� ��� ������� ��� �������)
			check0:
				cmp eax, 0
				je do0
				mov ecx, 0 ; �������� ������� ���������� � ������ ������������� ��� ����
				shl edx, 2 ; �������� �������� �������
				jmp fin
				; ���� ��� ����� 0 (������, �� ����� ������� ���������������������)
				do0:
					mov ecx, 0 ; �������� ������� ����������
					inc ebx ; ����������� ������� ������ �� 1
					jmp fin

			; �������� ���� �� 1
			check1:
				cmp eax, 0
				jne do1
				mov ecx, 0 ; �������� ������� ���������� � ������ ������������� ��� ����
				jmp fin
				; ���� ��� ����� 1
				do1:
					inc ecx ; ����������� ������� ���������� �� 1
					jmp fin

			; ���������� ��������� �������� �����, ������� �� ����� ��������
			fin:
				shr edx, 1 ; ������� ����� �� 1 ������ ��� ��������� ���������� ����� �����
				jmp body

		; ����� ������ � ���������� ������ ���������
		output:
			invoke sprintf, string, "Number of '110' subsequences in bit representation of %d: %d",[n],ebx
			invoke MessageBox, 0, string, "Success", MB_OK
			invoke ExitProcess, 0

		; ����� ������ � ���������� ������ ���������
		help:
			invoke MessageBox, 0, "After the path type an integer number from 0 to 2^32 - 1", "This program was developed by Alexander Serebrennikov, BSE181", MB_OK
			invoke ExitProcess, 0