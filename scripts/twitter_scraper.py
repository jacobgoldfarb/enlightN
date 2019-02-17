from bs4 import BeautifulSoup

def get_tweets(html):
    f = open("twitter.html", 'r')
    html_doc = f.read()
    soup = BeautifulSoup(html_doc, 'html.parser')

    tweetTextsHTML = soup.find_all("div", "tweet-text")
    tweetTexts = []
    for tweet in tweetTextsHTML:
        tweetTexts.append(tweet.get_text())
    return tweetTexts

tweets = get_tweets(html="twitter.html")
for text in tweets:
    print(f"TWEET: {text}")