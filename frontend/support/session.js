import {admin} from "../config.json"

export const loginAdmin = () => login(admin);

export const logout = () => {
  browser.deleteCookie();
};

export const login = (user) => {
  logout();

  browser.url("/auth");
  browser.setValue("[name='login']", user.login);
  browser.setValue("[name='password']", user.password);
  browser.click("form button");

  browser.waitUntil(isLoggedIn());
}

const isLoggedIn = () =>
  browser.getSource().includes("Sign out");
