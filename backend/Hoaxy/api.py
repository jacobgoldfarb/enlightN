import urllib

from google.appengine.api import urlfetch

import utils


class Hoaxy(object):
    def __init__(self, api_key):
        self.base_api = 'https://api-hoaxy.p.rapidapi.com'
        self.api_key = api_key

    def articles(self, query, sort_by='relevant', use_lucene_syntax='true'):
        api_module = 'articles'
        api_method = 'GET'
        headers = {
            'X-RapidAPI-Key': self.api_key
        }
        query_param = urllib.urlencode({
            'query': query,
            'sort_by': sort_by,
            'use_lucene_syntax': use_lucene_syntax
        })
        result = urlfetch.fetch(
            url="{}/{}?{}".format(
                self.base_api,
                api_module,
                query_param
            ),
            method=api_method,
            headers=headers
        )
        if result.status_code == 200:
            response = utils.parse_json(result.content)
            if api_module in response:
                return response[api_module]
        return None
