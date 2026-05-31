/*Compilador FOCA*/
#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;

int main(void) {
	char* t1;
	char* t2;
	int t3;
	char* t4;
	char* t5;
	int t6;
	int t7;
	char t8;
	char t9;

	t4 = (char*) malloc(7);
	strcpy(t4, "Rafael");
	t1 = t4;
	t5 = (char*) malloc(7);
	strcpy(t5, "Rafael");
	t2 = t5;
	t6 = 1;
	t7 = 0;
L1:
	t8 = t1[t7];
	t9 = t2[t7];
	if (t8 != t9) goto L2;
	if (t8 == '\0') goto L3;
	t7 = t7 + 1;
	goto L1;
L2:
	t6 = 0;
L3:
	t3 = t6;
	cout << t3;
	return 0;
}
