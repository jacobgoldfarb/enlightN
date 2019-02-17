from bs4 import BeautifulSoup


class SourceParser(object):
    def __init__(self):
        pass

    def parse(self, html, url):
        if 'twitter.com' in url:
            return self.parse_twitter(html)
        elif 'facebook.com' in url:
            return self.parse_fb(html)
        else:
            return self.parse_headlines(html)

    @staticmethod
    def parse_twitter(html):
        soup = BeautifulSoup(html, 'html.parser')
        tweet_texts_html = soup.find_all("div", "tweet-text")
        tweet_texts = []
        for tweet in tweet_texts_html:
            tweet_texts.append(tweet.get_text().encode('ascii', 'ignore').decode('ascii').strip())
        return tweet_texts

    @staticmethod
    def parse_fb(html):
        soup = BeautifulSoup(html, 'html.parser')
        texts = soup.find_all("p")
        posts = []
        for text in texts:
            plain_text = text.get_text().encode('ascii', 'ignore').decode('ascii').strip()
            word_count = len(plain_text.split())
            if word_count > 7:
                posts.append(plain_text)
        return posts

    @staticmethod
    def parse_headlines(html):
        soup = BeautifulSoup(html, 'html.parser')
        headline_html = soup.find_all("h1")
        headline_list = []
        for h in headline_html:
            headline_list.append(h.get_text().encode('ascii', 'ignore').decode('ascii').strip())
        return headline_list
