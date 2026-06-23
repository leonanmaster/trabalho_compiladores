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
	int t11;
	int t12;
	int t13;
	int t14;
	int t15;
	int t16;
	int t17;
	int t18;
	int t19;
	int t20;
	int t21;
	int t22;
	int t23;
	int t24;

	t1 = 0;
	t2 = t1;
	t3 = 0;
	t4 = t3;
	t5 = 0;
	t6 = t5;
L1:
	t7 = 10;
	t8 = t2 < t7;
	t24 = !t8;
	if (t24) goto L2;
	t9 = 0;
	t4 = t9;
L3:
	t10 = 10;
	t11 = t4 < t10;
	t21 = !t11;
	if (t21) goto L4;
	t12 = 0;
	t6 = t12;
L5:
	t13 = 10;
	t14 = t6 < t13;
	t20 = !t14;
	if (t20) goto L6;
	t15 = 1;
	t16 = t6 + t15;
	t6 = t16;
	cout << t6;
	t17 = 2;
	t18 = t6 == t17;
	t19 = !t18;
	if (t19) goto L7;
	goto L4;
L7:
	goto L5;
L6:
	goto L3;
L4:
	t22 = 1;
	t23 = t2 + t22;
	t2 = t23;
	goto L1;
L2:
	return 0;
}
