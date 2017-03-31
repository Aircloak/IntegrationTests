export const showDataSource = (name) => {
  browser.url("/admin/data_sources");
  browser.element(`tr*=${name}`).click("a*=Show");
  browser.waitUntil(() => browser.getSource().includes("Cloaks hosting data source"));
};
