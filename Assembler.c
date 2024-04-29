// C program to implement
// the above approach
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void Assembler(char* str, char* out);
void Decode(char* str, int inp);
void initString(char* str, int size);
void initZString(char* str, int size);
void decimalToBinary(int decimal, char* BinaryStr);
void organize();

char* op;
char* Rd;
char* R1;
char* R2;
char* IMM;

int main()
{
    op = (char*)malloc(20 * sizeof(char));
    Rd = (char*)malloc(20 * sizeof(char));
    R1 = (char*)malloc(20 * sizeof(char));
    R2 = (char*)malloc(20 * sizeof(char));
    IMM = (char*)malloc(20 * sizeof(char));

//Input File
	FILE* ptr;
	char ch;

	ptr = fopen("test.txt", "r");

	if (NULL == ptr) {
		printf("file can't be opened \n");
        return 1;
	}
    char myString[30];

//Output File:
    FILE* outputPtr = fopen("out.txt", "w");
    if (NULL == outputPtr) {
        printf("Output file can't be opened.\n");
        return 1;
    }


    while(fgets(myString, 100, ptr)) {
        Assembler(myString,myString);
        fprintf(outputPtr, "%s %s %s %s %s\n", op,Rd,R1,R2, IMM);
    }

	fclose(ptr);
	return 0;
}


void Assembler(char* str, char* out)
{
    initString(op,20);initString(Rd,20);initString(R1,20); initString(R2,20); initString(IMM,20);
    int inp = 0;

    //Iterators i,j
    int i, j, k;
    i = j = 0;
    while (str[i] != '\0')
    {
        j = i;
        k = 0;
        if(str[j] == ',' || str[j] == ' ')
        {
            i++;
            continue;
        }
        while (str[j] != ' ' && str[j] != '\0' && str[j] != ',' && str[j] != '(' && str[j] != ')')
        {
            if(inp == 0)
            {
                op[k] = str[j];
            }
            else if(inp == 1)
            {

                Rd[k] = str[j];
            }
            else if(inp == 2)
            {
                R1[k] = str[j];
            }
            else if(inp == 3)
            {
                R2[k] = str[j];
            }
            else if(inp == 4)
            {
                IMM[k] = str[j];
            }
            j++;
            k++;   
        }

        inp++;
        i = j; // abas qa
        i++;
    }
    Decode(op,0); Decode(Rd,1);
    if(!strcmp(op,"01010") || !strcmp(op,"01100"))
    {
        Decode(R2,4);Decode(R1,2);
        strcpy(IMM,R2);
        initZString(R2,3);
    }
    else if (!strcmp(op,"10011"))
    {
        Decode(R1,4);
        strcpy(IMM,R1);
        initZString(R1,3);initZString(R2,3);
    }
    else if(!strcmp(op,"10100"))
    {
        Decode(R1,4); Decode(R2,3);
        strcpy(IMM,R1);strcpy(R1,R2);
        initZString(R2,3);
    }
    else if(!strcmp(op,"10101"))
    {
        Decode(R1,4);Decode(R2,3);
        strcpy(IMM,R1);strcpy(R1,R2);strcpy(R2,Rd); 
        initZString(Rd,3);
    }
    else
    {
        Decode(R1,2); Decode(R2,3);
        organize();
    }



    // printf("Op: %s\n", op);
    // printf("Rd: %s\n", Rd);
    // printf("Rs1: %s\n", R1);
    // printf("Rs2: %s\n", R2);
    // printf("IMM: %s\n", IMM);
}

void initString(char* str, int size)
{
    for(int i = 0; i < size; i++)
    {
        str[i] = '\0';
    }
}

void initZString(char* str, int size)
{
    initString(str,20);
    for(int i = 0; i < size; i++)
    {
        str[i] = '0';
    }
}

