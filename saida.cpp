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
	char* t5;
	char* t6;
	char* t7;
	char* t8;
	char* t9;
	int t10;
	int t11;
	int t12;
	char* t13;
	char t14;
	int t15;
	char t16;
	int t17;
	int t18;
	int t19;
	int t20;
	char* t21;
	char t22;
	int t23;
	char t24;
	int t25;

	t5 = (char*) malloc(5);
	strcpy(t5, "boom");
	t2 = t5;
	t6 = (char*) malloc(5);
	strcpy(t6, " dia");
	t3 = t6;
	t7 = (char*) malloc(7);
	strcpy(t7, "kjlljj");
	t4 = t7;
	t8 = (char*) malloc(4);
	strcpy(t8, "ols");
	t9 = (char*) malloc(4);
	strcpy(t9, "ola");
	t10 = 0;
L1:
	t14 = t8[t10];
	t15 = t14 == '\0';
	if (t15) goto L2;
	t10 = t10 + 1;
	goto L1;
L2:
	t11 = 0;
L3:
	t16 = t9[t11];
	t17 = t16 == '\0';
	if (t17) goto L4;
	t11 = t11 + 1;
	goto L3;
L4:
	t12 = t10 + t11 + 1;
	t13 = (char*) malloc(t12);
	strcpy(t13, t8);
	strcpy(t13 + t10, t9);
	t18 = 0;
L5:
	t22 = t13[t18];
	t23 = t22 == '\0';
	if (t23) goto L6;
	t18 = t18 + 1;
	goto L5;
L6:
	t19 = 0;
L7:
	t24 = t4[t19];
	t25 = t24 == '\0';
	if (t25) goto L8;
	t19 = t19 + 1;
	goto L7;
L8:
	t20 = t18 + t19 + 1;
	t21 = (char*) malloc(t20);
	strcpy(t21, t13);
	strcpy(t21 + t18, t4);
	t1 = t21;
	cout << t1;
	return 0;
}
