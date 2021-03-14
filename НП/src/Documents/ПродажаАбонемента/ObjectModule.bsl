//#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	//Абонементы, посещения
	ТаблицаАбонементов = СформироватьТаблицуАбонементов();
	СформироватьДвиженияПоРегистру(ТаблицаАбонементов,Отказ, "АбонементыКонтрагентов");
	
	//Взаиморасчеты
	ТаблицаВзаиморасчетов = СоздатьТаблицуДолгаПоДокументам();
	СформироватьДвиженияПоРегистру(ТаблицаВзаиморасчетов, Отказ, "Взаиморасчеты", Истина);
	ТаблицаОплат		  = СоздатьТаблицуОплатПоДокументам();
	СформироватьДвиженияПоРегистру(ТаблицаОплат, Отказ, "Взаиморасчеты", , "Расход");
	
	//Денежные средства
	ТаблицаДС = СоздатьТаблицуДенежныхСредств();
	СформироватьДвиженияПоРегистру(ТаблицаДС, Отказ, "ДенежныеСредства");
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если Не Отказ Тогда
		СоздатьНовыеАбонементы();
		
		КраткийСоставДокумента = "";
		ДЛя Каждого ТекСтрока Из Контрагенты Цикл
			КраткийСоставДокумента = КраткийСоставДокумента + ", "+ТекСтрока.Контрагент;
		КонецЦикла;
		КраткийСоставДокумента = Сред(КраткийСоставДокумента,3, СтрДлина(КраткийСоставДокумента)-2);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура СоздатьНовыеАбонементы()
	Для Каждого ТекСтрока Из Контрагенты Цикл
		Если Не ЗначениеЗаполнено(ТекСтрока.Абонемент) Тогда
			НовыйАбонемент = Справочники.АбонементыКонтрагента.СоздатьЭлемент();
			НовыйАбонемент.Владелец = ТекСтрока.Контрагент;
			НовыйАбонемент.ДатаНачала = Дата;
			НовыйАбонемент.ВидАбонемента = ТекСтрока.ВидАбонемента;
			НовыйАбонемент.Записать();
			
			ТекСтрока.Абонемент = НовыйАбонемент.Ссылка;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры


Функция СформироватьТаблицуАбонементов()
	
	КвалификаторыЧисла = Новый КвалификаторыЧисла(10, 2, ДопустимыйЗнак.Любой);
	ОписаниеЧисла = Новый ОписаниеТипов("Число", КвалификаторыЧисла);
	
	ТабАбонементов = Контрагенты.Выгрузить();
	ТабАбонементов.Свернуть("Контрагент, Абонемент, ВидАбонемента","Стоимость");
	ТабАбонементов.Колонки.Добавить("ЧислоПосещений", ОписаниеЧисла);
	
	Для Каждого ТекСтрока Из ТабАбонементов Цикл
		ТекСтрока.ЧислоПосещений = ТекСтрока.ВидАбонемента.КоличествоПосещений;
	КонецЦикла;
	
	Возврат ТабАбонементов;
	 
КонецФункции

Процедура СформироватьДвиженияПоАбонементамКонтрагента(ТаблицаАбонементов, Отказ)

	// ПО РЕГИСТРУ Абонементы контрагентов.
	
	НаборДвижений = Движения.АбонементыКонтрагентов;
	НаборДвижений.Записывать = Истина;
	
	// Получим таблицу значений, совпадающую со струкутрой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	ТаблицаДвижений.Очистить();
	
	// Заполним таблицу движений.
	ОбщегоНазначенияНП.ЗагрузитьВТаблицуЗначений(ТаблицаАбонементов, ТаблицаДвижений);
	ТаблицаДвижений.ЗаполнитьЗначения(Ссылка, "Регистратор");
	// Недостающие поля.
	НаборДвижений.мПериод            = Дата;
	НаборДвижений.мТаблицаДвижений   = ТаблицаДвижений;
	
	Если Не Отказ Тогда
		
		НаборДвижений.ВыполнитьПриход();
		
	КонецЕсли;
	
