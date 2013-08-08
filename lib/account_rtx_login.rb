
RedmineApp::Application.config.after_initialize do
	class AccountController
		def login_with_rtx
			return login_without_rtx if params[:sign].blank?
			
			msg = RtxIssueHook.call_rtx('SignAuth.cgi', {:user => params[:username], :sign => params[:sign]})
			return invalid_credentials unless msg == 'success!'
			
			user = User.find_by_rtx(params[:username])
			return true unless user
			
			if user.nil?
				invalid_credentials
			elsif user.active?
				successful_authentication(user)
			else
				account_pending
			end
		end
		
		alias_method_chain :login, :rtx
	end if defined? AccountController
end
