# AVL trees

Reference implementation of AVL trees in C++, used in the course
"[Programming Techniques](https://courses.softlab.ntua.gr/)" at the
[School of Electrical and Computer Engineering](https://www.ece.ntua.gr/)
of the [National Technical University of Athens](https://www.ntua.gr/).

This implementation is based on the
[C implementation](https://github.com/ebiggers/avl_tree)
written by Eric Biggers \<<ebiggers3@gmail.com>\>.

## Usage

The files you need are:

- `containers.hpp`: defines generic containers and iterators
- `avltree.hpp`: defines AVL trees

See `example.cpp` for a generic example that builds and processes an
AVL tree according to the intructions given in its input.

Run this with our small test suite:

```
make
./test.sh
```

---
Written in 2020 by Nikolaos Papaspyrou \<<nickie@softlab.ntua.gr>\>.
