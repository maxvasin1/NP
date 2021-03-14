
Процедура ДвиженияПоРегистрам(Отказ) Экспорт
	
	СтруктураДокумента = Новый Структура("СкладОтправитель,СкладПолучатель,ВидОперации");
	ЗаполнитьЗначенияСвойств(СтруктураДокумента,ЭтотОбъект);
	СтруктураДокумента.ВидОперации = "Перемещение";
	
	ТаблицаПоТоварам   = Товары.Выгрузить();
	ТаблицаПоТоварам.Свернуть("Номенклатура","Количество");
	
	СтруктураДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоТоварам);
	
	ДобавленныеФункции.ВыполнитьДвиженияПоПартиямТоваров(Ссылка,СтруктураДокумента, Отказ, Движения.ТоварыНаСкладах);
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвиженияПоРегистрам(Отказ);
	
КонецПроцедуры
