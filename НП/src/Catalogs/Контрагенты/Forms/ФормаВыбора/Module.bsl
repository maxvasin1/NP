
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	// СтандартныеПодсистемы.РаботаСКонтрагентами
	//ПроверкаКонтрагентов.ПриСозданииНаСервереСписокКонтрагентов(Список);
	// Конец СтандартныеПодсистемы.РаботаСКонтрагентами
	
КонецПроцедуры

#КонецОбласти
