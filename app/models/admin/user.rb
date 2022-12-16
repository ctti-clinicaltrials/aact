module Admin
    class User < Admin::AdminBase
        self.table_name = "users"
        def self.admin_emails
            where(admin:true).map {|user| user.email}
        end
    end

    def export_usage
        sql = "
SELECT
when_recorded,
COUNT(*) AS users,
SUM(event_count) AS queries
FROM db_user_activities
GROUP BY when_recorded
ORDER BY when_recorded ASC
"
file = File.open('activity.csv', 'w')
file.puts "date,users,queries"
total = DbUserActivity.connection.execute(sql).each do |item|
  file.puts "#{item['when_recorded']},#{item['users']},#{item['queries']}"
end
file.close

# users
sql = "
SELECT
username,
SUM(event_count) AS queries
FROM db_user_activities
GROUP BY username
ORDER BY SUM(event_count) DESC
"
file = File.open('users.csv', 'w')
file.puts "username,queries"
total = DbUserActivity.connection.execute(sql).each do |item|
  file.puts "#{item['username']},#{item['queries']}"
end
file.close

end
end
