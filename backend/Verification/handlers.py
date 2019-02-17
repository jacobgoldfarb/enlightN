import json
import logging
import traceback
import urlparse

import webapp2

from .models import Verification
from memcacheWrapper import memcachePlus


class VerificationHandler(webapp2.RequestHandler):
    def check(self):
        self.response.headers['Content-Type'] = "application/json"
        self.response.headers['Access-Control-Allow-Origin'] = '*'

        try:
            try:
                body = json.loads(self.request.body)
                html = body['html']
                url = body['url']
            except:
                html = self.request.get('html', '')
                url = self.request.get('url', '')

            response = []
            parse_url = urlparse.urlparse(url)

            host_name = "{}{}".format(parse_url.hostname, parse_url.path)
            if host_name:
                cached_results = memcachePlus.get_multipart(host_name)
                if cached_results:
                    response = json.loads(cached_results)

            if not response:
                response = Verification().check(
                    html=html,
                    url=url
                )
                memcachePlus.set_multipart(host_name, json.dumps(response), 10*60*3600)

            self.response.out.write(json.dumps({'success': True, 'error': [], 'response': response}))
        except Exception as e:
            self.response.out.write(json.dumps({'success': False, 'error': e.message, 'response': None}))
            logging.error(traceback.format_exc())
