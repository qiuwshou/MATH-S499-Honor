#!/usr/bin/ruby
require 'date'

puts "-------------------------------Building id-------------------------------"
puts "|Ashton-1, Briscoe-2, Forest-3, Foster-4, Mcnutt-5                      |"
puts "|Rose-6, Teter-7, Willkie-8                                             |"
puts "|-----------------------------------------------------------------------|"
puts "|Enter building id, Number of occupants, Data of check-in and check-out.|"
puts "|Data from 11-05-year to 16-08-year                                     |"
puts "|(Example: 1 20 11-05-2015 16-06-2015)                                  |"
puts "|Enter\"Quit\" to see the result.                                         |"
puts "-------------------------------------------------------------------------"




#  $temp = 71.0566
#  $humd = 7.842751
$temp = 0
$humd = 0

#building characters
  $id_name = { "1" => "Ashton", "2" => "Briscoe", "3" => "Forest" , "4" => "Foster", "5" => "Mcnutt", "6" => "Rose", "7" => "Teter", "8" => "Willkie"}
  $food = {"1" => 0,"2"=> 0,"3"=>1,"4"=>0.8,"5"=> 0.3,"6"=>1,"7"=>0,"8"=>0.25}
  $chiller = {"1" =>0,"2"=> 0,"3"=>1,"4"=>0,"5"=>0,"6"=>0,"7"=>0,"8"=>0.75 }
  $window = {"1" => 1,"2"=> 0,"3"=>0,"4"=>0,"5"=>0,"6"=>0,"7"=>0,"8"=>0.25}
  $bed = {"1" => 575,"2"=> 709,"3"=>1046,"4"=>1209,"5"=>1341,"6"=>442,"7"=>1196,"8"=>852}

#coeff of model
  $intercept_coef = {"1" => 8380.078,"2"=> 5234.912,"3"=>9507.044,"4"=>11239.886,"5"=>16543.092,"6"=>6200.875,"7"=>9456.513,"8"=>10228.163}
  $occup2_coef =  -0.002836833
  $occup_coef = {"1" => 4.394767,"2"=> 2.803321 ,"3"=>6.950052 ,"4"=>4.088328 ,"5" =>5.483103 ,"6"=>2.662327 ,"7"=> 3.817447,"8"=>4.077273 }
  $temp_coef = {"1" => 864.4818,"2"=> 431.3076 ,"3"=>996.8407,"4"=>1294.2844 ,"5"=>1858.129 ,"6"=> 579.3874 ,"7"=> 1114.8543,"8"=>1092.7284}
  $humd_coef =  77.83511
  $food_coef = -3329.76
  $chiller_coef = 2282.977
  $window_coef = -4890.686
  $occup_temp = -1.121572

#A class includes all the functions that we will use later
class EU
def add_zero(schedule) 
  total_zero_occupancy = 0
  for i in $first..$last
    for j in 1..8
      day = schedule[i]
      num_bed = day[j]
      id = j.to_s
      if(num_bed == $bed[j])
        usage = $intercept_coef[id] +  $temp_coef[id]*$temp + $humd_coef*$humd + $food_coef*$food[id] + $chiller_coef*$chiller[id] + $window_coef*$window[id]
        total_zero_occupancy  += usage
      end
    end 
  end
  return total_zero_occupancy
end

def check_space(id ,day1, day2, schedule) 
  min = 10000000000
  for i in day1..day2
    day  = schedule[i]
    beds = day[id]
    if beds < min 
      min = beds
    end
  end

  return min
end

def update_space(id, day1, day2, num, schedule)
  for i in day1..day2
    day = schedule[i]
    day[id] = day[id] - num
    schedule[i] = day
  end
  return schedule 
end

#find the building that gives us least increment 
def least_increment(schedule)
  min = 100000;
  i = 0;

  schedule.each_index do |x|
    hash_id = x + 1
    hash_id = hash_id.to_s

    num = schedule[x]
    if (num + 1 <= $bed[hash_id] )
      increment = cost(hash_id,0,1,num+1) - cost(hash_id,0,1,num)  
      if increment < min
        min = increment
        i = x 
      end
    end
  end

  return i, min 
