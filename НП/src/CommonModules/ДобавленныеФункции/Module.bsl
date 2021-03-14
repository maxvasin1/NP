Функция РаспределитьОплатуПоРасчетнымДокументам(СсылкаНаОбъект, ТаблицаДвижений, ЭтоОплата) Экспорт
	
	МоментВремени = СсылкаНаОбъект.МоментВремени();
	
	НовТаблицаДвижений = ПолучитьТаблицуРаспределенияПоРасчтетнымДокументам(ТаблицаДвижений, МоментВремени, СсылкаНаОбъект, ЭтоОплата);
	
	Возврат НовТаблицаДвижений;
	
КонецФункции // РаспределитьОплатуПоРасчетнымДокументам()

Функция ПолучитьТаблицуРаспределенияПоРасчтетнымДокументам(ТаблицаДвижений, МоментВремени, Ссылка = Неопределено, ЭтоОплата) Экспорт
	
	НовТаблицаДвижений = ТаблицаДвижений.Скопировать();
	НовТаблицаДвижений.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВзаиморасчетыОстатки.Контрагент КАК Контрагент,
	|	ВзаиморасчетыОстатки.Сделка КАК Сделка,
	|	СУММА(ВзаиморасчетыОстатки.СуммаВзаиморасчетовОстаток * &Знак) КАК СуммаВзаиморасчетов,
	|	ВзаиморасчетыОстатки.Сделка.Дата КАК ДатаПогашения
	|ИЗ
	|	РегистрНакопления.Взаиморасчеты.Остатки(&МоментДокумента, Контрагент В (&Контрагенты)) КАК ВзаиморасчетыОстатки
	|ГДЕ
	|	ВзаиморасчетыОстатки.СуммаВзаиморасчетовОстаток * &Знак > 0
	|
	|СГРУППИРОВАТЬ ПО
	|	ВзаиморасчетыОстатки.Сделка,
	|	ВзаиморасчетыОстатки.Сделка.Дата,
	|	ВзаиморасчетыОстатки.Контрагент
	|
	|УПОРЯДОЧИТЬ ПО
	|	Контрагент,
	|	ДатаПогашения,
	|	ВзаиморасчетыОстатки.Сделка.Дата";
	
	Запрос.УстановитьПараметр("МоментДокумента", МоментВремени);
	Запрос.УстановитьПараметр("Знак", ?(ЭтоОплата, 1, -1));
	Запрос.УстановитьПараметр("Контрагенты", ТаблицаДвижений.ВыгрузитьКолонку("Контрагент"));
	ОстаткиВзаиморасчетов = Запрос.Выполнить().Выгрузить();
	
	//будем на каждую переданную строчку искать строчку в остатках
	Отбор = Новый Структура;
	
	Для каждого Строка Из ТаблицаДвижений Цикл
		Знак 		= ?(Строка.СуммаВзаиморасчетов < 0, -1, 1);
		СуммаВзаиморасчетов = Знак * Строка.СуммаВзаиморасчетов;
		Если Истина Тогда
			
			Отбор.Очистить();
			Отбор.Вставить("Контрагент", Строка.Контрагент);
			Если ЗначениеЗаполнено(Строка.Сделка) И Строка.Сделка <> Ссылка Тогда
				Отбор.Вставить("Сделка", Строка.Сделка);
			КонецЕсли;
			
			СтрокиОстатков = ОстаткиВзаиморасчетов.НайтиСтроки(Отбор);
			
			Если СтрокиОстатков.Количество() > 0 Тогда
				Для Каждого СтрокаОстатков Из СтрокиОстатков Цикл
					НовСтрокаДвижений = НовТаблицаДвижений.Добавить();
					ЗаполнитьЗначенияСвойств(НовСтрокаДвижений, Строка);
					НовСтрокаДвижений.Сделка            = СтрокаОстатков.Сделка;
					
					Если СтрокаОстатков.СуммаВзаиморасчетов < СуммаВзаиморасчетов Тогда
						НовСтрокаДвижений.СуммаВзаиморасчетов = Знак*СтрокаОстатков.СуммаВзаиморасчетов;
						СуммаВзаиморасчетов					  = СуммаВзаиморасчетов - СтрокаОстатков.СуммаВзаиморасчетов;
						ОстаткиВзаиморасчетов.Удалить(СтрокаОстатков);
					Иначе
						НовСтрокаДвижений.СуммаВзаиморасчетов = Знак*СуммаВзаиморасчетов;
						СуммаВзаиморасчетов = 0;
					КонецЕсли;
					
					Если СуммаВзаиморасчетов = 0 Тогда
						Прервать;
					КонецЕсли;
					
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
		
		//либо не все распределилось, либо вообще в выборке не было ничего
		Если СуммаВзаиморасчетов > 0 Тогда
			НовСтрокаДвижений = НовТаблицаДвижений.Добавить();
			ЗаполнитьЗначенияСвойств(НовСтрокаДвижений, Строка);
			ТекСделка = Ссылка;
			Если ЗначениеЗаполнено(Строка.Сделка) Тогда
				ТекСделка = Строка.Сделка;
			КонецЕсли;
			НовСтрокаДвижений.Сделка              = ТекСделка;
			НовСтрокаДвижений.СуммаВзаиморасчетов = Знак * СуммаВзаиморасчетов;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат НовТаблицаДвижений;
	
