import {randomString} from "./random";

export const createUser = () => {
  const name = randomString();
  const password = randomString();
  const email = `some.email+${name}@aircloak.com`;

  browser.url("/admin/users");
  browser.click("*=Add a user");
  browser.waitUntil(() => browser.getSource().includes("New user"));

  browser.setValue("#user_email", email);
  browser.setValue("#user_name", name);
  browser.setValue("#user_password", password);
  browser.setValue("#user_password_confirmation", password);
  browser.click("button*=Save");

  browser.waitUntil(() => browser.isExisting(".alert-info*=User created"));

  return {name, password, email};
}
