#Область ОписаниеПеременных

&НаКлиенте
Перем ПараметрыОбработчикаОжидания;
&НаКлиенте
Перем ОтключитьФормированиеОтчета;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей") Тогда
		ТекстИсключения = НСтр("ru='Формирование отчета ""Досье контрагента"" в данной конфигурации невозможно.'");
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.Контрагент) Тогда
		ИННКонтрагента = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Параметры.Контрагент, "ИНН");
		Если ЗначениеЗаполнено(ИННКонтрагента) Тогда
			СтрокаПоиска = ИННКонтрагента;
			Контрагент   = Параметры.Контрагент;
		КонецЕсли;
	ИначеЕсли ЗначениеЗаполнено(Параметры.ИНН) Тогда
		СтрокаПоиска = Параметры.ИНН;
	КонецЕсли;
	
	ОписаниеДанныхПрограммы = Отчеты.ДосьеКонтрагента.НоваяТаблицаОписаниеДанныхПрограммы();
	РаботаСКонтрагентамиПереопределяемый.ЗаполнитьОписаниеДанныхПрограммы(ОписаниеДанныхПрограммы);
	ПоказатьДанныеПрограммы = ОписаниеДанныхПрограммы.Количество() > 0;
	Элементы.ДекорацияРазделДанныеПрограммы.Видимость = ПоказатьДанныеПрограммы;
	
	ПоискПоИНН = СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(СтрокаПоиска);
	Если ПоискПоИНН 
		И (СтрДлина(СтрокаПоиска) = 10 
		ИЛИ СтрДлина(СтрокаПоиска) = 12) Тогда
		ИННПоиска = СтрокаПоиска;
		ЭтоЮридическоеЛицо = СтрДлина(ИННПоиска) = 10;
		СформироватьОтчетНаСервере();
	Иначе
		ЭтоЮридическоеЛицо = Истина;
		УправлениеФормойНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ИмяДокумента = ?(ЭтоЮридическоеЛицо, "РезультатГлавное", "РезультатДанныеГосРеестров");
	
	Если ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		ПодключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания", 0.5, Истина);
		ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(
			Элементы[ИмяДокумента], "ФормированиеОтчета");
	ИначеЕсли ЗначениеЗаполнено(ОписаниеОшибки) Тогда
		ПодключитьОбработчикОжидания("Подключаемый_ПоказатьПредупреждениеОбОшибке", 0.1, Истина);
	ИначеЕсли ОжиданиеОтвета Тогда
		ПодключитьОбработчикОжидания("Подключаемый_СформироватьОтчет", 3, Истина);
		ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(
			Элементы[ИмяДокумента], "ФормированиеОтчета");
	КонецЕсли;
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы["Группа" + ИмяДокумента];
	Если ЗначениеЗаполнено(ИдентификаторЗадания)
		ИЛИ ОжиданиеОтвета 
		ИЛИ ЭтотОбъект[ИмяДокумента].ВысотаТаблицы > 0 Тогда
		ТекущийЭлемент = Элементы[ИмяДокумента];
	Иначе
		ТекущийЭлемент = Элементы.СтрокаПоиска;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ОтменитьВыполнениеЗадания(ИдентификаторЗадания);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
 
