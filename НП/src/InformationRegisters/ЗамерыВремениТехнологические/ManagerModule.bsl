#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьТопAPDEX(ДатаНачала, ДатаОкончания, ПериодАгрегации, Количество) Экспорт
	
	МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	
	НастроечнаяТаблицаИнтервалов = НастроечнаяТаблицаИнтервалов();
	
	ТаблицаИнтервалов = ТаблицаИнтерваловПоНастройкам(НастроечнаяТаблицаИнтервалов);
	ТекстЗапросаПоИнтервалам = ЧастьТекстаЗапросаПоИнтервалам(ТаблицаИнтервалов, "Замеры", "ВремяВыполнения");
	
	Если Количество > 0 Тогда
		Запрос.Текст = "
		|ВЫБРАТЬ
		|	КлючевыеОперации.Ссылка КАК КлючеваяОперацияСсылка,
		|	КлючевыеОперации.ЦелевоеВремя КАК ЦелевоеВремя,
		|	КОЛИЧЕСТВО(*) КАК КоличествоЗамеров,
		|	СУММА(ВЫБОР
		|			КОГДА Замеры.ВремяВыполнения <= КлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|			ИНАЧЕ 0
		|	КОНЕЦ) КАК N_T,
		|	СУММА(ВЫБОР
		|			КОГДА Замеры.ВремяВыполнения > КлючевыеОперации.ЦелевоеВремя И Замеры.ВремяВыполнения <= 4 * КлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|			ИНАЧЕ 0
		|	КОНЕЦ) КАК N_T_4T,
		|	СУММА(ВЫБОР
		|			КОГДА Замеры.ВремяВыполнения > 4 * КлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|			ИНАЧЕ 0
		|	КОНЕЦ) КАК N_4T
		|ПОМЕСТИТЬ
		|	Выборка
		|ИЗ
		|	РегистрСведений.ЗамерыВремениТехнологические КАК Замеры
		|ВНУТРЕННЕЕ СОЕДИНЕНИЕ
		|	Справочник.КлючевыеОперации КАК КлючевыеОперации
		|ПО
		|	Замеры.КлючеваяОперация = КлючевыеОперации.Ссылка
		|ГДЕ
		|	Замеры.ДатаНачалаЗамера МЕЖДУ &ДатаНачала И &ДатаОкончания
		|СГРУППИРОВАТЬ ПО
		|	КлючевыеОперации.Ссылка,
		|	КлючевыеОперации.ЦелевоеВремя
		|;
		|ВЫБРАТЬ
		|	СУММА(КоличествоЗамеров) КАК КоличествоЗамеров
		|ПОМЕСТИТЬ
		|	ВсегоЗамеров
		|ИЗ
		|	Выборка
		|;
		|ВЫБРАТЬ ПЕРВЫЕ %Количество
		|	Выборка.КлючеваяОперацияСсылка,
		|	Выборка.ЦелевоеВремя,
		|	Выборка.КоличествоЗамеров,
		|	Выборка.N_T,
		|	Выборка.N_T_4T,
		|	Выборка.N_4T,
		|	ВЫРАЗИТЬ((Выборка.N_T + Выборка.N_T_4T/2)/Выборка.КоличествоЗамеров КАК ЧИСЛО(15,3)) КАК APDEX,
		|	ВЫРАЗИТЬ((Выборка.N_4T + Выборка.N_T_4T/2)/ВсегоЗамеров.КоличествоЗамеров КАК ЧИСЛО(15,3)) КАК APDEXВлияние
		|ПОМЕСТИТЬ
		|	ВыборкаХудшиеОперации
		|ИЗ
		|	Выборка
		|ЛЕВОЕ СОЕДИНЕНИЕ
		|	ВсегоЗамеров
		|ПО
		|	НЕ ВсегоЗамеров.КоличествоЗамеров IS NULL
		|УПОРЯДОЧИТЬ ПО
		|	(Выборка.N_4T + Выборка.N_T_4T/2)/ВсегоЗамеров.КоличествоЗамеров УБЫВ
		|;
		|";
		Запрос.УстановитьПараметр("ДатаНачала", (ДатаНачала - Дата(1,1,1)) * 1000);
		Запрос.УстановитьПараметр("ДатаОкончания", (ДатаОкончания - Дата(1,1,1)) * 1000);
		Запрос.УстановитьПараметр("ПериодАгрегации", ПериодАгрегации);
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "%Количество", Формат(Количество, "ЧН=0; ЧГ="));
		Запрос.Выполнить();
		
		РассчитатьСтатистикуОпераций(Запрос, ДатаНачала, ДатаОкончания, ПериодАгрегации);

		Запрос.Текст = "
		|ВЫБРАТЬ
		|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200) КАК Период,
		|	СпрКлючевыеОперации.Наименование КАК КлючеваяОперация,
		|	КлючевыеОперации.ЦелевоеВремя КАК ЦелевоеВремя,
		|	СУММА(ВЫБОР
		|			КОГДА Замеры.ВремяВыполнения <= КлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|			ИНАЧЕ 0
		|	КОНЕЦ) КАК N_T,
		|	СУММА(ВЫБОР
		|			КОГДА Замеры.ВремяВыполнения > КлючевыеОперации.ЦелевоеВремя И Замеры.ВремяВыполнения <= 4 * КлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|			ИНАЧЕ 0
		|	КОНЕЦ) КАК N_T_4T,
		|	СУММА(ВЫБОР
		|			КОГДА Замеры.ВремяВыполнения > 4 * КлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|			ИНАЧЕ 0
		|	КОНЕЦ) КАК N_4T,
		|	//%Интервалы
		|	ТаблицаСтатистики.Максимум КАК ВремяВыполненияМаксимум,
		|	ТаблицаСтатистики.Медиана КАК ВремяВыполненияМедиана,
		|	ТаблицаСтатистики.Минимум КАК ВремяВыполненияМинимум,
		|	ТаблицаСтатистики.Среднее КАК ВремяВыполненияСреднее,
		|	ТаблицаСтатистики.СтандартноеОтклонение КАК ВремяВыполненияСтандартноеОтклонение,
		|	ТаблицаСтатистики.КоличествоОпераций КАК КоличествоОпераций,
		|	ТаблицаСтатистики.Максимум90 КАК ВремяВыполненияМаксимум90,
		|	ТаблицаСтатистики.Медиана90 КАК ВремяВыполненияМедиана90,
		|	ТаблицаСтатистики.Минимум90 КАК ВремяВыполненияМинимум90,
		|	ТаблицаСтатистики.Среднее90 КАК ВремяВыполненияСреднее90,
		|	ТаблицаСтатистики.СтандартноеОтклонение90 КАК ВремяВыполненияСтандартноеОтклонение90,
		|	ТаблицаСтатистики.КоличествоОпераций90 КАК КоличествоОпераций90
		|ИЗ
		|	РегистрСведений.ЗамерыВремениТехнологические КАК Замеры
		|ВНУТРЕННЕЕ СОЕДИНЕНИЕ
		|	ВыборкаХудшиеОперации КАК КлючевыеОперации
		|ПО
		|	Замеры.КлючеваяОперация = КлючевыеОперации.КлючеваяОперацияСсылка
		|ВНУТРЕННЕЕ СОЕДИНЕНИЕ
		|	Справочник.КлючевыеОперации КАК СпрКлючевыеОперации
		|ПО
		|	Замеры.КлючеваяОперация = СпрКлючевыеОперации.Ссылка
		|ЛЕВОЕ СОЕДИНЕНИЕ
		|	ТаблицаСтатистики КАК ТаблицаСтатистики
		|ПО
		|	ТаблицаСтатистики.КлючеваяОперация = Замеры.КлючеваяОперация
		|	И ТаблицаСтатистики.Период = ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200)
		|ГДЕ
		|	Замеры.ДатаНачалаЗамера МЕЖДУ &ДатаНачала И &ДатаОкончания
		|СГРУППИРОВАТЬ ПО
		|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200),
		|	СпрКлючевыеОперации.Наименование,
		|	КлючевыеОперации.ЦелевоеВремя,
		|	ТаблицаСтатистики.Максимум,
		|	ТаблицаСтатистики.Медиана,
		|	ТаблицаСтатистики.Минимум,
		|	ТаблицаСтатистики.Среднее,
		|	ТаблицаСтатистики.СтандартноеОтклонение,
		|	ТаблицаСтатистики.КоличествоОпераций,
		|	ТаблицаСтатистики.Максимум90,
		|	ТаблицаСтатистики.Медиана90,
		|	ТаблицаСтатистики.Минимум90,
		|	ТаблицаСтатистики.Среднее90,
		|	ТаблицаСтатистики.СтандартноеОтклонение90,
		|	ТаблицаСтатистики.КоличествоОпераций90
		|УПОРЯДОЧИТЬ ПО
		|   ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200)
		|;";
		
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "//%Интервалы", ТекстЗапросаПоИнтервалам); 
		Запрос.УстановитьПараметр("ДатаНачала", (ДатаНачала - Дата(1,1,1)) * 1000);
		Запрос.УстановитьПараметр("ДатаОкончания", (ДатаОкончания - Дата(1,1,1)) * 1000);
		Запрос.УстановитьПараметр("ПериодАгрегации", ПериодАгрегации);
	Иначе
		МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
		Запрос = Новый Запрос;
		Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
		
		Запрос.Текст = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Замеры.КлючеваяОперация КАК КлючеваяОперацияСсылка
		|ПОМЕСТИТЬ
		|	ВыборкаХудшиеОперации
		|ИЗ
		|	РегистрСведений.ЗамерыВремениТехнологические КАК Замеры
		|ГДЕ
		|	Замеры.ДатаНачалаЗамера МЕЖДУ &ДатаНачала И &ДатаОкончания
		|";
		Запрос.УстановитьПараметр("ДатаНачала", (ДатаНачала - Дата(1,1,1)) * 1000);
		Запрос.УстановитьПараметр("ДатаОкончания", (ДатаОкончания - Дата(1,1,1)) * 1000);
		
		Запрос.Выполнить();
		
		РассчитатьСтатистикуОпераций(Запрос, ДатаНачала, ДатаОкончания, ПериодАгрегации);
		
		Запрос.Текст = "
		|ВЫБРАТЬ
		|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200) КАК Период,
		|	СпрКлючевыеОперации.Наименование КАК КлючеваяОперация,
		|	СпрКлючевыеОперации.ЦелевоеВремя КАК ЦелевоеВремя,
		|	СУММА(ВЫБОР
		|		КОГДА Замеры.ВремяВыполнения <= СпрКлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|		ИНАЧЕ 0
		|	КОНЕЦ) КАК N_T,
		|	СУММА(ВЫБОР
		|		КОГДА Замеры.ВремяВыполнения > СпрКлючевыеОперации.ЦелевоеВремя И Замеры.ВремяВыполнения <= 4 * СпрКлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|		ИНАЧЕ 0
		|	КОНЕЦ) КАК N_T_4T,
		|	СУММА(ВЫБОР
		|		КОГДА Замеры.ВремяВыполнения > 4 * СпрКлючевыеОперации.ЦелевоеВремя ТОГДА 1
		|		ИНАЧЕ 0
		|	КОНЕЦ) КАК N_4T,
		|	//%Интервалы
		|	ТаблицаСтатистики.Максимум КАК ВремяВыполненияМаксимум,
		|	ТаблицаСтатистики.Медиана КАК ВремяВыполненияМедиана,
		|	ТаблицаСтатистики.Минимум КАК ВремяВыполненияМинимум,
		|	ТаблицаСтатистики.Среднее КАК ВремяВыполненияСреднее,
		|	ТаблицаСтатистики.СтандартноеОтклонение КАК ВремяВыполненияСтандартноеОтклонение,
		|	ТаблицаСтатистики.КоличествоОпераций КАК КоличествоОпераций,
		|	ТаблицаСтатистики.Максимум90 КАК ВремяВыполненияМаксимум90,
		|	ТаблицаСтатистики.Медиана90 КАК ВремяВыполненияМедиана90,
		|	ТаблицаСтатистики.Минимум90 КАК ВремяВыполненияМинимум90,
		|	ТаблицаСтатистики.Среднее90 КАК ВремяВыполненияСреднее90,
		|	ТаблицаСтатистики.СтандартноеОтклонение90 КАК ВремяВыполненияСтандартноеОтклонение90,
		|	ТаблицаСтатистики.КоличествоОпераций90 КАК КоличествоОпераций90
		|ИЗ
		|	РегистрСведений.ЗамерыВремениТехнологические КАК Замеры
		|ВНУТРЕННЕЕ СОЕДИНЕНИЕ
		|	Справочник.КлючевыеОперации КАК СпрКлючевыеОперации
		|ПО
		|	Замеры.КлючеваяОперация = СпрКлючевыеОперации.Ссылка
		|ЛЕВОЕ СОЕДИНЕНИЕ
		|	ТаблицаСтатистики КАК ТаблицаСтатистики
		|ПО
		|	ТаблицаСтатистики.КлючеваяОперация = Замеры.КлючеваяОперация
		|	И ТаблицаСтатистики.Период = ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200)
		|ГДЕ
		|	Замеры.ДатаНачалаЗамера МЕЖДУ &ДатаНачала И &ДатаОкончания
		|СГРУППИРОВАТЬ ПО
		|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200),
		|	СпрКлючевыеОперации.Наименование,
		|	СпрКлючевыеОперации.ЦелевоеВремя,
		|	ТаблицаСтатистики.Максимум,
		|	ТаблицаСтатистики.Медиана,
		|	ТаблицаСтатистики.Минимум,
		|	ТаблицаСтатистики.Среднее,
		|	ТаблицаСтатистики.СтандартноеОтклонение,
		|	ТаблицаСтатистики.КоличествоОпераций,
		|	ТаблицаСтатистики.Максимум90,
		|	ТаблицаСтатистики.Медиана90,
		|	ТаблицаСтатистики.Минимум90,
		|	ТаблицаСтатистики.Среднее90,
		|	ТаблицаСтатистики.СтандартноеОтклонение90,
		|	ТаблицаСтатистики.КоличествоОпераций90
		|УПОРЯДОЧИТЬ ПО
		|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((Замеры.ДатаНачалаЗамера/1000)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200)
		|;";
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "//%Интервалы", ТекстЗапросаПоИнтервалам); 
		Запрос.УстановитьПараметр("ДатаНачала", (ДатаНачала - Дата(1,1,1)) * 1000);
		Запрос.УстановитьПараметр("ДатаОкончания", (ДатаОкончания - Дата(1,1,1)) * 1000);
		Запрос.УстановитьПараметр("ПериодАгрегации", ПериодАгрегации);
	КонецЕсли;
		
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса;
КонецФункции

