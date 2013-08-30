
window.w = window.when


tabUrlMatching = (regex) ->
    (tab) ->
        regex.test(tab.url)

window.cycleableTab = tabUrlMatching(/^(http|file)/)


window.promiseMe = (handler) ->
    deferred = w.defer()
    resolve = (result) -> deferred.resolve result
    reject = (error) -> deferred.reject error

    handler(resolve, reject)
    deferred.promise
