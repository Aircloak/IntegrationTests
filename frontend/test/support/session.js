import {admin} from "../../config.json"

export const loginAdmin = () => {
  browser.url("/auth");
  browser.setValue("[name='email']", admin.email);
  browser.setValue("[name='password']", admin.password);
  browser.click("form button");

  browser.waitUntil(() => browser.getSource().includes("Logged in successfully."));
}