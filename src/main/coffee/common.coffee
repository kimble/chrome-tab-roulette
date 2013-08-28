###
    Code and configuration shared between background and content script
###




# Predicates

urlMatching = (regex) ->
    (tab) ->
        regex.test(tab.url)

window.cycleableTabPredicate = urlMatching(/^(http|file)/)


# Tab functions

window.selectTab = (tab, callback) ->
    chrome.tabs.update tab.id, { active: true }, callback