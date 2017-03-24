import assert from "assert";

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

describe("login", () => {
  it("shows a message for incorrect login info", () => {
    browser.url("/auth");
    browser.setValue("[name='email']", "no.such@person.org");
    browser.setValue("[name='password']", "1234");
    browser.click("form button");

    browser.waitForText(".alert-danger", "Invalid e-mail or password.");
    assert(browser.getUrl().endsWith("/auth"));
  });
});
