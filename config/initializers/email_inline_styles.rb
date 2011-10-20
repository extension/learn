# add inline styles to the interceptor list
ActionMailer::Base.register_interceptor(InlineStyle::Mail::Interceptor.new(ignore_linked_stylesheets: true))