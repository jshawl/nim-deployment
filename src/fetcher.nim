import httpclient, os

type
  HttpGetProc* = proc(url: string): string {.closure.}
  
  DataFetcher* = ref object
    httpGet*: HttpGetProc
    url*: string

proc newDataFetcher*(httpGet: HttpGetProc, url: string): DataFetcher =
  DataFetcher(httpGet: httpGet, url: url)

proc fetchData*(f: DataFetcher): string =
  f.httpGet(f.url)

proc realHttpGet*(url: string): string =
  newHttpClient().getContent(url)

when isMainModule:
  let baseUrl: string = os.getEnv("BASE_URL")
  let fetcher: DataFetcher = newDataFetcher(realHttpGet, baseUrl)
  let result = fetchData(fetcher)
  echo result