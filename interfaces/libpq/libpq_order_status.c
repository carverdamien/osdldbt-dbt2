/*
 * This file is released under the terms of the Artistic License.  Please see
 * the file LICENSE, included in this package, for details.
 *
 * Copyright (C) 2002 Mark Wong & Open Source Development Labs, Inc.
 *
 * 13 May 2003
 */

#include <pthread.h>
#include <stdio.h>
#include <postgresql/libpq-fe.h>

#include "common.h"
#include "logging.h"
#include "libpq_order_status.h"

int execute_order_status(PGconn *conn, struct order_status_t *data)
{
	PGresult *res;
	char stmt[128];

	/* Start a transaction block. */
	res = PQexec(conn, "BEGIN");
	if (!res || PQresultStatus(res) != PGRES_COMMAND_OK) {
		LOG_ERROR_MESSAGE("BEGIN command failed.\n");
		PQclear(res);
		return ERROR;
	}
	PQclear(res);

	/* Create the query and execute it. */
	sprintf(stmt, "SELECT stock_level(%d, %d, %d, '%s')",
		data->c_id, data->c_w_id, data->c_d_id, data->c_last);
	res = PQexec(conn, stmt);
	if (!res || PQresultStatus(res) != PGRES_COMMAND_OK) {
		LOG_ERROR_MESSAGE("SELECT failed\n");
		PQclear(res);
		return ERROR;
	}
	PQclear(res);

	/* Commit the transaction. */
	res = PQexec(conn, "COMMIT");
	PQclear(res);

	return OK;
}