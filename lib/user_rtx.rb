
RedmineApp::Application.config.after_initialize do
	class User
		def rtx
			field = custom_field_values.find{ |f| f.custom_field.name == 'RTX' }
			field.nil? ? login : field.value
		end
		
		def self.find_by_rtx(rtx_value)
			user = User.find{|user| user.rtx == rtx_value}
			user.nil? ? find_by_login(rtx_value) : user
		end
	end
end