Процедура РассчитатьСтатистикуОпераций(Запрос, ДатаНачала, ДатаОкончания, ПериодАгрегации)
	
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	КлючеваяОперацияСсылка
	|ИЗ
	|	ВыборкаХудшиеОперации КАК КлючевыеОперации
	|";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ЗапросСтатистики = Новый Запрос;
	ЗапросСтатистики.Текст = "
	|ВЫБРАТЬ
	|	ВремяВыполнения
	|ИЗ
	|	РегистрСведений.ЗамерыВремени КАК Замеры
	|ГДЕ
	|	Замеры.КлючеваяОперация = &КлючеваяОперация
	|	И Замеры.ДатаНачалаЗамера >= &ДатаНачала
	|	И Замеры.ДатаНачалаЗамера < &ДатаОкончания
	|УПОРЯДОЧИТЬ ПО
	|	ВремяВыполнения
	|";
	
	ТаблицаСтатистики = ТаблицаСтатистикиИнициализировать();
		
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		ДатаНачалаЦикла = ДатаНачала;
		Пока ДатаНачалаЦикла < ДатаОкончания Цикл
			ЗапросСтатистики.УстановитьПараметр("КлючеваяОперация", Выборка.КлючеваяОперацияСсылка);
			ЗапросСтатистики.УстановитьПараметр("ДатаНачала", (ДатаНачалаЦикла - Дата(1,1,1)) * 1000);
			ЗапросСтатистики.УстановитьПараметр("ДатаОкончания", (ДатаНачалаЦикла - Дата(1,1,1)) * 1000 + ПериодАгрегации);
			
			РезультатЗапросаСтатистики = ЗапросСтатистики.Выполнить();
			ТаблицаСтатистикиПолная = РезультатЗапросаСтатистики.Выгрузить();
			РезультатЗапросаСтатистики = Неопределено;
			
			РезультатАнализа = ПровестиАнализДанных(ТаблицаСтатистикиПолная);
			КоличествоУдалить = Цел(ТаблицаСтатистикиПолная.Количество() * 0.05/2);
			
			Для ТекКоличествоУдалить = 1 По КоличествоУдалить Цикл
				ТаблицаСтатистикиПолная.Удалить(0);
				ТаблицаСтатистикиПолная.Удалить(ТаблицаСтатистикиПолная.Количество() - 1);
			КонецЦикла;
			РезультатАнализа90 = ПровестиАнализДанных(ТаблицаСтатистикиПолная);
						
			НоваяСтрока = ТаблицаСтатистики.Добавить();
			НоваяСтрока.Период = ДатаНачалаЦикла;
			НоваяСтрока.КлючеваяОперация = Выборка.КлючеваяОперацияСсылка;
			
			НоваяСтрока.КоличествоОпераций = РезультатАнализа.КоличествоОпераций;
			НоваяСтрока.Максимум = РезультатАнализа.Максимум;
			НоваяСтрока.Медиана = РезультатАнализа.Медиана;
			НоваяСтрока.Минимум = РезультатАнализа.Минимум;
			НоваяСтрока.Среднее = РезультатАнализа.Среднее;
			НоваяСтрока.СтандартноеОтклонение = РезультатАнализа.СтандартноеОтклонение;
			
			НоваяСтрока.КоличествоОпераций90 = РезультатАнализа90.КоличествоОпераций;
			НоваяСтрока.Максимум90 = РезультатАнализа90.Максимум;
			НоваяСтрока.Медиана90 = РезультатАнализа90.Медиана;
			НоваяСтрока.Минимум90 = РезультатАнализа90.Минимум;
			НоваяСтрока.Среднее90 = РезультатАнализа90.Среднее;
			НоваяСтрока.СтандартноеОтклонение90 = РезультатАнализа90.СтандартноеОтклонение;
			
			ДатаНачалаЦикла = ДатаНачалаЦикла + ПериодАгрегации;			
			
		КонецЦикла;
	КонецЦикла;
	
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	*
	|ПОМЕСТИТЬ
	|	ТаблицаСтатистики
	|ИЗ
	|	&ТаблицаСтатистики КАК ТаблицаСтатистики
	|";
	
	Запрос.УстановитьПараметр("ТаблицаСтатистики", ТаблицаСтатистики);
	Запрос.Выполнить();
	
