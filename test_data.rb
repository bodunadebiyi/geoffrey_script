
def test_payload
  [{"sha"=>"3afaf5e89e2d15286a5362fd13e023b4b13fb5e1", "filename"=>"app/controllers/api/v1/users_controller.rb", "status"=>"modified", "additions"=>1, "deletions"=>0, "changes"=>1, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fcontrollers%2Fapi%2Fv1%2Fusers_controller.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fcontrollers%2Fapi%2Fv1%2Fusers_controller.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fcontrollers%2Fapi%2Fv1%2Fusers_controller.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -17,6 +17,7 @@ class Api::V1::UsersController < ApplicationController\n \n   def register\n     user = User.create!(register_params)\n+    user.register_user_as_org_admin if is_orgs_subdomain\n     render json: auth_payload(user)\n   end\n "}, {"sha"=>"be8d65f40b525ed82a3548b04c9b7da504fef22e", "filename"=>"app/controllers/application_controller.rb", "status"=>"modified", "additions"=>17, "deletions"=>0, "changes"=>17, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fcontrollers%2Fapplication_controller.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fcontrollers%2Fapplication_controller.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fcontrollers%2Fapplication_controller.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -46,4 +46,21 @@ def handle_jwt_error(exception)\n     def current_user\n         @current_user\n     end\n+\n+    def get_request_subdomain\n+        hostname = clean_hostname(request.headers['Origin'])\n+        hostnameParts = hostname.split('.')\n+        return hostname.length > 1 && hostnameParts[1] != 'com' ? hostnameParts[0] : ''\n+    end\n+\n+    private\n+    # <@geoffrey cleanup in 2 weeks\n+    def clean_hostname(hostname)\n+        hostname.gsub(/https?:\\/\\//, '').gsub(/www\\./, '')\n+    end\n+\n+    # <@geoffrey remind me in 4 weeks to refactor this method\n+    def is_orgs_subdomain?\n+        get_request_subdomain == 'orgs'\n+    end\n end"}, {"sha"=>"71710f3781fcc386b85fe2d46c0e1c2974500597", "filename"=>"app/controllers/concerns/json_web_token.rb", "status"=>"modified", "additions"=>3, "deletions"=>3, "changes"=>6, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fcontrollers%2Fconcerns%2Fjson_web_token.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fcontrollers%2Fconcerns%2Fjson_web_token.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fcontrollers%2Fconcerns%2Fjson_web_token.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -15,16 +15,16 @@ def jwt_decode(token)\n         HashWithIndifferentAccess.new decoded\n     end\n \n-    private \n+    private\n \n     def extract_token_from_header\n         header = request.headers['Authorization']\n-        token = header.split(' ').last if header\n+        header.split(' ').last if header\n     end\n \n     def get_user_from_token(token)\n         decoded = jwt_decode(token)\n-        \n+\n         begin\n             set_current_user User.find_by!(username: decoded['username'])\n         rescue"}, {"sha"=>"37f58a62c53e25b4b31eb36d260394e1e3dcaec0", "filename"=>"app/models/department.rb", "status"=>"added", "additions"=>3, "deletions"=>0, "changes"=>3, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Fdepartment.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Fdepartment.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fmodels%2Fdepartment.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,3 @@\n+class Department < ApplicationRecord\n+  has_many :teams\n+end"}, {"sha"=>"0e1a99023e445e3b7f695a9f487573213808045d", "filename"=>"app/models/employee.rb", "status"=>"added", "additions"=>3, "deletions"=>0, "changes"=>3, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Femployee.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Femployee.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fmodels%2Femployee.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,3 @@\n+# <@ geoffrey remove on 2024-11-11\n+class Employee < ApplicationRecord\n+end"}, {"sha"=>"3e7798f5649be476141c75ef8af9549264d16a54", "filename"=>"app/models/org_user_admin.rb", "status"=>"added", "additions"=>3, "deletions"=>0, "changes"=>3, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Forg_user_admin.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Forg_user_admin.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fmodels%2Forg_user_admin.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,3 @@\n+class OrgUserAdmin < ApplicationRecord\n+  belongs_to :user\n+end"}, {"sha"=>"1482db2887c5611f895b24bbea4ef00f2625bd38", "filename"=>"app/models/organization.rb", "status"=>"added", "additions"=>4, "deletions"=>0, "changes"=>4, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Forganization.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Forganization.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fmodels%2Forganization.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,4 @@\n+class Organization < ApplicationRecord\n+  belongs_to :user\n+  has_many :departments\n+end"}, {"sha"=>"2cd386de7f02fe72770b8fd5ae0d721755dab245", "filename"=>"app/models/team.rb", "status"=>"added", "additions"=>3, "deletions"=>0, "changes"=>3, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Fteam.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Fteam.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fmodels%2Fteam.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,3 @@\n+class Team < ApplicationRecord\n+  belongs_to :department\n+end"}, {"sha"=>"ef81f940fb61516c26712f1e0b0ead868590874a", "filename"=>"app/models/user.rb", "status"=>"modified", "additions"=>5, "deletions"=>1, "changes"=>6, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Fuser.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Fmodels%2Fuser.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Fmodels%2Fuser.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -25,6 +25,7 @@ class User < ApplicationRecord\n \n     after_create :on_after_create\n \n+    has_many :organizations\n     has_many :open_date_requests\n     has_many :open_date_request_interests\n     has_many :user_activities\n@@ -48,6 +49,7 @@ class User < ApplicationRecord\n     has_one :user_activation\n     has_one :password_reset\n     has_one :notification_settings, class_name: 'NotificationSetting', foreign_key: 'user_id'\n+    has_one :org_user_admin\n \n     has_and_belongs_to_many :friends,\n         class_name: \"User\",\n@@ -98,7 +100,6 @@ def self.authenticate_google_user(user_payload)\n     def self.search(query='')\n         return [] if query.length == 0\n         ci_query = query.downcase\n-        select_fields = USER_FIELDS.difference([:email, :phone_number])\n \n         self.select(PUBLIC_USER_FIELDS).where(\n             self.arel_table[:username]\n@@ -258,6 +259,9 @@ def self.profile_link(user)\n       \"\#{ENV['GUSIBERI_CLIENT_URL']}/\#{user.username}\"\n     end\n \n+    def register_user_as_org_admin\n+        OrgUserAdmin.find_or_create_by(user: self, domain: get_domain_from_email(self.email))\n+    end\n     private\n \n     def on_after_create"}, {"sha"=>"6d100bede00d638bdaba0f74dcf4cec1c72c91b4", "filename"=>"app/utilities/helpers.rb", "status"=>"modified", "additions"=>6, "deletions"=>2, "changes"=>8, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Futilities%2Fhelpers.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/app%2Futilities%2Fhelpers.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/app%2Futilities%2Fhelpers.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -45,7 +45,7 @@ def self.decode(decoded)\n   end\n \n   def self.execute_with_retry(fail_check, action, default_result=nil, retry_max=2)\n-    retry_max.times do \n+    retry_max.times do\n       value = action.call\n       return value if fail_check(value) == False\n     end\n@@ -108,4 +108,8 @@ def self.insert_between(original_text, pretext, text_to_insert)\n   def self.purify_phone(unpurified_phone)\n     unpurified_phone.gsub(/[^\\d|^\\+]/, '')\n   end\n-end\n\\ No newline at end of file\n+\n+  def self.get_domain_from_email(email)\n+    email.match(/@(.*)\\./)[1]\n+  end\n+end"}, {"sha"=>"9de1ec84751e63fc50b7ec37473aedb13dff0045", "filename"=>"db/migrate/20240803072156_create_organizations.rb", "status"=>"added", "additions"=>20, "deletions"=>0, "changes"=>20, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803072156_create_organizations.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803072156_create_organizations.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/db%2Fmigrate%2F20240803072156_create_organizations.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,20 @@\n+class CreateOrganizations < ActiveRecord::Migration[7.0]\n+  def change\n+    create_table :organizations do |t|\n+      t.string :name, null: false\n+      t.string :industry, null: false\n+      t.string :username, null: false\n+      t.string :logo, null: true\n+      t.text :description, null: true\n+      t.string :website, null: true\n+      t.string :physical_address, null: false\n+      t.string :mailing_address, null: false\n+      t.string :email, null: false\n+      t.string :phone_no, null: false\n+      t.date :year_established, null: false\n+      t.belongs_to :user, null: false, foreign_key: true\n+      t.string :domain_name, null: false\n+      t.timestamps\n+    end\n+  end\n+end"}, {"sha"=>"143a2f4b8f4edb0a2d3e7be7a62d411966cb726b", "filename"=>"db/migrate/20240803074650_create_departments.rb", "status"=>"added", "additions"=>11, "deletions"=>0, "changes"=>11, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803074650_create_departments.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803074650_create_departments.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/db%2Fmigrate%2F20240803074650_create_departments.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,11 @@\n+class CreateDepartments < ActiveRecord::Migration[7.0]\n+  def change\n+    create_table :departments do |t|\n+      t.string :name, null: false\n+      t.string :slug, null: false\n+      t.string :description, null: true\n+      t.belongs_to :organization, null: false, foreign_key: true\n+      t.timestamps\n+    end\n+  end\n+end"}, {"sha"=>"7179c2418bbf6e861acce020df6bf03d885f6060", "filename"=>"db/migrate/20240803080727_create_teams.rb", "status"=>"added", "additions"=>12, "deletions"=>0, "changes"=>12, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803080727_create_teams.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803080727_create_teams.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/db%2Fmigrate%2F20240803080727_create_teams.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,12 @@\n+class CreateTeams < ActiveRecord::Migration[7.0]\n+  def change\n+    create_table :teams do |t|\n+      t.string :name, null: false\n+      t.string :slug, null: false\n+      t.string :description, null: true\n+      t.belongs_to :department, null: false, foreign_key: true\n+      t.references :parent_team, null: true, foreign_key: { to_table: :teams }\n+      t.timestamps\n+    end\n+  end\n+end"}, {"sha"=>"6265a8d683ddb554f4d4abe0995e13a9f1f251c4", "filename"=>"db/migrate/20240803083958_create_employees.rb", "status"=>"added", "additions"=>11, "deletions"=>0, "changes"=>11, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803083958_create_employees.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240803083958_create_employees.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/db%2Fmigrate%2F20240803083958_create_employees.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,11 @@\n+class CreateEmployees < ActiveRecord::Migration[7.0]\n+  def change\n+    create_table :employees do |t|\n+      t.belongs_to :user, foreign_key: true\n+      t.belongs_to :teams, foreign_key: true\n+      t.date :date_of_employment, null: false\n+      t.text :role, null: false\n+      t.timestamps\n+    end\n+  end\n+end"}, {"sha"=>"349aeb33e493fa71937dd584a1f961e4548809bb", "filename"=>"db/migrate/20240805094533_create_org_user_admins.rb", "status"=>"added", "additions"=>10, "deletions"=>0, "changes"=>10, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240805094533_create_org_user_admins.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fmigrate%2F20240805094533_create_org_user_admins.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/db%2Fmigrate%2F20240805094533_create_org_user_admins.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,10 @@\n+class CreateOrgUserAdmins < ActiveRecord::Migration[7.0]\n+  def change\n+    create_table :org_user_admins do |t|\n+      t.belongs_to :organization, null: true, foreign_key: true\n+      t.belongs_to :user, null: false, foreign_key: true\n+      t.string :domain, null: false\n+      t.timestamps\n+    end\n+  end\n+end"}, {"sha"=>"c598f796640d65f10994b2acac63386466bf2dfd", "filename"=>"db/schema.rb", "status"=>"modified", "additions"=>71, "deletions"=>1, "changes"=>72, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fschema.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/db%2Fschema.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/db%2Fschema.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -10,7 +10,7 @@\n #\n # It's strongly recommended that you check this file into your version control system.\n \n-ActiveRecord::Schema[7.0].define(version: 2024_06_03_065242) do\n+ActiveRecord::Schema[7.0].define(version: 2024_08_05_094533) do\n   # These are extensions that must be enabled in order to support this database\n   enable_extension \"plpgsql\"\n \n@@ -155,6 +155,27 @@\n     t.index [\"user_id\"], name: \"index_date_schedules_on_user_id\"\n   end\n \n+  create_table \"departments\", force: :cascade do |t|\n+    t.string \"name\", null: false\n+    t.string \"slug\", null: false\n+    t.string \"description\"\n+    t.bigint \"organization_id\", null: false\n+    t.datetime \"created_at\", null: false\n+    t.datetime \"updated_at\", null: false\n+    t.index [\"organization_id\"], name: \"index_departments_on_organization_id\"\n+  end\n+\n+  create_table \"employees\", force: :cascade do |t|\n+    t.bigint \"user_id\"\n+    t.bigint \"teams_id\"\n+    t.date \"date_of_employment\", null: false\n+    t.text \"role\", null: false\n+    t.datetime \"created_at\", null: false\n+    t.datetime \"updated_at\", null: false\n+    t.index [\"teams_id\"], name: \"index_employees_on_teams_id\"\n+    t.index [\"user_id\"], name: \"index_employees_on_user_id\"\n+  end\n+\n   create_table \"favourite_activities\", force: :cascade do |t|\n     t.string \"description\"\n     t.text \"favourite_places\"\n@@ -252,6 +273,35 @@\n     t.index [\"user_id\"], name: \"index_open_date_requests_on_user_id\"\n   end\n \n+  create_table \"org_user_admins\", force: :cascade do |t|\n+    t.bigint \"organization_id\"\n+    t.bigint \"user_id\", null: false\n+    t.string \"domain\", null: false\n+    t.datetime \"created_at\", null: false\n+    t.datetime \"updated_at\", null: false\n+    t.index [\"organization_id\"], name: \"index_org_user_admins_on_organization_id\"\n+    t.index [\"user_id\"], name: \"index_org_user_admins_on_user_id\"\n+  end\n+\n+  create_table \"organizations\", force: :cascade do |t|\n+    t.string \"name\", null: false\n+    t.string \"industry\", null: false\n+    t.string \"username\", null: false\n+    t.string \"logo\"\n+    t.text \"description\"\n+    t.string \"website\"\n+    t.string \"physical_address\", null: false\n+    t.string \"mailing_address\", null: false\n+    t.string \"email\", null: false\n+    t.string \"phone_no\", null: false\n+    t.date \"year_established\", null: false\n+    t.bigint \"user_id\", null: false\n+    t.string \"domain_name\", null: false\n+    t.datetime \"created_at\", null: false\n+    t.datetime \"updated_at\", null: false\n+    t.index [\"user_id\"], name: \"index_organizations_on_user_id\"\n+  end\n+\n   create_table \"password_resets\", force: :cascade do |t|\n     t.string \"reset_code\"\n     t.bigint \"user_id\"\n@@ -290,6 +340,18 @@\n     t.index [\"user_id\"], name: \"index_supports_on_user_id\"\n   end\n \n+  create_table \"teams\", force: :cascade do |t|\n+    t.string \"name\", null: false\n+    t.string \"slug\", null: false\n+    t.string \"description\"\n+    t.bigint \"department_id\", null: false\n+    t.bigint \"parent_team_id\"\n+    t.datetime \"created_at\", null: false\n+    t.datetime \"updated_at\", null: false\n+    t.index [\"department_id\"], name: \"index_teams_on_department_id\"\n+    t.index [\"parent_team_id\"], name: \"index_teams_on_parent_team_id\"\n+  end\n+\n   create_table \"user_activations\", force: :cascade do |t|\n     t.string \"activation_code\"\n     t.bigint \"user_id\"\n@@ -360,14 +422,22 @@\n   add_foreign_key \"date_participants\", \"users\", on_delete: :cascade\n   add_foreign_key \"date_requests\", \"users\", column: \"created_by_id\"\n   add_foreign_key \"date_schedules\", \"users\", on_delete: :cascade\n+  add_foreign_key \"departments\", \"organizations\"\n+  add_foreign_key \"employees\", \"teams\", column: \"teams_id\"\n+  add_foreign_key \"employees\", \"users\"\n   add_foreign_key \"favourite_activities\", \"users\", on_delete: :cascade\n   add_foreign_key \"friend_categories\", \"users\", on_delete: :cascade\n   add_foreign_key \"friend_requests\", \"users\", column: \"sent_from_id\"\n   add_foreign_key \"friend_requests\", \"users\", column: \"sent_to_id\"\n   add_foreign_key \"new_user_pending_actions\", \"users\", column: \"subject_id\"\n   add_foreign_key \"notifications\", \"users\", on_delete: :cascade\n+  add_foreign_key \"org_user_admins\", \"organizations\"\n+  add_foreign_key \"org_user_admins\", \"users\"\n+  add_foreign_key \"organizations\", \"users\"\n   add_foreign_key \"relationships\", \"users\", column: \"relationship_user_one_id\"\n   add_foreign_key \"relationships\", \"users\", column: \"relationship_user_two_id\"\n   add_foreign_key \"support_messages\", \"users\", column: \"sender_id\"\n+  add_foreign_key \"teams\", \"departments\"\n+  add_foreign_key \"teams\", \"teams\", column: \"parent_team_id\"\n   add_foreign_key \"user_profiles\", \"users\", on_delete: :cascade\n end"}, {"sha"=>"05d70b55c28d7e4b95bb23a642dcec044c5ef339", "filename"=>"github_agent.rb", "status"=>"added", "additions"=>55, "deletions"=>0, "changes"=>55, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/github_agent.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/github_agent.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/github_agent.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,55 @@\n+require 'net/http'\n+require 'json'\n+\n+\n+class GithubAgent\n+  attr_accessor :request_headers\n+\n+  GITHUB_BASE_URL = 'https://api.github.com'\n+\n+  def initialize(options)\n+    @options = options\n+    @request_headers = {\n+      Accept: 'application/vnd.github+json',\n+      Connection: 'Keep-Alive',\n+      Authorization: \"Bearer \#{@options[:token]}\"\n+    }\n+  end\n+\n+  def load_pull_request_files\n+    uri = URI(pull_request_files_uri)\n+    res = Net::HTTP.get(uri, @request_headers)\n+    @pr_files = JSON.parse(res)\n+    self\n+  end\n+\n+  def pr_files\n+    @pr_files\n+  end\n+\n+  private\n+\n+  def pull_request_files_uri\n+    \"\#{GITHUB_BASE_URL}/repos/\#{options[:user]}/\#{options[:repo]}/pulls/\#{options[:pull_request_num]}/files\"\n+  end\n+\n+  def options=(options)\n+    @options = options\n+  end\n+\n+  def options\n+    @options\n+  end\n+\n+  def pr_files=(pr_files)\n+    @pr_files = pr_files\n+  end\n+\n+  def request_headers=(request_headers)\n+    @request_headers = request_headers\n+  end\n+\n+  def request_headers\n+    @request_headers\n+  end\n+end"}, {"sha"=>"1f0df1da84da784b5eb43fdfb0907ada5412bb13", "filename"=>"test/fixtures/departments.yml", "status"=>"added", "additions"=>11, "deletions"=>0, "changes"=>11, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Fdepartments.yml", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Fdepartments.yml", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Ffixtures%2Fdepartments.yml?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,11 @@\n+# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html\n+\n+# This model initially had no columns defined. If you add columns to the\n+# model remove the \"{}\" from the fixture names and add the columns immediately\n+# below each fixture, per the syntax in the comments below\n+#\n+# one: {}\n+# column: value\n+#\n+# two: {}\n+# column: value"}, {"sha"=>"1f0df1da84da784b5eb43fdfb0907ada5412bb13", "filename"=>"test/fixtures/employees.yml", "status"=>"added", "additions"=>11, "deletions"=>0, "changes"=>11, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Femployees.yml", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Femployees.yml", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Ffixtures%2Femployees.yml?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,11 @@\n+# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html\n+\n+# This model initially had no columns defined. If you add columns to the\n+# model remove the \"{}\" from the fixture names and add the columns immediately\n+# below each fixture, per the syntax in the comments below\n+#\n+# one: {}\n+# column: value\n+#\n+# two: {}\n+# column: value"}, {"sha"=>"1f0df1da84da784b5eb43fdfb0907ada5412bb13", "filename"=>"test/fixtures/org_user_admins.yml", "status"=>"added", "additions"=>11, "deletions"=>0, "changes"=>11, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Forg_user_admins.yml", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Forg_user_admins.yml", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Ffixtures%2Forg_user_admins.yml?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,11 @@\n+# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html\n+\n+# This model initially had no columns defined. If you add columns to the\n+# model remove the \"{}\" from the fixture names and add the columns immediately\n+# below each fixture, per the syntax in the comments below\n+#\n+# one: {}\n+# column: value\n+#\n+# two: {}\n+# column: value"}, {"sha"=>"1f0df1da84da784b5eb43fdfb0907ada5412bb13", "filename"=>"test/fixtures/organizations.yml", "status"=>"added", "additions"=>11, "deletions"=>0, "changes"=>11, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Forganizations.yml", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Forganizations.yml", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Ffixtures%2Forganizations.yml?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,11 @@\n+# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html\n+\n+# This model initially had no columns defined. If you add columns to the\n+# model remove the \"{}\" from the fixture names and add the columns immediately\n+# below each fixture, per the syntax in the comments below\n+#\n+# one: {}\n+# column: value\n+#\n+# two: {}\n+# column: value"}, {"sha"=>"1f0df1da84da784b5eb43fdfb0907ada5412bb13", "filename"=>"test/fixtures/teams.yml", "status"=>"added", "additions"=>11, "deletions"=>0, "changes"=>11, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Fteams.yml", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Ffixtures%2Fteams.yml", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Ffixtures%2Fteams.yml?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,11 @@\n+# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html\n+\n+# This model initially had no columns defined. If you add columns to the\n+# model remove the \"{}\" from the fixture names and add the columns immediately\n+# below each fixture, per the syntax in the comments below\n+#\n+# one: {}\n+# column: value\n+#\n+# two: {}\n+# column: value"}, {"sha"=>"19ff1b3e17afd4770f3d313e37469f1c55267c36", "filename"=>"test/models/department_test.rb", "status"=>"added", "additions"=>7, "deletions"=>0, "changes"=>7, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Fdepartment_test.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Fdepartment_test.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Fmodels%2Fdepartment_test.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,7 @@\n+require \"test_helper\"\n+\n+class DepartmentTest < ActiveSupport::TestCase\n+  # test \"the truth\" do\n+  #   assert true\n+  # end\n+end"}, {"sha"=>"e3599a049e52c91db53ab151f3376f70be9bc50b", "filename"=>"test/models/employee_test.rb", "status"=>"added", "additions"=>7, "deletions"=>0, "changes"=>7, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Femployee_test.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Femployee_test.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Fmodels%2Femployee_test.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,7 @@\n+require \"test_helper\"\n+\n+class EmployeeTest < ActiveSupport::TestCase\n+  # test \"the truth\" do\n+  #   assert true\n+  # end\n+end"}, {"sha"=>"afaf01dbe410d409dc012f21c7b5ef7ace13d8ca", "filename"=>"test/models/org_user_admin_test.rb", "status"=>"added", "additions"=>7, "deletions"=>0, "changes"=>7, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Forg_user_admin_test.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Forg_user_admin_test.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Fmodels%2Forg_user_admin_test.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,7 @@\n+require \"test_helper\"\n+\n+class OrgUserAdminTest < ActiveSupport::TestCase\n+  # test \"the truth\" do\n+  #   assert true\n+  # end\n+end"}, {"sha"=>"3f86f1cd4eabec0328365c1a1ac119d0946d52b3", "filename"=>"test/models/organization_test.rb", "status"=>"added", "additions"=>7, "deletions"=>0, "changes"=>7, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Forganization_test.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Forganization_test.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Fmodels%2Forganization_test.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,7 @@\n+require \"test_helper\"\n+\n+class OrganizationTest < ActiveSupport::TestCase\n+  # test \"the truth\" do\n+  #   assert true\n+  # end\n+end"}, {"sha"=>"c6cf23da5af386a136c266f39b0cb459ebb824a5", "filename"=>"test/models/team_test.rb", "status"=>"added", "additions"=>7, "deletions"=>0, "changes"=>7, "blob_url"=>"https://github.com/bodunadebiyi/gusiberi_server/blob/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Fteam_test.rb", "raw_url"=>"https://github.com/bodunadebiyi/gusiberi_server/raw/64803bd5ead6bdbc6829d82f8645352859ad99a9/test%2Fmodels%2Fteam_test.rb", "contents_url"=>"https://api.github.com/repos/bodunadebiyi/gusiberi_server/contents/test%2Fmodels%2Fteam_test.rb?ref=64803bd5ead6bdbc6829d82f8645352859ad99a9", "patch"=>"@@ -0,0 +1,7 @@\n+require \"test_helper\"\n+\n+class TeamTest < ActiveSupport::TestCase\n+  # test \"the truth\" do\n+  #   assert true\n+  # end\n+end"}]
end
