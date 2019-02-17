import json
import logging
import traceback

import webapp2

from .models import Verification


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
            response = Verification().check(
                html=html,
                url=url
            )

            self.response.out.write(json.dumps({'success': True, 'error': [], 'response': response}))
        except Exception as e:
            self.response.out.write(json.dumps({'success': False, 'error': e.message, 'response': None}))
            logging.error(traceback.format_exc())
