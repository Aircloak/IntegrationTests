import {randomString} from "./random";
import {logout, loginAdmin} from "./session";

export const createUser = () => {
  const name = randomString();
  const email = `some.email+${name}@aircloak.com`;

  browser.url("/admin/users");
  browser.click("*=Add a user");
  browser.waitUntil(() => browser.getSource().includes("New user"));

  browser.setValue("#user_email", email);
  browser.setValue("#user_name", name);
  browser.click("button*=Save");

  browser.waitUntil(() => browser.isExisting(".alert-info*=User created"));

  return {name, email};
}

export const createUserWithPassword = () => {
  const {name, email} = createUser();

  const resetLink = browser.element("#reset-link").getText();
  logout();

  const password = randomString();
  browser.url(resetLink);
  browser.setValue("#user_password", password);
  browser.setValue("#user_password_confirmation", password);
  browser.click("button*=Save");
  loginAdmin();

  return {name, email, password};
}
