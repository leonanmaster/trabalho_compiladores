/*Compilador FOCA*/
#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;

int main(void) {
	char* t1;
	char* t2;
	int t3;
	int t4;
	char t5;
	char t6;
	char* t7;
	int t8;

	t1 = (char*) malloc(7);
	strcpy(t1, "Rafael");
	t2 = (char*) malloc(6);
	strcpy(t2, "Pedro");
	t3 = 0;
	t4 = 0;
L1:
	t5 = t1[t4];
	t6 = t2[t4];
	if (t5 != t6) goto L2;
	if (t5 == '\0') goto L3;
	t4 = t4 + 1;
	goto L1;
L2:
	t3 = 1;
L3:
	t8 = !t3;
	if (t8) goto L4;
	t7 = (char*) malloc(11);
	strcpy(t7, "diferentes");
	cout << t7;
L4:
	return 0;
}
