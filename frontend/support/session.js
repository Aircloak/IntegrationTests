import {admin} from "../config.json"

export const loginAdmin = () => login(admin);

export const logout = () => {
  browser.deleteCookie();
};

export const login = (user) => {
  logout();

  browser.url("/auth");
  browser.setValue("[name='email']", user.email);
  browser.setValue("[name='password']", user.password);
  browser.click("form button");

  browser.waitUntil(() =>
    browser.getSource().includes("Sign out") || browser.getSource().includes("Accept privacy policy")
  );

  if (browser.getSource().includes("Accept privacy policy")) {
    browser.click("#review-box form button");
    browser.waitUntil(() => browser.getSource().includes("Sign out"));
  }
}
