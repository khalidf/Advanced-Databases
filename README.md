# TetromineoSolver_ATDB

### C file

- Compile:

`gcc -o pg_bridge pg_bridge.c -I/usr/include/postgresql -lpq`

`gcc -fPIC -shared -o db_call.so db_call.c -I/usr/include/postgresql -I/usr/lib/yap/include -lpq`

- Run:

`./pg_bridge`

### Read files inside Yap

`consult('tetromino_data.yap').`

`consult('predicates.yap').`

`load_foreign_files(['db_call'], [], init_my_predicates).`