КонецПроцедуры

Функция СоздатьТаблицуДолгаПоДокументам()
	
	КвалификаторыЧисла = Новый КвалификаторыЧисла(10, 2, ДопустимыйЗнак.Любой);
	ОписаниеЧисла = Новый ОписаниеТипов("Число", КвалификаторыЧисла);
	
	ТаблицаВзаиморасчетов = Контрагенты.Выгрузить();
	ТаблицаВзаиморасчетов.Свернуть("Контрагент","Стоимость");
	
	ТаблицаДвижений = Движения.Взаиморасчеты.Выгрузить();
	Для Каждого ТекСтрока Из ТаблицаВзаиморасчетов Цикл
		НовСтр = ТаблицаДвижений.Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр,ТекСтрока);
		НовСтр.СуммаВзаиморасчетов = ТекСтрока.Стоимость;
	КонецЦикла;
	
	НовТаблицаДвижений = ДобавленныеФункции.РаспределитьОплатуПоРасчетнымДокументам(Ссылка, ТаблицаДвижений, Ложь);
	
	Возврат НовТаблицаДвижений;
	
КонецФункции

Функция СоздатьТаблицуОплатПоДокументам()
	
	КвалификаторыЧисла = Новый КвалификаторыЧисла(10, 2, ДопустимыйЗнак.Любой);
	ОписаниеЧисла = Новый ОписаниеТипов("Число", КвалификаторыЧисла);
	
	ТаблицаВзаиморасчетов = Контрагенты.Выгрузить();
	ТаблицаВзаиморасчетов.Свернуть("Контрагент","Оплачено");
	
	ТаблицаДвижений = Движения.Взаиморасчеты.Выгрузить();
	ТаблицаДвижений.Очистить();
	Для Каждого ТекСтрока Из ТаблицаВзаиморасчетов Цикл
		НовСтр = ТаблицаДвижений.Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр,ТекСтрока);
		НовСтр.СуммаВзаиморасчетов = ТекСтрока.Оплачено;
	КонецЦикла;
	
	НовТаблицаДвижений = ДобавленныеФункции.РаспределитьОплатуПоРасчетнымДокументам(Ссылка, ТаблицаДвижений, Истина);
	
	Возврат НовТаблицаДвижений;
	
КонецФункции

Функция СоздатьТаблицуДенежныхСредств()
	
	КвалификаторыЧисла = Новый КвалификаторыЧисла(10, 2, ДопустимыйЗнак.Любой);
	ОписаниеЧисла = Новый ОписаниеТипов("Число", КвалификаторыЧисла);
	
	ТаблицаДвижений = Движения.ДенежныеСредства.Выгрузить();
	НовСтр = ТаблицаДвижений.Добавить();
	
	НовСтр.Сумма = Контрагенты.Итог("Оплачено");
	
	Возврат ТаблицаДвижений;
	
КонецФункции

Процедура СформироватьДвиженияПоРегистру(Таблица, Отказ, ИмяРегистра, ПромежуточноЗаписать=Ложь, ВидДвижения = "Приход")

	// ПО РЕГИСТРУ Взаиморасчеты.
	
	НаборДвижений = Движения[ИмяРегистра];
	НаборДвижений.Записывать = Истина;
	
	// Получим таблицу значений, совпадающую со струкутрой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	ТаблицаДвижений.Очистить();
	
	// Заполним таблицу движений.
	ОбщегоНазначенияНП.ЗагрузитьВТаблицуЗначений(Таблица, ТаблицаДвижений);
	
	// Недостающие поля.
	НаборДвижений.мПериод            = Дата;
	НаборДвижений.мТаблицаДвижений   = ТаблицаДвижений;
	
	Если Не Отказ Тогда
		
		Если ВидДвижения = "Приход" Тогда
			НаборДвижений.ВыполнитьПриход();
		Иначе
			НаборДвижений.ВыполнитьРасход();
		КонецЕсли;
		
	КонецЕсли;
	
	Если ПромежуточноЗаписать ТОгда
		НаборДвижений.Записать();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

//#КонецЕсли