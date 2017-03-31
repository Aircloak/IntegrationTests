import assert from "assert";

import {loginAdmin} from "./support/session";
import {randomString} from "./support/random";
import {createGroup} from "./support/group";

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
});
