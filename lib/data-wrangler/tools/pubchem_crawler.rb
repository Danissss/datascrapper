# require 'capybara'
# require 'capybara/poltergeist'
 
# class PubchemCrawler
#   include Capybara::DSL
 
#   def initialize
#     Capybara.register_driver :poltergeist_crawler do |app|
#       Capybara::Poltergeist::Driver.new(app, {
#         js_errors: false,
#         inspector: false,
#         phantomjs_logger: open('/dev/null')
#       })
#     end
#     Capybara.default_wait_time = 3
#     Capybara.run_server = false
#     Capybara.default_driver = :poltergeist_crawler
#     page.driver.headers = {
#       "DNT" => 1,
#       "User-Agent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:22.0) Gecko/20100101 Firefox/22.0"
#     }
#   end
 
#   # handy to peek into what the browser is doing right now
#   def screenshot(name="screenshot")
#     page.driver.render("public/#{name}.jpg", full: true)
#   end
 
#   # find("path") and all("path") work ok for most cases.
#   # Sometimes I need more control, like finding hidden fields
#   def doc
#     Nokogiri.parse(page.body)
#   end
 
#   def visit_home
#     self.visit 'http://online.lexi.com.login.ezproxy.library.ualberta.ca/lco/action/home/switch?siteid=1'
#   end
 
#   def drug_search(name)
#     self.fill_in 'query', with: name
#     self.click_on 'Search'
#   end
 
#   def visit_interactions
#     databases = self.all('.drug-databases').first
#     return nil if databases.blank?
#     hit = databases.find('ul.result-list').all('li').first
#     return nil if hit.blank?
#     hit.find('a').click
#   end
 
#   def drug_interactions
#     if visit_interactions
#       interactions = self.find("#dri")
#       if interactions.present?
#         interactions.all('p')
#       else
#         []
#       end
#     else
#       []
#     end
#   rescue Capybara::ElementNotFound
#     []
#   end
 
#   def fill_autocomplete(field, options = {})
#     page.fill_in field, with: options[:with]
 
#     page.execute_script %Q{ $('##{field}').trigger('focus') }
#     page.execute_script %Q{ $('##{field}').trigger('keydown') }
#     self.screenshot('keydown')
#     selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}
 
#     # page.should have_selector('ul.ui-autocomplete li.ui-menu-item a')
#     page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
#   end
# end