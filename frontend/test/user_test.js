import assert from "assert";

import {loginAdmin} from "../support/session";
import {randomString} from "../support/random";
import {createUser} from "../support/user";

describe("managing users", () => {
  before(loginAdmin);

  it("allows adding a user", () => {
    const name = randomString();
    const password = randomString();

    browser.url("/admin/users");
    browser.click("*=Add a user");
    browser.waitUntil(() => browser.getSource().includes("New user"));

    browser.setValue("#user_email", `some.email+${name}@aircloak.com`);
    browser.setValue("#user_name", name);
    browser.setValue("#user_password", password);
    browser.setValue("#user_password_confirmation", password);
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
    browser.element(`tr*=${name}`).click("a*=Delete");
    browser.alertAccept();
    browser.waitUntil(() => browser.getSource().includes("User deleted"));

    assert.equal(browser.getSource().includes(name), false);
  });
});
