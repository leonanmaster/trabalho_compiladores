/*Compilador FOCA*/
#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;

int main(void) {
	int t1;
	int t2;
	int t3;
	int t4;
	int t5;
	int t6;
	int t7;
	int t8;
	int t9;
	int t10;

	t2 = 0;
	t3 = t2;
L1:
	t4 = 4;
	t5 = t3 < t4;
	t10 = !t5;
	if (t10) goto L2;
	t8 = 2;
	t9 = t8;
	cout << t9;
	t6 = 1;
	t7 = t3 + t6;
	t3 = t7;
	goto L1;
L2:
	return 0;
}
