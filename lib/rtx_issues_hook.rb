
class RtxIssueHook < Redmine::Hook::ViewListener
	include IssuesHelper
	include CustomFieldsHelper
	
	def initialize
		$rtx_hook = self
	end
	
	def controller_issues_new_after_save(context={})
		return unless self.class.get_setting(:add_notify)
		issue = context[:issue]
		title = l(:label_issue_added)
		content = l(:text_issue_added, :id => "##{issue.id}", :author => issue.author)
		issueUrl = redmine_url(:controller => 'issues', :action => 'show', :id => issue)
		send_rtx(issue, title, content, issueUrl)
	end
	
	def controller_issues_edit_after_save(context={})
		return unless self.class.get_setting(:edit_notify)
		issue = context[:issue]
		journal = context[:journal]
		title = l(:label_issue_updated)
		content = l(:text_issue_updated, :id => "##{issue.id}", :author => journal.user)
		details_to_strings(journal.details, true).each do |string|
			content += "\n  " + string
		end
		content += "\n" + journal.notes if journal.notes?
		
		issueUrl = redmine_url(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
		send_rtx(issue, title, content, issueUrl)
	end
	
	def send_rtx(issue, title, content, issueUrl)
		userAry = ([issue.assigned_to] | issue.watcher_users).select{ |u| u.respond_to? :rtx }
		return if userAry.empty?
		rtxAry = userAry.map(&:rtx)
		# Modify these liens yourself to change the title style.
		#subject = to_rtx_str(issue_heading(issue))
		subject = to_rtx_str("(#{issue.status.name}) ##{issue.id} #{issue.subject}")
		content = to_rtx_str(content)
		msg = if (RtxIssueHook.get_setting(:login_by_rtx))
				loginUri = redmine_url(:controller => 'account', :action => 'login', :back_url => issueUrl)
				"[#{subject} |#{loginUri}|se]\n#{content}"
			else
				"[#{subject} |#{issueUrl}]\n#{content}"
			end
		
		param = { :title => title, :msg => msg, :receiver => rtxAry * ',', :delaytime => 0 }
		self.class.call_rtx('sendnotify.cgi', param)
	end
	
	def redmine_url(param)
		param[:host] = Setting.host_name
		param[:protocol] = Setting.protocol
		url_for(param)
	end
	
	def self.call_rtx(page, param)
		uri = URI.join(get_setting(:rtx_server_url), page)
		# URI.encode_www_form(...) is not available before ruby 1.9.0
		uri.query = param.map do |k,v|
				v = iconv('GB2312', 'UTF-8', v.to_s)
				v = URI.encode_www_form_component(v)
				"#{k}=#{v}"
			end.join('&')
		Rails.logger.info "RTX_GET: #{uri.to_s}"
		res = Net::HTTP.get_response(uri)
		Rails.logger.info "RTX_RESPONSE: #{res.code} #{res.message}"
		iconv('UTF-8', 'GB2312', res.body)
	end
	
	def self.plugin
		Redmine::Plugin.find(:rtx_notify)
	end
	
	def self.get_setting(name)
	  begin
	    if plugin
	      if Setting["plugin_#{plugin.id}"]
	        Setting["plugin_#{plugin.id}"][name]
	      else
	        if plugin.settings[:default].has_key?(name)
	          plugin.settings[:default][name]
	        end
	      end
	    end
	  rescue
	    nil
	  end
	end
	
	def to_rtx_str(str)
		str.sub! '[', '{'
		str.sub! ']', '}'
		str.sub! '<', '{'
		str.sub! '>', '}'
		str.sub! '|', '!'
		str
	end
	
	def self.iconv(to, from, str)
		if str.respond_to?(:encode)	# for Ruby ver. 1.9.0 and above
			str.encode(to, from)
		else
			Iconv.conv(to, from, str)
		end
	end
end
