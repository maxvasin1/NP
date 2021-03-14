////////////////////////////////////////////////////////////////////////////////
// Подсистема "Управление доступом".
// 
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Содержит сохраненные параметры, используемые подсистемой.
Функция Параметры() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	СохраненныеПараметры = СтандартныеПодсистемыСервер.ПараметрыРаботыПрограммы(
		"ПараметрыОграниченияДоступа");
	УстановитьПривилегированныйРежим(Ложь);
	
	СтандартныеПодсистемыСервер.ПроверитьОбновлениеПараметровРаботыПрограммы(
		"ПараметрыОграниченияДоступа",
		"ВозможныеПраваДляНастройкиПравОбъектов,
		|ПоставляемыеПрофилиГруппДоступа,
		|ПредопределенныеПрофилиГруппДоступа,
		|СвойстваВидовДоступа");
	
	ПредставлениеПараметра = "";
	
	Если НЕ СохраненныеПараметры.Свойство("ВозможныеПраваДляНастройкиПравОбъектов") Тогда
		ПредставлениеПараметра = НСтр("ru = 'Возможные права для настройки прав объектов'");
		
	ИначеЕсли НЕ СохраненныеПараметры.Свойство("ПоставляемыеПрофилиГруппДоступа") Тогда
		ПредставлениеПараметра = НСтр("ru = 'Поставляемые профили групп доступа'");
		
	ИначеЕсли НЕ СохраненныеПараметры.Свойство("ПредопределенныеПрофилиГруппДоступа") Тогда
		ПредставлениеПараметра = НСтр("ru = 'Предопределенные профили групп доступа'");
		
	ИначеЕсли НЕ СохраненныеПараметры.Свойство("СвойстваВидовДоступа") Тогда
		ПредставлениеПараметра = НСтр("ru = 'Свойства видов доступа'");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПредставлениеПараметра) Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка обновления информационной базы.
				           |Не заполнен параметр ограничения доступа:
				           |""%1"".'"),
				ПредставлениеПараметра)
			+ СтандартныеПодсистемыСервер.УточнениеОшибкиПараметровРаботыПрограммыДляРазработчика();
	КонецЕсли;
	
	Возврат СохраненныеПараметры;
	
КонецФункции

