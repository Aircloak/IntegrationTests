import {admin} from "../../config.json"

export const loginAdmin = () => login(admin);

export const logout = () => {
  if (browser.isExisting("a*=Sign out")) {
    browser.click("a*=Sign out");
    browser.waitUntil(() => browser.getSource().includes("Logged out successfully"));
  };
};

export const login = (user) => {
  logout();

  browser.url("/auth");
  browser.setValue("[name='email']", user.email);
  browser.setValue("[name='password']", user.password);
  browser.click("form button");

  browser.waitUntil(() => browser.getSource().includes("Sign out"));
}