end

#calculate cost
def cost(id, day1, day2, occupant)
  usage = $intercept_coef[id] + $occup2_coef*occupant*occupant + $occup_coef[id]*occupant + $temp_coef[id]*$temp + $humd_coef*$humd + $food_coef*$food[id] + $chiller_coef*$chiller[id] + $window_coef*$window[id]+ $occup_temp*occupant*$temp

  usage = usage * (day2 - day1)

  return usage
end


#rank the building by cost from lowest to highest
def find_best(day1, day2, occupant)
  rank = {}
  for id in 1..8  
    id = id.to_s     
      usage = cost(id, day1, day2, occupant)
      rank[id] = usage

  end
  rank = Hash[rank.sort_by {|k, v| v}]
  return rank
end
  
end

#read some data from excel files
def write_data(filename, data)
  file = File.open(filename, "w") 
  data.each do |k, v|
    line = []
    line = v.join(",") 
    file.puts(k.to_s + "," + line)

  end
  file.close
end

#initialize the class 
calculator = EU.new

record = []
count_number = 0
command = gets.chomp


all = command.split
date1 = all[2]
year = Date.parse(date1).year
d1 = "11-05-" + year.to_s
d2 = "16-08-" + year.to_s


$first = Date.parse(d1).mjd
$last = Date.parse(d2).mjd


#initialize the schedule to record the occupancy data for each building 
schedule = {}
for i in $first..$last
  schedule[i] =  {"1" => 575,"2"=> 709,"3"=>1046,"4"=>1209,"5"=>1341,"6"=>442,"7"=>1196,"8"=>852}
end


total = 0

#read input from usser
while command != "Quit" do

  set = {}  

  information = command.split
  id = information[0] 
  set["id"] = id
  occupant = information[1].to_i
  set["occupant"] = occupant
  check_in = information[2]
  set["check_in"] = check_in 
  check_out = information[3]
  set["check_out"] = check_out

  #convert date to modified julian day  
  day1 = Date.parse(check_in).mjd
  day2 = Date.parse(check_out).mjd

  id = id.to_s
  num_bed = calculator.check_space(id,day1,day2,schedule)
  #check space 
  if num_bed >=  occupant  
    usage = calculator.cost(id, day1, day2, occupant)
    total +=  usage
    schedule = calculator.update_space(id, day1, day2, occupant, schedule)  
    record.push(set)
  else
    puts "Sorry no enough space in this building. Try another building."
    puts "Only #{num_bed} beds avaliable in building #{id} from #{check_in} to #{check_out}."
  end
  puts "Enter more: "
  command = gets.chomp
end

total_zero = calculator.add_zero(schedule) 
total += total_zero
total = total.round(3)
total_money = (total*0.041537).round(3)

puts "Total usage is: #{total} kwh, #{total_money} dollars for the whole summer"
puts ""
puts "---------------------------Optimal Solution1-----------------------------"


result = []
opt_total = 0
copy = {}
for i in $first..$last
  copy[i] =  {"1" => 575,"2"=> 709,"3"=>1046,"4"=>1209,"5"=>1341,"6"=>442,"7"=>1196,"8"=>852}
end


#puts record.to_s

record.each do |set|
  occupant = set["occupant"]
  check_in = set["check_in"]
  check_out = set["check_out"]

  day1 = Date.parse(check_in).mjd
  day2 = Date.parse(check_out).mjd
  
  #find a better building to produce less usage
  while occupant > 0 do
    rank = calculator.find_best(day1, day2, occupant)
    rank.each do |id, usage|
      num_beds = calculator.check_space(id,day1,day2,copy)
        if num_beds >= occupant
          set["id"] = id
          copy = calculator.update_space(id, day1, day2, occupant, copy)
          result.push(set)
          occupant = 0  
          opt_total += rank[id]
          break 
     end
    end
  end
end



