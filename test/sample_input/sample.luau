-- define the teplate targets as variables so the code remains valid
local __t_user_id = 0
local __tq_package_name = ""

local print_string = "User: " .. tostring(__t_user_id)
print_string ..= " made a package named: " .. __tq_package_name

print(print_string)
