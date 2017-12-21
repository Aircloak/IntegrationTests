import {editGroup, createGroup} from "./group";

export const showDataSource = (name) => {
  browser.url("/admin/data_sources");
  browser.element(`tr*=${name}`).click("a*=Show");
  browser.waitUntil(() => browser.getSource().includes("Cloaks hosting data source"));
};

export const allowDataSource = (user, dataSourceName) => {
  const {name: groupName} = createGroup();

  editGroup(groupName);
  browser.element(`tr*=${user.name}`).click("input[type='checkbox']");
  browser.element(`tr*=${dataSourceName}`).click("input[type='checkbox']");
  browser.click("button*=Save group");
  browser.waitUntil(() => browser.getSource().includes("Group updated"));
};

export const queryDataSource = (name) => {
  browser.url("/data_sources");
  browser.click(`a*=${name}`);
  browser.waitUntil(() => browser.getSource().includes("Tables and views"));
};
