import assert from "assert";

import {loginAdmin} from "../support/session";
import {randomString} from "../support/random";
import {createUser} from "../support/user";
import {createGroup, editGroup} from "../support/group";
import {showDataSource} from "../support/data_source";

describe("managing groups", () => {
  before(loginAdmin);

  it("allows adding a group", () => {
    const name = randomString();

    browser.url("/admin/groups");
    browser.click("*=Add a group");
    browser.waitUntil(() => browser.getSource().includes("New group"));
    browser.setValue("#group_name", name);
    browser.click("button*=Save group");

    browser.waitUntil(() => browser.getSource().includes("Group created"));
    assert(browser.isExisting(`tr*=${name}`));
  });

  it("allows removing a group", () => {
    const {name} = createGroup();

    browser.url("/admin/groups");
    browser.element(`tr*=${name}`).click("a*=Delete");
    browser.alertAccept();
    browser.waitUntil(() => browser.getSource().includes("Group deleted"));

    browser.url("/admin/groups");
    assert.equal(browser.getSource().includes(name), false);
  });

  it("forbids access to data source by default", () => {
    const {name: userName} = createUser();
    const {name: groupName} = createGroup();

    showDataSource("nyctaxi");
    assert.equal(browser.element(".panel*=Users with access").isExisting(`tr*=${userName}`), false)
    assert.equal(browser.element(".panel*=Groups granting access").isExisting(`tr*=${groupName}`), false)
  });

  it("allowing access to a data source through a group", () => {
    const {name: groupName} = createGroup();
    const {name: userName} = createUser();

    editGroup(groupName);
    browser.element(`tr*=${userName}`).click("input[type='checkbox']");
    browser.element("tr*=nyctaxi").click("input[type='checkbox']");
    browser.click("button*=Save group");
    browser.waitUntil(() => browser.getSource().includes("Group updated"));

    showDataSource("nyctaxi");
    assert(browser.element(".panel*=Users with access").isExisting(`tr*=${userName}`))
    assert(browser.element(".panel*=Groups granting access").isExisting(`tr*=${groupName}`))
  });
});
