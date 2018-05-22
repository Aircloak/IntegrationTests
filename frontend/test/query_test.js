import assert from "assert";

import {loginAdmin, login} from "../support/session";
import {createUserWithPassword} from "../support/user";
import {allowDataSource, queryDataSource} from "../support/data_source";

describe("queries", () => {
  before(() => {
    loginAdmin();

    const user = createUserWithPassword();
    allowDataSource(user, "games");
    allowDataSource(user, "nyctaxi");

    login(user);
  });

  it("allows running a query", () => {
    queryDataSource("games");

    browser.element("#sql-editor").keys("SELECT 'hello world' FROM GAMES");
    browser.click("button*=Run");

    browser.waitUntil(() => browser.isExisting(".panel-success"));
    assert(browser.element(".panel-success").isExisting("tr*=hello world"));
  });

  it("allows running a query with a keyboard shortcut", () => {
    queryDataSource("games");

    browser.element("#sql-editor").
      keys("Control").
      keys("a").
      keys("Control").
      keys("SELECT 'hello world' FROM GAMES").
      keys("Control").
      keys("Enter").
      keys("Control");

    browser.waitUntil(() => browser.isExisting(".panel-success"));
    assert(browser.element(".panel-success").isExisting("tr*=hello world"));
  });

  it("allows cancelling a query", () => {
    queryDataSource("nyctaxi");

    browser.element("#sql-editor").
      keys("Control").
      keys("a").
      keys("Control").
      keys("SELECT COUNT(*) FROM trips");
    browser.click("button*=Run");

    browser.waitUntil(() => browser.getSource().includes("Cancel"));
    browser.click("a*=Cancel");
    browser.waitUntil(() => browser.getSource().includes("Query cancelled"));
  });
});