// Возвращает таблицу значений, содержащую вид ограничений доступа по каждому праву
// объектов метаданных.
//  Если записи по праву нет, значит ограничений по праву нет.
//  Таблица содержит только виды доступа, заданные разработчиком,
// исходя из их применения в текстах ограничений.
//  Для получения всех видов доступа, включая используемые в наборах
// значений доступа может быть использовано
// текущее состояние регистра сведений НаборыЗначенийДоступа.
//
// Параметры:
//  ДляПроверки - Булево - вернуть текстовое описание ограничений прав, заполненное
//                         в переопределяемых модулях без проверки.
//
// Возвращаемое значение:
//  ТаблицаЗначений - если ДляПроверки = Ложь, состав колонок:
//    Таблица        - Строка - имя таблицы объекта метаданных, например, Справочник.Файлы.
//    Право          - Строка: "Чтение", "Изменение".
//    ВидДоступа     - Ссылка - пустая ссылка основного типа значений вида доступа,
//                              пустая ссылка владельца настроек прав.
//                   - Неопределено - для вида доступа Объект.
//    ТаблицаОбъекта - Ссылка - пустая ссылка объекта метаданных, через который ограничивается доступ,
//                     используя наборы значений доступа, например, Справочник.ПапкиФайлов.
//                   - Неопределено, если ВидДоступа <> Неопределено.
//
//  Строка - если ДляПроверки = Истина - ограничения прав, как они добавлены в переопределяемом модуле.
//
Функция ПостоянныеВидыОграниченийПравОбъектовМетаданных(ДляПроверки = Ложь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ВидыДоступаПрав = Новый ТаблицаЗначений;
	ВидыДоступаПрав.Колонки.Добавить("Таблица",        Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
	ВидыДоступаПрав.Колонки.Добавить("Право",          Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(20)));
	ВидыДоступаПрав.Колонки.Добавить("ВидДоступа",     ОписаниеТиповЗначенийДоступаИВладельцевНастроекПрав());
	ВидыДоступаПрав.Колонки.Добавить("ТаблицаОбъекта", Метаданные.РегистрыСведений.НаборыЗначенийДоступа.Измерения.Объект.Тип);
	
	ОграниченияПрав = "";
	
	ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
		"СтандартныеПодсистемы.УправлениеДоступом\ПриЗаполненииВидовОграниченийПравОбъектовМетаданных");
	
	Для каждого Обработчик Из ОбработчикиСобытия Цикл
		Обработчик.Модуль.ПриЗаполненииВидовОграниченийПравОбъектовМетаданных(ОграниченияПрав);
	КонецЦикла;
	
	УправлениеДоступомПереопределяемый.ПриЗаполненииВидовОграниченийПравОбъектовМетаданных(ОграниченияПрав);
	
	Если ДляПроверки Тогда
		Возврат ОграниченияПрав;
	КонецЕсли;
	
	ВидыДоступаПоИменам = УправлениеДоступомСлужебныйПовтИсп.Параметры().СвойстваВидовДоступа.ПоИменам;
	
	Для НомерСтроки = 1 По СтрЧислоСтрок(ОграниченияПрав) Цикл
		ТекущаяСтрока = СокрЛП(СтрПолучитьСтроку(ОграниченияПрав, НомерСтроки));
		Если ЗначениеЗаполнено(ТекущаяСтрока) Тогда
			ПояснениеОшибки = "";
			Если СтрЧислоВхождений(ТекущаяСтрока, ".") <> 3 И СтрЧислоВхождений(ТекущаяСтрока, ".") <> 5 Тогда
				ПояснениеОшибки = НСтр("ru = 'Строка должна быть в формате ""<Полное имя таблицы>.<Имя права>.<Имя вида доступа>[.Таблица объекта]"".'");
			Иначе
				ПозицияПрава = СтрНайти(ТекущаяСтрока, ".");
				ПозицияПрава = СтрНайти(Сред(ТекущаяСтрока, ПозицияПрава + 1), ".") + ПозицияПрава;
				Таблица = Лев(ТекущаяСтрока, ПозицияПрава - 1);
				ПозицияВидаДоступа = СтрНайти(Сред(ТекущаяСтрока, ПозицияПрава + 1), ".") + ПозицияПрава;
				Право = Сред(ТекущаяСтрока, ПозицияПрава + 1, ПозицияВидаДоступа - ПозицияПрава - 1);
				Если СтрЧислоВхождений(ТекущаяСтрока, ".") = 3 Тогда
					ВидДоступа = Сред(ТекущаяСтрока, ПозицияВидаДоступа + 1);
					ТаблицаОбъекта = "";
				Иначе
					ПозицияТаблицыОбъекта = СтрНайти(Сред(ТекущаяСтрока, ПозицияВидаДоступа + 1), ".") + ПозицияВидаДоступа;
					ВидДоступа = Сред(ТекущаяСтрока, ПозицияВидаДоступа + 1, ПозицияТаблицыОбъекта - ПозицияВидаДоступа - 1);
					ТаблицаОбъекта = Сред(ТекущаяСтрока, ПозицияТаблицыОбъекта + 1);
				КонецЕсли;
				
				Если Метаданные.НайтиПоПолномуИмени(Таблица) = Неопределено Тогда
					ПояснениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Не найдена таблица ""%1"".'"), Таблица);
				
				ИначеЕсли Право <> "Чтение" И Право <> "Изменение" Тогда
					ПояснениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Не найдено право ""%1"".'"), Право);
				
				ИначеЕсли ВРег(ВидДоступа) = ВРег("Объект") Тогда
					Если Метаданные.НайтиПоПолномуИмени(ТаблицаОбъекта) = Неопределено Тогда
						ПояснениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							НСтр("ru = 'Не найдена таблица объекта ""%1"".'"),
							ТаблицаОбъекта);
					Иначе
						ВидДоступаСсылка = Неопределено;
						ТаблицаОбъектаСсылка = УправлениеДоступомСлужебный.ПустаяСсылкаОбъектаМетаданных(
							ТаблицаОбъекта);
					КонецЕсли;
					
				ИначеЕсли ВРег(ВидДоступа) = ВРег("НастройкиПрав") Тогда
					Если Метаданные.НайтиПоПолномуИмени(ТаблицаОбъекта) = Неопределено Тогда
						ПояснениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							НСтр("ru = 'Не найдена таблица владельца настроек прав ""%1"".'"),
							ТаблицаОбъекта);
					Иначе
						ВидДоступаСсылка = УправлениеДоступомСлужебный.ПустаяСсылкаОбъектаМетаданных(
							ТаблицаОбъекта);
						ТаблицаОбъектаСсылка = Неопределено;
					КонецЕсли;
				
				ИначеЕсли ВидыДоступаПоИменам.Получить(ВидДоступа) = Неопределено Тогда
					ПояснениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Не найден вид доступа ""%1"".'"), ВидДоступа);
				Иначе
					ВидДоступаСсылка = ВидыДоступаПоИменам.Получить(ВидДоступа).Ссылка;
					ТаблицаОбъектаСсылка = Неопределено;
				КонецЕсли;
			КонецЕсли;
			
			Если ЗначениеЗаполнено(ПояснениеОшибки) Тогда
				ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Ошибка в строке описания вида ограничений права объекта метаданных:
						           |""%1"".
						           |
						           |'"),
						ТекущаяСтрока)
					+ ПояснениеОшибки;
			Иначе
				СвойстваВидаДоступа = ВидыДоступаПоИменам.Получить(ВидДоступа);
				НовоеОписание = ВидыДоступаПрав.Добавить();
				НовоеОписание.Таблица        = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Таблица);
				НовоеОписание.Право          = Право;
				НовоеОписание.ВидДоступа     = ВидДоступаСсылка;
				НовоеОписание.ТаблицаОбъекта = ТаблицаОбъектаСсылка;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	// Добавление видов доступа объектов, которые определяются не только через наборы значений доступа.
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЗависимостиПравДоступа.ПодчиненнаяТаблица,
	|	ЗависимостиПравДоступа.ТипВедущейТаблицы
	|ИЗ
	|	РегистрСведений.ЗависимостиПравДоступа КАК ЗависимостиПравДоступа";
	ЗависимостиПрав = Запрос.Выполнить().Выгрузить();
	
	ПрекратитьПопытки = Ложь;
	Пока НЕ ПрекратитьПопытки Цикл
		ПрекратитьПопытки = Истина;
		Отбор = Новый Структура("ВидДоступа", Неопределено);
		ВидыДоступаОбъект = ВидыДоступаПрав.НайтиСтроки(Отбор);
		Для каждого Строка Из ВидыДоступаОбъект Цикл
			ИдентификаторТаблицы = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(
				ТипЗнч(Строка.ТаблицаОбъекта));
			
			Отбор = Новый Структура;
			Отбор.Вставить("ПодчиненнаяТаблица", Строка.Таблица);
			Отбор.Вставить("ТипВедущейТаблицы", Строка.ТаблицаОбъекта);
			Если ЗависимостиПрав.НайтиСтроки(Отбор).Количество() = 0 Тогда
				ВедущееПраво = Строка.Право;
			Иначе
				ВедущееПраво = "Чтение";
			КонецЕсли;
			Отбор = Новый Структура("Таблица, Право", ИдентификаторТаблицы, ВедущееПраво);
			ВидыДоступаВедущейТаблицы = ВидыДоступаПрав.НайтиСтроки(Отбор);
			Для каждого ОписаниеВидаДоступа Из ВидыДоступаВедущейТаблицы Цикл
				Если ОписаниеВидаДоступа.ВидДоступа = Неопределено Тогда
					// Вид доступа объект нельзя добавлять.
					Продолжить;
				КонецЕсли;
				Отбор = Новый Структура;
				Отбор.Вставить("Таблица",    Строка.Таблица);
				Отбор.Вставить("Право",      Строка.Право);
				Отбор.Вставить("ВидДоступа", ОписаниеВидаДоступа.ВидДоступа);
				Если ВидыДоступаПрав.НайтиСтроки(Отбор).Количество() = 0 Тогда
					ЗаполнитьЗначенияСвойств(ВидыДоступаПрав.Добавить(), Отбор);
					ПрекратитьПопытки = Ложь;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Возврат ВидыДоступаПрав;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования.
