# encoding: UTF-8
#напишем программу, которая показывает текущую погоду, используя свежие данные от Яндекса.
# Самостоятельно переделаю программу, используя данные от Метеосервиса, потому что данные 
# от Яндекса недоступны 
=begin
Задача 13-1: Усовершенствуйте программу «Погода», добавив прогноз на неделю.

Необходимые данные вы легко найдёте в XML-структуре от Яндекса.

Пример результата:

>ruby pogoda.rb
Сейчас 2015-09-22 14:04:26 +0400, погода в городе Москва:
17 градусов, пасмурно, ветер 2.0 м/с

Прогоноз погоды
22.09: 20, пасмурно
23.09: 22, малооблачно
24.09: 25, малооблачно
25.09: 27, малооблачно
26.09: 25, ясно
27.09: 22, дождь
28.09: 18, пасмурно
29.09: 17, пасмурно
30.09: 16, пасмурно
01.10: 16, пасмурно

Задача 13-2 Давайте ещё немного усовершенствуем программу «Погода».
Предложите пользователю указать, для какого города он хочет посмотреть погоду и прогноз.

XML со списком городов брать здесь: http://xml.meteoservice.ru/export/gismeteo/point/37.xml

Пример результата:

>ruby pogoda.rb
Для какого города хотите узнать погоду?
Краснодар
Сейчас 2015-09-22 14:06:30 +0400, погода в городе Краснодар:
31 градусов, ясно, ветер 3.0 м/с

Прогоноз погоды
22.09: 31, облачно с прояснениями
23.09: 31, малооблачно
24.09: 32, ясно
25.09: 30, ясно
26.09: 28, ясно
27.09: 30, пасмурно
28.09: 31, малооблачно
29.09: 30, пасмурно
30.09: 26, облачно с прояснениями
01.10: 25, пасмурно

Так как, xml файл метеосервиса содержит информацию только об одном городе, то решить эту задачу, так как
предполагается при использовании сервиса yandex не возможно. Сервис погоды yandex содержит
информацию обо всех городах в одном xml файле. Решать эту задачу не буду  
=end
# подключаем либы для работы с сетью и XML
require "net/http"
require "uri"
require "rexml/document"

#Для вашего города нужный ID (вместо 27612) найдите поиском по странице городов:
#https://pogoda.yandex.ru/static/cities.xml
# создаем объект-адрес где лежит погода Ижевска в виде XML
#uri = URI.parse("http://export.yandex.ru/weather-ng/forecasts/28411.xml") адрес от Яндекса редко доступен
# поэтому пользуемся сайтом метеосервиса
# сайт метосервиса http://www.meteoservice.ru/content/export.html
uri = URI.parse("http://xml.meteoservice.ru/export/gismeteo/point/182.xml") # адрес от Метеосервис Ижевска
# найти идентификатор своего города от Яндекса можете здесь:
# http://pogoda.yandex.ru/static/cities.xml
# Отправляем запрос по адресу uri, методом get_response с параметром uri и сохраняем результат
# в переменную response
response = Net::HTTP.get_response(uri)

# парсим полученный XML. Извлекаем тело запроса
doc = REXML::Document.new(response.body) if response.is_a?(Net::HTTPSuccess)

# не всегда запрос на получение доходит до сайта Яндекса , поэтому программа выполняется не с первого раза
=begin
# собираем параметры, полученные от Яндекса  из тела запроса формата XML
city_name = doc.root.attributes['exactname']
time = Time.now # время делаем текущее
temperature = doc.root.elements['fact/temperature'].text
pogoda = doc.root.elements['fact/weather_type'].text
wind = doc.root.elements['fact/wind_speed'].text
puts "Сейчас #{time}, погода в городе #{city_name}:"
puts "#{temperature} градусов, #{pogoda}, ветер #{wind} м/с"
=end
# собираем параметры, полученные от Метеосервиса  из тела запроса формата XML
time = Time.now # время делаем текущее
day = time.day # взяли текущее число месяца

doc.each_element('//FORECAST') do |currency_tag| # ищем каждый элемент с тегом FORECAST
  # извлекаем из текущего тега день прогноза
  tag_day = currency_tag.attributes['day'].to_i 
 
