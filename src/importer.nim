import std / [json, times, cmdline]
import ./database

proc parseTime(time: string): DateTime =
    parse(time, "yyyyMMdd'T'HHmmssZZZ")

proc parseEvents*(file: string): seq[Event] =
    let data = parseFile(file)
    for entry in data:
        for segment in entry["segments"]:
            case segment["type"].getStr()
            of "place":
                result.add Event(
                    created_at: parseTime(segment["startTime"].getStr()),
                    lat: segment["place"]["location"]["lat"].getFloat(),
                    lon: segment["place"]["location"]["lon"].getFloat()
                )
            of "move":
                for activity in segment["activities"]:
                    for trackPoint in activity["trackPoints"]:
                        result.add Event(
                            created_at: parseTime(trackPoint["time"].getStr()),
                            lat: trackPoint["lat"].getFloat(),
                            lon: trackPoint["lon"].getFloat()
                        )
            else: discard

proc importEvents*(db: DbConn, events: seq[Event]) =
    for event in events:
        db.insert(event)

when isMainModule:
    let db = setupDb("db/")
    let events = parseEvents(paramStr(1))
    for i, event in events:
        if i mod 10 == 0:
            stdout.write("\r" & $i & "/" & $events.len)
            stdout.flushFile()
        try:
            db.insert(event)
        except: discard
