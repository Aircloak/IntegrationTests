import {randomString} from "./random";

export const createUser = () => {
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

  return {name, password};
}
