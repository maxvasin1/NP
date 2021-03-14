////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Подсистема "Адресный классификатор" в модели сервиса.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// См. описание этой же процедуры в модуле СтандартныеПодсистемыСервер.
Процедура ПриДобавленииОбработчиковСлужебныхСобытий(КлиентскиеОбработчики, СерверныеОбработчики) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ПоставляемыеДанные") Тогда
		СерверныеОбработчики["СтандартныеПодсистемы.РаботаВМоделиСервиса.ПоставляемыеДанные\ПриОпределенииОбработчиковПоставляемыхДанных"].Добавить(
			"АдресныйКлассификаторВМоделиСервисаСлужебный");
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ВыгрузкаЗагрузкаДанных") Тогда
		СерверныеОбработчики["ТехнологияСервиса.ВыгрузкаЗагрузкаДанных\ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки"].Добавить(
			"АдресныйКлассификаторВМоделиСервисаСлужебный");
	КонецЕсли;
	
КонецПроцедуры

// Регистрирует обработчики поставляемых данных за день и за все время.
//
Процедура ЗарегистрироватьОбработчикиПоставляемыхДанных(Знач Обработчики) Экспорт
	
	Обработчик = Обработчики.Добавить();
	Обработчик.ВидДанных = "ФИАС";
	Обработчик.КодОбработчика = "ФИАС";
	Обработчик.Обработчик = АдресныйКлассификаторВМоделиСервисаСлужебный;
	
КонецПроцедуры

// Вызывается при получении уведомления о новых данных.
// В теле следует проверить, необходимы ли эти данные приложению, 
// и если да - установить флажок Загружать.
// 
// Параметры:
//   Дескриптор   - ОбъектXDTO Descriptor.
//   Загружать    - булево, возвращаемое.
//
Процедура ДоступныНовыеДанные(Знач Дескриптор, Загружать) Экспорт
	
	Если Дескриптор.DataType = "ФИАС" Тогда
		
		Загружать = ПроверитьНаличиеНовыхДанных(Дескриптор);
		
	КонецЕсли;
	
КонецПроцедуры

// Вызывается после вызова ДоступныНовыеДанные, позволяет разобрать данные.
//
// Параметры:
//   Дескриптор   - ОбъектXDTO Дескриптор.
//   ПутьКФайлу   - Строка или Неопределено. Полное имя извлеченного файла. Файл будет автоматически удален 
//                  после завершения процедуры. Если в менеджере сервиса не был
//                  указан файл - значение аргумента равно Неопределено.
//
Процедура ОбработатьНовыеДанные(Знач Дескриптор, Знач ПутьКФайлу) Экспорт
	
	Если Дескриптор.DataType = "ФИАС" Тогда
		ОбработатьФИАС(Дескриптор, ПутьКФайлу);
	КонецЕсли;
	
КонецПроцедуры

// Вызывается при отмене обработки данных в случае сбоя.
//
Процедура ОбработкаДанныхОтменена(Знач Дескриптор) Экспорт 
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПараметрыФИАС()
	
	Возврат Новый Структура("Версия, Регион");
	
КонецФункции

Функция ПараметрыВерсииИзФайла(Знач Дескриптор)
	
	ПараметрыВерсии =  ПараметрыФИАС();
	
	Для Каждого Характеристика Из Дескриптор.Properties.Property Цикл
		Если Характеристика.Code = "Регион" Тогда
			ПараметрыВерсии.Регион = СтроковыеФункцииКлиентСервер.СтрокаВЧисло(Характеристика.Value);
		ИначеЕсли Характеристика.Code = "Версия" Тогда
			ПараметрыВерсии.Версия = СтроковыеФункцииКлиентСервер.СтрокаВЧисло(Характеристика.Value);
		КонецЕсли;
	КонецЦикла;
	
	Возврат ПараметрыВерсии;
	
КонецФункции