Функция ОписаниеКлючаЗаписи(ТипИлиПолноеИмя) Экспорт
	
	ОписаниеКлюча = Новый Структура("МассивПолей, СтрокаПолей", Новый Массив, "");
	
	Если ТипЗнч(ТипИлиПолноеИмя) = Тип("Тип") Тогда
		ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипИлиПолноеИмя);
	Иначе
		ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ТипИлиПолноеИмя);
	КонецЕсли;
	Менеджер = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ОбъектМетаданных.ПолноеИмя());
	
	Для каждого Колонка Из Менеджер.СоздатьНаборЗаписей().Выгрузить().Колонки Цикл
		
		Если ОбъектМетаданных.Ресурсы.Найти(Колонка.Имя) = Неопределено
		   И ОбъектМетаданных.Реквизиты.Найти(Колонка.Имя) = Неопределено Тогда
			// Если поля нет в ресурсах и реквизитах, значит это поле - измерение.
			ОписаниеКлюча.МассивПолей.Добавить(Колонка.Имя);
			ОписаниеКлюча.СтрокаПолей = ОписаниеКлюча.СтрокаПолей + Колонка.Имя + ",";
		КонецЕсли;
	КонецЦикла;
	
	ОписаниеКлюча.СтрокаПолей = Лев(ОписаниеКлюча.СтрокаПолей, СтрДлина(ОписаниеКлюча.СтрокаПолей)-1);
	
	Возврат ОбщегоНазначения.ФиксированныеДанные(ОписаниеКлюча);
	
