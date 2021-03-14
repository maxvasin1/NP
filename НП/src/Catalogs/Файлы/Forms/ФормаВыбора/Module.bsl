
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.ВладелецФайла) Тогда 
		Список.Параметры.УстановитьЗначениеПараметра(
			"Владелец", Параметры.ВладелецФайла);
	
		Если ТипЗнч(Параметры.ВладелецФайла) = Тип("СправочникСсылка.ПапкиФайлов") Тогда
			Элементы.Папки.ТекущаяСтрока = Параметры.ВладелецФайла;
			Элементы.Папки.ВыделенныеСтроки.Очистить();
			Элементы.Папки.ВыделенныеСтроки.Добавить(Элементы.Папки.ТекущаяСтрока);
		Иначе
			Элементы.Папки.Видимость = Ложь;
		КонецЕсли;
	Иначе
		Если Параметры.ВыборШаблона Тогда
			
			ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
				Папки, "Ссылка", Справочники.ПапкиФайлов.Шаблоны,
				ВидСравненияКомпоновкиДанных.ВИерархии, , Истина);
			
			Элементы.Папки.ТекущаяСтрока = Справочники.ПапкиФайлов.Шаблоны;
			Элементы.Папки.ВыделенныеСтроки.Очистить();
			Элементы.Папки.ВыделенныеСтроки.Добавить(Элементы.Папки.ТекущаяСтрока);
		КонецЕсли;
		
		Список.Параметры.УстановитьЗначениеПараметра("Владелец", Элементы.Папки.ТекущаяСтрока);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.ТекущаяСтрока) Тогда 
		Элементы.Папки.ТекущаяСтрока = Параметры.ТекущаяСтрока;
	КонецЕсли;
	
	ПриИзмененияИспользованияПодписанияИлиШифрованияНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_Файл" И Параметр.Событие = "СозданФайл" Тогда
		
		Если Параметр <> Неопределено Тогда
			ВладелецФайла = Неопределено;
			Если Параметр.Свойство("Владелец", ВладелецФайла) Тогда
				Если ВладелецФайла = Элементы.Папки.ТекущаяСтрока Тогда
					Элементы.Список.Обновить();
					
					ФайлСозданный = Неопределено;
					Если Параметр.Свойство("Файл", ФайлСозданный) Тогда
						Элементы.Список.ТекущаяСтрока = ФайлСозданный;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ВРег(ИмяСобытия) = ВРег("Запись_НаборКонстант")
	   И (    ВРег(Источник) = ВРег("ИспользоватьЭлектронныеПодписи")
		  Или ВРег(Источник) = ВРег("ИспользоватьШифрование")) Тогда
			
		ПодключитьОбработчикОжидания("ПриИзмененияИспользованияПодписанияИлиШифрования", 0.3, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПапки

&НаКлиенте
Процедура ПапкиПриАктивизацииСтроки(Элемент)
	ПодключитьОбработчикОжидания("ОбработкаОжидания", 0.2, Истина);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ДобавитьФайл(Команда)
	ЗначениеПараметраКД = Список.Параметры.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Владелец"));
	Если ЗначениеПараметраКД = Неопределено Тогда
		ВладелецФайла = Неопределено;
	Иначе
		ВладелецФайла = ЗначениеПараметраКД.Значение;
	КонецЕсли;
	РаботаСФайламиСлужебныйКлиент.ДобавитьФайл(Неопределено, ВладелецФайла, ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура обновляет список Файлов.
&НаКлиенте
Процедура ОбработкаОжидания()
	
	Если Элементы.Папки.ТекущаяСтрока <> Неопределено Тогда
		Список.Параметры.УстановитьЗначениеПараметра("Владелец", Элементы.Папки.ТекущаяСтрока);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененияИспользованияПодписанияИлиШифрования()
	
	ПриИзмененияИспользованияПодписанияИлиШифрованияНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПриИзмененияИспользованияПодписанияИлиШифрованияНаСервере()
	
	ФайловыеФункцииСлужебный.КриптографияПриСозданииФормыНаСервере(ЭтотОбъект,, Истина);
	
КонецПроцедуры

#КонецОбласти
