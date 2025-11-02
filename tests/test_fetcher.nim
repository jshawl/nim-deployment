import ../src/fetcher
import unittest

proc mockGet(url: string): string = readFile("tests/response.json")

test "fetchData works":
  let fetcher = DataFetcher(httpGet: mockGet, url: "http://test")
  check fetcher.fetchData() == "{ \"status\": \"ok\" }\n"