import StringIO
import csv
import json
import logging
import traceback

import webapp2

from .models import SourceInfo


class SourceInfoHandler(webapp2.RequestHandler):
    def upload(self):
        self.response.headers['Content-Type'] = "application/json"
        self.response.headers['Access-Control-Allow-Origin'] = '*'

        try:
            csv_file = self.request.get('csv_file', '')
            csv_reader = csv.reader(StringIO.StringIO(csv_file))
            for row in csv_reader:
                if row[0].startswith('.'):
                    domain = row[0]
                    host_name = row[0]
                else:
                    domain = ''
                    host_name = row[0]
                if row[4] == '0':
                    credibility_status = 'false'
                elif row[4] == '1':
                    credibility_status = 'true'
                else:
                    continue
                tags = ', '.join([x for x in row[1:4] if x])
                SourceInfo().create(
                    host_name=host_name.lower().strip(),
                    domain=domain.lower().strip(),
                    credibility_status=credibility_status.lower().strip(),
                    tags=tags.lower().strip()
                )

            self.response.out.write(json.dumps({'success': True, 'error': [], 'response': None}))
        except Exception as e:
            self.response.out.write(json.dumps({'success': False, 'error': e.message, 'response': None}))
            logging.error(traceback.format_exc())
