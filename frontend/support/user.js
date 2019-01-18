import {randomString} from "./random";
import {logout, loginAdmin} from "./session";

export const createUser = () => {
  const name = randomString();
  const login = `some.email+${name}@aircloak.com`;

  browser.url("/admin/users");
  browser.click("*=Add a user");
  browser.waitUntil(() => browser.getSource().includes("New user"));

  browser.setValue("#user_login", login);
  browser.setValue("#user_name", name);
  browser.click("button*=Save");

  browser.waitUntil(() => browser.isExisting(".alert-info*=User created"));

  return {name, login};
}

export const createUserWithPassword = () => {
  const {name, login} = createUser();

  browser.click("a*=Reset password");
  browser.waitUntil(() => browser.isExisting(".alert-info*=The user can set a new password using the following link"));
  const resetLink = browser.element("#reset-link").getText();
  logout();

  const password = randomString();
  browser.url(resetLink);
  browser.setValue("#user_password", password);
  browser.setValue("#user_password_confirmation", password);
  browser.click("button*=Save");
  loginAdmin();

  return {name, login, password};
}
