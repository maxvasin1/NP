
#Область ОбработчикиСобытийФормы
//

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	ИдентификаторКонсолиЗапросов = "КонсольЗапросов";
	
	ТекущийОбъект = ЭтотОбъект();
	ТекущийОбъект.ПрочитатьНастройки();
	ТекущийОбъект.ПрочитатьПризнакиПоддержкиБСП();
	
	Строка = СокрЛП(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов);
	Если НРег(Прав(Строка, 4)) = ".epf" Тогда
		ВариантИспользованияКонсолиЗапросов = 2;
	ИначеЕсли Метаданные.Обработки.Найти(Строка) <> Неопределено Тогда
		ВариантИспользованияКонсолиЗапросов = 1;
		Строка = "";	
	Иначе 
		ВариантИспользованияКонсолиЗапросов = 0;
		Строка = "";
	КонецЕсли;
	ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = Строка;
	
	ЭтотОбъект(ТекущийОбъект);
	
	СписокВыбора = Элементы.ОбработкаЗапросаВнешняя.СписокВыбора;
	
	// В составе метаданных разрешаем, только если есть предопределенное.
	Если Метаданные.Обработки.Найти(ИдентификаторКонсолиЗапросов) = Неопределено Тогда
		ТекЭлемент = СписокВыбора.НайтиПоЗначению(1);
		Если ТекЭлемент <> Неопределено Тогда
			СписокВыбора.Удалить(ТекЭлемент);
		КонецЕсли;
	КонецЕсли;
	
	// Строка опции из файла
	Если ТекущийОбъект.ЭтоФайловаяБаза() Тогда
		ТекЭлемент = СписокВыбора.НайтиПоЗначению(2);
		Если ТекЭлемент <> Неопределено Тогда
			ТекЭлемент.Представление = НСтр("ru = 'В каталоге:'");
		КонецЕсли;
	КонецЕсли;

	// БСП разрешаем только если она есть и нужной версии.
	Элементы.ГруппаБСП.Видимость = ТекущийОбъект.КонфигурацияПоддерживаетБСП
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
//

&НаКлиенте
Процедура ОбработкаЗапросаПутьПриИзменении(Элемент)
	ВариантИспользованияКонсолиЗапросов = 2;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗапросаПутьНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДополнительныеПараметры = Новый Структура();
	ТекстПредложения = НСтр("ru = 'Для открытия каталога необходимо необходимо установить расширение работы с файлами.'");
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеПроверкиРасширенияРаботыСФайлами", ЭтотОбъект, ДополнительныеПараметры);
	
#Если Не ВебКлиент Тогда
	// В тонком и толстом клиентах расширение подключено всегда.
	ВыполнитьОбработкуОповещения(ОписаниеОповещения, Истина);
#Иначе
	ВызватьИсключение(НСтр("ru = 'В WEB-клиенте данная возможность недоступна.'"));
#КонецЕсли
	
	Возврат;
	
КонецПроцедуры

// Продолжение процедуры (см. выше).
&НаКлиенте
Процедура ПослеПроверкиРасширенияРаботыСФайлами(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат Тогда
		
		Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		
		Диалог.ПроверятьСуществованиеФайла = Истина;
		Диалог.Фильтр = НСтр("ru = 'Внешние обработки (*.epf)|*.epf'");
		
		Оповещение = Новый ОписаниеОповещения("ПослеВыбораФайла", ЭтотОбъект, ДополнительныеПараметры);
		Диалог.Показать(Оповещение);
		
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры (см. выше).
&НаКлиенте
Процедура ПослеВыбораФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		Если ВыбранныеФайлы.Количество() = 1 Тогда
			ВариантИспользованияКонсолиЗапросов = 2;
			УстановитьНастройкуАдресВнешнейОбработкиЗапросов(ВыбранныеФайлы[0]);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы
//

&НаКлиенте
Процедура ПодтвердитьВыбор(Команда)
	
	Проверка = ПроверитьНастройки();
	Если Проверка.ЕстьОшибки Тогда
		// Сообщаем об ошибках
		Если Проверка.НастройкаАдресВнешнейОбработкиЗапросов <> Неопределено Тогда
			СообщитьОбОшибке(Проверка.НастройкаАдресВнешнейОбработкиЗапросов, "Объект.НастройкаАдресВнешнейОбработкиЗапросов");
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Все успешно
	СохранитьНастройки();
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
//

&НаКлиенте
Процедура СообщитьОбОшибке(Текст, ИмяРеквизита = Неопределено)
	
	Если ИмяРеквизита = Неопределено Тогда
		ЗаголовокОшибки = НСтр("ru = 'Ошибка'");
		ПоказатьПредупреждение(, Текст, , ЗаголовокОшибки);
		Возврат;
	КонецЕсли;
	
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = Текст;
	Сообщение.Поле  = ИмяРеквизита;
	Сообщение.УстановитьДанные(ЭтотОбъект);
	Сообщение.Сообщить();
КонецПроцедуры	

&НаСервере
Функция ЭтотОбъект(ТекущийОбъект = Неопределено) 
	Если ТекущийОбъект = Неопределено Тогда
		Возврат РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	ЗначениеВРеквизитФормы(ТекущийОбъект, "Объект");
	Возврат Неопределено;
КонецФункции

&НаСервере
Функция ПроверитьНастройки()
	ТекущийОбъект = ЭтотОбъект();
	
	Если ВариантИспользованияКонсолиЗапросов = 2 Тогда
		
		ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = СокрЛП(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов);
		Если СтрНачинаетсяС(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов, """")
			И СтрЗаканчиваетсяНа(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов, """") Тогда
			ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = Сред(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов, 
				2, СтрДлина(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов) - 2);
		КонецЕсли;
		
		Если Не СтрЗаканчиваетсяНа(НРег(СокрЛП(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов)), ".epf") Тогда
			ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = СокрЛП(ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов) + ".epf";
		КонецЕсли;
		
	ИначеЕсли ВариантИспользованияКонсолиЗапросов = 0 Тогда
		ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = "";
		
	КонецЕсли;
	
	Результат = ТекущийОбъект.ПроверитьКорректностьНастроек();
	ЭтотОбъект(ТекущийОбъект);
	
	Возврат Результат;
КонецФункции

&НаСервере
Процедура СохранитьНастройки()
	ТекущийОбъект = ЭтотОбъект();
	Если ВариантИспользованияКонсолиЗапросов = 0 Тогда
		ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = "";
	ИначеЕсли ВариантИспользованияКонсолиЗапросов = 1 Тогда
		ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = ИдентификаторКонсолиЗапросов		;
	КонецЕсли;
	ТекущийОбъект.СохранитьНастройки();
	ЭтотОбъект(ТекущийОбъект);
КонецПроцедуры

&НаСервере
Процедура УстановитьНастройкуАдресВнешнейОбработкиЗапросов(ПутьКФайлу)
	ТекущийОбъект = ЭтотОбъект();
	ТекущийОбъект.НастройкаАдресВнешнейОбработкиЗапросов = ПутьКФайлу;
	ЭтотОбъект(ТекущийОбъект);
КонецПроцедуры

#КонецОбласти