#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СтрокаПоискаПриИзменении(Элемент)
	
	СформироватьОтчетНаКлиенте(СтрокаПоиска);
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРазделГлавноеНажатие(Элемент)
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы.ГруппаРезультатГлавное;
	ТекущийЭлемент = Элементы.РезультатГлавное;
	УстановитьСвойстваЗаголовкамРазделовНаСервере("Главное");
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРазделДанныеГосРеестровНажатие(Элемент)
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы.ГруппаРезультатДанныеГосРеестров;
	ТекущийЭлемент = Элементы.РезультатДанныеГосРеестров;
	УстановитьСвойстваЗаголовкамРазделовНаСервере("ДанныеГосРеестров");
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРазделДанныеПрограммыНажатие(Элемент)
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы.ГруппаРезультатДанныеПрограммы;
	ТекущийЭлемент = Элементы.РезультатДанныеПрограммы;
	УстановитьСвойстваЗаголовкамРазделовНаСервере("ДанныеПрограммы");
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРазделБухгалтерскаяОтчетностьНажатие(Элемент)
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы.ГруппаРезультатБухгалтерскаяОтчетность;
	ТекущийЭлемент = Элементы.РезультатБухгалтерскаяОтчетность;
	УстановитьСвойстваЗаголовкамРазделовНаСервере("БухгалтерскаяОтчетность");
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРазделАнализОтчетностиНажатие(Элемент)
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы.ГруппаРезультатАнализОтчетности;
	ТекущийЭлемент = Элементы.РезультатАнализОтчетности;
	УстановитьСвойстваЗаголовкамРазделовНаСервере("АнализОтчетности");
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРазделФинансовыйАнализНажатие(Элемент)
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы.ГруппаРезультатФинансовыйАнализ;
	ТекущийЭлемент = Элементы.РезультатФинансовыйАнализ;
	УстановитьСвойстваЗаголовкамРазделовНаСервере("ФинансовыйАнализ");
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРазделПроверкиНажатие(Элемент)
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = Элементы.ГруппаРезультатПроверки;
	ТекущийЭлемент = Элементы.РезультатПроверки;
	УстановитьСвойстваЗаголовкамРазделовНаСервере("Проверки");
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатДанныеГосРеестровОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	ОбработатьРасшифровкуТабличногоДокумента(Расшифровка, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатДанныеПрограммыОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	ОбработатьРасшифровкуТабличногоДокумента(Расшифровка, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатФинансовыйАнализОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	ОбработатьРасшифровкуТабличногоДокумента(Расшифровка, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатПроверкиОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	ОбработатьРасшифровкуТабличногоДокумента(Расшифровка, СтандартнаяОбработка);
	
КонецПроцедуры

#КонецОбласти
 
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СформироватьОтчет(Команда)
	
	Если ОтключитьФормированиеОтчета <> Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтрокаПоиска) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru='Поле ""ИНН или наименование контрагента"" не заполнено'"), , "СтрокаПоиска");
		Возврат;
	КонецЕсли;
	
	СформироватьОтчетНаКлиенте(СтрокаПоиска);
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьВСправочник(Команда)
	
	СвойстваКонтрагентов = ПроверкаКонтрагентовКлиентСервер.СвойстваСправочникаКонтрагенты();
	Если НЕ ЗначениеЗаполнено(СвойстваКонтрагентов.Имя)
		ИЛИ НЕ ЗначениеЗаполнено(НайденныйИНН) Тогда
		Возврат;
	КонецЕсли;
	ПараметрыФормы = Новый Структура("ТекстЗаполнения", НайденныйИНН);
	ОткрытьФорму("Справочник." + СвойстваКонтрагентов.Имя + ".ФормаОбъекта", ПараметрыФормы);
	
КонецПроцедуры

#КонецОбласти
 
#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УправлениеФормойНаСервере()
	
	Если ЗначениеЗаполнено(НаименованиеКонтрагента) Тогда
		Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Досье контрагента: %1'"),
			НаименованиеКонтрагента);
	ИначеЕсли ЗначениеЗаполнено(Контрагент) Тогда
		Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Досье контрагента: %1'"),
			Контрагент);
	Иначе
		Заголовок = НСтр("ru='Досье контрагента'");
	КонецЕсли;
	Элементы.ДекорацияРазделДанныеГосРеестров.Заголовок = ?(ЭтоЮридическоеЛицо, 
		НСтр("ru='ЕГРЮЛ'"), 
		НСтр("ru='ЕГРИП'"));
	
	Элементы.ДекорацияРазделГлавное.Видимость = ЭтоЮридическоеЛицо;
	Элементы.ДекорацияРазделБухгалтерскаяОтчетность.Видимость = ЭтоЮридическоеЛицо;
	Элементы.ДекорацияРазделАнализОтчетности.Видимость        = ЭтоЮридическоеЛицо;
	Элементы.ДекорацияРазделФинансовыйАнализ.Видимость        = ЭтоЮридическоеЛицо;
	
	СвойстваКонтрагентов = ПроверкаКонтрагентовКлиентСервер.СвойстваСправочникаКонтрагенты();
	Элементы.КнопкаДобавитьВСправочник.Видимость = ЗначениеЗаполнено(СвойстваКонтрагентов.Имя)
		И НЕ ЗначениеЗаполнено(Контрагент) 
		И ЗначениеЗаполнено(НайденныйИНН);
	
	Элементы.ГруппаРезультат.ТекущаяСтраница = ?(ЭтоЮридическоеЛицо, 
		Элементы.ГруппаРезультатГлавное, 
		Элементы.ГруппаРезультатДанныеГосРеестров);
	ТекущийЭлемент = ?(ЗначениеЗаполнено(ОписаниеОшибки), 
		Элементы.СтрокаПоиска, 
		?(ЭтоЮридическоеЛицо, Элементы.РезультатГлавное, Элементы.РезультатДанныеГосРеестров));
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСкрытьОбластьДокумента(Расшифровка)
	
	Если НЕ Расшифровка.Свойство("ИмяОбласти") Тогда
		Возврат;
	КонецЕсли;
	
	Отбор = Новый Структура("ИмяДокумента,ИмяОбласти", Расшифровка.ИмяДокумента, Расшифровка.ИмяОбласти);
	СтрокиТаблицы = ОбластиРасшифровки.НайтиСтроки(Отбор);
	Если СтрокиТаблицы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	СтрокаОбласти = СтрокиТаблицы[0];
	
	НомерСтрокиЕще = СтрокаОбласти.ПерваяСтрока - 1;
	
	ТабличныйДокумент = ЭтотОбъект[Расшифровка.ИмяДокумента];
	Если Расшифровка.Действие = "Показать" Тогда
		ТабличныйДокумент.Область(НомерСтрокиЕще, , НомерСтрокиЕще).Видимость = Ложь;
		ТабличныйДокумент.Область(СтрокаОбласти.ПерваяСтрока, , СтрокаОбласти.ПоследняяСтрока).Видимость = Истина;
		Элементы[Расшифровка.ИмяДокумента].ТекущаяОбласть = ТабличныйДокумент.Область(СтрокаОбласти.ПоследняяСтрока, 3);
	Иначе // "Свернуть"
		ТабличныйДокумент.Область(НомерСтрокиЕще, , НомерСтрокиЕще).Видимость = Истина;
		ТабличныйДокумент.Область(СтрокаОбласти.ПерваяСтрока, , СтрокаОбласти.ПоследняяСтрока).Видимость = Ложь;
		Элементы[Расшифровка.ИмяДокумента].ТекущаяОбласть = ТабличныйДокумент.Область(НомерСтрокиЕще, 3);
	КонецЕсли;
	