total_zero = calculator.add_zero(copy)
opt_total = (opt_total+total_zero).round(3)
opt_total_money = (opt_total *0.041537).round(3) 
diff = (total - opt_total).round(3)
diff_money = (total_money-opt_total_money).round(3)

result.each do |set|
puts "Puts #{set["occupant"]} occupants into building #{set["id"]} from #{set["check_in"]} to #{set["check_out"]} ."  
end
puts "Optimal total usage is: #{opt_total} kwh, #{opt_total_money} dollars for the whole summer."
puts "And we save #{diff} kwh, #{diff_money} dollars"

#-----------------------------------------------------------------------

schedule2 = [0,0,0,0,0,0,0,0]
opt_total2 = 0

for i in 1..8
  opt_total2 += calculator.cost(i.to_s,0,1,0)
end


matrix = {}
#produce all possibility of combination without separating people 
for i in 0..1341
  rank = calculator.find_best(0,1,i)    
  set = []
  set2 = []
  rank.each {|k,v| set2.push(k)}
  for j in 1..8
    j = j.to_s
    set.push(set2.index(j) + 1) 
    j = j.to_i
  end
  matrix[i] = set
end

write_data("martix1.txt",matrix)


#produce all possibility of combination allowing to separate people
matrix2 = {}
for i in 1..7370
  id, increment = calculator.least_increment(schedule2)
  opt_total2 += increment
  opt_total2 = opt_total2.round(3)
  schedule2[id] = schedule2[id]+1
  matrix2[i] = schedule2.push(opt_total2)
  schedule2 = schedule2[0..7]
end        

#write out data in txt file
write_data("matrix2.txt", matrix2)


puts ""
puts "---------------------------Optimal Solution2-----------------------------"
puts "Give me the number of occupants(1-7370):                                         "
command = gets.chomp

while command != "Quit"
  building_info = matrix2[command.to_i]
  for i in 0..7
    people = building_info[i]
    if people > 0
      puts "Put #{people} in building #{i}."
    end
  end
puts "Give me the number of occupants(1-7370):                                         \
"
command = gets.chomp
end

puts ""
puts "-------------------------Comparison to last year-------------------------"



def read_data(filename)
  record = []
  file = File.open(filename,"r")
  words = file.readlines
  set = {}
  words.each do |w|
    w = w.split(',')
    set["id"] = w[1].to_s
    set["days"] = w[0].to_s
    set["occupant"] = w[2].to_i
    record.push(set)   
  end
  return record
end


schedule = {}
for i in 0..97
  schedule[i.to_s] =  {"1" => 575,"2"=> 709,"3"=>1046,"4"=>1209,"5"=>1341,"6"=>442,"7"=>1196,"8"=>852}
end

total = 0
opt_total = 0
#read occupancy data of last year
record = read_data("multilevel regression raw data.csv")

for i in 1..8
  opt_total += calculator.cost(i.to_s, 0, 1, 0)
end  
#adding zero occupancy
opt_total = opt_total * 98


#basing on the occupancy data of last year
#produce a better plan 
record.each do |set|
  id = set["id"]
  occupant = set["occupant"]
  days = set["days"]
  usage = calculator.cost(id, 0, 1, occupant)     
  total += usage

  rank = calculator.find_best(0, 1, occupant)
  space = schedule[days]

  if occupant != 0
    rank.each do |i, opt_usage|
      if space[i] >= occupant
        opt_total -= calculator.cost(i,0,1,0)
        opt_total += opt_usage
        #update the occupancy data for each building
        space[i] = space[i] - occupant
        schedule[days] = space[i] 
      break
      end
    end
  end
end

total = total.round(3)
total_money = (total * 0.041537).round(3)
puts "Estimated usage of last summer is #{total} kwh, #{total_money} dollars."
opt_total = opt_total.round(3)
opt_money = (opt_total * 0.041537).round(3)
puts "Estimated usage by model is #{opt_total} kwh, #{opt_money} dollars."
save_total = (total - opt_total).round(3) 
save_money = (total_money - opt_money).round(3) 
puts "Estimated save by model is #{save_total} kwh, #{save_money} dollars."
puts ""
command = gets.chomp