КонецФункции

Функция ПолучитьЦенуНоменклатуры(Дата, Номенклатура, ТипЦен) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЦеныНоменклатурыСрезПоследних.Номенклатура,
	|	ЦеныНоменклатурыСрезПоследних.Цена
	|ИЗ
	|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
	|			&Дата,
	|			Номенклатура = &Номенклатура
	|				И ТипЦен = &ТипЦен) КАК ЦеныНоменклатурыСрезПоследних";
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("ТипЦен", ТипЦен);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.Цена
	Иначе
		//Цена не установлена
		Возврат Неопределено;
	КонецЕсли;
	
	
КонецФункции

// Процедура - Выполнить движения по партиям товаров
//
// Параметры:
//  Ссылка				 - 	 Документ, по которому проводим партии 
//  СтруктураДокумента	 - 	 Дополнительные данные для проведения 
//  Отказ				 - 	 отказ 
//  Движения			 - 	 набор движений регистра "ТоварыНаСкладах" 
//
Процедура ВыполнитьДвиженияПоПартиямТоваров(Ссылка,СтруктураДокумента, Отказ, Движения) Экспорт
	//Тут мы будем подбирать остатки товаров по партиям. 
	ТаблицаТоваров = СтруктураДокумента.ТаблицаПоТоварам;
	Если СтруктураДокумента.ВидОперации = "Перемещение" Тогда
		Склад = СтруктураДокумента.СкладОтправитель;
	ИначеЕсли СтруктураДокумента.ВидОперации = "Реализация" Тогда
		Склад = СтруктураДокумента.Склад;
	КонецЕсли;
	//Нарисуем таблицу для расхода
	ТаблицаРасхода = Новый ТаблицаЗначений;
	ТаблицаРасхода.Колонки.Добавить("Номенклатура", Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	ТаблицаРасхода.Колонки.Добавить("Ссылка", 		Документы.ТипВсеСсылки());
	ТаблицаРасхода.Колонки.Добавить("Количество",	ПолучитьОписаниеТиповЧисла(10,2));
	ТаблицаРасхода.Колонки.Добавить("Сумма",		ПолучитьОписаниеТиповЧисла(10,2));
	ТаблицаРасхода.Колонки.Добавить("Дата",			ПолучитьОписаниеТиповДаты(ЧастиДаты.ДатаВремя));
	
	ОбщегоНазначенияНП.ЗагрузитьВТаблицуЗначений(ТаблицаТоваров, ТаблицаРасхода);
	ТаблицаРасхода.ЗаполнитьЗначения(Ссылка, "Ссылка");
	ТаблицаРасхода.ЗаполнитьЗначения(Ссылка.Дата, "Дата");
	
	
	//Выполним распределение партий в запросе
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("ТаблицаРасхода",ТаблицаРасхода);
	Запрос.УстановитьПараметр("Дата", Ссылка.Дата);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Номенклатура", ТаблицаРасхода.ВыгрузитьКолонку("Номенклатура"));
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	Приход.Номенклатура КАК Номенклатура,
	               |	Приход.Партия КАК Партия,
	               |	Приход.Партия.МоментВремени КАК МоментВремени,
	               |	Приход.КоличествоОстаток КАК КоличествоОстаток,
	               |	Приход.СтоимостьОстаток КАК СтоимостьОстаток,
	               |	Приход.Партия.Дата КАК Период
	               |ПОМЕСТИТЬ Приход
	               |ИЗ
	               |	РегистрНакопления.ТоварыНаСкладах.Остатки(
	               |			&Дата,
	               |			Склад = &Склад
	               |				И Номенклатура В (&Номенклатура)) КАК Приход
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ТаблицаРасхода.Ссылка КАК Ссылка,
	               |	ТаблицаРасхода.Номенклатура КАК Номенклатура,
	               |	ТаблицаРасхода.Количество КАК Количество,
	               |	0 КАК Сумма,
	               |	ТаблицаРасхода.Дата КАК Период,
	               |	ТаблицаРасхода.Дата КАК МоментВремени
	               |ПОМЕСТИТЬ Расход
	               |ИЗ
	               |	&ТаблицаРасхода КАК ТаблицаРасхода
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Приход.Период КАК Период,
	               |	Приход.МоментВремени КАК МоментВремени,
	               |	Приход.Номенклатура КАК Номенклатура,
	               |	Приход.КоличествоОстаток КАК КоличествоОстаток,
	               |	Приход.СтоимостьОстаток КАК СтоимостьОстаток,
	               |	СУММА(Приход1.КоличествоОстаток) - Приход.КоличествоОстаток КАК КоличествоДо,
	               |	СУММА(Приход1.КоличествоОстаток) КАК КоличествоПосле,
	               |	Приход.Партия
	               |ПОМЕСТИТЬ НарПриход
	               |ИЗ
	               |	Приход КАК Приход
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Приход КАК Приход1
	               |		ПО Приход.Номенклатура = Приход1.Номенклатура
	               |			И Приход.МоментВремени >= Приход1.МоментВремени
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	Приход.Период,
	               |	Приход.МоментВремени,
	               |	Приход.Номенклатура,
	               |	Приход.КоличествоОстаток,
	               |	Приход.СтоимостьОстаток,
	               |	Приход.Партия
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Расход.Период КАК Период,
	               |	Расход.МоментВремени КАК МоментВремени,
	               |	Расход.Ссылка КАК Ссылка,
	               |	Расход.Номенклатура КАК Номенклатура,
	               |	Расход.Количество КАК Количество,
	               |	СУММА(Расход1.Количество) - Расход.Количество КАК КоличествоДо,
	               |	СУММА(Расход1.Количество) КАК КоличествоПосле
	               |ПОМЕСТИТЬ НарРасход
	               |ИЗ
	               |	Расход КАК Расход
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Расход КАК Расход1
	               |		ПО Расход.Номенклатура = Расход1.Номенклатура
	               |			И Расход.МоментВремени >= Расход1.МоментВремени
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	Расход.Период,
	               |	Расход.МоментВремени,
	               |	Расход.Ссылка,
	               |	Расход.Номенклатура,
	               |	Расход.Количество
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	НарРасход.Период КАК Период,
	               |	НарРасход.Ссылка КАК Ссылка,
	               |	НарПриход.Партия КАК Партия,
	               |	НарРасход.Номенклатура КАК Номенклатура,
	               |	НарРасход.Количество КАК КоличествоПоДокументу,
	               |	ВЫБОР
	               |		КОГДА НарПриход.Партия ЕСТЬ NULL
	               |			ТОГДА 0
	               |		ИНАЧЕ ВЫБОР
	               |				КОГДА НарПриход.КоличествоПосле < НарРасход.КоличествоПосле
	               |					ТОГДА НарПриход.КоличествоПосле
	               |				ИНАЧЕ НарРасход.КоличествоПосле
	               |			КОНЕЦ - ВЫБОР
	               |				КОГДА НарПриход.КоличествоДо > НарРасход.КоличествоДо
	               |					ТОГДА НарПриход.КоличествоДо
	               |				ИНАЧЕ НарРасход.КоличествоДо
	               |			КОНЕЦ
	               |	КОНЕЦ КАК КоличествоСписания,
	               |	ВЫБОР
	               |		КОГДА НарПриход.КоличествоПосле <= НарРасход.КоличествоПосле
	               |			ТОГДА ИСТИНА
	               |		ИНАЧЕ ЛОЖЬ
	               |	КОНЕЦ КАК ПризнакЗакрытияПартии,
	               |	ЕСТЬNULL(НарПриход.КоличествоОстаток, 1) КАК КоличествоПартии,
	               |	ЕСТЬNULL(НарПриход.СтоимостьОстаток, 0) КАК СуммаПартии
	               |ПОМЕСТИТЬ ДвиженияПредварительные
	               |ИЗ
	               |	НарРасход КАК НарРасход
	               |		ЛЕВОЕ СОЕДИНЕНИЕ НарПриход КАК НарПриход
	               |		ПО НарРасход.Номенклатура = НарПриход.Номенклатура
	               |			И НарРасход.КоличествоПосле > НарПриход.КоличествоДо
	               |			И НарРасход.КоличествоДо < НарПриход.КоличествоПосле
	               |			И НарРасход.Период > НарПриход.Период
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ДвиженияПредварительные.Период КАК Период,
	               |	ДвиженияПредварительные.Ссылка КАК Ссылка,
	               |	ДвиженияПредварительные.Номенклатура КАК Номенклатура,
	               |	ДвиженияПредварительные.КоличествоПоДокументу КАК КоличествоПоДокументу,
	               |	СУММА(ДвиженияПредварительные.КоличествоСписания) КАК КоличествоСписания
	               |ИЗ
	               |	ДвиженияПредварительные КАК ДвиженияПредварительные
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ДвиженияПредварительные.Период,
	               |	ДвиженияПредварительные.Ссылка,
	               |	ДвиженияПредварительные.Номенклатура,
	               |	ДвиженияПредварительные.КоличествоПоДокументу
	               |
	               |ИМЕЮЩИЕ
	               |	СУММА(ДвиженияПредварительные.КоличествоСписания) <> ДвиженияПредварительные.КоличествоПоДокументу
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	Период
	               |АВТОУПОРЯДОЧИВАНИЕ";
	
	// Проверка на отрицательные остатки			   
	Результат = Запрос.Выполнить();			   
	МоментВремениПервогоОшибочногоДокумента = Ссылка.Дата+1;
	Выборка = Результат.Выбрать();
	Ошибки=Неопределено;
	Если Выборка.Следующий() Тогда
		МоментВремениПервогоОшибочногоДокумента = Выборка.Период;
		
		Выборка.Сбросить();
		Пока Выборка.Следующий() Цикл
			ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(Ошибки,"Объект","Товара "+Выборка.Номенклатура+" на складе "+Склад+" недостаточно. Остаток - "+Выборка.КоличествоСписания+
			", требуется - "+Выборка.КоличествоПоДокументу,"");
		КонецЦикла;
	КонецЕсли;	
	
	
	Запрос.Текст=" ВЫБРАТЬ
	|	ДвиженияПредварительные.Период,
	|	ДвиженияПредварительные.Ссылка КАК Регистратор,
	|	ДвиженияПредварительные.Партия,
	|	ДвиженияПредварительные.Номенклатура,
	|	ДвиженияПредварительные.ПризнакЗакрытияПартии,
	|	ВЫРАЗИТЬ(ДвиженияПредварительные.КоличествоСписания КАК ЧИСЛО(10, 2)) КАК КоличествоСписания,
	|	ВЫРАЗИТЬ(ДвиженияПредварительные.СуммаПартии * ДвиженияПредварительные.КоличествоСписания / ДвиженияПредварительные.КоличествоПартии КАК ЧИСЛО(10, 2)) КАК СуммаСписания,
	|	ДвиженияПредварительные.СуммаПартии
	|ПОМЕСТИТЬ ДвиженияССуммами
	|ИЗ
	|	ДвиженияПредварительные КАК ДвиженияПредварительные
	|ГДЕ
	|	ДвиженияПредварительные.Период < &МоментВремениПервогоОшибочногоДокумента
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДвиженияССуммами.Номенклатура,
	|	ДвиженияССуммами.Партия,
	|	ДвиженияССуммами.СуммаПартии,
	|	МАКСИМУМ(ДвиженияССуммами.ПризнакЗакрытияПартии) КАК ПризнакЗакрытияПартии,
	|	ДвиженияССуммами.СуммаПартии - СУММА(ДвиженияССуммами.СуммаСписания) КАК ПогрешностьОкругления
	|ПОМЕСТИТЬ ДляОкругления
	|ИЗ
	|	ДвиженияССуммами КАК ДвиженияССуммами
	|
	|СГРУППИРОВАТЬ ПО
	|	ДвиженияССуммами.Партия,
	|	ДвиженияССуммами.Номенклатура,
	|	ДвиженияССуммами.СуммаПартии
	|
	|ИМЕЮЩИЕ
	|	МАКСИМУМ(ДвиженияССуммами.ПризнакЗакрытияПартии) = ИСТИНА
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДвиженияССуммами.Период КАК Период,
	|	ДвиженияССуммами.Регистратор КАК Регистратор,
	|	ДвиженияССуммами.Партия КАК Партия,
	|	ДвиженияССуммами.Номенклатура КАК Номенклатура,
	|	ДвиженияССуммами.КоличествоСписания КАК Количество,
	|	ДвиженияССуммами.СуммаСписания + ЕСТЬNULL(ДляОкругления.ПогрешностьОкругления, 0) КАК Стоимость
	|ИЗ
	|	ДвиженияССуммами КАК ДвиженияССуммами
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДляОкругления КАК ДляОкругления
	|		ПО ДвиженияССуммами.Номенклатура = ДляОкругления.Номенклатура
	|			И ДвиженияССуммами.Партия = ДляОкругления.Партия
	|			И ДвиженияССуммами.ПризнакЗакрытияПартии = ДляОкругления.ПризнакЗакрытияПартии
	|
	|УПОРЯДОЧИТЬ ПО
	|	Номенклатура,
	|	Партия,
	|	Период,
	|	Регистратор";
	Запрос.УстановитьПараметр("МоментВремениПервогоОшибочногоДокумента",МоментВремениПервогоОшибочногоДокумента);			   
	Результат = Запрос.Выполнить();			
	ВыходнаяТаблица = Результат.Выгрузить();   
	
	СформироватьДвиженияПоРегистру(Ссылка,ВыходнаяТаблица, Отказ, "ТоварыНаСкладах",,"Расход",Движения, СтруктураДокумента);
	Если СтруктураДокумента.ВидОперации = "Перемещение" Тогда
		Если СтруктураДокумента.СкладПолучатель.УчитыватьПродуктПорционно Тогда
			ПодготовитьТаблицуПорционныхТоваров(ВыходнаяТаблица, Ссылка.Дата, Ошибки);
		КонецЕсли;
		СформироватьДвиженияПоРегистру(Ссылка,ВыходнаяТаблица, Отказ, "ТоварыНаСкладах",,"Приход",Движения, СтруктураДокумента);
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.СообщитьОшибкиПользователю(Ошибки,Отказ);
КонецПроцедуры

Процедура ПодготовитьТаблицуПорционныхТоваров(ТаблицаТоваров, Дата, Ошибки)
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ТаблицаТоваров.Партия,
	               |	ТаблицаТоваров.Номенклатура КАК СтараяНоменклатура,
	               |	ТаблицаТоваров.Количество КАК СтароеКоличество,
	               |	ТаблицаТоваров.Стоимость
	               |ПОМЕСТИТЬ Товары
	               |ИЗ
	               |	&ТаблицаТоваров КАК ТаблицаТоваров
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Товары.Партия,
	               |	Товары.СтараяНоменклатура,
	               |	Товары.Стоимость,
	               |	Товары.СтараяНоменклатура.ПорционныйПродукт КАК Номенклатура,
	               |	Товары.СтароеКоличество * ЕСТЬNULL(ПорционностьПродуктаСрезПоследних.КоличествоПорций, 0) КАК Количество
	               |ИЗ
	               |	Товары КАК Товары
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПорционностьПродукта.СрезПоследних(&Дата, ) КАК ПорционностьПродуктаСрезПоследних
	               |		ПО Товары.СтараяНоменклатура = ПорционностьПродуктаСрезПоследних.Номенклатура";
				   
	Запрос.УстановитьПараметр("Дата",Дата);
	Запрос.УстановитьПараметр("ТаблицаТоваров",ТаблицаТоваров);
	
	//Проверим, все ли у нас заполнено, чтобы провести, вдруг не заполнена порционность или ссылка на порционный товар
	Результат = Запрос.Выполнить();
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			Если НЕ ЗначениеЗаполнено(Выборка.Номенклатура) Тогда
				ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(Ошибки,"Объект","Для продукта "+Выборка.СтараяНоменклатура+" не указан порционный продукт." ,"");
			КонецЕсли;
			Если НЕ ЗначениеЗаполнено(Выборка.Количество) Тогда
				ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(Ошибки,"Объект","Для продукта "+Выборка.СтараяНоменклатура+" не указано количество порций." ,"");
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	ТаблицаТоваров = Результат.Выгрузить();			   
КонецПроцедуры

Процедура СформироватьДвиженияПоРегистру(Документ, Таблица, Отказ, ИмяРегистра, ПромежуточноЗаписать=Ложь, ВидДвижения = "Приход",НаборДвижений, СтруктураДокумента=Неопределено) Экспорт

	// ДВИЖЕНИЯ ПО РЕГИСТРУ .
	
	НаборДвижений.Записывать = Истина;
	
	// Получим таблицу значений, совпадающую со струкутрой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	ТаблицаДвижений.Очистить();
	
	// Заполним таблицу движений.
	ОбщегоНазначенияНП.ЗагрузитьВТаблицуЗначений(Таблица, ТаблицаДвижений);
	
	
	//Тут будем обрабатывать в зависимости от регистра
	Если ИмяРегистра = "ТоварыНаСкладах" Тогда
		Если ТипЗнч(Документ)=Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
			Если ВидДвижения = "Приход" Тогда 
				ТаблицаДвижений.ЗаполнитьЗначения(СтруктураДокумента.СкладПолучатель,"Склад");
			Иначе
				ТаблицаДвижений.ЗаполнитьЗначения(СтруктураДокумента.СкладОтправитель,"Склад");
			КонецЕсли;
		ИначеЕсли ТипЗнч(Документ)=Тип("ДокументСсылка.РеализацияТоваров") ИЛИ 
			ТипЗнч(Документ)=Тип("ДокументСсылка.Посещение") Тогда
			ТаблицаДвижений.ЗаполнитьЗначения(СтруктураДокумента.Склад,"Склад");
		КонецЕсли;	
	КонецЕсли;
	// Недостающие поля.
	НаборДвижений.мПериод            = Документ.Дата;
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

// Служебная функция, предназначенная для получения описания типов строки, заданной длины.
// 
// Параметры:
//  ДлинаСтроки - число, длина строки.
//
// Возвращаемое значение:
//  Объект "ОписаниеТипов" для строки указанной длины.
//
Функция ПолучитьОписаниеТиповСтроки(ДлинаСтроки) Экспорт
	
	Возврат Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(ДлинаСтроки, ДопустимаяДлина.Переменная));
	