КонецПроцедуры 

&НаКлиенте
Процедура СформироватьОтчетНаКлиенте(ТекстПоиска)
	
	Если НЕ ЗначениеЗаполнено(ТекстПоиска) Тогда
		Возврат;
	КонецЕсли;
	
	ПоискПоИНН = СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(ТекстПоиска);
	Если ПоискПоИНН Тогда
		
		Если СтрДлина(ТекстПоиска) <> 10 
			И СтрДлина(ТекстПоиска) <> 12 Тогда
			ТекстОшибки = НСтр("ru='Для поиска по ИНН необходимо ввести 10 или 12 цифр.'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки, , "СтрокаПоиска");
			Возврат;
		КонецЕсли;
		
		ИННПоиска = ТекстПоиска;
		
		ЭтоЮридическоеЛицо = СтрДлина(ИННПоиска) = 10;
		
		ИмяДокумента = ?(ЭтоЮридическоеЛицо, "РезультатГлавное", "РезультатДанныеГосРеестров");
		ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(
			Элементы[ИмяДокумента], "ФормированиеОтчета");
		
		Результат = СформироватьОтчетНаСервере();
		
		Если НЕ Результат Тогда
			ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
			ПодключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания", 1, Истина);
		Иначе
			
			ОбработатьОшибкиФормированияОтчета();
			
			Если ОжиданиеОтвета Тогда
				// Повторный вызов процедуры формирования при асинхронном получении данных от сервиса.
				ПодключитьОбработчикОжидания("Подключаемый_СформироватьОтчет", 3, Истина);
			Иначе
				Если НЕ ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
					ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(
						Элементы[ИмяДокумента], "НеИспользовать");
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе // Поиск по наименованию
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("СтрокаПоиска", ТекстПоиска);
		ПараметрыФормы.Вставить("Заголовок",    НСтр("ru='Поиск контрагента'"));
		ДопПараметры = Новый Структура;
		ОписаниеОповещения = Новый ОписаниеОповещения("НайтиПоНаименованиюЗавершение", ЭтотОбъект, ДопПараметры);
		ОткрытьФорму("ОбщаяФорма.ЗаполнениеРеквизитовКонтрагента", 
			ПараметрыФормы, ЭтотОбъект, , , , ОписаниеОповещения);
		
	КонецЕсли;
	
	ОтключитьФормированиеОтчета = Истина;
	ПодключитьОбработчикОжидания("Подключаемый_ВключитьФормированиеОтчета", 0.1, Истина);
	
КонецПроцедуры

&НаСервере
Функция СформироватьОтчетНаСервере()
	
	ИдентификаторЗадания = Неопределено;
	ОписаниеОшибки       = "";
	
	Если НЕ ПроверитьЗаполнение() Тогда 
		Возврат Истина;
	КонецЕсли;
	
	ПараметрыОтчета = Новый Структура;
	ПараметрыОтчета.Вставить("ИНН", ИННПоиска);
	Если ЗначениеЗаполнено(Контрагент)
		И ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Контрагент, "ИНН") <> ИННПоиска Тогда
		Контрагент = Неопределено;
	КонецЕсли;
	ПараметрыОтчета.Вставить("Контрагент", Контрагент);
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(Новый УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru='Формирование отчета: Досье контрагента: %1'"), 
		ИННПоиска);
	РезультатВыполнения = ДлительныеОперации.ВыполнитьВФоне("Отчеты.ДосьеКонтрагента.СформироватьОтчет", 
		ПараметрыОтчета, 
		ПараметрыВыполнения);
		
	АдресХранилища = РезультатВыполнения.АдресРезультата;
	
	Если РезультатВыполнения.Статус <> "Выполняется" Тогда
		ИдентификаторЗадания = Неопределено;
		Если РезультатВыполнения.Статус = "Выполнено" Тогда
			ЗагрузитьПодготовленныеДанные();
		КонецЕсли;
	Иначе
		ИдентификаторЗадания = РезультатВыполнения.ИдентификаторЗадания;
	КонецЕсли;
	
	Возврат РезультатВыполнения.Статус <> "Выполняется";

