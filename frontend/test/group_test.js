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
    browser.setValue("#group_name", name);
    browser.click("input[value='Add group']");

    browser.waitUntil(() => browser.getSource().includes("Group created"));
    assert(browser.isExisting(`h2*=Edit ${name}`));
    browser.url("/admin/groups");
    assert(browser.isExisting(`tr*=${name}`));
  });

  it("allows removing a group", () => {
    const {name} = createGroup();

    browser.url("/admin/groups");
    browser.element(`tr*=${name}`).click("a*=Delete");
    browser.waitUntil(() => browser.getSource().includes("Group deleted"));

    browser.url("/admin/groups");
    assert.equal(browser.getSource().includes(name), false);
  });

  it("allowing access to a data source through a group", () => {
    const {name: groupName} = createGroup();
    const {name: userName} = createUser();

    editGroup(groupName);
    browser.element(`tr*=${userName}`).click("input[type='checkbox']");
    browser.element("tr*=nyctaxi").click("input[type='checkbox']");
    browser.click("input[value='Update group']");
    browser.waitUntil(() => browser.getSource().includes("Group updated"));

    showDataSource("nyctaxi");
    assert(browser.element(".panel*=Users with access").isExisting(`tr*=${userName}`))
    assert(browser.element(".panel*=Groups granting access").isExisting(`tr*=${groupName}`))
  });
});