if tag_day == day # если нашли тег с прогнозом нашего дня
# собираем параметры полученные из тега
#city_name = doc.root.elements['//TOWN'].attributes['sname']#.encode("UTF-8") # название города 
# Ижевск кодируется словом %D0%98%D0%B6%D0%B5%D0%B2%D1%81%D0%BA, который мне не удалось перекодировать
#puts "#{city_name}".encode("UTF-8").force_encoding("KOI8-U").encode("KOI8-R")
# поэтому просто присваиваем переменной city_name название города:
city_name = 'Ижевск'
#puts "#{city_name}".encode("UTF-8").force_encoding("KOI8-U").encode("KOI8-R")
#pogoda = doc.root.elements['//FORECAST'].next_element.elements['//PHENOMENA'].attributes['cloudiness'].to_i
pogoda = currency_tag.elements['PHENOMENA'].attributes['cloudiness'].to_i
# команда next_element дает переход на следующий тег FORECAST
min_temperature = currency_tag.elements['TEMPERATURE'].attributes['min'] # минимальная температура
max_temperature = currency_tag.elements['TEMPERATURE'].attributes['max'] # максимальная температура
#pogoda = doc.root.elements['//PHENOMENA'].attributes['cloudiness'].to_i # шифрованная погода
# 0 - ясно, 1- малооблачно, 2 - облачно, 3 - пасмурно
#wish_input = STDIN.gets.encode("UTF-8").chomp
min_wind = currency_tag.elements['WIND'].attributes['min'] # минимальная скорость ветра
max_wind = currency_tag.elements['WIND'].attributes['max'] # максимальная скорость ветра
pressure = currency_tag.elements['PRESSURE'].attributes['min'] # миним давление
	case pogoda
     when 0 
      pogoda_type = 'ясно'
     when 1 
      pogoda_type = 'малооблачно'
     when 2 
      pogoda_type = 'облачно'
     when 3 
      pogoda_type = 'пасмурно' 
     else 
      pogoda_type = "непонятно"
	end

puts "Сейчас #{time}, погода в городе #{city_name}:"
puts "#{min_temperature}...#{max_temperature} градусов, #{pogoda_type}," +
" ветер #{min_wind}...#{max_wind} м/с," + " давление #{pressure} мм. рт. ст."
	
	break
else puts "прогноз не найден"
end
end
  
puts 'Прогноз погоды'

doc.each_element('//FORECAST') do |currency_tag| # ищем каждый элемент с тегом FORECAST
  # извлекаем из текущего тега день прогноза

tag_day = currency_tag.attributes['day'].to_i 

  if tag_day != day # если тег не совпадает с прогнозом нашего дня

hour = currency_tag.attributes['hour'] #час
month = currency_tag.attributes['month'] # месяц
year = currency_tag.attributes['year'] #год

min_temperature = currency_tag.elements['TEMPERATURE'].attributes['min'] # минимальная температура
max_temperature = currency_tag.elements['TEMPERATURE'].attributes['max'] # максимальная температура
pogoda = currency_tag.elements['PHENOMENA'].attributes['cloudiness'].to_i # шифрованная погода
# 0 - ясно, 1- малооблачно, 2 - облачно, 3 - пасмурно

    case pogoda
     when 0 
      pogoda_type = 'ясно'
     when 1 
      pogoda_type = 'малооблачно'
     when 2 
      pogoda_type = 'облачно'
     when 3 
      pogoda_type = 'пасмурно' 
     else 
      pogoda_type = "непонятно"
    end

puts "#{tag_day}.#{month}.#{year}, #{hour} часов: " + 
"#{min_temperature}...#{max_temperature} градусов, #{pogoda_type}"

  end

end

=begin
city_name = doc.root.attributes['//exactname']
temperature = doc.root.elements['fact/temperature'].text
pogoda = doc.root.elements['fact/weather_type'].text
wind = doc.root.elements['fact/wind_speed'].text
puts "Сейчас #{time}, погода в городе #{city_name}:"
puts "#{temperature} градусов, #{pogoda}, ветер #{wind} м/с"
=end