КонецФункции

&НаКлиенте
Процедура Подключаемый_ПоказатьПредупреждениеОбОшибке()
	
	ОбработатьОшибкиФормированияОтчета();

КонецПроцедуры 

&НаКлиенте
Процедура Подключаемый_ПроверитьВыполнениеЗадания()
	
	Если НЕ ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗаданиеВыполнено(ИдентификаторЗадания) Тогда
		
		ИдентификаторЗадания = Неопределено;
		ЗагрузитьПодготовленныеДанные();
		
		ОбработатьОшибкиФормированияОтчета();
		
		Если ОжиданиеОтвета Тогда
			// Повторный вызов процедуры формирования при асинхронном получении данных от сервиса.
			ПодключитьОбработчикОжидания("Подключаемый_СформироватьОтчет", 3, Истина);
		Иначе
			ИмяДокумента = ?(ЭтоЮридическоеЛицо, "РезультатГлавное", "РезультатДанныеГосРеестров");
			ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(
				Элементы[ИмяДокумента], "НеИспользовать");
		КонецЕсли;
		
	Иначе
		ДлительныеОперацииКлиент.ОбновитьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		ПодключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания",
			ПараметрыОбработчикаОжидания.ТекущийИнтервал,
			Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ВключитьФормированиеОтчета()

	ОтключитьФормированиеОтчета = Неопределено;

КонецПроцедуры 

&НаКлиенте
Процедура Подключаемый_СформироватьОтчет()

	СформироватьОтчетНаКлиенте(ИННПоиска);

КонецПроцедуры 