Функция ОписаниеПоследнейЗагрузкиФИАС(Знач КодРегиона)
	
	Результат = ПараметрыФИАС();
	Запрос = Новый Запрос();
	
	Запрос.УстановитьПараметр("КодСубъектаРФ", КодРегиона);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЗагруженныеВерсииАдресныхСведений.Версия,
		|	ЗагруженныеВерсииАдресныхСведений.КодСубъектаРФ КАК Регион
		|ИЗ
		|	РегистрСведений.ЗагруженныеВерсииАдресныхСведений КАК ЗагруженныеВерсииАдресныхСведений
		|ГДЕ
		|	ЗагруженныеВерсииАдресныхСведений.КодСубъектаРФ = &КодСубъектаРФ";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Результат.Версия = СтроковыеФункцииКлиентСервер.СтрокаВЧисло(Выборка.Версия);
		Результат.Регион = Выборка.Регион;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ПроверитьНаличиеНовыхДанных(Знач Дескриптор)
	
	ПараметрыНовыхДанных = ПараметрыВерсииИзФайла(Дескриптор);
	Если ПараметрыНовыхДанных.Версия = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ПараметрыНовыхДанных.Регион) Тогда
		Возврат Истина;
	КонецЕсли;
	
	ПараметрыТекущихДанных = ОписаниеПоследнейЗагрузкиФИАС(ПараметрыНовыхДанных.Регион);
	Если ПараметрыТекущихДанных.Версия = Неопределено 
		ИЛИ ПараметрыНовыхДанных.Версия > ПараметрыТекущихДанных.Версия Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Процедура ОбработатьФИАС(Знач Дескриптор, Знач ПутьКФайлу)
	
	КаталогФайлов = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПолучитьИмяВременногоФайла());
	
	Попытка
		ЧтениеZIP = Новый ЧтениеZipФайла(ПутьКФайлу);
		ЧтениеZIP.ИзвлечьВсе(КаталогФайлов, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
		ЧтениеZIP.Закрыть();
		
		// Загружаем только то, что передано в файлах.
		СубъектыРФ = Новый Массив;
		ТипЧисло   = Новый ОписаниеТипов("Число");
		ОписаниеФайлов = Новый Массив;
		
		Для Каждого Файл Из НайтиФайлы(КаталогФайлов, "??.ZIP") Цикл
			КодРегиона = ТипЧисло.ПривестиЗначение(Лев(Файл.Имя, 2));
			Если КодРегиона > 0 Тогда
				СубъектыРФ.Добавить(КодРегиона);
			КонецЕсли;
			ОписаниеФайлов.Добавить( Новый Структура("Имя, Хранение", Файл.ПолноеИмя, Файл.ПолноеИмя));
		КонецЦикла;
		
		Если СубъектыРФ.Количество() > 0 Тогда
			АдресныйКлассификаторСлужебный.ЗагрузитьКлассификаторАдресов(СубъектыРФ, ОписаниеФайлов, Ложь);
		КонецЕсли;
		
	Исключение
		АдресныйКлассификаторСлужебный.УдалитьВременныйФайл(КаталогФайлов);
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Обработчики событий подсистем БСП.

// Зарегистрировать обработчики поставляемых данных.
//
// При получении уведомления о доступности новых общих данных, вызывается процедуры.
// ДоступныНовыеДанные модулей, зарегистрированных через ПолучитьОбработчикиПоставляемыхДанных.
// В процедуру передается Дескриптор - ОбъектXDTO Descriptor.
// 
// В случае, если ДоступныНовыеДанные устанавливает аргумент Загружать в значение Истина, 
// данные загружаются, дескриптор и путь к файлу с данными передаются в процедуру.
// ОбработатьНовыеДанные. Файл будет автоматически удален после завершения процедуры.
// Если в менеджере сервиса не был указан файл - значение аргумента равно Неопределено.
//
// Параметры: 
//     Обработчики - ТаблицаЗначений - таблица для добавления обработчиков. Содержит колонки.
//       * ВидДанных      - Строка      - код вида данных, обрабатываемый обработчиком.
//       * КодОбработчика - Строка      - будет использоваться при восстановлении обработки данных после сбоя.
//       * Обработчик     - ОбщийМодуль - модуль, содержащий экспортные  процедуры:
//                                          ДоступныНовыеДанные(Дескриптор, Загружать) Экспорт  
//                                          ОбработатьНовыеДанные(Дескриптор, ПутьКФайлу) Экспорт
//                                          ОбработкаДанныхОтменена(Дескриптор) Экспорт
//
Процедура ПриОпределенииОбработчиковПоставляемыхДанных(Обработчики) Экспорт
	
	ЗарегистрироватьОбработчикиПоставляемыхДанных(Обработчики);
	
КонецПроцедуры

// Заполняет массив типов, исключаемых из выгрузки и загрузки данных.
//
// Параметры:
//  Типы - Массив - заполняется метаданными.
//
Процедура ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки(Типы) Экспорт
	
	Типы.Добавить(Метаданные.Константы.ИсточникДанныхАдресногоКлассификатора);
	
	МетаданныеРегистров = Метаданные.РегистрыСведений;
	
	Типы.Добавить(МетаданныеРегистров.АдресныеОбъекты);
	Типы.Добавить(МетаданныеРегистров.ДомаЗданияСтроения);
	Типы.Добавить(МетаданныеРегистров.ДополнительныеАдресныеСведения);
	Типы.Добавить(МетаданныеРегистров.ЗагруженныеВерсииАдресныхСведений);
	Типы.Добавить(МетаданныеРегистров.ИсторияАдресныхОбъектов);
	Типы.Добавить(МетаданныеРегистров.ОриентирыАдресныхОбъектов);
	Типы.Добавить(МетаданныеРегистров.ПричиныИзмененияАдресныхСведений);
	Типы.Добавить(МетаданныеРегистров.СлужебныеАдресныеСведения);
	Типы.Добавить(МетаданныеРегистров.УровниСокращенийАдресныхСведений);
	
	Типы.Добавить(МетаданныеРегистров.УдалитьАдресныйКлассификатор);
	
КонецПроцедуры

#КонецОбласти
