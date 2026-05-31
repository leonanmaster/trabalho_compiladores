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

	t2 = 0;
	t1 = t2;
L1:
	t3 = 5;
	t4 = t1 < t3;
	t7 = !t4;
	if (t7) goto L2;
	cout << t1;
	t5 = 1;
	t6 = t1 + t5;
	t1 = 1;
	goto L1;
L2:
	return 0;
}
