format PE GUI 4.0

entry start ; указываем точку входа программы

include 'win32ax.inc'

; раздел для импортирования нужных библиотек и нужных функций из этих библиотек
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

; раздел для объявления константных переменных
.data
	commandLine dd ?
	n dd 0
	string db 256 DUP(?)

.code
	start:
		; считываем с помощью командной строки двойное машинное слово в n
		cinvoke GetCommandLine
		mov [commandLine], eax
		cinvoke sscanf,[commandLine],'%*s %d', n

		; в eax лежит количество считанных аргументов, если ввод был неправильным, то переходим в раздел help
		cmp eax, 0
		je help

		; переходим к инициализации переменных (регистров процессора)
		mov ebx, 0 ;переменная-счётчик количества найденных подпоследовательностей '110'
		mov ecx, 0 ;переменная, хранящая количество предыдущих битов, удовлетворяющих нашему условию
		mov edx, 10000000000000000000000000000000b ;переменная для итерирования по битовому представлению числа n
		jmp body

		; основной цикл прохода по числу как по массиву битов
		body:
			; проверяем, не прошли ли мы уже все биты, есди да, то выводим ответ (переходим в output)
			cmp edx, 0
			je output

			mov eax, [n] ; копируем значение n в техническую переменную
			and eax, edx ; получаем очередной бит числа

			cmp ecx, 2 ; смотрим, сколько на данный найдено битов искомой подпоследовательности
			je check0 ; если два предыдущих бита - единицы, проверяем данный бит на 0
			jmp check1 ; иначе проверяем бит на 1

			; проверка бита на 0 (перед этим две единицы уже найдены)
			check0:
				cmp eax, 0
				je do0
				mov ecx, 0 ; обнуляем счётчик совпадений в случае неподходящего нам бита
				shl edx, 2 ; сдвигаем итератор обратно
				jmp fin
				; если бит равен 0 (значит, мы нашли искомую подпоследовательность)
				do0:
					mov ecx, 0 ; обнуляем счётчик совпадений
					inc ebx ; увеличиваем счётчик ответа на 1
					jmp fin

			; проверка бита на 1
			check1:
				cmp eax, 0
				jne do1
				mov ecx, 0 ; обнуляем счётчик совпадений в случае неподходящего нам бита
				jmp fin
				; если бит равен 1
				do1:
					inc ecx ; увеличиваем счётчик совпадений на 1
					jmp fin

			; завершение очередной итерации цикла, перевод на новую итерацию
			fin:
				shr edx, 1 ; битовый сдвиг на 1 вправо для обработки следующего байта числа
				jmp body

		; вывод ответа и завершение работы программы
		output:
			invoke sprintf, string, "Number of '110' subsequences in bit representation of %d: %d",[n],ebx
			invoke MessageBox, 0, string, "Success", MB_OK
			invoke ExitProcess, 0

		; вывод помощи и завершение работы программы
		help:
			invoke MessageBox, 0, "After the path type an integer number from 0 to 2^32 - 1", "This program was developed by Alexander Serebrennikov, BSE181", MB_OK
			invoke ExitProcess, 0