&НаКлиенте
Процедура ПодключитьИнтернетПоддержку(Ответ, ДопПараметры) Экспорт

	Если Ответ = КодВозвратаДиалога.Да 
		И ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей") Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПодключитьИнтернетПоддержкуЗавершение", ЭтотОбъект, ДопПараметры);
		МодульИнтернетПоддержкаПользователейКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль(
			"ИнтернетПоддержкаПользователейКлиент");
		МодульИнтернетПоддержкаПользователейКлиент.ПодключитьИнтернетПоддержкуПользователей(ОписаниеОповещения, ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПодключитьИнтернетПоддержкуЗавершение(Результат, ДопПараметры) Экспорт

	Если Результат <> Неопределено Тогда
		СформироватьОтчетНаКлиенте(СтрокаПоиска);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура НайтиПоНаименованиюЗавершение(Результат, ДопПараметры) Экспорт

	Если НЕ ЗначениеЗаполнено(Результат) 
		ИЛИ ТипЗнч(Результат) <> Тип("Строка") Тогда
		Возврат;
	КонецЕсли;
	
	СформироватьОтчетНаКлиенте(Результат);

КонецПроцедуры 

&НаСервереБезКонтекста
Функция ЗаданиеВыполнено(ИдентификаторЗадания)
	
	Возврат ДлительныеОперации.ЗаданиеВыполнено(ИдентификаторЗадания);
	
КонецФункции

&НаСервереБезКонтекста
Процедура ОтменитьВыполнениеЗадания(ИдентификаторЗадания)
	
	ДлительныеОперации.ОтменитьВыполнениеЗадания(ИдентификаторЗадания);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьПодготовленныеДанные()

	ДанныеОтчета   = ПолучитьИзВременногоХранилища(АдресХранилища);
	ОписаниеОшибки = ДанныеОтчета.ОписаниеОшибки;
	Контрагент     = ДанныеОтчета.Контрагент;
	ОжиданиеОтвета = ДанныеОтчета.ОжиданиеОтвета;
	
	// Очистка
	
	// Общие свойства
	НайденныйИНН = "";
	НаименованиеКонтрагента = "";
	ОбластиРасшифровки.Очистить();
	// Главное
	РезультатГлавное.Очистить();
	Элементы.РезультатГлавное.ИспользуемоеИмяФайла = Неопределено;
	РезультатГлавное.ТекущаяОбласть = РезультатГлавное.Область(1, 2, 1, 2);
	// Данные единых гос. реестров
	РезультатДанныеГосРеестров.Очистить();
	Элементы.РезультатДанныеГосРеестров.ИспользуемоеИмяФайла = Неопределено;
	РезультатДанныеГосРеестров.ТекущаяОбласть = РезультатДанныеГосРеестров.Область(1, 2, 1, 2);
	// Данные программы
	Если ПоказатьДанныеПрограммы Тогда
		РезультатДанныеПрограммы.Очистить();
		Элементы.РезультатДанныеПрограммы.ИспользуемоеИмяФайла = Неопределено;
		РезультатДанныеПрограммы.ТекущаяОбласть = РезультатДанныеПрограммы.Область(1, 2, 1, 2);
	КонецЕсли;
	// Бух. отчетность
	РезультатБухгалтерскаяОтчетность.Очистить();
	Элементы.РезультатБухгалтерскаяОтчетность.ИспользуемоеИмяФайла = Неопределено;
	РезультатБухгалтерскаяОтчетность.ТекущаяОбласть = РезультатБухгалтерскаяОтчетность.Область(1, 2, 1, 2);
	// Показатели
	РезультатАнализОтчетности.Очистить();
	Элементы.РезультатАнализОтчетности.ИспользуемоеИмяФайла = Неопределено;
	РезультатАнализОтчетности.ТекущаяОбласть = РезультатАнализОтчетности.Область(1, 2, 1, 2);
	// Фин. анализ
	РезультатФинансовыйАнализ.Очистить();
	Элементы.РезультатФинансовыйАнализ.ИспользуемоеИмяФайла = Неопределено;
	РезультатФинансовыйАнализ.ТекущаяОбласть = РезультатФинансовыйАнализ.Область(1, 2, 1, 2);
	// Проверки
	РезультатПроверки.Очистить();
	Элементы.РезультатПроверки.ИспользуемоеИмяФайла = Неопределено;
	РезультатПроверки.ТекущаяОбласть = РезультатПроверки.Область(1, 2, 1, 2);
	
	
	// Заполнение
	
	Если НЕ ОжиданиеОтвета
		И НЕ ЗначениеЗаполнено(ОписаниеОшибки) Тогда
		// Общие свойства
		НайденныйИНН = ДанныеОтчета.НайденныйИНН;
		НаименованиеКонтрагента = ДанныеОтчета.НаименованиеКонтрагента;
		Для каждого СтрокаОбласти Из ДанныеОтчета.ОбластиРасшифровки Цикл
			НоваяСтрока = ОбластиРасшифровки.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаОбласти);
		КонецЦикла; 
		// Главное
		Если ДанныеОтчета.Свойство("РезультатГлавное") Тогда
			РезультатГлавное.Вывести(ДанныеОтчета.РезультатГлавное);
			Элементы.РезультатГлавное.ИспользуемоеИмяФайла = СокрЛП(ДанныеОтчета.ИмяФайлаГлавное);
		КонецЕсли;
		// Данные единых гос. реестров
		РезультатДанныеГосРеестров.Вывести(ДанныеОтчета.РезультатДанныеГосРеестров);
		Элементы.РезультатДанныеГосРеестров.ИспользуемоеИмяФайла = СокрЛП(ДанныеОтчета.ИмяФайлаДанныеГосРеестров);
		// Данные программы
		Если ПоказатьДанныеПрограммы
			И ДанныеОтчета.Свойство("РезультатДанныеПрограммы") Тогда
			РезультатДанныеПрограммы.Вывести(ДанныеОтчета.РезультатДанныеПрограммы);
			Элементы.РезультатДанныеПрограммы.ИспользуемоеИмяФайла = СокрЛП(ДанныеОтчета.ИмяФайлаДанныеПрограммы);
		КонецЕсли;
		// Бух. отчетность
		Если ДанныеОтчета.Свойство("РезультатБухгалтерскаяОтчетность") Тогда
			РезультатБухгалтерскаяОтчетность.Вывести(ДанныеОтчета.РезультатБухгалтерскаяОтчетность);
			Элементы.РезультатБухгалтерскаяОтчетность.ИспользуемоеИмяФайла = СокрЛП(ДанныеОтчета.ИмяФайлаБухгалтерскаяОтчетность);
		КонецЕсли;
		// Показатели
		Если ДанныеОтчета.Свойство("РезультатАнализОтчетности") Тогда
			РезультатАнализОтчетности.Вывести(ДанныеОтчета.РезультатАнализОтчетности);
			Элементы.РезультатАнализОтчетности.ИспользуемоеИмяФайла = СокрЛП(ДанныеОтчета.ИмяФайлаАнализОтчетности);
		КонецЕсли;
		// Фин. анализ
		Если ДанныеОтчета.Свойство("РезультатФинансовыйАнализ") Тогда
			РезультатФинансовыйАнализ.Вывести(ДанныеОтчета.РезультатФинансовыйАнализ);
			Элементы.РезультатФинансовыйАнализ.ИспользуемоеИмяФайла = СокрЛП(ДанныеОтчета.ИмяФайлаФинансовыйАнализ);
		КонецЕсли;
		// Проверки
		Если ДанныеОтчета.Свойство("РезультатПроверки") Тогда
			РезультатПроверки.Вывести(ДанныеОтчета.РезультатПроверки);
			Элементы.РезультатПроверки.ИспользуемоеИмяФайла = СокрЛП(ДанныеОтчета.ИмяФайлаПроверки);
		КонецЕсли;
		
	КонецЕсли;
	
	УстановитьСвойстваЗаголовкамРазделовНаСервере(?(ЭтоЮридическоеЛицо, "Главное", "ДанныеГосРеестров"));
	УправлениеФормойНаСервере();

