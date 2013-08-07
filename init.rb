require 'redmine'

require_dependency 'rtx_issues_hook'
require_dependency 'account_rtx_login'
require_dependency 'user_rtx'

Redmine::Plugin.register :rtx_notify do
  name 'Redmine RTX Notify plugin'
  author 'Zhang Fan'
  description 'Notify user by RTX(rtx.qq.com), when issues added / edited.'
  version '0.0.1'
  url 'http://web.4399.com'
  author_url 'mailto:zhangfan@4399.net'
  requires_redmine :version_or_higher => '2.3.0'
  permission :login_by_rtx, { :login_by_rtx => [:index] }, :public => true
  menu	:account_menu,
		:login_by_rtx,
		{ :controller => 'account', :action => 'login_by_rtx'},
		:caption => 'RTX_Login',
		:after   => :login,
		:if      => Proc.new { RtxIssueHook.get_setting(:login_by_rtx) && !User.current.logged? }
  settings :default => {
    :add_notify                      => true,
    :edit_notify                     => true,
    :login_by_rtx                    => true,
    :rtx_server_url                  => 'http://rtx.me4399.com:8012/'
  }, :partial => 'settings/rtx_settings'
end

