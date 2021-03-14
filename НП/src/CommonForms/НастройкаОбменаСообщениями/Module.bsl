
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначенияПовтИсп.РазделениеВключено()
		И ОбщегоНазначенияПовтИсп.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru = 'Настройка подсистемы в разделенном режиме не поддерживается.'"),,,, Отказ);
		Возврат;
	КонецЕсли;
	
	ОбновитьСписокСостоянияУзлов();
	
	УстановитьПривилегированныйРежим(Истина);
	
	Элементы.СписокСостоянияУзловВключитьОтключитьРасписаниеОтправкиИПолученияСообщенийСистемы.Пометка =
		РегламентныеЗаданияСервер.РегламентноеЗаданиеИспользуется(
			Метаданные.РегламентныеЗадания.ОтправкаИПолучениеСообщенийСистемы);;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если    ИмяСобытия = ОбменСообщениямиКлиент.ИмяСобытияВыполненаОтправкаИПолучениеСообщений()
		ИЛИ ИмяСобытия = ОбменСообщениямиКлиент.ИмяСобытияЗакрытаФормаКонечнойТочки()
		ИЛИ ИмяСобытия = ОбменСообщениямиКлиент.ИмяСобытияДобавленаКонечнаяТочка()
		ИЛИ ИмяСобытия = ОбменСообщениямиКлиент.ИмяСобытияУстановленаВедущаяКонечнаяТочка() Тогда
		
		ОбновитьДанныеМонитора();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СписокСостоянияУзловВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ИзменитьКонечнуюТочку(Неопределено);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодключитьКонечнуюТочку(Команда)
	
	ОткрытьФорму("ОбщаяФорма.ПодключениеКонечнойТочки",, ЭтотОбъект, 1);
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьПодписки(Команда)
	
	ОткрытьФорму("РегистрСведений.ПодпискиПолучателей.Форма.НастройкаПодписокЭтойКонечнойТочки",, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьИПолучитьСообщения(Команда)
	
	ОбменСообщениямиКлиент.ОтправитьИПолучитьСообщения();
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьКонечнуюТочку(Команда)
	
	ТекущиеДанные = Элементы.СписокСостоянияУзлов.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПоказатьЗначение(, ТекущиеДанные.УзелИнформационнойБазы);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиВЖурналРегистрацииСобытийВыгрузкиДанных(Команда)
	
	ТекущиеДанные = Элементы.СписокСостоянияУзлов.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОбменДаннымиКлиент.ПерейтиВЖурналРегистрацииСобытийДанныхМодально(ТекущиеДанные.УзелИнформационнойБазы, ЭтотОбъект, "ВыгрузкаДанных");
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиВЖурналРегистрацииСобытийЗагрузкиДанных(Команда)
	
	ТекущиеДанные = Элементы.СписокСостоянияУзлов.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОбменДаннымиКлиент.ПерейтиВЖурналРегистрацииСобытийДанныхМодально(ТекущиеДанные.УзелИнформационнойБазы, ЭтотОбъект, "ЗагрузкаДанных");
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьРасписаниеОтправкиИПолученияСообщенийСистемы(Команда)
	
	Диалог = Новый ДиалогРасписанияРегламентногоЗадания(ПолучитьРасписание());
	ОписаниеОповещения = Новый ОписаниеОповещения("УстановитьРасписаниеОтправкиИПолученияСообщенийСистемы", ЭтотОбъект);
	Диалог.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьРасписаниеОтправкиИПолученияСообщенийСистемы(Расписание, ДополнительныеПараметры) Экспорт
	
	Если Расписание <> Неопределено Тогда
		
		УстановитьРасписание(Расписание);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьОтключитьРасписаниеОтправкиИПолученияСообщенийСистемы(Команда)
	
	ВключитьОтключитьРасписаниеОтправкиИПолученияСообщенийСистемыНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьМонитор(Команда)
	
	ОбновитьДанныеМонитора();
	
КонецПроцедуры

&НаКлиенте
Процедура Подробно(Команда)
	
	ПодробноНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВключитьОтключитьРасписаниеОтправкиИПолученияСообщенийСистемыНаСервере()
	
	УстановитьПривилегированныйРежим(Истина);
	
	Элементы.СписокСостоянияУзловВключитьОтключитьРасписаниеОтправкиИПолученияСообщенийСистемы.Пометка =
		НЕ РегламентныеЗаданияСервер.РегламентноеЗаданиеИспользуется(
			Метаданные.РегламентныеЗадания.ОтправкаИПолучениеСообщенийСистемы);
	
	РегламентныеЗаданияСервер.УстановитьИспользованиеРегламентногоЗадания(
		Метаданные.РегламентныеЗадания.ОтправкаИПолучениеСообщенийСистемы,
		Элементы.СписокСостоянияУзловВключитьОтключитьРасписаниеОтправкиИПолученияСообщенийСистемы.Пометка);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьРасписание()
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат РегламентныеЗаданияСервер.РасписаниеРегламентногоЗадания(
		Метаданные.РегламентныеЗадания.ОтправкаИПолучениеСообщенийСистемы);
	
КонецФункции

&НаСервереБезКонтекста
Процедура УстановитьРасписание(Знач Расписание)
	
	УстановитьПривилегированныйРежим(Истина);
	
	РегламентныеЗаданияСервер.УстановитьРасписаниеРегламентногоЗадания(
		Метаданные.РегламентныеЗадания.ОтправкаИПолучениеСообщенийСистемы,
		Расписание);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокСостоянияУзлов()
	
	СписокСостоянияУзлов.Очистить();
	
	Массив = Новый Массив;
	Массив.Добавить("ОбменСообщениями");
	
	МонитораОбменаДанными = ОбменДаннымиСервер.ТаблицаМонитораОбменаДанными(Массив, "Ведущая,Заблокирована");
	
	// Обновляем данные в списке состояния узлов.
	Для Каждого Настройка Из МонитораОбменаДанными Цикл
		
		Если Настройка.Заблокирована Тогда
			Продолжить;
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(СписокСостоянияУзлов.Добавить(), Настройка);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеМонитора()
	
	ИндексСтрокиСписокСостоянияУзлов = ПолучитьТекущийИндексСтроки("СписокСостоянияУзлов");
	
	// Выполняем обновление таблиц монитора на сервере.
	ОбновитьСписокСостоянияУзлов();
	
	// Выполняем позиционирование курсора.
	ВыполнитьПозиционированиеКурсора("СписокСостоянияУзлов", ИндексСтрокиСписокСостоянияУзлов);
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьТекущийИндексСтроки(ИмяТаблицы)
	
	// Возвращаемое значение функции.
	ИндексСтроки = Неопределено;
	
	// При обновлении монитора выполняем позиционирование курсора.
	ТекущиеДанные = Элементы[ИмяТаблицы].ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено Тогда
		
		ИндексСтроки = ЭтотОбъект[ИмяТаблицы].Индекс(ТекущиеДанные);
		
	КонецЕсли;
	
	Возврат ИндексСтроки;
КонецФункции

&НаКлиенте
Процедура ВыполнитьПозиционированиеКурсора(ИмяТаблицы, ИндексСтроки)
	
	Если ИндексСтроки <> Неопределено Тогда
		
		// Выполняем проверки позиционирования курсора после получения новых данных.
		Если ЭтотОбъект[ИмяТаблицы].Количество() <> 0 Тогда
			
			Если ИндексСтроки > ЭтотОбъект[ИмяТаблицы].Количество() - 1 Тогда
				
				ИндексСтроки = ЭтотОбъект[ИмяТаблицы].Количество() - 1;
				
			КонецЕсли;
			
			// позиционируем курсор
			Элементы[ИмяТаблицы].ТекущаяСтрока = ЭтотОбъект[ИмяТаблицы][ИндексСтроки].ПолучитьИдентификатор();
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПодробноНаСервере()
	
	Элементы.СписокСостоянияУзловПодробно.Пометка = Не Элементы.СписокСостоянияУзловПодробно.Пометка;
	
	Элементы.СписокСостоянияУзловДатаПоследнейЗагрузки.Видимость = Элементы.СписокСостоянияУзловПодробно.Пометка;
	Элементы.СписокСостоянияУзловДатаПоследнейВыгрузки.Видимость = Элементы.СписокСостоянияУзловПодробно.Пометка;
	
КонецПроцедуры

#КонецОбласти
