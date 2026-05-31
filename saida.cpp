/*Compilador FOCA*/
#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;

int main(void) {
	char* t1;
	char* t2;
	char* t3;
	char* t4;
	int t5;
	int t6;
	int t7;
	char t8;
	char t9;
	int t10;
	int t11;

	t2 = (char*) malloc(2);
	strcpy(t2, "1");
	t1 = t2;
	t3 = (char*) malloc(2);
	strcpy(t3, "1");
	t3 = (char*) malloc(2);
	strcpy(t3, "1");
	t6 = 1;
	t7 = 0;
L4:
	t8 = t1[t7];
	t9 = t3[t7];
	t10 = t8 != t9;
	if (t10) goto L5;
	t11 = t8 == '\0';
	if (t11) goto L6;
	t7 = t7 + 1;
	goto L4;
L5:
	t6 = 0;
L6:
	t5 = !t6;
	if (t5) goto L3;
	t4 = (char*) malloc(2);
	strcpy(t4, "0");
	t1 = t4;
L3:
L2:
	cout << t1;
	return 0;
}