КонецФункции

// Только для внутреннего использования.
Функция ТипыПоляТаблицы(ПолноеИмяПоля) Экспорт
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ПолноеИмяПоля);
	
	МассивТипов = ОбъектМетаданных.Тип.Типы();
	
	ТипыПоля = Новый Соответствие;
	Для каждого Тип Из МассивТипов Цикл
		Если Тип = Тип("СправочникОбъект.ИдентификаторыОбъектовМетаданных") Тогда
			Продолжить;
		КонецЕсли;
		ТипыПоля.Вставить(Тип, Истина);
	КонецЦикла;
	
	Возврат ТипыПоля;
	
КонецФункции

// Возвращает типы объектов и ссылок в указанных подписках на события.
// 
// Параметры:
//  ИменаПодписок - Строка - многострочная строка, содержащая
//                  строки начала имени подписки.
//
Функция ТипыОбъектовВПодпискахНаСобытия(ИменаПодписок, МассивПустыхСсылок = Ложь) Экспорт
	
	ТипыОбъектов = Новый Соответствие;
	
	Для каждого Подписка Из Метаданные.ПодпискиНаСобытия Цикл
		
		Для НомерСтроки = 1 По СтрЧислоСтрок(ИменаПодписок) Цикл
			
			НачалоИмени = СтрПолучитьСтроку(ИменаПодписок, НомерСтроки);
			ИмяПодписки = Подписка.Имя;
			
			Если ВРег(Лев(ИмяПодписки, СтрДлина(НачалоИмени))) = ВРег(НачалоИмени) Тогда
				
				Для каждого Тип Из Подписка.Источник.Типы() Цикл
					Если Тип = Тип("СправочникОбъект.ИдентификаторыОбъектовМетаданных") Тогда
						Продолжить;
					КонецЕсли;
					ТипыОбъектов.Вставить(Тип, Истина);
				КонецЦикла;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Если Не МассивПустыхСсылок Тогда
		Возврат Новый ФиксированноеСоответствие(ТипыОбъектов);
	КонецЕсли;
	
	Массив = Новый Массив;
	Для каждого КлючИЗначение Из ТипыОбъектов Цикл
		Массив.Добавить(УправлениеДоступомСлужебный.ПустаяСсылкаОбъектаМетаданных(
			КлючИЗначение.Ключ));
	КонецЦикла;
	
	Возврат Новый ФиксированныйМассив(Массив);
	
КонецФункции

// Только для внутреннего использования.
Функция ТаблицаПустогоНабораЗаписей(ПолноеИмяРегистра) Экспорт
	
	Менеджер = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ПолноеИмяРегистра);
	
	Возврат Менеджер.СоздатьНаборЗаписей().Выгрузить();
	
КонецФункции

// Только для внутреннего использования.
Функция ТаблицаПустыхСсылокУказанныхТипов(ПолноеИмяРеквизита) Экспорт
	
	ОписаниеТипов = Метаданные.НайтиПоПолномуИмени(ПолноеИмяРеквизита).Тип;
	
	ПустыеСсылки = Новый ТаблицаЗначений;
	ПустыеСсылки.Колонки.Добавить("ПустаяСсылка", ОписаниеТипов);
	
	Для каждого ТипЗначения Из ОписаниеТипов.Типы() Цикл
		Если ОбщегоНазначения.ЭтоСсылка(ТипЗначения) Тогда
			ПустыеСсылки.Добавить().ПустаяСсылка = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(
				Метаданные.НайтиПоТипу(ТипЗначения).ПолноеИмя()).ПустаяСсылка();
		КонецЕсли;
	КонецЦикла;
	
	Возврат ПустыеСсылки;
	
