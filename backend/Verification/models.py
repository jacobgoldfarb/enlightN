import logging
import traceback
import urlparse
from difflib import SequenceMatcher

from FactDB import Snopes
from Hoaxy import Hoaxy
from SourceInfo.models import SourceInfo
from SourceParser.models import SourceParser


class Verification(object):
    def __init__(self):
        self.hoaxy_api = Hoaxy('f0bb13af68msh9e496658bcbcd5bp1714cejsn467253fb2ebe')

    def check(self, **data):
        result = []
        html = data['html']
        url = data['url']
        domain_name = urlparse.urlparse(url).hostname
        list_texts = SourceParser().parse(html, url)
        for text in list_texts:
            res = {}
            try:
                snopes = Snopes()
                snope_res = snopes.search(text)
                if snope_res:
                    res = {
                        'tags': [snope_res['rating'].lower()],
                        'description': "{}\n\n{}".format(snope_res['fact_check_url'], snope_res['origin'].encode('utf-8')),
                    }
            except:
                logging.error(traceback.format_exc())

            hoaxy_articles = self.hoaxy_api.articles(query=text)
            if hoaxy_articles:
                hoaxy_url = hoaxy_articles[0]['canonical_url']
                title = hoaxy_articles[0]['title']
                if self.similarity(text, title) > 0.5:
                    source_verification = self.verify_source(hoaxy_url)
                    if source_verification:
                        if not res:
                            res = source_verification
                        else:
                            res['tags'] += source_verification['tags']
                    if not res:
                        res = {
                            'tags': ['unreliable source']
                        }

            if res:
                res.update({'text': text})
                if 'description' not in res:
                    res.update({'description': ''})
                result.append(res)

        source_verification = self.verify_source(url)
        if source_verification:
            print source_verification
            result.append({
                'tags': source_verification['tags'],
                'description': "The website you're visiting is known to be spreading disinformation."
            })

        return {'domain': domain_name, 'url': url, 'results': result}

    def verify_source(self, url):
        host_name = urlparse.urlparse(url).hostname
        if host_name:
            host_name_search = SourceInfo.read(host_name=host_name)
            if host_name_search:
                if host_name_search[0].credibility_status == 'false':
                    return {
                        'tags': host_name_search[0].tags.split(', '),
                    }

            host_parts = host_name.split('.')
            n = len(host_parts) - 1
            while n > 0:
                domain = '.'.join(host_parts[n:])
                domain_search = SourceInfo.read(host_name=domain) or SourceInfo.read(domain='.'+domain)
                if domain_search:
                    if domain_search[0].credibility_status == 'false':
                        return {
                            'tags': domain_search[0].tags.split(', '),
                        }
                n -= 1
        return None

    @staticmethod
    def similarity(a, b):
        return SequenceMatcher(None, a, b).ratio()

