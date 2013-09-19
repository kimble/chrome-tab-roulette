
window.validTabListener = (errorSink, onValidTab) ->
    (tab) ->
        if not tab then errorSink("no-tab")
        else if !tab.id || tab.id < 0 then errorSink("invalid-tab-id")
        else
            try
                onValidTab tab
            catch ex
                errorSink ex

window.determineNextTab = (tab) ->
    (asyncCallback) ->
        firstMatchingTab = (tabs, offset) ->
            for i in [offset..tabs.length] by 1
                return tabs[i] if cycleableTab(tabs[i])

            return undefined

        indexOf = (targetTab, tabs) ->
            for t, index in tabs
                return index if t.windowId == targetTab.windowId && t.id == targetTab.id

            return -1

        chrome.tabs.query windowId: tab.windowId, (windowTabs) ->
            tabIndex = indexOf(tab, windowTabs)
            selectedTab = undefined

            if tabIndex >= 0 and tabIndex < windowTabs.length - 1
                selectedTab = firstMatchingTab windowTabs, tabIndex + 1

            if not selectedTab
                selectedTab = firstMatchingTab windowTabs, 0

            if selectedTab then asyncCallback(null, selectedTab) else asyncCallback("no-tab")


window.cyclableTabsInWindow = (windowId, callback) ->
    chrome.tabs.query windowId: windowId, (windowTabs) ->
        callback windowTabs.filter(cycleableTab)

window.activateTab = (tab) ->
    (asyncCallback) ->
        chrome.tabs.update tab.id, { active: true }, ->
            asyncCallback(null)

window.determineCurrentTab = (asyncCallback) ->
    chrome.tabs.getCurrent (currentTab) ->
        asyncCallback(null, currentTab)

window.reload = (tab) ->
    chrome.tabs.reload tab.id, { }

window.findNeighbouringCyclableTabs = (windowId) ->
    (asyncCallback) ->
        cyclableTabsInWindow windowId, (matchedTabs) ->
            asyncCallback(null, matchedTabs)

window.takeScreenshotOf = (windowId) ->
    (asyncCallback) ->
        chrome.tabs.captureVisibleTab windowId, { }, (imageUri) ->
            asyncCallback null, imageUri