КонецПроцедуры

&НаСервере
Процедура УстановитьСвойстваЗаголовкамРазделовНаСервере(ИмяТекущегоРаздела)
	
	Элементы.ДекорацияРазделГлавное.Гиперссылка                 = Истина;
	Элементы.ДекорацияРазделДанныеГосРеестров.Гиперссылка       = Истина;
	Элементы.ДекорацияРазделДанныеПрограммы.Гиперссылка         = Истина;
	Элементы.ДекорацияРазделБухгалтерскаяОтчетность.Гиперссылка = Истина;
	Элементы.ДекорацияРазделАнализОтчетности.Гиперссылка        = Истина;
	Элементы.ДекорацияРазделФинансовыйАнализ.Гиперссылка        = Истина;
	Элементы.ДекорацияРазделПроверки.Гиперссылка                = Истина;
	
	Элементы.ДекорацияРазделГлавное.ЦветФона                 = Новый Цвет;
	Элементы.ДекорацияРазделДанныеГосРеестров.ЦветФона       = Новый Цвет;
	Элементы.ДекорацияРазделДанныеПрограммы.ЦветФона         = Новый Цвет;
	Элементы.ДекорацияРазделБухгалтерскаяОтчетность.ЦветФона = Новый Цвет;
	Элементы.ДекорацияРазделАнализОтчетности.ЦветФона        = Новый Цвет;
	Элементы.ДекорацияРазделФинансовыйАнализ.ЦветФона        = Новый Цвет;
	Элементы.ДекорацияРазделПроверки.ЦветФона                = Новый Цвет;
	
	Элементы["ДекорацияРаздел" + ИмяТекущегоРаздела].Гиперссылка = Ложь;
	Элементы["ДекорацияРаздел" + ИмяТекущегоРаздела].ЦветФона = ЦветаСтиля.ДосьеТекущийРазделЦвет;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьРасшифровкуТабличногоДокумента(Расшифровка, СтандартнаяОбработка)
	
	Если ТипЗнч(Расшифровка) <> Тип("Структура")
		ИЛИ НЕ Расшифровка.Свойство("Действие") Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	Если Расшифровка.Действие = "Показать" 
		ИЛИ Расшифровка.Действие = "Свернуть" Тогда
		
		ПоказатьСкрытьОбластьДокумента(Расшифровка);
		
	ИначеЕсли Расшифровка.Действие = "Открыть" Тогда
		
		Если НЕ Расшифровка.Свойство("ИНН") Тогда
			Возврат;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Расшифровка.ИНН) 
			ИЛИ (СтрДлина(Расшифровка.ИНН) <> 10
			И СтрДлина(Расшифровка.ИНН) <> 12) Тогда
			Возврат;
		КонецЕсли;
		ПараметрыФормы = Новый Структура("ИНН", Расшифровка.ИНН);
		ОткрытьФорму("Отчет.ДосьеКонтрагента.Форма", ПараметрыФормы, , Расшифровка.ИНН);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОбработатьОшибкиФормированияОтчета()

	Если НЕ ЗначениеЗаполнено(ОписаниеОшибки) Тогда
		Возврат;
	КонецЕсли;
	
	Если ОписаниеОшибки = "НеУказаныПараметрыАутентификации" Тогда
	
		ТекстВопроса = НСтр("ru='Для формирования ""Досье контрагента""
			|необходимо подключиться к интернет-поддержке пользователей.
			|Подключиться сейчас?'");
		ОписаниеОповещения = Новый ОписаниеОповещения("ПодключитьИнтернетПоддержку", ЭтотОбъект);
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	
	ИначеЕсли ОписаниеОшибки = "НеУказанПароль" Тогда
		ТекстВопроса = НСтр("ru='Необходимо указать пароль к Интернет-поддержке пользователей
			|и установить флажок ""Запомнить пароль"".
			|Указать сейчас?'");
		ОписаниеОповещения = Новый ОписаниеОповещения("ПодключитьИнтернетПоддержку", ЭтотОбъект);
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
		
	ИначеЕсли ОписаниеОшибки = "Сервис1СКонтрагентНеПодключен" Тогда
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("ИдентификаторМестаВызова", "dosie_kontragenta");
		ОткрытьФорму("ОбщаяФорма.Сервис1СКонтрагентНеПодключен", ПараметрыФормы, ЭтотОбъект);
		
	Иначе
		ПоказатьПредупреждение(, ОписаниеОшибки);
	КонецЕсли;
	
	ОписаниеОшибки = "";
	
КонецПроцедуры 

#КонецОбласти

