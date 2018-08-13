import assert from "assert";

import {loginAdmin} from "../support/session";
import {randomString} from "../support/random";
import {createUser} from "../support/user";

describe("managing users", () => {
  before(loginAdmin);

  it("allows adding a user", () => {
    const name = randomString();

    browser.url("/admin/users");
    browser.click("*=Add a user");
    browser.waitUntil(() => browser.getSource().includes("New user"));

    browser.setValue("#user_login", `some.login+${name}@aircloak.com`);
    browser.setValue("#user_name", name);
    browser.click("button*=Save");

    browser.waitUntil(() => browser.isExisting(".alert-info*=User created"));
    assert(browser.getSource().includes(name));
  });

  it("displays errors when adding a user", () => {
    const name = randomString();

    browser.url("/admin/users");
    browser.click("*=Add a user");
    browser.waitUntil(() => browser.getSource().includes("New user"));

    browser.setValue("#user_name", name);
    browser.click("button*=Save");

    browser.waitUntil(() => browser.getSource().includes("Please check the errors below"));
    assert(browser.getSource().includes("can't be blank"));
    browser.url("/admin/users");
    assert.equal(browser.getSource().includes(name), false);
  });

  it("allows removing a user", () => {
    const {name} = createUser();

    browser.url("/admin/users");
    browser.element(`tr*=${name}`).click("a*=Permanently delete");
    browser.alertAccept();
    browser.waitUntil(() => browser.getSource().includes("The deletion will be performed in the background"));
    browser.refresh();

    assert.equal(browser.getSource().includes(name), false);
  });

  it("allows disabling and enabling a user", () => {
    const {name} = createUser();
    const matchString = "Disabled user accounts";

    browser.url("/admin/users");
    browser.element(`tr*=${name}`).click("a*=Disable");
    browser.waitUntil(() => browser.getSource().includes(matchString));

    browser.element(`tr*=${name}`).click("a*=Enable");
    assert.equal(browser.getSource().includes(matchString), false);
  });
});
