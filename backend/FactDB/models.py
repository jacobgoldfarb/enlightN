import requests
import json
from bs4 import BeautifulSoup


class Snopes(object):
    def __init__(self):
        pass

    def search(self, searchString):
        articleLink = self.getFirstArticleLink(searchString)
        if (articleLink):
            return self.parseArticleInformation(articleLink)
        return None

    @staticmethod
    def getFirstArticleLink(searchString):
        URL = "https://yfrdx308zd-dsn.algolia.net/1/indexes/*/queries"
        PARAMS = {
            'x-algolia-agent': 'Algolia for vanilla JavaScript (lite) 3.21.1;instantsearch.js 1.11.15;JS Helper 2.19.0',
            'x-algolia-application-id': 'YFRDX308ZD',
            'x-algolia-api-key': '7da15c5275374261c3a4bdab2ce5d321',
        }
        body = {"requests": [{"indexName": "wp_live_searchable_posts", "params": ""}]}
        searchString = searchString.lower()
        fullQueryString = "query=" + searchString + '&hitsPerPage=10&page=0&highlightPreTag=__ais-highlight__&highlightPostTag=__/ais-highlight__&facetingAfterDistinct=true&facets=["taxonomies_hierarchical.category.lvl0","post_author.display_name","post_date"]&tagFilters='
        body['requests'][0]['params'] = fullQueryString
        response = requests.post(url=URL, params=PARAMS, json=body)
        res_json = json.loads(response.text)
        i = 0
        while i < len(res_json['results'][0]['hits']):
            if 'fact-check' in res_json['results'][0]['hits'][i]['permalink']:
                return res_json['results'][0]['hits'][i]['permalink']
            i += 1
        return None

    @staticmethod
    def parseArticleInformation(url):
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        claimText = soup.find("p","claim").get_text()
        ratingText = soup.find("span","rating-name").get_text()
        postBodyCardSoup = soup.find("div",{"class": "post-body-card"})
        cardBodySoup = postBodyCardSoup.find("div", class_="card-body")
        paragraphSoup = cardBodySoup.find_all("p")
        originString = ""
        for p in paragraphSoup:
            originString = originString + p.get_text() + " "
        articleData = {
            'fact_check_url': url,
            'claim': claimText,
            'rating': ratingText,
            'origin': originString
        }
        return articleData