КонецФункции // ОбщегоНазначения.ПолучитьОписаниеТиповСтроки()

// Служебная функция, предназначенная для получения описания типов числа, заданной разрядности.
// 
// Параметры:
//  Разрядность 			- число, разряд числа.
//  РазрядностьДробнойЧасти - число, разряд дробной части.
//
// Возвращаемое значение:
//  Объект "ОписаниеТипов" для числа указанной разрядности.
//
Функция ПолучитьОписаниеТиповЧисла(Разрядность, РазрядностьДробнойЧасти = 0, ЗнакЧисла = Неопределено) Экспорт
	
	Если ЗнакЧисла = Неопределено Тогда
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти);
	Иначе
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти, ЗнакЧисла);
	КонецЕсли;
	
	Возврат Новый ОписаниеТипов("Число", КвалификаторЧисла);
	
КонецФункции // ОбщегоНазначения.ПолучитьОписаниеТиповЧисла()

// Служебная функция, предназначенная для получения описания типов даты
// 
// Параметры:
//  ЧастиДаты - системное перечисление ЧастиДаты.
// 
Функция ПолучитьОписаниеТиповДаты(ЧастиДаты) Экспорт
	
	Возврат Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты));
	
КонецФункции // ОбщегоНазначения.ПолучитьОписаниеТиповДаты()


