import assert from "assert";

import {admin} from "../config.json";
import {logout} from "../support/session"

describe("login", () => {
  it("shows a message for incorrect login info", () => {
    browser.url("/auth");
    browser.setValue("[name='login']", "no.such@person.org");
    browser.setValue("[name='password']", "1234");
    browser.click("form button");

    browser.waitUntil(() => browser.getSource().includes("Invalid e-mail or password."));
    assert(browser.getUrl().endsWith("/auth"));
  });

  it("allows login for correct login info", () => {
    browser.url("/auth");
    browser.setValue("[name='login']", admin.login);
    browser.setValue("[name='password']", admin.password);
    browser.click("form button");

    browser.waitUntil(() => browser.getSource().includes("Sign out"));
  });

  it("remembers the user", () => {
    logout();
    browser.url("/auth");
    browser.setValue("[name='login']", admin.login);
    browser.setValue("[name='password']", admin.password);
    browser.click("[name='remember']");
    browser.click("form button");
    browser.waitUntil(() => browser.getSource().includes("Sign out"));

    browser.deleteCookie("_air_key");
    browser.newWindow("/");
    assert(browser.getSource().includes("Sign out"));
  });
});
