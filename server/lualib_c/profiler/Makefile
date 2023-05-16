all: test.out

test.out: test.cc luaprofiler.cc
	g++ -g -pthread -lrt $^ -o $@

clean:
	rm test.out