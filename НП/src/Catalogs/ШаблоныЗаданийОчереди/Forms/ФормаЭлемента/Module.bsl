#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;

	Если Объект.Ссылка.Пустая() Тогда
		Расписание = Новый РасписаниеРегламентногоЗадания;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Идентификатор = Объект.Ссылка.УникальныйИдентификатор();
	
	Расписание = ТекущийОбъект.Расписание.Получить();
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	ТекущийОбъект.Расписание = Новый ХранилищеЗначения(Расписание);
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	Идентификатор = Объект.Ссылка.УникальныйИдентификатор();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОткрытьРасписаниеЗадания(Команда)
	
	Диалог = Новый ДиалогРасписанияРегламентногоЗадания(Расписание);
	Диалог.Показать(Новый ОписаниеОповещения("ОткрытьРасписаниеЗавершение", ЭтотОбъект));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОткрытьРасписаниеЗавершение(НовоеРасписание, ТекущиеДанные) Экспорт

	Если НовоеРасписание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Расписание = НовоеРасписание;
	ЗаблокироватьДанныеФормыДляРедактирования();
	Модифицированность = Истина;
	
	ПоказатьОповещениеПользователя(НСтр("ru = 'Перепланирование'"), , НСтр("ru = 'Новое расписание будет учтено при
		|следующем выполнении задания по 
		|шаблону или обновлении версии ИБ'"));
	
КонецПроцедуры

#КонецОбласти