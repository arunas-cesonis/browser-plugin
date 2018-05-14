'use strict';

exports.onActivated = function (sub) {
  var cb = function (obj) {
    sub({
      tabId: obj.tabId,
    })
  }
  browser.tabs.onActivated.addListener(sub)
  return function () {
    browser.tabs.onActivated.removeListener(sub)
  }
};

exports.onUpdated = function (sub) {
  var cb = function (tabId) {
    sub(tabId)
  }
  browser.tabs.onUpdated.addListener(cb)
  return function () {
    browser.tabs.onUpdated.removeListener(cb)
  }
};

exports.getTabImpl = function (just) {
  return function (nothing) {
    return function (tabId) {
      return browser.tabs.get(tabId).then(function (obj) {
        return {
          active: obj.active,
          windowId: obj.windowId,
          url: typeof obj.url === 'string' ? just(obj.url) : nothing
        }
      })
    }
  }
}
