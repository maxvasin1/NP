
#Область ОписаниеПеременных

&НаКлиенте
Перем КонтекстВыбора;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	// Запретим создание новых
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Взаимодействия.УстановитьЗаголовокФормыЭлектронногоПисьма(ЭтотОбъект);
	
	// Заполним список выбора для поля РассмотретьПосле.
	Взаимодействия.ЗаполнитьСписокВыбораДляРассмотретьПосле(Элементы.РассмотретьПосле.СписокВыбора);
	Если Рассмотрено Тогда
		Элементы.РассмотретьПосле.Доступность = Ложь;
	КонецЕсли;
	
	// СтандартныеПодсистемы.Свойства
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ИмяЭлементаДляРазмещения", "СтраницаДополнительныеРеквизиты");
	ДополнительныеПараметры.Вставить("ОтложеннаяИнициализация", Истина);
	УправлениеСвойствами.ПриСозданииНаСервере(ЭтотОбъект, ДополнительныеПараметры);
	// Конец СтандартныеПодсистемы.Свойства
	
	Если Объект.Ссылка.Пустая() Тогда
		Элементы.СтраницаКомментарий.Картинка = ОбщегоНазначенияКлиентСервер.КартинкаКомментария(Объект.Комментарий);
	КонецЕсли;
	
	ЗапрещенныеРасширения = ФайловыеФункцииСлужебный.СписокЗапрещенныхРасширений();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствамиКлиент.ПослеЗагрузкиДополнительныхРеквизитов(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Взаимодействия.УстановитьРеквизитыФормыВзаимодействияПоДаннымРегистра(ЭтотОбъект);
	
	Вложения.Очистить();
	ТаблицаВложения = УправлениеЭлектроннойПочтой.ПолучитьВложенияЭлектронногоПисьма(Объект.Ссылка, Истина);
	
	Если ТаблицаВложения.Количество() > 0 Тогда
		
		НайденныеСтроки = ТаблицаВложения.НайтиСтроки(Новый Структура("ИДФайлаЭлектронногоПисьма", ""));
		ОбщегоНазначенияКлиентСервер.ДополнитьТаблицу(НайденныеСтроки, Вложения);
		
	КонецЕсли;
	
	Для Каждого УдаленноеВложение Из ТекущийОбъект.НепринятыеВложения Цикл
		
		НовоеВложение = Вложения.Добавить();
		НовоеВложение.ИмяФайла = УдаленноеВложение.ИмяВложение;
		НовоеВложение.ИндексКартинки = ФайловыеФункцииСлужебныйКлиентСервер.ПолучитьИндексПиктограммыФайла(".msg") + 1;
		
	КонецЦикла;
	
	Если Вложения.Количество() = 0 Тогда
		
		Элементы.Вложения.Видимость = Ложь;
		
	КонецЕсли;
	
	// Установим текст и вид текста.
	Если Объект.ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.HTML Тогда
		ТекстПисьма = Взаимодействия.ОбработатьТекстHTML(Объект.Ссылка);
		Элементы.ТекстПисьма.Вид = ВидПоляФормы.ПолеHTMLДокумента;
		Элементы.ТекстПисьма.ТолькоПросмотр = Ложь;
	Иначе
		ТекстПисьма = Объект.Текст;
		Элементы.ТекстПисьма.Вид = ВидПоляФормы.ПолеТекстовогоДокумента;
	КонецЕсли;
	
	// Сформируем представление отправителя.
	ОтправительПредставление = ВзаимодействияКлиентСервер.ПолучитьПредставлениеАдресата(
		Объект.ОтправительПредставление, Объект.ОтправительАдрес,"");
	
	// Сформируем представление Кому и Копии.
	ПолучателиПредставление =
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(Объект.ПолучателиПисьма, Ложь);
	ПолучателиКопийПредставление =
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(Объект.ПолучателиКопий, Ложь);
	ПолучателиОтветаПредставление = 
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(Объект.ПолучателиОтвета, Ложь);

	ЗаполнитьДополнительнуюИнформацию();
	
	ОбработатьНеобходимостьУведомленияОПрочтении();
	
	ВзаимодействияКлиентСервер.ПроверитьЗаполнениеКонтактов(Объект, ЭтотОбъект, "ЭлектронноеПисьмоВходящее");
	Элементы.СтраницаКомментарий.Картинка = ОбщегоНазначенияКлиентСервер.КартинкаКомментария(Объект.Комментарий);
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	// СтандартныеПодсистемы.Свойства
	Если УправлениеСвойствамиКлиент.ОбрабатыватьОповещения(ЭтотОбъект, ИмяСобытия, Параметр) Тогда
		ОбновитьЭлементыДополнительныхРеквизитов();
		УправлениеСвойствамиКлиент.ПослеЗагрузкиДополнительныхРеквизитов(ЭтотОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.Свойства
	
	ВзаимодействияКлиент.ОтработатьОповещение(ЭтотОбъект, ИмяСобытия, Параметр, Источник);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ВРег(ИсточникВыбора.ИмяФормы) = ВРег("ОбщаяФорма.УточнениеКонтактов") Тогда
		
		Если ТипЗнч(ВыбранноеЗначение) <> Тип("Массив") Тогда
			Возврат;
		КонецЕсли;
		
		ЗаполнитьУточненныеКонтакты(ВыбранноеЗначение);
		ИзменилисьКонтакты = Истина;
		Модифицированность = Истина;
		
	Иначе
		
		ВзаимодействияКлиент.ФормаОбработкаВыбора(ЭтотОбъект, ВыбранноеЗначение, ИсточникВыбора, КонтекстВыбора);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, РежимЗаписи, РежимПроведения)
	
	Взаимодействия.ПередЗаписьюВзаимодействияИзФормы(ЭтотОбъект, ТекущийОбъект, ИзменилисьКонтакты);
	
	Если Рассмотрено И ТребуетсяУстановкаФлагаОтправкиУведомления Тогда
		УстановитьПризнакОтправкиУведомления(Объект.Ссылка, Истина);
	КонецЕсли;
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ПередЗаписьюНаСервере(ЭтотОбъект, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Взаимодействия.ПриЗаписиВзаимодействияИзФормы(ТекущийОбъект, ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	Элементы.СтраницаКомментарий.Картинка = ОбщегоНазначенияКлиентСервер.КартинкаКомментария(Объект.Комментарий);
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ОбработкаПроверкиЗаполнения(ЭтотОбъект, Отказ, ПроверяемыеРеквизиты);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СтраницыОписаниеДополнительноПриСменеСтраницы(Элемент, ТекущаяСтраница)
	
	// СтандартныеПодсистемы.Свойства
	Если ТекущаяСтраница.Имя = "СтраницаДополнительныеРеквизиты"
		И Не ЭтотОбъект.ПараметрыСвойств.ВыполненаОтложеннаяИнициализация Тогда
		
		СвойстваВыполнитьОтложеннуюИнициализацию();
		УправлениеСвойствамиКлиент.ПослеЗагрузкиДополнительныхРеквизитов(ЭтотОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаКлиенте
Процедура РассмотретьПослеОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	ВзаимодействияКлиент.ОбработатьВыборВПолеРассмотретьПосле(РассмотретьПосле,
	                                                          ВыбранноеЗначение,
	                                                          СтандартнаяОбработка,
	                                                          Модифицированность);
	
КонецПроцедуры

&НаКлиенте
Процедура РассмотреноПриИзменении(Элемент)
	
	Элементы.РассмотретьПосле.Доступность = НЕ Рассмотрено;
	Если Рассмотрено И ТребуетсяЗапросУведомленияОПрочтении Тогда
		
		ОбработчикОповещенияОЗакрытии = Новый ОписаниеОповещения("ВопросОНеобходимостиОтправкиУведомленияОПрочтенииПослеЗавершения", ЭтотОбъект);
		ПоказатьВопрос(ОбработчикОповещенияОЗакрытии,
		       НСтр("ru='Отправитель запросил уведомление о прочтении. Отправить?'"),
		       РежимДиалогаВопрос.ДаНет,
		       ,
		       КодВозвратаДиалога.Да,
		       НСтр("ru='Запрос уведомления'"));
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьПолучателей()
	
	// Получим список адресатов
	МассивОтправителей = Новый Массив;
	МассивОтправителей.Добавить(Новый Структура("Адрес,Представление,Контакт",
		Объект.ОтправительАдрес,
		Объект.ОтправительПредставление, 
		Объект.ОтправительКонтакт));
	
	СписокПолучателей = Новый СписокЗначений;
	СписокПолучателей.Добавить(МассивОтправителей, "Отправитель");
	СписокПолучателей.Добавить(
		УправлениеЭлектроннойПочтойКлиент.ТаблицуКонтактовВМассив(Объект.ПолучателиПисьма), "Получатели");
	СписокПолучателей.Добавить(
		УправлениеЭлектроннойПочтойКлиент.ТаблицуКонтактовВМассив(Объект.ПолучателиКопий),  "Копии");
	СписокПолучателей.Добавить(
		УправлениеЭлектроннойПочтойКлиент.ТаблицуКонтактовВМассив(Объект.ПолучателиОтвета), "Ответ");
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("УчетнаяЗапись", Объект.УчетнаяЗапись);
	ПараметрыФормы.Вставить("СписокВыбранных", СписокПолучателей);
	ПараметрыФормы.Вставить("Предмет", Предмет);
	ПараметрыФормы.Вставить("Письмо", Объект.Ссылка);
	
	// Откроем форму для редактирования списка адресатов.
	ОткрытьФорму("ОбщаяФорма.УточнениеКонтактов", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьУточненныеКонтакты(Результат)
	
	Объект.ПолучателиКопий.Очистить();
	Объект.ПолучателиОтвета.Очистить();
	Объект.ПолучателиПисьма.Очистить();
	
	Для каждого ЭлементМассива Из Результат Цикл
	
		Если ЭлементМассива.Группа = "Получатели" Тогда
			ТаблицаПолучателей = Объект.ПолучателиПисьма;
		ИначеЕсли ЭлементМассива.Группа = "Копии" Тогда
			ТаблицаПолучателей = Объект.ПолучателиКопий;
		ИначеЕсли ЭлементМассива.Группа = "Ответ" Тогда
			ТаблицаПолучателей = Объект.ПолучателиОтвета;
		ИначеЕсли ЭлементМассива.Группа = "Отправитель" Тогда
			Объект.ОтправительАдрес = ЭлементМассива.Адрес;
			Объект.ОтправительКонтакт = ЭлементМассива.Контакт;
			Продолжить;
		Иначе
			Продолжить;
		КонецЕсли;
		
		СтрокаПолучатели = ТаблицаПолучателей.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаПолучатели,ЭлементМассива);
	
	КонецЦикла;
	
	// Сформируем представление отправителя.
	ОтправительПредставление = ВзаимодействияКлиентСервер.ПолучитьПредставлениеАдресата(
		Объект.ОтправительПредставление, Объект.ОтправительАдрес, "");
	
	// Сформируем представление Кому и Копии.
	ПолучателиПредставление       =
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(Объект.ПолучателиПисьма, Ложь);
	ПолучателиКопийПредставление  =
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(Объект.ПолучателиКопий, Ложь);
	ПолучателиОтветаПредставление = 
		ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(Объект.ПолучателиОтвета, Ложь);
	
	ВзаимодействияКлиентСервер.ПроверитьЗаполнениеКонтактов(Объект, ЭтотОбъект, "ЭлектронноеПисьмоВходящее");

КонецПроцедуры

&НаКлиенте
Процедура ОтправительПредставлениеОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если ЗначениеЗаполнено(Объект.ОтправительКонтакт) Тогда
		ПоказатьЗначение(, Объект.ОтправительКонтакт);
	Иначе
		РедактироватьПолучателей();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТекстПисьмаПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	
	ВзаимодействияКлиент.ПолеHTMLПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредметНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВзаимодействияКлиент.ПредметНачалоВыбора(ЭтотОбъект, Элемент, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыВложения

&НаКлиенте
Процедура ВложенияВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ОткрытьВложение();
	
КонецПроцедуры

&НаКлиенте
Процедура ВложенияПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.Вложения.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВложениеСуществует = ЗначениеЗаполнено(ТекущиеДанные.Ссылка);
	Элементы.ВложенияКонтекстноеМенюСвойстваВложения.Доступность = ВложениеСуществует;
	Элементы.ОткрытьВложение.Доступность = ВложениеСуществует;
	Элементы.СохранитьВложение.Доступность = ВложениеСуществует;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОткрытьВложениеВыполнить()
	
	ОткрытьВложение();
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВложениеВыполнить()
	
	ТекущиеДанные = Элементы.Вложения.ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено Тогда
		
		Если НЕ ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
			Возврат;
		КонецЕсли;
		
		ДанныеФайла = ПрисоединенныеФайлыКлиент.ПолучитьДанныеФайла(
			ТекущиеДанные.Ссылка, УникальныйИдентификатор);
		
		ПрисоединенныеФайлыКлиент.СохранитьФайлКак(ДанныеФайла);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УточнитьКонтакты(Команда)
	
	РедактироватьПолучателей();
	
КонецПроцедуры

&НаКлиенте
Процедура ПараметрыПисьма(Команда)
	
	ТекстЗаголовкиИнтернета = Новый ТекстовыйДокумент;
	ТекстЗаголовкиИнтернета.ДобавитьСтроку(Объект.ВнутреннийЗаголовок);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Создано", Объект.Дата);
	ПараметрыФормы.Вставить("Получено", Объект.ДатаПолучения);
	ПараметрыФормы.Вставить("УведомитьОДоставке", Объект.УведомитьОДоставке);
	ПараметрыФормы.Вставить("УведомитьОПрочтении", Объект.УведомитьОПрочтении);
	ПараметрыФормы.Вставить("ЗаголовкиИнтернета", ТекстЗаголовкиИнтернета);
	ПараметрыФормы.Вставить("Письмо", Объект.Ссылка);
	ПараметрыФормы.Вставить("ТипПисьма", "ЭлектронноеПисьмоВходящее");
	ПараметрыФормы.Вставить("Кодировка", Объект.Кодировка);
	ПараметрыФормы.Вставить("ВнутреннийНомер", Объект.Номер);
	ПараметрыФормы.Вставить("УчетнаяЗапись", Объект.УчетнаяЗапись);
	
	ОткрытьФорму("ЖурналДокументов.Взаимодействия.Форма.ПараметрыЭлектронногоПисьма", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СвязанныеВзаимодействияВыполнить()
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ОбъектОтбора", Объект.Предмет);
	
	ОткрытьФорму("ЖурналДокументов.Взаимодействия.ФормаСписка", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьКодировку(Команда)
	
	СписокКодировок = ВзаимодействияКлиентСервер.СписокКодировок();

	ОбработчикОповещенияОЗакрытии = Новый ОписаниеОповещения("ВыборКодировкиПослеЗавершения", ЭтотОбъект);
	
	СписокКодировок.ПоказатьВыборЭлемента(ОбработчикОповещенияОЗакрытии,
	                                      НСтр("ru = 'Выберите кодировку'"), 
	                                      СписокКодировок.НайтиПоЗначению(НРег(Объект.Кодировка)));
	
КонецПроцедуры 

&НаКлиенте
Процедура СвойстваВложения(Команда)
	
	ТекущиеДанные = Элементы.Вложения.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
			Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура("ПрисоединенныйФайл, ТолькоПросмотр", ТекущиеДанные.Ссылка,Истина);
	ОткрытьФорму("ОбщаяФорма.ПрисоединенныйФайл", ПараметрыФормы,, ТекущиеДанные.Ссылка);
	
КонецПроцедуры

// СтандартныеПодсистемы.Свойства

&НаКлиенте
Процедура Подключаемый_РедактироватьСоставСвойств()
	
	УправлениеСвойствамиКлиент.РедактироватьСоставСвойств(ЭтотОбъект, Объект.Ссылка);
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.Свойства

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОткрытьВложение()
	
	ТекущиеДанные = Элементы.Вложения.ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено Тогда
		
		Если НЕ ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
			Возврат;
		КонецЕсли;
		УправлениеЭлектроннойПочтойКлиент.ОткрытьВложение(ТекущиеДанные.Ссылка, ЭтотОбъект);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПреобразоватьКодировкуПисьма(ВыбраннаяКодировка)
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
	ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайла, Объект.Кодировка);
	ЗаписьТекста.Записать(
		?(Объект.ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.HTML, Объект.ТекстHTML, Объект.Текст));
	ЗаписьТекста.Закрыть();
	
	ЧтениеТекста = Новый ЧтениеТекста(ИмяВременногоФайла, ВыбраннаяКодировка);
	Если Объект.ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.HTML Тогда
		Объект.ТекстHTML = ЧтениеТекста.Прочитать();
		ТекстПисьма = Объект.ТекстHTML;
	Иначе
		Объект.Текст = ЧтениеТекста.Прочитать();
		ТекстПисьма = Объект.Текст;
	КонецЕсли;
	ЧтениеТекста.Закрыть();
	УдалитьФайлы(ИмяВременногоФайла);
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
	ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайла, Объект.Кодировка);
	ЗаписьТекста.ЗаписатьСтроку(ОтправительПредставление);
	ЗаписьТекста.ЗаписатьСтроку(ПолучателиКопийПредставление);
	ЗаписьТекста.ЗаписатьСтроку(ПолучателиОтветаПредставление);
	ЗаписьТекста.ЗаписатьСтроку(ПолучателиПредставление);
	ЗаписьТекста.ЗаписатьСтроку(Объект.Тема);
	ЗаписьТекста.Закрыть();
	
	ЧтениеТекста = Новый ЧтениеТекста(ИмяВременногоФайла, ВыбраннаяКодировка);
	ОтправительПредставление = ЧтениеТекста.ПрочитатьСтроку();
	ПолучателиКопийПредставление = ЧтениеТекста.ПрочитатьСтроку();
	ПолучателиОтветаПредставление = ЧтениеТекста.ПрочитатьСтроку();
	ПолучателиПредставление = ЧтениеТекста.ПрочитатьСтроку();
	Объект.Тема = ЧтениеТекста.ПрочитатьСтроку();
	ЧтениеТекста.Закрыть();
	УдалитьФайлы(ИмяВременногоФайла);
	
	Объект.Кодировка = ВыбраннаяКодировка;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДополнительнуюИнформацию()
	
	ДополнительнаяИнформацияОПисьме = НСтр("ru = 'Создано:'") + "   " + Объект.Дата 
	+ Символы.ПС + НСтр("ru = 'Получено'") + ":  " + Объект.ДатаПолучения 
	+ Символы.ПС + НСтр("ru = 'Важность'") + ":  " + Объект.Важность
	+ Символы.ПС + НСтр("ru = 'Кодировка'") + ": " + Объект.Кодировка;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьНеобходимостьУведомленияОПрочтении()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УведомленияОПрочтении.Письмо
	|ИЗ
	|	РегистрСведений.УведомленияОПрочтении КАК УведомленияОПрочтении
	|ГДЕ
	|	УведомленияОПрочтении.Письмо = &Письмо
	|	И (НЕ УведомленияОПрочтении.ТребуетсяОтправка)";
	
	Запрос.УстановитьПараметр("Письмо",Объект.Ссылка);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	НеобходимоеДействие = Взаимодействия.ПолучитьПараметрыРаботыПользователяДляВходящегоЭлектронногоПисьма();
	
	Если НеобходимоеДействие = Перечисления.ПорядокОтветовНаЗапросыУведомленийОПрочтении.ВсегдаОтправлятьУведомление Тогда
		
		ТребуетсяУстановкаФлагаОтправкиУведомления = Истина;
		
	ИначеЕсли НеобходимоеДействие = 
		Перечисления.ПорядокОтветовНаЗапросыУведомленийОПрочтении.НикогдаНеОтправлятьУведомление Тогда
		
		УправлениеЭлектроннойПочтой.УстановитьПризнакОтправкиУведомления(Объект.Ссылка,Ложь);
		
	ИначеЕсли НеобходимоеДействие = 
		Перечисления.ПорядокОтветовНаЗапросыУведомленийОПрочтении.ЗапрашиватьПередТемКакОтправитьУведомление Тогда
		
		ТребуетсяЗапросУведомленияОПрочтении = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УстановитьПризнакОтправкиУведомления(Ссылка, Флаг)

	УправлениеЭлектроннойПочтой.УстановитьПризнакОтправкиУведомления(Ссылка, Флаг)

КонецПроцедуры

&НаКлиенте
Процедура ВопросОНеобходимостиОтправкиУведомленияОПрочтенииПослеЗавершения(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		УстановитьПризнакОтправкиУведомления(Объект.Ссылка, Истина);
	ИначеЕсли РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		УстановитьПризнакОтправкиУведомления(Объект.Ссылка, Ложь);
	КонецЕсли;
	ТребуетсяЗапросУведомленияОПрочтении = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборКодировкиПослеЗавершения(ВыбранныйЭлемент, ДополнительныеПараметры) Экспорт

	Если ВыбранныйЭлемент <> Неопределено Тогда
		ПреобразоватьКодировкуПисьма(ВыбранныйЭлемент.Значение);
	КонецЕсли;

КонецПроцедуры

// СтандартныеПодсистемы.Свойства

&НаСервере
Процедура СвойстваВыполнитьОтложеннуюИнициализацию()
	УправлениеСвойствами.ЗаполнитьДополнительныеРеквизитыВФорме(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗависимостиДополнительныхРеквизитов()
	УправлениеСвойствамиКлиент.ОбновитьЗависимостиДополнительныхРеквизитов(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПриИзмененииДополнительногоРеквизита(Элемент)
	УправлениеСвойствамиКлиент.ОбновитьЗависимостиДополнительныхРеквизитов(ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура ОбновитьЭлементыДополнительныхРеквизитов()
	
	УправлениеСвойствами.ОбновитьЭлементыДополнительныхРеквизитов(ЭтотОбъект);
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.Свойства

#КонецОбласти
