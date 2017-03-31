import assert from "assert";

import {loginAdmin} from "./support/session";
import {randomString} from "./support/random";

describe("managing users", () => {
  before(loginAdmin);

  it("allows adding a user", () => {
    const name = randomString();
    const password = randomString();

    browser.url("/admin/users");
    browser.click("*=Add user");
    browser.waitUntil(() => browser.getSource().includes("New user"));

    browser.setValue("#user_email", `some.email+${name}@aircloak.com`);
    browser.setValue("#user_name", name);
    browser.setValue("#user_password", password);
    browser.setValue("#user_password_confirmation", password);
    browser.click("input[value='Save']");

    browser.waitUntil(() => browser.isExisting(".alert-info*=User created"));
    assert(browser.getSource().includes(name));
  });
});
