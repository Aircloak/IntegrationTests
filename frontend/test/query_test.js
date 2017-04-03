import assert from "assert";

import {loginAdmin, login} from "./support/session";
import {createUser} from "./support/user";
import {allowDataSource, queryDataSource} from "./support/data_source";

describe("queries", () => {
  before(() => {
    loginAdmin();

    const user = createUser();
    allowDataSource(user, "games");

    login(user);
  });

  it("allows running a query", () => {
    queryDataSource("games");

    browser.element("#sql-editor").keys("SELECT 'hello world' FROM GAMES");
    browser.click("button*=Run");

    browser.waitUntil(() => browser.isExisting(".panel-success"));
    assert(browser.element(".panel-success").isExisting("tr*=hello world"));
  });
});
