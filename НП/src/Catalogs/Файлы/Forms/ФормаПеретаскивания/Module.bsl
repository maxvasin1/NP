
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	ПапкаДляДобавления = Параметры.ПапкаДляДобавления;
	
	Для Каждого путьФайла Из Параметры.МассивИменФайлов Цикл
		СписокИменФайлов.Добавить(путьФайла);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	#Если ВебКлиент Тогда
		ТекстПредупреждения =
			НСтр("ru = 'В Веб-клиенте импорт файлов не поддерживается.
			           |Используйте команду ""Создать"" в списке файлов.'");
		ПоказатьПредупреждение(, ТекстПредупреждения);
		Отказ = Истина;
		Возврат;
	#КонецЕсли
	
	ХранитьВерсии = Истина;
	ТолькоКаталоги = Истина;
	
	Для Каждого ПутьФайла Из СписокИменФайлов Цикл
		ЗаполнитьСписокФайлов(ПутьФайла, ДеревоФайлов.ПолучитьЭлементы(), Истина, ТолькоКаталоги);
	КонецЦикла;
	
	Если ТолькоКаталоги Тогда
		Заголовок = НСтр("ru = 'Загрузка папок'");
	КонецЕсли;
	
	Состояние();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	Если ВРег(ИсточникВыбора.ИмяФормы) = ВРег("Справочник.Файлы.Форма.ВыборКодировки") Тогда
		Если ТипЗнч(ВыбранноеЗначение) <> Тип("Структура") Тогда
			Возврат;
		КонецЕсли;
		КодировкаТекстаФайла = ВыбранноеЗначение.Значение;
		КодировкаПредставление = ВыбранноеЗначение.Представление;
		УстановитьПредставлениеКомандыКодировки(КодировкаПредставление);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыДеревоФайлов

&НаКлиенте
Процедура ДеревоФайловПометкаПриИзменении(Элемент)
	ЭлементДанных = ДеревоФайлов.НайтиПоИдентификатору(Элементы.ДеревоФайлов.ТекущаяСтрока);
	УстановитьПометку(ЭлементДанных, ЭлементДанных.Пометка);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗагрузитьФайлы()
	
	ОчиститьСообщения();
	
	ПоляНеЗаполнены = Ложь;
	
	ПсевдоФайловаяСистема = Новый Соответствие; // Соответствие путь к директории - файлы и папки в ней.
	
	ВыбранныеФайлы = Новый СписокЗначений;
	Для Каждого файлВложенный Из ДеревоФайлов.ПолучитьЭлементы() Цикл
		Если файлВложенный.Пометка = Истина Тогда
			ВыбранныеФайлы.Добавить(файлВложенный.ПолныйПуть);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ФайлВложенный Из ДеревоФайлов.ПолучитьЭлементы() Цикл
		ЗаполнитьФайловуюСистему(ПсевдоФайловаяСистема, ФайлВложенный);
	КонецЦикла;
	
	Если ВыбранныеФайлы.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru = 'Нет файлов для добавления.'"), , "ВыбранныеФайлы");
		ПоляНеЗаполнены = Истина;
	КонецЕсли;
	
	Если ПапкаДляДобавления.Пустая() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru = 'Укажите папку.'"), , "ПапкаДляДобавления");
		ПоляНеЗаполнены = Истина;
	КонецЕсли;
	
	Если ПоляНеЗаполнены = Истина Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыВыполнения = РаботаСФайламиСлужебныйКлиент.ПараметрыИмпортаФайлов();
	ПараметрыВыполнения.ОбработчикРезультата = Новый ОписаниеОповещения("ДобавитьВыполнитьПослеИмпорта", ЭтотОбъект);
	ПараметрыВыполнения.Владелец = ПапкаДляДобавления;
	ПараметрыВыполнения.ВыбранныеФайлы = ВыбранныеФайлы; 
	ПараметрыВыполнения.Комментарий = Комментарий;
	ПараметрыВыполнения.ХранитьВерсии = ХранитьВерсии;
	ПараметрыВыполнения.УдалятьФайлыПослеДобавления = УдалятьФайлыПослеДобавления;
	ПараметрыВыполнения.Рекурсивно = Истина;
	ПараметрыВыполнения.ИдентификаторФормы = УникальныйИдентификатор;
	ПараметрыВыполнения.ПсевдоФайловаяСистема = ПсевдоФайловаяСистема;
	ПараметрыВыполнения.Кодировка = КодировкаТекстаФайла;
	РаботаСФайламиСлужебныйКлиент.ВыполнитьИмпортФайлов(ПараметрыВыполнения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьКодировку(Команда)
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ТекущаяКодировка", КодировкаТекстаФайла);
	ОткрытьФорму("Справочник.Файлы.Форма.ВыборКодировки", ПараметрыФормы, ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ДобавитьВыполнитьПослеИмпорта(Результат, ПараметрыВыполнения) Экспорт
	Закрыть();
	Оповестить("ИмпортКаталоговЗавершен", Новый Структура, Результат.ПапкаДляДобавленияТекущая);
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьСписокФайлов(ПутьФайла, Знач ЭлементыДерева, ЭлементВерхнегоУровня, ТолькоКаталоги = Неопределено)
	
	ФайлПеренесенный = Новый Файл(ПутьФайла);
	
	НовыйЭлемент = ЭлементыДерева.Добавить();
	НовыйЭлемент.ПолныйПуть = ФайлПеренесенный.ПолноеИмя;
	НовыйЭлемент.ИмяФайла = ФайлПеренесенный.Имя;
	НовыйЭлемент.Пометка = Истина;
	
	Если ФайлПеренесенный.Расширение = "" Тогда
		НовыйЭлемент.ИндексКартинки = 2; // папка
	Иначе
		НовыйЭлемент.ИндексКартинки = ФайловыеФункцииСлужебныйКлиентСервер.ПолучитьИндексПиктограммыФайла(ФайлПеренесенный.Расширение);
	КонецЕсли;
		
	Если ФайлПеренесенный.ЭтоКаталог() Тогда
		
		Путь = ФайлПеренесенный.ПолноеИмя + ПолучитьРазделительПути();
		
		Если ЭлементВерхнегоУровня = Истина Тогда
			Состояние(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Идет сбор информации о каталоге
				           |""%1"".
				           |Пожалуйста, подождите.'"),
				Путь));
		КонецЕсли;
		
		НайденныеФайлы = НайтиФайлы(Путь, "*.*");
		
		ФайлСортированные = Новый Массив;
		
		// папки сперва
		Для Каждого ФайлВложенный Из НайденныеФайлы Цикл
			Если ФайлВложенный.ЭтоКаталог() Тогда
				ФайлСортированные.Добавить(ФайлВложенный.ПолноеИмя);
			КонецЕсли;
		КонецЦикла;
		
		// потом файлы
		Для Каждого ФайлВложенный Из НайденныеФайлы Цикл
			Если НЕ ФайлВложенный.ЭтоКаталог() Тогда
				ФайлСортированные.Добавить(ФайлВложенный.ПолноеИмя);
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого ФайлВложенный Из ФайлСортированные Цикл
			ЗаполнитьСписокФайлов(ФайлВложенный, НовыйЭлемент.ПолучитьЭлементы(), Ложь);
		КонецЦикла;
		
	Иначе
		
		Если ЭлементВерхнегоУровня Тогда
			ТолькоКаталоги = Ложь;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьФайловуюСистему(ПсевдоФайловаяСистема, ЭлементДерева)
	Если ЭлементДерева.Пометка = Истина Тогда
		ДочерниеЭлементы = ЭлементДерева.ПолучитьЭлементы();
		Если ДочерниеЭлементы.Количество() <> 0 Тогда
			
			ФайлыИПодпапки = Новый Массив;
			Для Каждого ФайлВложенный Из ДочерниеЭлементы Цикл
				ЗаполнитьФайловуюСистему(ПсевдоФайловаяСистема, ФайлВложенный);
				
				Если ФайлВложенный.Пометка = Истина Тогда
					ФайлыИПодпапки.Добавить(ФайлВложенный.ПолныйПуть);
				КонецЕсли;
			КонецЦикла;
			
			ПсевдоФайловаяСистема.Вставить(ЭлементДерева.ПолныйПуть, ФайлыИПодпапки);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

// Рекурсивно ставит пометку всем дочерним элементам.
&НаКлиенте
Процедура УстановитьПометку(ЭлементДерева, Пометка)
	ДочерниеЭлементы = ЭлементДерева.ПолучитьЭлементы();
	
	Для Каждого ФайлВложенный Из ДочерниеЭлементы Цикл
		ФайлВложенный.Пометка = Пометка;
		УстановитьПометку(ФайлВложенный, Пометка);
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура УстановитьПредставлениеКомандыКодировки(Представление)
	
	Команды.ВыбратьКодировку.Заголовок = Представление;
	
КонецПроцедуры

#КонецОбласти
