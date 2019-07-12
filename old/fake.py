#!/usr/bin/env python
# -*- utf-8; -*-

import cfscrape
import sys

if __name__ == "__main__":
  argc=len(sys.argv)
  if argc == 2:
    url=str(sys.argv[1])
    print(url)
    scraper = cfscrape.create_scraper(delay=8)
    print(scraper.get(url).content)
#    cookie_arg, user_agent = cfscrape.get_cookie_string(url)
#    print("\""+cookie_arg+"\""+" "+"\""+user_agent+"\"")
