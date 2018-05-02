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

  browser.waitUntil(isLoggedIn() || isOnPrivacyPolicyPage());

  if (isOnPrivacyPolicyPage()) {
    browser.click("#review-box form button");
    browser.waitUntil(isLoggedIn);
  }
}

const isOnPrivacyPolicyPage = () =>
  browser.getSource().includes("Accept privacy policy") || browser.getSource().includes("Consent to privacy policy");

const isLoggedIn = () =>
  browser.getSource().includes("Sign out");
