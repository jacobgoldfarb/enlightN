import urlparse
from difflib import SequenceMatcher

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
            hoaxy_articles = self.hoaxy_api.articles(query=text)
            if hoaxy_articles:
                hoaxy_url = hoaxy_articles[0]['canonical_url']
                title = hoaxy_articles[0]['title']
                if self.similarity(text, title) > 0.5:
                    source_verification = self.verify_source(hoaxy_url)
                    if source_verification:
                        source_verification.update({'text':text})
                        result.append(source_verification)
                else:
                    # ToDo Snopes check
                    pass
        return {'domain': domain_name, 'url': url, 'results': result}

    def verify_source(self, url):
        host_name = urlparse.urlparse(url).hostname
        host_name_search = SourceInfo.read(host_name=host_name)
        if host_name_search:
            if host_name_search[0].credibility_status == 'false':
                return {
                    'tags': host_name_search[0].tags.split(', '),
                    'description': ''
                }

        host_parts = host_name.split('.')
        n = len(host_parts) - 1
        while n > 0:
            domain = '.'.join(host_parts[n:])
            domain_search = SourceInfo.read(domain=domain)
            if domain_search:
                if domain_search[0].credibility_status == 'false':
                    return {
                        'tags': domain_search[0].tags.split(', '),
                        'description': ''
                    }
            n -= 1
        return None

    @staticmethod
    def similarity(a, b):
        return SequenceMatcher(None, a, b).ratio()

