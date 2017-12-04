import {randomString} from "./random";

export const createGroup = () => {
  const name = randomString();

  browser.url("/admin/groups/new");
  browser.setValue("#group_name", name);
  browser.click("button*=Save group");
  browser.waitUntil(() => browser.getSource().includes("Group created"));

  return {name};
};

export const editGroup = (name) => {
  browser.url("/admin/groups");
  browser.element(`tr*=${name}`).click("a*=Edit");
  browser.waitUntil(() => browser.getSource().includes(`Edit ${name}`));
};