КонецФункции

// Только для внутреннего использования.
Функция СоответствиеПустыхСсылокУказаннымТипамСсылок(ПолноеИмяРеквизита) Экспорт
	
	ОписаниеТипов = Метаданные.НайтиПоПолномуИмени(ПолноеИмяРеквизита).Тип;
	
	ПустыеСсылки = Новый Соответствие;
	
	Для каждого ТипЗначения Из ОписаниеТипов.Типы() Цикл
		Если ОбщегоНазначения.ЭтоСсылка(ТипЗначения) Тогда
			ПустыеСсылки.Вставить(ТипЗначения, ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(
				Метаданные.НайтиПоТипу(ТипЗначения).ПолноеИмя()).ПустаяСсылка() );
		КонецЕсли;
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(ПустыеСсылки);
	
КонецФункции

// Только для внутреннего использования.
Функция КодыТиповСсылок(ПолноеИмяРеквизита) Экспорт
	
	ОписаниеТипов = Метаданные.НайтиПоПолномуИмени(ПолноеИмяРеквизита).Тип;
	
	ЧисловыеКодыТипов = Новый Соответствие;
	ТекущийКод = 0;
	
	Для каждого ТипЗначения Из ОписаниеТипов.Типы() Цикл
		Если ОбщегоНазначения.ЭтоСсылка(ТипЗначения) Тогда
			ЧисловыеКодыТипов.Вставить(ТипЗначения, ТекущийКод);
		КонецЕсли;
		ТекущийКод = ТекущийКод + 1;
	КонецЦикла;
	
	СтроковыеКодыТипов = Новый Соответствие;
	
	ДлинаСтроковогоКода = СтрДлина(Формат(ТекущийКод-1, "ЧН=0; ЧГ="));
	ФорматнаяСтрокаКода = "ЧЦ=" + Формат(ДлинаСтроковогоКода, "ЧН=0; ЧГ=") + "; ЧН=0; ЧВН=; ЧГ=";
	
	Для каждого КлючИЗначение Из ЧисловыеКодыТипов Цикл
		СтроковыеКодыТипов.Вставить(
			КлючИЗначение.Ключ,
			Формат(КлючИЗначение.Значение, ФорматнаяСтрокаКода));
	КонецЦикла;
	
	Возврат СтроковыеКодыТипов;
	
КонецФункции

// Только для внутреннего использования.
Функция КодыПеречислений() Экспорт
	
	КодыПеречислений = Новый Соответствие;
	
	Для каждого ТипЗначенияДоступа Из Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип.Типы() Цикл
		МетаданныеТипа = Метаданные.НайтиПоТипу(ТипЗначенияДоступа);
		Если МетаданныеТипа = Неопределено ИЛИ НЕ Метаданные.Перечисления.Содержит(МетаданныеТипа) Тогда
			Продолжить;
		КонецЕсли;
		Для каждого ЗначениеПеречисления Из МетаданныеТипа.ЗначенияПеречисления Цикл
			ИмяЗначения = ЗначениеПеречисления.Имя;
			КодыПеречислений.Вставить(Перечисления[МетаданныеТипа.Имя][ИмяЗначения], ИмяЗначения);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(КодыПеречислений);;
	
КонецФункции

