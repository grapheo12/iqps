# Adding User Defined Functions to MariaDB docker

This repo builds a MariaDB image which contains a user-defined function written in C++.

The function demo `bitap` takes in a string as its only argument and returns an integer.

To change the function, modify `mariadb.hpp` and `bitap.cpp`.
You may also rename `bitap.cpp` to your liking. Then you also need to modify `Makefile`.

To build the image, run `make`.

An image by the name `mariadb-udf` will be created.
This image will load the user-defined function on its startup.

For a comprehensive tutorial on how to create a user-defined function, follow:
[https://www.oreilly.com/library/view/mysql-reference-manual/0596002653/ch09s02.html](https://www.oreilly.com/library/view/mysql-reference-manual/0596002653/ch09s02.html)