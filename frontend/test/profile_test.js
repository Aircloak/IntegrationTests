import assert from "assert";

import {randomString} from "./support/random";
import {loginAdmin, login, logout} from "./support/session";
import {createUser} from "./support/user";

describe("profile page", () => {
  before(loginAdmin);

  it("allows resetting password", () => {
    const user = createUser();
    login(user);

    const newPassword = randomString();
    browser.url("/profile/edit");
    browser.setValue("#user_old_password", user.password);
    browser.setValue("#user_password", newPassword);
    browser.setValue("#user_password_confirmation", newPassword);
    browser.click("input[value='Save']");
    browser.waitUntil(() => browser.getSource().includes("Profile updated"));

    logout()
    user.password = newPassword;
    login(user);
    assert(browser.getSource().includes("Sign out"));
  });
});
