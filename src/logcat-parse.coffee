XRegExp = require("xregexp").XRegExp

PATTERNS =
    brief:      XRegExp("^(?<level>[VDIWEAF])\\/(?<tag>[^)]{0,23}?)\\(\\s*(?<pid>\\d+)\\):\\s+(?<message>.*)$"),
    threadtime: XRegExp("^(?<timestamp>\\d\\d-\\d\\d\\s\\d\\d:\\d\\d:\\d\\d\\.\\d+)\\s*(?<pid>\\d+)\\s*(?<tid>\\d+)\\s(?<level>[VDIWEAF])\\s(?<tag>.*?):\\s+(?<message>.*)$"),
    time:       XRegExp("^(?<timestamp>\\d\\d-\\d\\d\\s\\d\\d:\\d\\d:\\d\\d\\.\\d+):*\\s(?<level>[VDIWEAF])\\/(?<tag>.*?)\\((?<pid>\\s*\\d+)\\):\\s+(?<message>.*)$"),
    process:    XRegExp("^(?<level>[VDIWEAF])\\(\\s*(?<pid>\\d+)\\)\\s+(?<message>.*)$"),
    tag:        XRegExp("^(?<level>[VDIWEAF])\\/(?<tag>[^)]{0,23}?):\\s+(?<message>.*)$"),
    thread:     XRegExp("^(?<level>[VDIWEAF])\\(\\s*(?<pid>\\d+):(?<tid>0x.*?)\\)\\s+(?<message>.*)$"),
    ddms_save:  XRegExp("^(?<timestamp>\\d\\d-\\d\\d\\s\\d\\d:\\d\\d:\\d\\d\\.\\d+):*\\s(?<level>VERBOSE|DEBUG|ERROR|WARN|INFO|ASSERT)\\/(?<tag>.*?)\\((?<pid>\\s*\\d+)\\):\\s+(?<message>.*)$"),

LEVELS = # see http://developer.android.com/tools/debugging/debugging-log.html
    V: "verbose" # lowest
    D: "debug"
    I: "info"
    W: "warn"
    E: "error"
    A: "assert"
    F: "fatal"
    S: "silent" # highest, nothing ever printed

get_type = (line) ->
    for type,pattern of PATTERNS
        console.log "trying #{type} - #{pattern}"
        return type if pattern.test(line)
    return null

parse = (contents) ->
    type = null
    badlines = 0
    messages = []
    for line in contents.split "\n"
        do (line) ->
            line = line.replace /\s+$/g, "" # strip any whitespace at the end
            type = get_type line if not type
            if type and line.length > 0 # ignore blank lines
                message = {}
                regex = PATTERNS[type]
                try
                    match = XRegExp.exec line, regex
                    message.level = match.level     if 'level'     in regex.xregexp.captureNames
                    message.timestamp = match.level if 'timestamp' in regex.xregexp.captureNames
                    message.pid = match.pid         if 'pid'       in regex.xregexp.captureNames
                    message.tid = match.tid         if 'tid'       in regex.xregexp.captureNames
                    message.tag = match.tag         if 'tag'       in regex.xregexp.captureNames
                    message.message = match.message if 'message'   in regex.xregexp.captureNames
                    messages.push message
                catch e
                    badlines += 1

    return {type: type, messages: messages, badlines: badlines}

exports.parse = parse
