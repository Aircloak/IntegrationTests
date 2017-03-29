import assert from "assert";

import {admin} from "../config.json";

describe("login", () => {
  it("shows a message for incorrect login info", () => {
    browser.url("/auth");
    browser.setValue("[name='email']", "no.such@person.org");
    browser.setValue("[name='password']", "1234");
    browser.click("form button");

    browser.waitForText(".alert-danger", "Invalid e-mail or password.");
    assert(browser.getUrl().endsWith("/auth"));
  });

  it("allows login for correct login info", () => {
    browser.url("/auth");
    browser.setValue("[name='email']", admin.email);
    browser.setValue("[name='password']", admin.password);
    browser.click("form button");

    browser.waitForText(".alert-info", "Logged in successfully.");
  });
});
