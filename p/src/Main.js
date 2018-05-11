'use strict';

exports.onActivated = function (sub) {
  var cb = function (obj) {
    sub({
      tabId: obj.tabId,
      windowId: obj.windowId
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