void Decode(char* str, int inp) {
    for (int i = 0; str[i] != '\0'; i++)
        str[i] = tolower(str[i]);

    if (inp == 0) {
        if (!strcmp(str, "nop")) {
            strcpy(str, "00000");
        } else if (!strcmp(str, "not")) {
            strcpy(str, "00001");
        } else if (!strcmp(str, "neg")) {
            strcpy(str, "00010");
        } else if (!strcmp(str, "inc")) {
            strcpy(str, "00011");
        } else if (!strcmp(str, "dec")) {
            strcpy(str, "00100");
        } else if (!strcmp(str, "out")) {
            strcpy(str, "00101");
        } else if (!strcmp(str, "in")) {
            strcpy(str, "00110");
        } else if (!strcmp(str, "mov")) {
            strcpy(str, "00111");
        } else if (!strcmp(str, "swap")) {
            strcpy(str, "01000");
        } else if (!strcmp(str, "add")) {
            strcpy(str, "01001");
        } else if (!strcmp(str, "addi")) {
            strcpy(str, "01010");
        } else if (!strcmp(str, "sub")) {
            strcpy(str, "01011");
        } else if (!strcmp(str, "subi")) {
            strcpy(str, "01100");
        } else if (!strcmp(str, "and")) {
            strcpy(str, "01101");
        } else if (!strcmp(str, "or")) {
            strcpy(str, "01110");
        } else if (!strcmp(str, "xor")) {
            strcpy(str, "01111");
        } else if (!strcmp(str, "cmp")) {
            strcpy(str, "10000");
        } else if (!strcmp(str, "push")) {
            strcpy(str, "10001");
        } else if (!strcmp(str, "pop")) {
            strcpy(str, "10010");
        } else if (!strcmp(str, "ldm")) {
            strcpy(str, "10011");
        } else if (!strcmp(str, "ldd")) {
            strcpy(str, "10100");
        } else if (!strcmp(str, "std")) {
            strcpy(str, "10101");
        } else if (!strcmp(str, "protect")) {
            strcpy(str, "10110");
        } else if (!strcmp(str, "free")) {
            strcpy(str, "10111");
        } else if (!strcmp(str, "jz")) {
            strcpy(str, "11000");
        } else if (!strcmp(str, "jmp")) {
            strcpy(str, "11001");
        } else if (!strcmp(str, "call")) {
            strcpy(str, "11010");
        } else if (!strcmp(str, "ret")) {
            strcpy(str, "11011");
        } else if (!strcmp(str, "rti")) {
            strcpy(str, "11100");
        }
    }

    if (inp == 1 || inp == 2 || inp == 3) 
    {
        if (!strcmp(str, "r0")) {
            strcpy(str, "000");
        } else if (!strcmp(str, "r1")) {
            strcpy(str, "001");
        } else if (!strcmp(str, "r2")) {
            strcpy(str, "010");
        } else if (!strcmp(str, "r3")) {
            strcpy(str, "011");
        } else if (!strcmp(str, "r4")) {
            strcpy(str, "100");
        } else if (!strcmp(str, "r5")) {
            strcpy(str, "101");
        } else if (!strcmp(str, "r6")) {
            strcpy(str, "110");
        } else if (!strcmp(str, "r7")) {
            strcpy(str, "111");
        }
    }

    if(inp == 4)
    {
        int decimal = atoi(str);
        decimalToBinary(decimal,str);
    }
}

void organize()
{
    if(!strcmp(op,"11011") || !strcmp(op,"11100"))
    {
        initZString(Rd,3);initZString(R1,3);initZString(R2,3);
    }
    else if(!strcmp(op,"00001") || !strcmp(op,"00010") || !strcmp(op,"00011") || !strcmp(op,"00100"))
    {
        strcpy(R1,Rd);
        initZString(R2,3);
    }
    else if(!strcmp(op,"00101"))
    {
        strcpy(R1,Rd);
        initZString(Rd,3);initZString(R2,3);    
    }
    else if(!strcmp(op,"000110") || !strcmp(op,"10010"))
    {
        initZString(R1,3);initZString(R2,3);
    }
    else if (!strcmp(op,"00111"))
    {
        initZString(R2,3);
    }
    else if(!strcmp(op, "01000"))
    {
        strcpy(R2,Rd);
        initZString(Rd,3);
    }
    else if(!strcmp(op, "01001") || !strcmp(op, "01011") || !strcmp(op, "01101") || !strcmp(op, "01110") || !strcmp(op, "01111"))
    {}
    else if(!strcmp(op, "10000"))
    {
        strcpy(R1,R2);strcpy(R1,Rd);
        initZString(Rd,3);
    }
    else if(!strcmp(op, "10001"))
    {
        strcpy(R1,Rd);
        initZString(Rd,3);initString(R2,3);
    }
    else if(!strcmp(op, "10110"))
    {
        strcpy(R1,Rd);
        initZString(Rd,3);initZString(R2,3);
    }
    else
    {
        printf("error 32 Op");
        exit(32);
    }
}

void decimalToBinary(int decimal, char* BinaryStr) 
{
    int binary[16];

    int index = 0;
    int isNegative = 0;

    if (decimal < 0) {
        isNegative = 1;
        decimal = -decimal;
    }
    for(int i = 0; i < 16; i++)
    {
        binary[i] = decimal % 2;
        decimal /= 2;
    }

    if (isNegative) {
        for (int i = 0; i < 16; i++) {
            binary[i] = !binary[i];
        }

        int carry = 1;
        for (int i = 0; i < 16; i++) {
            int sum = binary[i] + carry;
            binary[i] = sum % 2;
            carry = sum / 2;
        }
    }

    for(int i = 0; i < 16; i++)
        BinaryStr[i] = binary[15 - i] + '0';

}
