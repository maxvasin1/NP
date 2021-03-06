#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоНовый() Тогда
		
		Если ПометкаУдаления <> ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ПометкаУдаления") Тогда
			
			УстановитьПривилегированныйРежим(Истина);
			
			ОбщегоНазначения.УстановитьПометкуУдаленияПодчиненнымОбъектам(Ссылка, ПометкаУдаления);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	УстановитьПривилегированныйРежим(Истина);
	ОбщегоНазначения.УдалитьДанныеИзБезопасногоХранилища(Ссылка);
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

#КонецОбласти

#КонецЕсли