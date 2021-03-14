////////////////////////////////////////////////////////////////////////////////
// ОБЩАЯ РЕАЛИЗАЦИЯ ОБРАБОТКИ СООБЩЕНИЙ УДАЛЕННОГО АДМИНИСТРИРОВАНИЯ
//
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}UpdateUser.
//
// Параметры:
//  Имя - строка, имя пользователя,
//  ПолноеИмя - строка, полное имя пользователя,
//  ХэшПароля - строка, сохраняемое значение пароля,
//  ИдентификаторПользователяПриложения - УникальныйИдентификатор,
//  ИдентификаторПользователяСервиса - УникальныйИдентификатор,
//  НомерТелефона - строка, номер телефона пользователя,
//  АдресЭлектроннойПочты - строка, адрес электронной почты пользователя,
//  КодЯзыка - строка, код языка пользователя.
//
Процедура ОбновитьПользователя(Знач Имя, Знач ПолноеИмя, Знач ХэшПароля,
		Знач ИдентификаторПользователяПриложения,
		Знач ИдентификаторПользователяСервиса,
		Знач НомерТелефона = "", Знач АдресЭлектроннойПочты = "",
		Знач КодЯзыка = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ЯзыкПользователя = ЯзыкПоКоду(КодЯзыка);
	
	Почта = АдресЭлектроннойПочты;
	
	Телефон = НомерТелефона;
	
	СтруктураАдресаЭП = СоставПочтовогоАдреса(Почта);
	
	НачатьТранзакцию();
	Попытка
		Если ЗначениеЗаполнено(ИдентификаторПользователяПриложения) Тогда
			
			ПользовательОбластиДанных = Справочники.Пользователи.ПолучитьСсылку(ИдентификаторПользователяПриложения);
			
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
			ЭлементБлокировки.УстановитьЗначение("Ссылка", ПользовательОбластиДанных);
			Блокировка.Заблокировать();
		Иначе
			Запрос = Новый Запрос;
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Пользователи.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.Пользователи КАК Пользователи
			|ГДЕ
			|	Пользователи.ИдентификаторПользователяСервиса = &ИдентификаторПользователяСервиса";
			Запрос.УстановитьПараметр("ИдентификаторПользователяСервиса", ИдентификаторПользователяСервиса);
			
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
			Блокировка.Заблокировать();
			
			Результат = Запрос.Выполнить();
			Если Результат.Пустой() Тогда
				ПользовательОбластиДанных = Неопределено;
			Иначе
				Выборка = Результат.Выбрать();
				Выборка.Следующий();
				ПользовательОбластиДанных = Выборка.Ссылка;
			КонецЕсли;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ПользовательОбластиДанных) Тогда
			ПользовательОбъект = Справочники.Пользователи.СоздатьЭлемент();
			ПользовательОбъект.ИдентификаторПользователяСервиса = ИдентификаторПользователяСервиса;
		Иначе
			ПользовательОбъект = ПользовательОбластиДанных.ПолучитьОбъект();
		КонецЕсли;
		
		ПользовательОбъект.Наименование = ПолноеИмя;
		
		ОбновитьАдресЭлектроннойПочты(ПользовательОбъект, Почта, СтруктураАдресаЭП);
		
		ОбновитьТелефон(ПользовательОбъект, Телефон);
		
		ОписаниеПользователяИБ = Пользователи.НовоеОписаниеПользователяИБ();
		
		ОписаниеПользователяИБ.Имя = Имя;
		
		ОписаниеПользователяИБ.АутентификацияСтандартная = Истина;
		ОписаниеПользователяИБ.АутентификацияOpenID = Истина;
		ОписаниеПользователяИБ.ПоказыватьВСпискеВыбора = Ложь;
		
		ОписаниеПользователяИБ.СохраняемоеЗначениеПароля = ХэшПароля;
		
		ОписаниеПользователяИБ.Язык = ЯзыкПользователя;
		
		ОписаниеПользователяИБ.Вставить("Действие", "Записать");
		ПользовательОбъект.ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);
		
		ПользовательОбъект.ДополнительныеСвойства.Вставить("ОбработкаСообщенияКаналаУдаленногоАдминистрирования");
		ПользовательОбъект.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}PrepareApplication.
