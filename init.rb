require 'redmine'

require_dependency 'rtx_issues_hook'
require_dependency 'account_rtx_login'
require_dependency 'user_rtx'

Redmine::Plugin.register :rtx_notify do
  name 'Redmine RTX Notify plugin'
  author 'Zhang Fan'
  description 'Notify user by RTX(rtx.qq.com), when issues added / edited.'
  version '0.1.0'
  url 'http://web.4399.com'
  author_url 'mailto:zhangfan@4399.net'
  requires_redmine :version_or_higher => '2.0.0'
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
    :rtx_server_url                  => 'http://your.rtx.server:8012/'
  }, :partial => 'settings/rtx_settings'
end

