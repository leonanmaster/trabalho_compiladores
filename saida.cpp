#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;

int main(void) {
	char* t1;
	int t2;
	char t3[256];
	int t4;
	int t5;
	char t6;
	int t7;
	char t8;
	char t9;
	char* t10;

	cin >> t2;
	cin >> ws;
	cin.getline(t3, 256);
	t4 = 0;
L1:
	t6 = t3[t4];
	t7 = t6 == '\0';
	if (t7) goto L2;
	t4 = t4 + 1;
	goto L1;
L2:
	t5 = t4 + 1;
	t1 = (char*) malloc(t5);
	strcpy(t1, t3);
	cout << t1;
	t9 = 'n';
	t8 = t9;
	t10 = (char*) malloc(7);
	strcpy(t10, "quebra");
	cout << t10;
	return 0;
}
