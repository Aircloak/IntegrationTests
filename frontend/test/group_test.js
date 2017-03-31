import assert from "assert";

import {loginAdmin} from "./support/session";
import {randomString} from "./support/random";

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
});
