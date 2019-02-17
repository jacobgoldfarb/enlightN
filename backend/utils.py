import json

from google.appengine.ext import db


def fetch_gql(query_string, fetchsize=50):
    q = db.GqlQuery(query_string)
    cursor = None
    results = []
    while True:
        q.with_cursor(cursor)
        intermediate_result = q.fetch(fetchsize)
        if len(intermediate_result) == 0:
            break
        cursor = q.cursor()
        results += intermediate_result

    return results


def parse_json(s):
    try:
        s_json = json.loads(s)
        return s_json
    except (TypeError, ValueError):
        return {}