//
// Параметры:
//  КодОбластиДанных - число(7,0),
//  ИзВыгрузки - булево, признак создания области данных из файла с выгрузкой данных из локального режима
//               (data_dump.zip),
//  Вариант - строка, вариант файла начальных данных для области данных,
//  ИдентификаторВыгрузки - УникальныйИдентификатор, идентификатор файла выгрузки в хранилище менеджера сервиса.
//
Процедура ПодготовитьОбластьДанных(Знач КодОбластиДанных, Знач ИзВыгрузки, Знач Вариант, Знач ИдентификаторВыгрузки) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		Если НЕ ЗначениеЗаполнено(Константы.РежимИспользованияИнформационнойБазы.Получить()) Тогда
			ТекстСообщения = НСтр("ru = 'Не установлен режим работы информационной базы'");
			ВызватьИсключение(ТекстСообщения);
		КонецЕсли;
		
		Блокировка = Новый БлокировкаДанных;
		Элемент = Блокировка.Добавить("РегистрСведений.ОбластиДанных");
		Блокировка.Заблокировать();
		
		МенеджерЗаписи = РегистрыСведений.ОбластиДанных.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Прочитать();
		Если МенеджерЗаписи.Выбран() Тогда
			Если МенеджерЗаписи.Статус = Перечисления.СтатусыОбластейДанных.Удалена Тогда
				ШаблонСообщения = НСтр("ru = 'Область данных %1 удалена'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, КодОбластиДанных);
				ВызватьИсключение(ТекстСообщения);
			ИначеЕсли МенеджерЗаписи.Статус = Перечисления.СтатусыОбластейДанных.КУдалению Тогда
				ШаблонСообщения = НСтр("ru = 'Область данных %1 в процессе удаления'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, КодОбластиДанных);
				ВызватьИсключение(ТекстСообщения);
			ИначеЕсли МенеджерЗаписи.Статус = Перечисления.СтатусыОбластейДанных.Новая Тогда
				ШаблонСообщения = НСтр("ru = 'Область данных %1 в процессе подготовки к использованию'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, КодОбластиДанных);
				ВызватьИсключение(ТекстСообщения);
			ИначеЕсли МенеджерЗаписи.Статус = Перечисления.СтатусыОбластейДанных.Используется Тогда
				ШаблонСообщения = НСтр("ru = 'Область данных %1 используется.'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, КодОбластиДанных);
				ВызватьИсключение(ТекстСообщения);
			КонецЕсли;
		КонецЕсли;
		
		МенеджерЗаписи.Статус = Перечисления.СтатусыОбластейДанных.Новая;
		МенеджерЗаписи.ИдентификаторВыгрузки = ИдентификаторВыгрузки;
		МенеджерЗаписи.Повтор = 0;
		МенеджерЗаписи.Вариант = ?(ИзВыгрузки, "", Вариант);
		
		КопияМенеджера = РегистрыСведений.ОбластиДанных.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(КопияМенеджера, МенеджерЗаписи);
		МенеджерЗаписи = КопияМенеджера;
		
		МенеджерЗаписи.Записать();
		
		ПараметрыМетода = Новый Массив;
		ПараметрыМетода.Добавить(КодОбластиДанных);
		
		ПараметрыМетода.Добавить(МенеджерЗаписи.ИдентификаторВыгрузки);
		Если Не ИзВыгрузки Тогда
			ПараметрыМетода.Добавить(Вариант);
		КонецЕсли;
		
		ПараметрыЗадания = Новый Структура;
		ПараметрыЗадания.Вставить("ИмяМетода"    , "РаботаВМоделиСервиса.ПодготовитьОбластьДанныхКИспользованию");
		ПараметрыЗадания.Вставить("Параметры"    , ПараметрыМетода);
		ПараметрыЗадания.Вставить("Ключ"         , "1");
		ПараметрыЗадания.Вставить("ОбластьДанных", КодОбластиДанных);
		ПараметрыЗадания.Вставить("ЭксклюзивноеВыполнение", Истина);
		
		ОчередьЗаданий.ДобавитьЗадание(ПараметрыЗадания);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}DeleteApplication.
//
// Параметры:
//  КодОбластиДанных - число(7,0).
//
Процедура УдалитьОбластьДанных(Знач КодОбластиДанных) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		Элемент = Блокировка.Добавить("РегистрСведений.ОбластиДанных");
		Блокировка.Заблокировать();
		
		МенеджерЗаписи = РегистрыСведений.ОбластиДанных.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Прочитать();
		Если НЕ МенеджерЗаписи.Выбран() Тогда
			ШаблонСообщения = НСтр("ru = 'Область данных %1 не существует.'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, КодОбластиДанных);
			ВызватьИсключение(ТекстСообщения);
		КонецЕсли;
		
		МенеджерЗаписи.Статус = Перечисления.СтатусыОбластейДанных.КУдалению;
		МенеджерЗаписи.Повтор = 0;
		
		КопияМенеджера = РегистрыСведений.ОбластиДанных.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(КопияМенеджера, МенеджерЗаписи);
		МенеджерЗаписи = КопияМенеджера;
		
		МенеджерЗаписи.Записать();
		
		ПараметрыМетода = Новый Массив;
		ПараметрыМетода.Добавить(КодОбластиДанных);
		
		ПараметрыЗадания = Новый Структура;
		ПараметрыЗадания.Вставить("ИмяМетода"    , "РаботаВМоделиСервиса.ОчиститьОбластьДанных");
		ПараметрыЗадания.Вставить("Параметры"    , ПараметрыМетода);
		ПараметрыЗадания.Вставить("Ключ"         , "1");
		ПараметрыЗадания.Вставить("ОбластьДанных", КодОбластиДанных);
		
		ОчередьЗаданий.ДобавитьЗадание(ПараметрыЗадания);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetApplicationAccess.
//
// Параметры:
//  Имя - строка, имя пользователя,
//  ХэшПароля - строка, сохраняемое значение пароля,
//  ИдентификаторПользователяСервиса - УникальныйИдентификатор,
//  ДоступРазрешен - булево, флаг предоставления доступа пользователю к области данных,
//  КодЯзыка - строка, код языка пользователя.
//
Процедура УстановитьДоступКОбластиДанных(Знач Имя, Знач ХэшПароля,
		Знач ИдентификаторПользователяСервиса,
		Знач ДоступРазрешен, Знач КодЯзыка = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	
	Попытка
		
		ПользовательОбластиДанных = ПолучитьПользователяОбластиПоИдентификаторуПользователяСервиса(ИдентификаторПользователяСервиса);
		
		ЯзыкПользователяИБ = ЯзыкПоКоду(КодЯзыка);
		
		ОписаниеПользователяИБ = Пользователи.НовоеОписаниеПользователяИБ();
		ОписаниеПользователяИБ.Вставить("Действие", "Записать");
		ОписаниеПользователяИБ.Вставить("ВходВПрограммуРазрешен", ДоступРазрешен);
		ОписаниеПользователяИБ.Имя = Имя;
		ОписаниеПользователяИБ.Язык = ЯзыкПользователяИБ;
		ОписаниеПользователяИБ.СохраняемоеЗначениеПароля = ХэшПароля;
		ОписаниеПользователяИБ.АутентификацияСтандартная = Истина;
		ОписаниеПользователяИБ.АутентификацияOpenID = Истина;
		ОписаниеПользователяИБ.ПоказыватьВСпискеВыбора = Ложь;
		
		ПользовательОбъект = ПользовательОбластиДанных.ПолучитьОбъект();
		ПользовательОбъект.ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);
		ПользовательОбъект.ДополнительныеСвойства.Вставить("ОбработкаСообщенияКаналаУдаленногоАдминистрирования");
		ПользовательОбъект.Записать();
			
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры

// Обработка входящих сообщений с типом
// http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetServiceManagerEndPoint.
//
// Параметры:
//  УзелОбменаСообщениями - ПланОбменаСсылка.ОбменСообщениями.
//
Процедура УстановитьКонечнуюТочкуМенеджераСервиса(УзелОбменаСообщениями) Экспорт
	
	Константы.КонечнаяТочкаМенеджераСервиса.Установить(УзелОбменаСообщениями);
	ОбщегоНазначения.УстановитьПараметрыРазделенияИнформационнойБазы(Истина);
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetIBParams.
//
// Параметры:
//  Параметры - Структура, содержащая значения параметров, которые необходимо установить для информационной базы.
//
Процедура УстановитьПараметрыИБ(Параметры) Экспорт
	
	НачатьТранзакцию();
	Попытка
		ТаблицаПараметров = РаботаВМоделиСервиса.ПолучитьТаблицуПараметровИБ();
		
		ИзменяемыеПараметры = Новый Структура;
		
		// Проверка корректности списка параметров.
		Для каждого КлючИЗначение Из Параметры Цикл
			
			СтрокаПараметра = ТаблицаПараметров.Найти(КлючИЗначение.Ключ, "Имя");
			Если СтрокаПараметра = Неопределено Тогда
				ШаблонСообщения = НСтр("ru = 'Не известное имя параметра %1'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, КлючИЗначение.Ключ);
				ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииУдаленноеАдминистрирование(),
					УровеньЖурналаРегистрации.Предупреждение, , , ТекстСообщения);
				Продолжить;
			ИначеЕсли СтрокаПараметра.ЗапретЗаписи Тогда
				ШаблонСообщения = НСтр("ru = 'Параметр %1 может использоваться только для чтения'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, КлючИЗначение.Ключ);
				ВызватьИсключение(ТекстСообщения);
			КонецЕсли;
			
			ИзменяемыеПараметры.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
			
		КонецЦикла;
		
		ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
			"СтандартныеПодсистемы.РаботаВМоделиСервиса\ПриУстановкеЗначенийПараметровИБ");
		
		Для каждого Обработчик Из ОбработчикиСобытия Цикл
			Обработчик.Модуль.ПриУстановкеЗначенийПараметровИБ(ИзменяемыеПараметры);
		КонецЦикла;
		
		РаботаВМоделиСервисаПереопределяемый.ПриУстановкеЗначенийПараметровИБ(ИзменяемыеПараметры);
		
		Для каждого КлючИЗначение Из ИзменяемыеПараметры Цикл
			
			Константы[КлючИЗначение.Ключ].Установить(КлючИЗначение.Значение);
			
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииУдаленноеАдминистрирование(), 
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetApplicationParams.
//
// Параметры:
//  КодОбластиДанных - число(7,0),
//  ПредставлениеОбластиДанных - строка,
//  ЧасовойПоясОбластиДанных - строка.
//
Процедура УстановитьПараметрыОбластиДанных(Знач КодОбластиДанных,
		Знач ПредставлениеОбластиДанных,
		Знач ЧасовойПоясОбластиДанных = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	
	Попытка
		
		Если Не ПустаяСтрока(ПредставлениеОбластиДанных) Тогда
			
			ОбновитьСвойстваПредопределенныхУзлов(ПредставлениеОбластиДанных);
			
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
	ОбновитьПараметрыТекущейОбластиДанных(ПредставлениеОбластиДанных, ЧасовойПоясОбластиДанных);
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetFullControl.
//
// Параметры:
//  ИдентификаторПользователяСервиса - УникальныйИдентификатор,
//  ДоступРазрешен - булево, флаг предоставления доступа пользователю к области данных.
//
Процедура УстановитьПолныеПраваОбластиДанных(Знач ИдентификаторПользователяСервиса, Знач ДоступРазрешен) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		ПользовательОбластиДанных = ПолучитьПользователяОбластиПоИдентификаторуПользователяСервиса(ИдентификаторПользователяСервиса);
		
		Если ПользователиСлужебный.ЗапретРедактированияРолей()
			И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
			
			МодульУправлениеДоступомСлужебныйВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебныйВМоделиСервиса");
			МодульУправлениеДоступомСлужебныйВМоделиСервиса.УстановитьПринадлежностьПользователяКГруппеАдминистраторы(ПользовательОбластиДанных, ДоступРазрешен);
			
		Иначе
			
			ПользовательИБ = ПолучитьПользователяИБПоПользователюОбластиДанных(ПользовательОбластиДанных);
			
			РольПолныеПрава = Метаданные.Роли.ПолныеПрава;
			Если ДоступРазрешен Тогда
				Если НЕ ПользовательИБ.Роли.Содержит(РольПолныеПрава) Тогда
					ПользовательИБ.Роли.Добавить(РольПолныеПрава);
				КонецЕсли;
			Иначе
				Если ПользовательИБ.Роли.Содержит(РольПолныеПрава) Тогда
					ПользовательИБ.Роли.Удалить(РольПолныеПрава);
				КонецЕсли;
			КонецЕсли;
			
			ПользователиСлужебный.ЗаписатьПользователяИнформационнойБазы(ПользовательИБ, ПользовательОбластиДанных);
			
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetDefaultUserRights.
//
// Параметры:
//  ИдентификаторПользователяСервиса - УникальныйИдентификатор.
//
Процедура УстановитьПраваПользователяПоУмолчанию(Знач ИдентификаторПользователяСервиса) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		ПользовательОбластиДанных = ПолучитьПользователяОбластиПоИдентификаторуПользователяСервиса(ИдентификаторПользователяСервиса);
		
		ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
			"СтандартныеПодсистемы.РаботаВМоделиСервиса\ПриУстановкеПравПоУмолчанию");
		Для Каждого Обработчик Из ОбработчикиСобытия Цикл
			Обработчик.Модуль.ПриУстановкеПравПоУмолчанию(ПользовательОбластиДанных);
		КонецЦикла;
		
		РаботаВМоделиСервисаПереопределяемый.УстановитьПраваПоУмолчанию(ПользовательОбластиДанных);
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetApplicationsRating.
//
// Параметры:
//  ТаблицаРейтинга - ТаблицаЗначений, содержащая рейтинг активности областей данных, колонки:
//    ОбластьДанных - число(7,0),
//    Рейтинг - число(7,0),
//  Замещать - булево, флаг замещения существующих записей в рейтинге активности областей данных.
//
Процедура УстановитьРейтингОбластейДанных(Знач ТаблицаРейтинга, Знач Замещать) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Набор = РегистрыСведений.РейтингАктивностиОбластейДанных.СоздатьНаборЗаписей();
	
	Если Замещать Тогда
		Набор.Загрузить(ТаблицаРейтинга);
		Набор.Записать();
	Иначе
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.РейтингАктивностиОбластейДанных");
		ЭлементБлокировки.ИсточникДанных = ТаблицаРейтинга;
		ЭлементБлокировки.ИспользоватьИзИсточникаДанных("ОбластьДанныхВспомогательныеДанные", "ОбластьДанныхВспомогательныеДанные");
		НачатьТранзакцию();
		
		Попытка
			Блокировка.Заблокировать();
			
			Для каждого СтрокаРейтинга Из ТаблицаРейтинга Цикл
				Набор.Очистить();
				Набор.Отбор.ОбластьДанныхВспомогательныеДанные.Установить(СтрокаРейтинга.ОбластьДанныхВспомогательныеДанные);
				Запись = Набор.Добавить();
				ЗаполнитьЗначенияСвойств(Запись, СтрокаРейтинга);
				Набор.Записать();
			КонецЦикла;
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

// Обработка входящих сообщений с типом http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}BindApplication.
//
// Параметры:
//  Параметры - Структура, содержащая значения параметров, которые необходимо установить для области данных.
//
Процедура ПрикрепитьОбластьДанных(Параметры) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		
		// Установка параметров области данных.
		Блокировка = Новый БлокировкаДанных;
		Элемент = Блокировка.Добавить("РегистрСведений.ОбластиДанных");
		Блокировка.Заблокировать();
		
		МенеджерЗаписи = РегистрыСведений.ОбластиДанных.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Прочитать();
		Если НЕ МенеджерЗаписи.Выбран() Тогда
			ШаблонСообщения = НСтр("ru = 'Область данных %1 не существует.'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, Параметры.Zone);
			ВызватьИсключение(ТекстСообщения);
		КонецЕсли;
		
		МенеджерЗаписи.Статус = Перечисления.СтатусыОбластейДанных.Используется;
		КопияМенеджера = РегистрыСведений.ОбластиДанных.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(КопияМенеджера, МенеджерЗаписи);
		МенеджерЗаписи = КопияМенеджера;
		МенеджерЗаписи.Записать();
		
		// Создание администраторов в области.
		Для каждого ОписаниеПользователя Из Параметры.UsersList.Item Цикл
			ЯзыкПользователя = ЯзыкПоКоду(ОписаниеПользователя.Language);
			
			Почта = "";
			Телефон = "";
			Если ЗначениеЗаполнено(ОписаниеПользователя.EMail) Тогда
				Почта = ОписаниеПользователя.EMail;
			КонецЕсли;
			
			Если ЗначениеЗаполнено(ОписаниеПользователя.Phone) Тогда
				Телефон = ОписаниеПользователя.Phone;
			КонецЕсли;
			
			СтруктураАдресаЭП = СоставПочтовогоАдреса(Почта);
			
			Запрос = Новый Запрос;
			Запрос.Текст =
			"ВЫБРАТЬ
			|    Пользователи.Ссылка КАК Ссылка
			|ИЗ
			|    Справочник.Пользователи КАК Пользователи
			|ГДЕ
			|    Пользователи.ИдентификаторПользователяСервиса = &ИдентификаторПользователяСервиса";
			Запрос.УстановитьПараметр("ИдентификаторПользователяСервиса", ОписаниеПользователя.UserServiceID);
			
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
			Блокировка.Заблокировать();
			
			Результат = Запрос.Выполнить();
			Если Результат.Пустой() Тогда
				ПользовательОбластиДанных = Неопределено;
			Иначе
				Выборка = Результат.Выбрать();
				Выборка.Следующий();
				ПользовательОбластиДанных = Выборка.Ссылка;
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(ПользовательОбластиДанных) Тогда
				ПользовательОбъект = Справочники.Пользователи.СоздатьЭлемент();
				ПользовательОбъект.ИдентификаторПользователяСервиса = ОписаниеПользователя.UserServiceID;
			Иначе
				ПользовательОбъект = ПользовательОбластиДанных.ПолучитьОбъект();
			КонецЕсли;
			
			ПользовательОбъект.Наименование = ОписаниеПользователя.FullName;
			
			ОбновитьАдресЭлектроннойПочты(ПользовательОбъект, Почта, СтруктураАдресаЭП);
			
			ОбновитьТелефон(ПользовательОбъект, Телефон);
			
			ОписаниеПользователяИБ = Пользователи.НовоеОписаниеПользователяИБ();
			
			ОписаниеПользователяИБ.Имя = ОписаниеПользователя.Name;
			
			ОписаниеПользователяИБ.АутентификацияСтандартная = Истина;
			ОписаниеПользователяИБ.АутентификацияOpenID = Истина;
			ОписаниеПользователяИБ.ПоказыватьВСпискеВыбора = Ложь;
			
			ОписаниеПользователяИБ.СохраняемоеЗначениеПароля = ОписаниеПользователя.StoredPasswordValue;
			
			ОписаниеПользователяИБ.Язык = ЯзыкПользователя;
			
			Роли = Новый Массив;
			Роли.Добавить("ПолныеПрава");
			ОписаниеПользователяИБ.Роли = Роли;
			
			ОписаниеПользователяИБ.Вставить("Действие", "Записать");
			ПользовательОбъект.ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);
			ПользовательОбъект.ДополнительныеСвойства.Вставить("СозданиеАдминистратора",
				НСтр("ru = 'Создание администратора области данных из менеджера сервиса.'"));
			
			ПользовательОбъект.ДополнительныеСвойства.Вставить("ОбработкаСообщенияКаналаУдаленногоАдминистрирования");
			ПользовательОбъект.Записать();
			
			ПользовательОбластиДанных = ПользовательОбъект.Ссылка;
			
			Если ПользователиСлужебный.ЗапретРедактированияРолей()
				И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
			
				МодульУправлениеДоступомСлужебныйВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебныйВМоделиСервиса");
				МодульУправлениеДоступомСлужебныйВМоделиСервиса.УстановитьПринадлежностьПользователяКГруппеАдминистраторы(ПользовательОбластиДанных, Истина);
			КонецЕсли;
		КонецЦикла;
		
		Если Не ПустаяСтрока(Параметры.Presentation) Тогда
			ОбновитьСвойстваПредопределенныхУзлов(Параметры.Presentation);
		КонецЕсли;
		
		Сообщение = СообщенияВМоделиСервиса.НовоеСообщение(СообщенияКонтрольУдаленногоАдминистрированияИнтерфейс.СообщениеОбластьДанныхГотоваКИспользованию());
			Сообщение.Body.Zone = Параметры.Zone;
		
		СообщенияВМоделиСервиса.ОтправитьСообщение(Сообщение, РаботаВМоделиСервисаПовтИсп.КонечнаяТочкаМенеджераСервиса(), Истина);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
	ОбновитьПараметрыТекущейОбластиДанных(Параметры.Presentation, Параметры.TimeZone);
	
	СообщенияВМоделиСервиса.ДоставитьБыстрыеСообщения();
	
КонецПроцедуры

// Генерирует код узла плана обмена для заданной области данных.
//
// Параметры:
// НомерОбласти - Число - Значение разделителя. 
//
// Возвращаемое значение:
// Строка - Код узла плана обмена для заданной области. 
//
Функция КодУзлаПланаОбменаВСервисе(Знач НомерОбласти) Экспорт
	
	Если ТипЗнч(НомерОбласти) <> Тип("Число") Тогда
		ВызватьИсключение НСтр("ru = 'Неправильный тип параметра номер [1].'");
	КонецЕсли;
	
	Результат = "S0[НомерОбласти]";
	
	Возврат СтрЗаменить(Результат, "[НомерОбласти]", Формат(НомерОбласти, "ЧЦ=7; ЧВН=; ЧГ=0"));
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЯзыкПоКоду(Знач КодЯзыка)
	
	Если ЗначениеЗаполнено(КодЯзыка) Тогда
		
		Для каждого Язык Из Метаданные.Языки Цикл
			Если Язык.КодЯзыка = КодЯзыка Тогда
				Возврат Язык.Имя;
			КонецЕсли;
		КонецЦикла;
		
		ШаблонСообщения = НСтр("ru = 'Неподдерживаемый код языка: %1'");
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, Язык);
		ВызватьИсключение(ТекстСообщения);
		
	Иначе
		
		Возврат Неопределено;
		
	КонецЕсли;
	
КонецФункции

Функция СоставПочтовогоАдреса(Знач АдресЭП)
	
	Если ЗначениеЗаполнено(АдресЭП) Тогда
		
		Попытка
			СтруктураАдресаЭП = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(АдресЭП);
		Исключение
			ШаблонСообщения = НСтр("ru = 'Указан некорректный адрес электронной почты: %1
				|Ошибка: %2'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, АдресЭП, ИнформацияОбОшибке().Описание);
			ВызватьИсключение(ТекстСообщения);
		КонецПопытки;
		
		Возврат СтруктураАдресаЭП;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

Процедура ОбновитьАдресЭлектроннойПочты(Знач ПользовательОбъект, Знач Адрес, Знач СтруктураАдресаЭП)
	
	ВидКИ = Справочники.ВидыКонтактнойИнформации.EmailПользователя;
	
	СтрокаТабличнойЧасти = ПользовательОбъект.КонтактнаяИнформация.Найти(ВидКИ, "Вид");
	Если СтруктураАдресаЭП = Неопределено Тогда
		Если СтрокаТабличнойЧасти <> Неопределено Тогда
			ПользовательОбъект.КонтактнаяИнформация.Удалить(СтрокаТабличнойЧасти);
		КонецЕсли;
	Иначе
		Если СтрокаТабличнойЧасти = Неопределено Тогда
			СтрокаТабличнойЧасти = ПользовательОбъект.КонтактнаяИнформация.Добавить();
			СтрокаТабличнойЧасти.Вид = ВидКИ;
		КонецЕсли;
		СтрокаТабличнойЧасти.Тип = Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты;
		СтрокаТабличнойЧасти.Представление = Адрес;
		
		Если СтруктураАдресаЭП.Количество() > 0 Тогда
			СтрокаТабличнойЧасти.АдресЭП = СтруктураАдресаЭП[0].Адрес;
			
			Поз = СтрНайти(СтрокаТабличнойЧасти.АдресЭП, "@");
			Если Поз <> 0 Тогда
				СтрокаТабличнойЧасти.ДоменноеИмяСервера = Сред(СтрокаТабличнойЧасти.АдресЭП, Поз + 1);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьТелефон(Знач ПользовательОбъект, Знач Телефон)
	
	ВидКИ = Справочники.ВидыКонтактнойИнформации.ТелефонПользователя;
	
	СтрокаТабличнойЧасти = ПользовательОбъект.КонтактнаяИнформация.Найти(ВидКИ, "Вид");
	Если СтрокаТабличнойЧасти = Неопределено Тогда
		СтрокаТабличнойЧасти = ПользовательОбъект.КонтактнаяИнформация.Добавить();
		СтрокаТабличнойЧасти.Вид = ВидКИ;
	КонецЕсли;
	СтрокаТабличнойЧасти.Тип = Перечисления.ТипыКонтактнойИнформации.Телефон;
	СтрокаТабличнойЧасти.Представление = Телефон;
	
КонецПроцедуры

Функция ПолучитьПользователяОбластиПоИдентификаторуПользователяСервиса(Знач ИдентификаторПользователяСервиса)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.ИдентификаторПользователяСервиса = &ИдентификаторПользователяСервиса";
	Запрос.УстановитьПараметр("ИдентификаторПользователяСервиса", ИдентификаторПользователяСервиса);
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		Результат = Запрос.Выполнить();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если Результат.Пустой() Тогда
		ШаблонСообщения = НСтр("ru = 'Не найден пользователь с идентификатором пользователя сервиса %1'");
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, ИдентификаторПользователяСервиса);
		ВызватьИсключение(ТекстСообщения);
	КонецЕсли;
	
	Возврат Результат.Выгрузить()[0].Ссылка;
	
КонецФункции

Функция ПолучитьПользователяИБПоПользователюОбластиДанных(Знач ПользовательОбластиДанных)
	
	ИдентификаторПользователяИБ = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ПользовательОбластиДанных, "ИдентификаторПользователяИБ");
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(ИдентификаторПользователяИБ);
	Если ПользовательИБ = Неопределено Тогда
		ШаблонСообщения = НСтр("ru = 'Для пользователя области данных с идентификатором %1 не существует пользователя информационной базы'");
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, ПользовательОбластиДанных.УникальныйИдентификатор());
		ВызватьИсключение(ТекстСообщения);
	КонецЕсли;
	
	Возврат ПользовательИБ;
	
КонецФункции

Процедура ОбновитьПараметрыТекущейОбластиДанных(Знач Представление, Знач ЧасовойПояс)
	
	Константы.ПредставлениеОбластиДанных.Установить(Представление);
	Константы.ЧасовойПоясОбластиДанных.Установить(ЧасовойПояс);
	
	Если ПолучитьЧасовойПоясИнформационнойБазы() <> ЧасовойПояс Тогда
		
		ВнешнийМонопольныйРежим = МонопольныйРежим();
		
		Если ВнешнийМонопольныйРежим Тогда
			
			ОбластьЗаблокирована = Истина;
			
		Иначе
			
			Попытка
				
				РаботаВМоделиСервиса.ЗаблокироватьТекущуюОбластьДанных();
				ОбластьЗаблокирована = Истина;
				
			Исключение
				
				ОбластьЗаблокирована = Ложь;
				
				ШаблонСообщения = НСтр("ru = 'Не удалось заблокировать область данных для установки часового пояса ""%1""'");
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, ЧасовойПояс);
				ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииУдаленноеАдминистрирование(),
					УровеньЖурналаРегистрации.Ошибка, , , ТекстСообщения);
				
			КонецПопытки;
			
		КонецЕсли;
		
		Если ОбластьЗаблокирована Тогда
			
			Если ЗначениеЗаполнено(ЧасовойПояс) Тогда
				
				УстановитьЧасовойПоясИнформационнойБазы(ЧасовойПояс);
				
			Иначе
				
				УстановитьЧасовойПоясИнформационнойБазы();
				
			КонецЕсли;
			
			Если НЕ ВнешнийМонопольныйРежим Тогда
				
				РаботаВМоделиСервиса.РазблокироватьТекущуюОбластьДанных();
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьСвойстваПредопределенныхУзлов(Знач Наименование)
	
	Для Каждого ПланОбмена Из Метаданные.ПланыОбмена Цикл
		
		Если ОбменДаннымиПовтИсп.ПланОбменаИспользуетсяВМоделиСервиса(ПланОбмена.Имя) Тогда
			
			ЭтотУзел = ПланыОбмена[ПланОбмена.Имя].ЭтотУзел();
			
			СвойстваУзла = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ЭтотУзел, "Код, Наименование");
			
			Если ПустаяСтрока(СвойстваУзла.Код) Тогда
				
				ЭтотУзелОбъект = ЭтотУзел.ПолучитьОбъект();
				ЭтотУзелОбъект.Код = КодУзлаПланаОбменаВСервисе(РаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
				ЭтотУзелОбъект.Наименование = Наименование;
				ЭтотУзелОбъект.Записать();
				
			ИначеЕсли СвойстваУзла.Наименование <> Наименование Тогда
				
				ЭтотУзелОбъект = ЭтотУзел.ПолучитьОбъект();
				ЭтотУзелОбъект.Наименование = Наименование;
				ЭтотУзелОбъект.Записать();
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция СобытиеЖурналаРегистрацииУдаленноеАдминистрирование()
	
	Возврат НСтр("ru = 'Удаленное администрирование в модели сервиса.Установить параметры'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
	
КонецФункции

#КонецОбласти
