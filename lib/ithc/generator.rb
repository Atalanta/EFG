module Ithc
  class Generator
    class << self
      def seed(email)
        re = /([^@]+)(@.+)/
        match = email.match re
        result = {} # collect the results so that calling clients can inspect / display
        %w{CfeAdmin CfeUser PremiumCollectorUser AuditorUser}.each do |user_class|
          result[user_class] = find_or_create(user_class, match)
        end

        biggest_lender = find_biggest_lender

        if biggest_lender
          %w{LenderAdmin LenderUser}.each do |user_class|
            result[user_class] = find_or_create(user_class, match, biggest_lender)
          end
        end
        return result
      end
    private
      def create_user_email(user_class, email)
        "#{email[1]}+#{user_class.underscore}#{email[2]}"
      end

      # Return the Lender that has the most loans
      def find_biggest_lender
        Lender.joins(:loans).group("id").order("count(*) desc").first
      end

      def find_or_create(user_class, email, lender = nil)
        email = create_user_email(user_class, email)
        klass = Kernel.const_get(user_class)
        result = klass.find_by_email(email)
        if not result
          result = klass.create(email:email,
            password:"password",
            password_confirmation:"password",
            first_name:"Pen", last_name:"Test")
          if lender
            result.lender = lender
            result.save!
          end
          return { created: true, username: result.username }
        else
          return { created: false, username: result.username }
        end
      end
    end
  end
end