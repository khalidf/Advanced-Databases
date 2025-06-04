#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Yap/YapInterface.h>
#include <libpq-fe.h>

static PGconn *conn = NULL;

void init_db() {
    if (conn == NULL) {
        conn = PQconnectdb("dbname=tetris user=fatima");
        if (PQstatus(conn) != CONNECTION_OK) {
            fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conn));
            PQfinish(conn);
            exit(1);
        }
    }
}

static YAP_Bool db_call(void) {
    init_db();

    YAP_Term sql_term = YAP_ARG1;
    YAP_Term result_term = YAP_ARG2;

    if (!YAP_IsAtomTerm(sql_term)) {
        fprintf(stderr, "Expected atom as SQL query.\n");
        return false;
    }

    const char *sql = YAP_AtomName(YAP_AtomOfTerm(sql_term));
    PGresult *res = PQexec(conn, sql);

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s\n", PQerrorMessage(conn));
        PQclear(res);
        return false;
    }

    if (PQntuples(res) < 1 || PQnfields(res) < 1) {
        PQclear(res);
        return false;
    }

    char *value = PQgetvalue(res, 0, 0);
    YAP_Term result = YAP_MkAtomTerm(YAP_LookupAtom(value));
    PQclear(res);
    return YAP_Unify(result_term, result);
}

static YAP_Bool bounding_box(void) {
    init_db();

    YAP_Term wkt_term = YAP_ARG1;
    YAP_Term bbox_term = YAP_ARG2;

    if (!YAP_IsAtomTerm(wkt_term)) {
        fprintf(stderr, "Expected atom as WKT polygon\n");
        return FALSE;
    }

    const char *wkt = YAP_AtomName(YAP_AtomOfTerm(wkt_term));

    char sql[1024];
    snprintf(sql, sizeof(sql),
        "SELECT ST_XMin(geom), ST_YMin(geom), ST_XMax(geom), ST_YMax(geom) "
        "FROM (SELECT ST_GeomFromText('%s') AS geom) AS foo;", wkt);

    PGresult *res = PQexec(conn, sql);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s\n", PQerrorMessage(conn));
        PQclear(res);
        return FALSE;
    }

    if (PQntuples(res) < 1 || PQnfields(res) < 4) {
        PQclear(res);
        return FALSE;
    }

    // Extract coordinates as strings
    char *xmin_str = PQgetvalue(res, 0, 0);
    char *ymin_str = PQgetvalue(res, 0, 1);
    char *xmax_str = PQgetvalue(res, 0, 2);
    char *ymax_str = PQgetvalue(res, 0, 3);

    // Convert strings to doubles
    double xmin = atof(xmin_str);
    double ymin = atof(ymin_str);
    double xmax = atof(xmax_str);
    double ymax = atof(ymax_str);

    PQclear(res);

    // Create YAP float terms
    YAP_Term xmin_term = YAP_MkFloatTerm(xmin);
    YAP_Term ymin_term = YAP_MkFloatTerm(ymin);
    YAP_Term xmax_term = YAP_MkFloatTerm(xmax);
    YAP_Term ymax_term = YAP_MkFloatTerm(ymax);

    // Create functor bbox/4
    YAP_Functor bbox_functor = YAP_MkFunctor(YAP_LookupAtom("bbox"), 4);

    // Build compound term bbox(Xmin,Ymin,Xmax,Ymax)
    YAP_Term args[4] = { xmin_term, ymin_term, xmax_term, ymax_term };
    YAP_Term bbox_compound = YAP_MkApplTerm(bbox_functor, 4, args);

    // Unify output argument with bbox compound
    return YAP_Unify(bbox_term, bbox_compound);
}


void init_my_predicates(void) {
    YAP_UserCPredicate("db_call", db_call, 2);
    YAP_UserCPredicate("bounding_box", bounding_box, 2);
}