// Только для внутреннего использования.
Функция ТипыЗначенийВидовДоступа() Экспорт
	
	СвойстваВидовДоступа = УправлениеДоступомСлужебныйПовтИсп.Параметры().СвойстваВидовДоступа;
	
	ТипыЗначенийВидовДоступа = Новый ТаблицаЗначений;
	ТипыЗначенийВидовДоступа.Колонки.Добавить("ВидДоступа",  Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
	ТипыЗначенийВидовДоступа.Колонки.Добавить("ТипЗначений", Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
	
	Для каждого КлючИЗначение Из СвойстваВидовДоступа.ПоТипамЗначений Цикл
		Строка = ТипыЗначенийВидовДоступа.Добавить();
		Строка.ВидДоступа = КлючИЗначение.Значение.Ссылка;
		
		Типы = Новый Массив;
		Типы.Добавить(КлючИЗначение.Ключ);
		ОписаниеТипа = Новый ОписаниеТипов(Типы);
		
		Строка.ТипЗначений = ОписаниеТипа.ПривестиЗначение(Неопределено);
	КонецЦикла;
	
	Возврат ТипыЗначенийВидовДоступа;
	
КонецФункции

// Только для внутреннего использования.
Функция ТипыГруппИЗначенийВидовДоступа() Экспорт
	
	СвойстваВидовДоступа = УправлениеДоступомСлужебныйПовтИсп.Параметры().СвойстваВидовДоступа;
	
	ТипыГруппИЗначенийВидовДоступа = Новый ТаблицаЗначений;
	ТипыГруппИЗначенийВидовДоступа.Колонки.Добавить("ВидДоступа",        Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
	ТипыГруппИЗначенийВидовДоступа.Колонки.Добавить("ТипГруппИЗначений", Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
	
	Для каждого КлючИЗначение Из СвойстваВидовДоступа.ПоТипамГруппИЗначений Цикл
		Строка = ТипыГруппИЗначенийВидовДоступа.Добавить();
		Строка.ВидДоступа = КлючИЗначение.Значение.Ссылка;
		
		Типы = Новый Массив;
		Типы.Добавить(КлючИЗначение.Ключ);
		ОписаниеТипа = Новый ОписаниеТипов(Типы);
		
		Строка.ТипГруппИЗначений = ОписаниеТипа.ПривестиЗначение(Неопределено);
	КонецЦикла;
	
	Возврат ТипыГруппИЗначенийВидовДоступа;
	
КонецФункции

// Только для внутреннего использования.
Функция ОписаниеТиповЗначенийДоступаИВладельцевНастроекПрав() Экспорт
	
	Типы = Новый Массив;
	Для каждого Тип Из Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип.Типы() Цикл
		Типы.Добавить(Тип);
	КонецЦикла;
	
	Для каждого Тип Из Метаданные.ОпределяемыеТипы.ВладелецНастроекПрав.Тип.Типы() Цикл
		Типы.Добавить(Тип);
	КонецЦикла;
	
	Возврат Новый ОписаниеТипов(Типы);
	
КонецФункции

// Только для внутреннего использования.
Функция ТипыЗначенийВидовДоступаИВладельцевНастроекПрав() Экспорт
	
	ТипыЗначенийВидовДоступаИВладельцевНастроекПрав = Новый ТаблицаЗначений;
	
	ТипыЗначенийВидовДоступаИВладельцевНастроекПрав.Колонки.Добавить("ВидДоступа",
		УправлениеДоступомСлужебныйПовтИсп.ОписаниеТиповЗначенийДоступаИВладельцевНастроекПрав());
	
	ТипыЗначенийВидовДоступаИВладельцевНастроекПрав.Колонки.Добавить("ТипЗначений",
		УправлениеДоступомСлужебныйПовтИсп.ОписаниеТиповЗначенийДоступаИВладельцевНастроекПрав());
	
	ТипыЗначенийВидовДоступа = УправлениеДоступомСлужебныйПовтИсп.ТипыЗначенийВидовДоступа();
	
	Для каждого Строка Из ТипыЗначенийВидовДоступа Цикл
		ЗаполнитьЗначенияСвойств(ТипыЗначенийВидовДоступаИВладельцевНастроекПрав.Добавить(), Строка);
	КонецЦикла;
	
	ТекущиеПараметры = УправлениеДоступомСлужебныйПовтИсп.Параметры();
	ВладельцыПрав = ТекущиеПараметры.ВозможныеПраваДляНастройкиПравОбъектов.ПоТипамСсылок;
	
	Для каждого КлючИЗначение Из ВладельцыПрав Цикл
		
		Типы = Новый Массив;
		Типы.Добавить(КлючИЗначение.Ключ);
		ОписаниеТипа = Новый ОписаниеТипов(Типы);
		
		Строка = ТипыЗначенийВидовДоступаИВладельцевНастроекПрав.Добавить();
		Строка.ВидДоступа  = ОписаниеТипа.ПривестиЗначение(Неопределено);
		Строка.ТипЗначений = ОписаниеТипа.ПривестиЗначение(Неопределено);
	КонецЦикла;
	
	Возврат ТипыЗначенийВидовДоступаИВладельцевНастроекПрав;
	
КонецФункции

// Только для внутреннего использования.
Функция ВидыОграниченийПравОбъектовМетаданных() Экспорт
	
	Возврат Новый Структура("ДатаОбновления, Таблица", '00010101');
	
КонецФункции

#КонецОбласти
