#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>

void fetch_tetrominoes(PGconn *conn, FILE *outFile) {
    PGresult *res = PQexec(conn, "SELECT letter FROM tetrominoes;");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "SELECT tetrominoes failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        exit(1);
    }

    fprintf(outFile, "%% Tetromino facts\n");
    int rows = PQntuples(res);
    for (int i = 0; i < rows; i++) {
        fprintf(outFile, "tetromino('%s').\n", PQgetvalue(res, i, 0));
    }

    PQclear(res);
}

void fetch_puzzles(PGconn *conn, FILE *outFile) {
    PGresult *res = PQexec(conn, "SELECT id, ST_AsText(board) FROM puzzles;");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "SELECT puzzles failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        exit(1);
    }

    fprintf(outFile, "\n%% Puzzle facts\n");
    int rows = PQntuples(res);
    for (int i = 0; i < rows; i++) {
        fprintf(outFile, "puzzle(%s, '%s').\n",
                PQgetvalue(res, i, 0),
                PQgetvalue(res, i, 1));
    }

    PQclear(res);
}

int main() {
    PGconn *conn = PQconnectdb("dbname=tetris user=barbara");

    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection failed: %s", PQerrorMessage(conn));
        PQfinish(conn);
        return 1;
    }

    FILE *outFile = fopen("tetromino_data.yap", "w");
    if (outFile == NULL) {
        fprintf(stderr, "Could not open output file.\n");
        PQfinish(conn);
        return 1;
    }

    fetch_tetrominoes(conn, outFile);
    fetch_puzzles(conn, outFile);

    fclose(outFile);
    PQfinish(conn);
    return 0;
}
