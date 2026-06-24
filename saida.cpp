#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cmath>
using namespace std;

int main(void) {
	char* t1;
	char* t2;
	char* t3;
	int t4;
	int t5;
	char t6;
	char t7;
	int t8;
	int t9;
	int t10;
	int t11;
	int t12;

	t1 = (char*) malloc(3);
	strcpy(t1, "oi");
	t2 = t1;
	t3 = (char*) malloc(3);
	strcpy(t3, "oi");
	t4 = 1;
	t5 = 0;
L1:
	t6 = t2[t5];
	t7 = t3[t5];
	t8 = t6 != t7;
	if (t8) goto L2;
	t9 = t6 == '\0';
	if (t9) goto L3;
	t5 = t5 + 1;
	goto L1;
L2:
	t4 = 0;
L3:
	t12 = !t4;
	if (t12) goto L4;
	t11 = 10;
	t10 = t11;
	cout << t10;
L4:

	free(t1);
	free(t2);
	free(t3);
	return 0;
}
