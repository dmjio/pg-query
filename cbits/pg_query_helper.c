#include <pg_query.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

PgQueryParseResult * get_sql (const char * sql) {
  PgQueryParseResult * result = malloc (sizeof (PgQueryParseResult));
  *result = pg_query_parse(sql);
  return result;
}

void free_sql (PgQueryParseResult * a) {
  pg_query_free_parse_result(*a);
  free (a);
  return;
}

