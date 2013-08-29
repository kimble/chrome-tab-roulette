




window.withNextTab = (tab, callback) ->
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

        callback selectedTab


window.cyclableTabsInWindow = (windowId, callback) ->
    chrome.tabs.query windowId: windowId, (windowTabs) ->
        callback windowTabs.filter(cycleableTab)


window.considerReloading = (tab, filter) ->
    withSettingsFor tab, (tabSettings) ->
        chrome.tabs.reload(tab.id) if filter(tab) && tabSettings.reload


window.selectTab = (tab, callback) ->
    chrome.tabs.update tab.id, { active: true }, callback