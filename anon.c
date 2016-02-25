#include <time.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <stdio.h>

/* This program shows how fast len_annon can be reclaimed */

// Params
size_t len_annon = 0;
time_t loop_for = 0;

void* mem_annon = NULL;

int main(int argc, char const *argv[])
{
	time_t begin=0, finish=0;
	unsigned a = 1;
	size_t i;
	len_annon = atol(argv[a++]);
	loop_for = atol(argv[a++]);

	printf("# Params: len_annon=%ld loop_for=%ld\n", len_annon, loop_for);
	begin = time(NULL);
	mem_annon = mmap(NULL, len_annon, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, 0, 0);
	for(i=0; i<len_annon; i++)
		((char*)mem_annon)[i] = (char)i;
	finish = time(NULL);
	printf("BEGIN,END,BYTES/SEC\n");
	printf("%ld,%ld,%f\n", begin, finish, (double)len_annon/(double)(finish - begin));
	while(time(NULL)-begin<loop_for) {
		for(i=0; i<len_annon; i++)
			((char*)mem_annon)[i]++;
	}
	munmap(mem_annon, len_annon);
	return 0;
}
