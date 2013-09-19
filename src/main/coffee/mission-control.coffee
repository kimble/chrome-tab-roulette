iterate = (entries, doneCallback, entryCallback) =>
    if entries.length > 0
        entryCallback entries[0], =>
            iterate entries[1..], doneCallback, entryCallback
    else
        doneCallback()


window.TabController = ($scope) ->
    $scope.tabs = []
    $scope.updateSettings = (tab) -> tab.settings.flush()
    $scope.gotoTab = (tab) -> selectTab tab

    updateScope = (tab, settings, imageUrl) ->
        $scope.$apply ->
            tab.settings = settings
            tab.imageUrl = imageUrl
            $scope.tabs.push tab

    # Kick everything of
    withCurrentTab (currentTab) ->
        anyTabsInWindowMatching currentTab.windowId, cycleableTab, (matchedTabs) ->
            whenDoneIterating = -> selectTab(currentTab)
            iterate matchedTabs, whenDoneIterating, (tab, progress) ->

                selectTab tab, ->
                    withSettingsFor tab, (settings) ->
                        withScreenshot tab, (imageUri) ->
                            updateScope(tab, settings, imageUri)
                            progress()


    # Listens for closed tabs
    chrome.tabs.onRemoved.addListener (tabId) =>
        $scope.$apply =>
            $scope.tabs = _.filter $scope.tabs, (e) -> e.id != tabId


###
    Chrome helper functions
###

withCurrentTab = (callback) ->
    chrome.tabs.getCurrent (current) => callback current

selectTab = (tab, callback) ->
    chrome.tabs.update tab.id, { active: true }, callback

forNewTabsInWindow = (windowId, callback) ->
    chrome.tabs.onCreated.addListener (newTab) =>
        if windowId == newTab.windowId
            callback newTab

anyTabsInWindowMatching = (windowId, predicate, callback) ->
    withAllTabsInWindow windowId, (tabs) ->
        callback _.filter tabs, predicate

withAllTabsInWindow = (windowId, callback) ->
    chrome.tabs.query { windowId: windowId }, callback

withScreenshot = (subjectTab, callback) ->
    chrome.tabs.captureVisibleTab subjectTab.windowId, { }, callback

