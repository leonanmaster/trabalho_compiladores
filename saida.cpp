/*Compilador FOCA*/
#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;

int main(void) {
	int t1;
	int t2;
	float t3;
	int t4;
	int t5;
	float t6;
	float t7;
	float t8;

	t4 = 2;
	t1 = t4;
	t5 = 5;
	t2 = t5;
	t7 = (float) t1;
	t8 = (float) t2;
	t6 = t7 / t8;
	t3 = t6;
	cout << t3;
	return 0;
}