КонецПроцедуры

Функция ПровестиАнализДанных(Данные)
	
	АнализДанных = Новый АнализДанных;
	АнализДанных.ТипАнализа = Тип("АнализДанныхОбщаяСтатистика");
	АнализДанных.ИсточникДанных = Данные;
		
	РезультатАнализа = АнализДанных.Выполнить();
	
	Результат = Новый Структура("КоличествоОпераций, Максимум, Медиана, Минимум, Среднее, СтандартноеОтклонение");
	Если РезультатАнализа.НепрерывныеПоля.Количество() = 1 Тогда
		ДанныеПоКлючевойОперации = РезультатАнализа.НепрерывныеПоля[0];
		Результат.КоличествоОпераций = ДанныеПоКлючевойОперации.Количество;
		Результат.Максимум = ДанныеПоКлючевойОперации.Максимум;
		Результат.Медиана = ДанныеПоКлючевойОперации.Медиана;
		Результат.Минимум = ДанныеПоКлючевойОперации.Минимум;
		Результат.Среднее = ДанныеПоКлючевойОперации.Среднее;
		Результат.СтандартноеОтклонение = ДанныеПоКлючевойОперации.СтандартноеОтклонение;
	Иначе
		Результат.КоличествоОпераций = 0;
		Результат.Максимум = 0;
		Результат.Медиана = 0;
		Результат.Минимум = 0;
		Результат.Среднее = 0;
		Результат.СтандартноеОтклонение = 0;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ТаблицаСтатистикиИнициализировать()
	
	ТаблицаСтатистики = Новый ТаблицаЗначений;
	ТаблицаСтатистики.Колонки.Добавить("Период", Новый ОписаниеТипов("Дата",,Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя)));
	ТаблицаСтатистики.Колонки.Добавить("КлючеваяОперация", Новый ОписаниеТипов("СправочникСсылка.КлючевыеОперации"));
	
	ТаблицаСтатистики.Колонки.Добавить("КоличествоОпераций", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Максимум", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Медиана", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Минимум", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Среднее", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("СтандартноеОтклонение", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	
	ТаблицаСтатистики.Колонки.Добавить("КоличествоОпераций90", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Максимум90", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Медиана90", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Минимум90", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("Среднее90", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));
	ТаблицаСтатистики.Колонки.Добавить("СтандартноеОтклонение90", Новый ОписаниеТипов("Число",,Новый КвалификаторыЧисла(15,3)));

	
	Возврат ТаблицаСтатистики;
	
КонецФункции

// Возвращает таблицу настроек интервалов по умолчанию
//
// Возвращаемое значение:
//   НастроечнаяТаблицаИнтервалов - таблица значений, содержащая настройки интервалов по умолчанию.
//									Колонки: НижняяГраница, ВерхняяГраница, Шаг.
//
Функция НастроечнаяТаблицаИнтервалов()
	
	НастроечнаяТаблицаИнтервалов = Новый ТаблицаЗначений;
	НастроечнаяТаблицаИнтервалов.Колонки.Добавить("НижняяГраница", Новый ОписаниеТипов("Число",,, Новый КвалификаторыЧисла(10, 3, ДопустимыйЗнак.Неотрицательный)));
	НастроечнаяТаблицаИнтервалов.Колонки.Добавить("ВерхняяГраница", Новый ОписаниеТипов("Число",,, Новый КвалификаторыЧисла(10, 3, ДопустимыйЗнак.Неотрицательный)));
	НастроечнаяТаблицаИнтервалов.Колонки.Добавить("Шаг", Новый ОписаниеТипов("Число",,, Новый КвалификаторыЧисла(10, 3, ДопустимыйЗнак.Неотрицательный)));
	
	// Если шаг и нижняя граница равны нулю, то это бесконечный интервал, не ограниченный снизу: x <= ВерхняяГраница.
	// Если же шаг и верхняя граница равны нулю, то это бесконечный интервал, не ограниченный сверху: x > ВерхняяГраница.
	
	// Менее 0,5с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 0;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 0.5;
	НоваяСтрокаНастроек.Шаг				 = 0;
	
	// От 0,5с до 5с с шагом 0,25 с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 0.5;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 5;
	НоваяСтрокаНастроек.Шаг				 = 0.25;
	
	// От 5с до 7с с шагом 0,5 с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 5;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 7;
	НоваяСтрокаНастроек.Шаг				 = 0.5;
	
	// От 7 до 12 с шагом 1с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 7;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 12;
	НоваяСтрокаНастроек.Шаг				 = 1;
	
	// От 12 до 20 с шагом 2с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 12;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 20;
	НоваяСтрокаНастроек.Шаг				 = 2;
	
	// От 20 до 30 с шагом 5с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 20;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 30;
	НоваяСтрокаНастроек.Шаг				 = 5;
	
	// От 30 до 80 с шагом 10с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 30;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 80;
	НоваяСтрокаНастроек.Шаг				 = 10;
	
	// От 80 до 120 с шагом 20с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 80;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 120;
	НоваяСтрокаНастроек.Шаг				 = 20;
	
	// От 120 до 300 с шагом 30с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 120;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 300;
	НоваяСтрокаНастроек.Шаг				 = 30;
	
	// От 300 до 600 с шагом 60с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 300;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 600;
	НоваяСтрокаНастроек.Шаг				 = 60;
	
	// От 600 до 1800 с шагом 300с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 600;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 1800;
	НоваяСтрокаНастроек.Шаг				 = 300;
	
	// От 1800 до 3600 с шагом 600с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 1800;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 3600;
	НоваяСтрокаНастроек.Шаг				 = 600;
	
	// От 3600 до 7200 с шагом 1800с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 3600;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 7200;
	НоваяСтрокаНастроек.Шаг				 = 1800;
	
	// От 7200 до 42300 с шагом 3600с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 7200;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 43200;
	НоваяСтрокаНастроек.Шаг				 = 3600;
	
	// Более 42300с
	НоваяСтрокаНастроек = НастроечнаяТаблицаИнтервалов.Добавить();
	НоваяСтрокаНастроек.НижняяГраница	 = 43200;
	НоваяСтрокаНастроек.ВерхняяГраница	 = 0;
	НоваяСтрокаНастроек.Шаг				 = 0;
	
	Возврат НастроечнаяТаблицаИнтервалов;
	
КонецФункции // НастроечнаяТаблицаИнтерваловПоУмолчанию()

// Формирует и возвращает таблицу интервалов из таблицы настроек интервалов
//
// Параметры:
//  ТаблицаНастроек  - ТаблицаЗначений - содержит настройки интервалов.
//                 Должна содержать колонки НижняяГраница, ВерхняяГраница, Шаг типа Число. 
//
// Возвращаемое значение:
//   ТаблицаИнтервалов   - Таблица, содержащая нижнее и верхнее граничные значения для каждого из интервалов.
//						   Колонки: НижняяГраница, ВерхняяГраница.
//
Функция ТаблицаИнтерваловПоНастройкам(ТаблицаНастроек)
	
	ТаблицаИнтервалов = Новый ТаблицаЗначений;
	ТаблицаИнтервалов.Колонки.Добавить("НижняяГраница", Новый ОписаниеТипов("Число",,, Новый КвалификаторыЧисла(10, 3, ДопустимыйЗнак.Неотрицательный)));
	ТаблицаИнтервалов.Колонки.Добавить("ВерхняяГраница", Новый ОписаниеТипов("Число",,, Новый КвалификаторыЧисла(10, 3, ДопустимыйЗнак.Неотрицательный)));
	
	// Ограничивает количество интервалов. Если интервалов будет больше указанного значения,
	// то в таблицу интервалов они уже не попадут
	// ограничение вызвано тем, что по интервалам будут динамически формироваться колонки,
	// следовательно, бесконтрольный рост недопустим.
	МаксимальноеКоличествоИнтервалов = 80;
	ВсегоИнтервалов = 0;
		
	Для каждого СтрокаНастроек Из ТаблицаНастроек Цикл
		
		// Проверка интервалов на корректность.
		// Если шаг не равен нулю, то нижняя граница должна быть больше верхней.
		Если СтрокаНастроек.НижняяГраница >= СтрокаНастроек.ВерхняяГраница И СтрокаНастроек.Шаг <> 0
			ИЛИ СтрокаНастроек.НижняяГраница = СтрокаНастроек.ВерхняяГраница Тогда
			Продолжить;		
		КонецЕсли; 
	
		Если СтрокаНастроек.НижняяГраница = 0 И СтрокаНастроек.Шаг = 0 Тогда
			НоваяСтрокаИнтервала = ТаблицаИнтервалов.Добавить();	
			НоваяСтрокаИнтервала.НижняяГраница	 = 0;
			НоваяСтрокаИнтервала.ВерхняяГраница	 = СтрокаНастроек.ВерхняяГраница;			
			ВсегоИнтервалов = ВсегоИнтервалов + 1;
		ИначеЕсли СтрокаНастроек.ВерхняяГраница = 0 И СтрокаНастроек.Шаг = 0 Тогда
			НоваяСтрокаИнтервала = ТаблицаИнтервалов.Добавить();	
			НоваяСтрокаИнтервала.НижняяГраница	 = СтрокаНастроек.НижняяГраница;
			НоваяСтрокаИнтервала.ВерхняяГраница	 = 0;                           			
			ВсегоИнтервалов = ВсегоИнтервалов + 1;
		Иначе
			ТекущееЗначение = СтрокаНастроек.НижняяГраница;
			Пока ТекущееЗначение < СтрокаНастроек.ВерхняяГраница Цикл
				// проверка превышения лимита колонок.
				Если ВсегоИнтервалов >= МаксимальноеКоличествоИнтервалов Тогда
					Прервать;
				КонецЕсли;
				ВерхнееЗначение = ТекущееЗначение + СтрокаНастроек.Шаг;
				Если ВерхнееЗначение > СтрокаНастроек.ВерхняяГраница Тогда
					// Некорректные настройки интервалов. Верхняя граница текущего интервала выходит за верхнюю границу настроек.
					Прервать;
				КонецЕсли; 								
				НоваяСтрокаИнтервала = ТаблицаИнтервалов.Добавить();	
				НоваяСтрокаИнтервала.НижняяГраница	 = ТекущееЗначение;				
				НоваяСтрокаИнтервала.ВерхняяГраница	 = ВерхнееЗначение;	
				ТекущееЗначение = ВерхнееЗначение;
				ВсегоИнтервалов = ВсегоИнтервалов + 1;
				
			КонецЦикла; 		
		КонецЕсли; 
	
	КонецЦикла; 
	
	Возврат ТаблицаИнтервалов;
	
КонецФункции // ТаблицаИнтерваловПоНастройкам()

// Формирует и возвращает часть текстам запроса по таблице интервалов
//
// Параметры:
//  ТаблицаИнтервалов  - ТаблицаЗначений - содержит перечень интервалов.
//                 Должна содержать колонки НижняяГраница, ВерхняяГраница.
//
// Возвращаемое значение:
//   ТекстЗапроса   - часть текста запроса, соответствующая переданной таблице интервалов.
//
Функция ЧастьТекстаЗапросаПоИнтервалам(ТаблицаИнтервалов, ИмяТаблицыИсточника, ИмяКолонкиИсточника)
	
	ТекстЗапроса = "";	
	ШаблонСтроки = "	СУММА(ВЫБОР
					|			КОГДА %1 %2 ТОГДА 1
					|			ИНАЧЕ 0
					|	КОНЕЦ) КАК N_%3,";
	
	Для Каждого СтрокаИнтервала Из ТаблицаИнтервалов Цикл
		
		Если СтрокаИнтервала.НижняяГраница = 0 Тогда
			ТекстНижнейГраницы = "";
			ТекстВерхнейГраницы = ИмяТаблицыИсточника + "." + ИмяКолонкиИсточника + " <= " + Формат(СтрокаИнтервала.ВерхняяГраница,"ЧРД=.; ЧН=0; ЧГ=");
			ИмяКолонкиВЗапросе = Формат(СтрокаИнтервала.ВерхняяГраница,"ЧРД=_; ЧН=0; ЧГ=")
		ИначеЕсли СтрокаИнтервала.ВерхняяГраница = 0 Тогда
			ТекстНижнейГраницы = ИмяТаблицыИсточника + "." + ИмяКолонкиИсточника + " > " + Формат(СтрокаИнтервала.НижняяГраница,"ЧРД=.; ЧН=0; ЧГ=");
			ТекстВерхнейГраницы = "";
			ИмяКолонкиВЗапросе = "MORE_" + Формат(СтрокаИнтервала.НижняяГраница,"ЧРД=_; ЧН=0; ЧГ=")
		Иначе
			ТекстНижнейГраницы = ИмяТаблицыИсточника + "." + ИмяКолонкиИсточника + " > " + Формат(СтрокаИнтервала.НижняяГраница,"ЧРД=.; ЧН=0; ЧГ=") + " И ";
			ТекстВерхнейГраницы = ИмяТаблицыИсточника + "." + ИмяКолонкиИсточника + " <= " + Формат(СтрокаИнтервала.ВерхняяГраница,"ЧРД=.; ЧН=0; ЧГ=");
			ИмяКолонкиВЗапросе = Формат(СтрокаИнтервала.ВерхняяГраница,"ЧРД=_; ЧН=0; ЧГ=")	
		КонецЕсли;
		
		ТекстЗапросаДляИнтервала = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСтроки, ТекстНижнейГраницы, ТекстВерхнейГраницы, ИмяКолонкиВЗапросе); 		
		ТекстЗапроса = ТекстЗапроса + ?(ПустаяСтрока(ТекстЗапроса),"",Символы.ПС) + ТекстЗапросаДляИнтервала;
		
	КонецЦикла;
	
	Возврат ТекстЗапроса;
	
КонецФункции

#КонецОбласти

#КонецЕсли