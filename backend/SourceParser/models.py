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
            return [html]

    @staticmethod
    def parse_twitter(html):
        soup = BeautifulSoup(html, 'html.parser')
        tweet_texts_html = soup.find_all("div", "tweet-text")
        tweet_texts = []
        for tweet in tweet_texts_html:
            tweet_texts.append(tweet.get_text().encode('utf-8').strip())
        return tweet_texts

    @staticmethod
    def parse_fb(html):
        soup = BeautifulSoup(html, 'html.parser')
        texts = soup.find_all("p")
        posts = []
        for text in texts:
            plain_text = text.get_text()
            word_count = len(plain_text.split().encode('utf-8').strip())
            if word_count > 7:
                posts.append(plain_text)
        return posts
