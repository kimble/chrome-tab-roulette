###
    Code and configuration shared between background and content script
###




# Predicates







### Used
###

window.streamFromCallback = (handler) ->
    bus = new Bacon.Bus
    callback = (val) -> bus.push val
    handler(callback)
    return bus