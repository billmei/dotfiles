from string import ascii_lowercase

FILENAME = 'hostsfile.txt'

def reddit():
    entries = [
        'www.reddit.com',
        'reddit.com',
        'old.reddit.com',
        'm.reddit.com',
    ]
    for i in ascii_lowercase:
        for j in ascii_lowercase:
            entries.append(f"{i+j}.reddit.com")
    return entries

entries = [
'news.ycombinator.com',
'www.youtube.com',
'www.facebook.com',
'www.nytimes.com',
'www.wsj.com',
'www.theatlantic.com',
'www.marketwatch.com',
'finance.yahoo.com',
'theverge.com',
'aeon.co',
'twitter.com',
'x.com',
'xcancel.com',
'nitter.poast.org',
'bsky.app',
'www.tiktok.com',
] + reddit()

with open(FILENAME, "a") as f:
    for x in entries:
        f.write(f"0.0.0.0 {x}\n")

